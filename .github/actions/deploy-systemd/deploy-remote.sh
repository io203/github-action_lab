#!/usr/bin/env bash
# =============================================================================
# 대상 VM에서 실행되는 배포 스크립트 (runner가 `ssh ... bash -s < 이 파일` 로 전달)
#
#  1. 사전 점검   : sudo(비밀번호 없이), java 실행 파일, 업로드된 jar
#  2. systemd 유닛 : /etc/systemd/system/<APP_NAME>.service 생성·갱신 (내용이 바뀐 경우만)
#  3. jar 교체     : app.jar.new → app.jar (이전 버전은 app.jar.prev 로 보관)
#  4. 재시작       : systemctl restart (최초 전환 시 기존 nohup 프로세스 정리)
#  5. 헬스체크     : actuator/health 가 UP 될 때까지 대기, 실패 시 journal 로그 출력
#
# 필요한 환경변수: APP_NAME REMOTE_DIR JAVA_PATH SPRING_PROFILE APP_PORT HEALTH_TIMEOUT
# =============================================================================
set -euo pipefail

: "${APP_NAME:?}" "${REMOTE_DIR:?}" "${JAVA_PATH:?}" "${SPRING_PROFILE:?}"
APP_PORT="${APP_PORT:-8080}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-90}"

SERVICE="${APP_NAME}.service"
UNIT_PATH="/etc/systemd/system/${SERVICE}"
RUN_USER="$(id -un)"
HEALTH_URL="http://localhost:${APP_PORT}/actuator/health"

log()  { echo "[deploy] $*"; }
fail() { echo "::error::$*"; exit 1; }

show_logs() {
  echo "----- journalctl -u ${SERVICE} (최근 50줄) -----"
  sudo journalctl -u "${SERVICE}" -n 50 --no-pager || true
}

# ---------------------------------------------------------------------------
# 1. 사전 점검
# ---------------------------------------------------------------------------
sudo -n true 2>/dev/null \
  || fail "${RUN_USER} 계정에 비밀번호 없는 sudo 권한이 필요합니다 (systemctl 실행용). /etc/sudoers.d 에 NOPASSWD 설정을 추가하세요."
[ -x "${JAVA_PATH}" ] || fail "java 실행 파일이 없습니다: ${JAVA_PATH}"
[ -f "${REMOTE_DIR}/app.jar.new" ] || fail "업로드된 jar 가 없습니다: ${REMOTE_DIR}/app.jar.new"
log "java: $("${JAVA_PATH}" -version 2>&1 | head -1)"

# ---------------------------------------------------------------------------
# 2. 실행 환경 파일 + systemd 유닛 (내용이 달라졌을 때만 교체)
# ---------------------------------------------------------------------------
cat > "${REMOTE_DIR}/app.env" <<ENV
# ${SERVICE} 실행 환경 (배포 시 자동 생성 — 직접 수정하면 다음 배포 때 덮어씀)
SPRING_PROFILES_ACTIVE=${SPRING_PROFILE}
JAVA_OPTS=
ENV

UNIT_TMP="$(mktemp)"
trap 'rm -f "${UNIT_TMP}"' EXIT
cat > "${UNIT_TMP}" <<UNIT
# 배포 워크플로가 자동 생성 — 직접 수정하면 다음 배포 때 덮어씀
[Unit]
Description=${APP_NAME} (Spring Boot)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${RUN_USER}
WorkingDirectory=${REMOTE_DIR}
EnvironmentFile=${REMOTE_DIR}/app.env
ExecStart=${JAVA_PATH} \$JAVA_OPTS -jar ${REMOTE_DIR}/app.jar
# SIGTERM 으로 종료 시 JVM 종료코드 143 을 정상으로 간주
SuccessExitStatus=143
TimeoutStopSec=40
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${APP_NAME}

[Install]
WantedBy=multi-user.target
UNIT

if ! sudo cmp -s "${UNIT_TMP}" "${UNIT_PATH}" 2>/dev/null; then
  log "systemd 유닛 설치/갱신: ${UNIT_PATH}"
  sudo install -m 644 "${UNIT_TMP}" "${UNIT_PATH}"
  sudo systemctl daemon-reload
fi
sudo systemctl enable "${SERVICE}" >/dev/null 2>&1 || true   # 부팅 시 자동 기동

# ---------------------------------------------------------------------------
# 3. jar 교체 (같은 파일을 덮어쓰지 않고 rename → 실행 중인 JVM 이 깨지지 않음)
# ---------------------------------------------------------------------------
[ -f "${REMOTE_DIR}/app.jar" ] && mv -f "${REMOTE_DIR}/app.jar" "${REMOTE_DIR}/app.jar.prev"
mv -f "${REMOTE_DIR}/app.jar.new" "${REMOTE_DIR}/app.jar"

# ---------------------------------------------------------------------------
# 4. 재시작
#    nohup 방식 → systemd 로 처음 전환하는 경우, 서비스 밖에서 떠 있는 기존 프로세스가
#    포트를 잡고 있으므로 정리한다.
# ---------------------------------------------------------------------------
if ! systemctl is-active --quiet "${SERVICE}" && sudo fuser "${APP_PORT}/tcp" >/dev/null 2>&1; then
  log "서비스 밖에서 ${APP_PORT} 포트를 쓰는 기존 프로세스 종료 (nohup → systemd 전환)"
  sudo fuser -k -TERM "${APP_PORT}/tcp" || true
  for _ in $(seq 1 15); do sudo fuser "${APP_PORT}/tcp" >/dev/null 2>&1 || break; sleep 1; done
fi

log "systemctl restart ${SERVICE}"
sudo systemctl restart "${SERVICE}"
restarts_before="$(systemctl show -p NRestarts --value "${SERVICE}")"

# ---------------------------------------------------------------------------
# 5. 헬스체크
# ---------------------------------------------------------------------------
deadline=$(( $(date +%s) + HEALTH_TIMEOUT ))
while [ "$(date +%s)" -lt "${deadline}" ]; do
  if curl -sf "${HEALTH_URL}" | grep -q '"status":"UP"'; then
    log "App is UP! (${SERVICE}, profile=${SPRING_PROFILE})"
    exit 0
  fi
  # 기동 직후 죽어서 재시작 반복 중이면 기다리지 않고 바로 실패 처리
  if [ "$(systemctl show -p NRestarts --value "${SERVICE}")" -gt "${restarts_before}" ] \
     || systemctl is-failed --quiet "${SERVICE}"; then
    show_logs
    fail "${SERVICE} 기동 실패 (프로세스 종료됨)"
  fi
  log "기동 대기 중..."
  sleep 5
done

show_logs
fail "헬스체크 시간 초과 (${HEALTH_TIMEOUT}초): ${HEALTH_URL}"

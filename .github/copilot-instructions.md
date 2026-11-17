# 저장소 지침 (GitHub Copilot)

이 저장소는 Spring Boot 4 / Java 25 / Maven 기반의 간단한 REST API(`simple-api`)와,
GitHub Actions 로 VM 에 systemd 서비스로 배포하는 CI/CD 실습 저장소다.

## 코드 리뷰 형식 — Conventional Comments

- 리뷰 코멘트는 **한국어**로 작성한다.
- 모든 코멘트는 `<label> [decorations]: <subject>` 형식으로 시작한다. (https://conventionalcomments.org)
- label 은 다음 중 하나만 쓴다.
  - `issue` — 버그·보안·요구사항 누락 등 실제 문제. 반드시 근거와 대안을 함께 쓴다.
  - `suggestion` — 개선 제안. 왜 더 나은지 설명한다.
  - `question` — 의도를 확인하는 질문.
  - `nitpick` — 사소한 취향 차이. 항상 `(non-blocking)` 을 붙인다.
  - `todo` — 머지 전에 해야 하는 작은 작업.
  - `praise` — 잘한 점. 구체적으로 쓴다.
  - `thought`, `note` — 참고 의견·정보.
- decorations 로 머지 차단 여부를 밝힌다: `(blocking)`, `(non-blocking)`, `(if-minor)`.
  - 보안·데이터 손실·장애로 이어질 수 있는 문제만 `(blocking)` 으로 표시한다.
- 고칠 코드가 분명하면 GitHub suggestion 블록으로 수정안을 함께 제시한다.
- 들여쓰기·import 순서 같은 스타일은 Checkstyle(`config/checkstyle/checkstyle.xml`)이 검사하므로 지적하지 않는다.

예시:

```
issue (blocking, security): 요청 헤더 전체를 INFO 로그로 남기고 있습니다

Authorization 헤더의 토큰이 로그에 그대로 기록됩니다. 민감한 헤더는 제외하거나 마스킹해 주세요.
```

## 리뷰 우선순위

1. 정확성 — 요구사항대로 동작하는가, null·빈 값·경계값·예외 처리
2. 보안 — 입력 검증, 비밀 정보(토큰·비밀번호·개인정보)의 로그 출력, 주입 공격
3. 설계 — 기존 코드와의 중복, 변경의 영향 범위
4. 테스트 — 새 동작과 실패 케이스에 테스트가 있는가 (라인 커버리지 80% 미만이면 CI 실패)
5. 가독성 — 이름이 의도를 드러내는가

## 커밋·PR 규칙

- 커밋 메시지와 PR 제목은 Conventional Commits 형식이다: `<type>(<scope>): <subject>`
  - type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert / scope 는 소문자
  - 한국어로 쓰고, 제목은 50자 안팎, 마침표 없음
- 자세한 규칙: `docs/commit-convention.md`, 리뷰 규칙: `docs/code-review-guide.md`

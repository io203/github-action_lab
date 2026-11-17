#!/usr/bin/env bash
# 저장소를 clone 한 뒤 한 번 실행: 커밋 템플릿 + commit-msg hook 활성화 (이 저장소에만 적용)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

git config commit.template .gitmessage   # git commit 시 편집기에 템플릿 표시
git config core.hooksPath .githooks      # .githooks/commit-msg 로 메시지 검사
chmod +x .githooks/*

echo "✔ 커밋 템플릿: $(git config commit.template)"
echo "✔ hook 경로  : $(git config core.hooksPath)"

// commitlint 설정 — CI(.github/workflows/pr-convention.yaml)에서 PR 커밋 메시지·PR 제목 검사에 사용
// 규칙: https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional
// type 목록을 바꾸면 .githooks/commit-msg 와 .gitmessage 도 같이 맞출 것
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert',
    ]],
    // scope 는 소문자만 (예: api, deploy) — .githooks/commit-msg 와 동일
    'scope-case': [2, 'always', 'lower-case'],
    // 한글 제목은 대소문자 규칙이 의미 없으므로 끔
    'subject-case': [0],
    // 본문·푸터 줄 길이는 경고 대신 끔 (URL·로그 붙여넣기 허용)
    'body-max-line-length': [0],
    'footer-max-line-length': [0],
  },
};

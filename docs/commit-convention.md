# 커밋 메시지 규칙 가이드 (Conventional Commits)

이 저장소는 커밋 메시지와 PR 제목을 **Conventional Commits** 형식으로 씁니다.
규칙을 어기면 ① 내 PC에서 커밋할 때 hook이 막고, ② PR을 올리면 CI가 한 번 더 막습니다.

```
<type>(<scope>): <subject>        ← 첫 줄(제목). 50자 안팎, 최대 100자, 마침표 없음
                                  ← 빈 줄
<body>                            ← "무엇을"보다 "왜"
                                  ← 빈 줄
<footer>                          ← BREAKING CHANGE: ..., Refs: #123
```

| type | 언제 | 예시 |
|---|---|---|
| `feat` | 새 기능 | `feat(api): 인사 메시지 조회 API 추가` |
| `fix` | 버그 수정 | `fix(deploy): 헬스체크 실패 시 로그 누락 수정` |
| `docs` | 문서만 변경 | `docs: 커밋 규칙 가이드 추가` |
| `style` | 동작 변화 없는 포매팅 | `style: 들여쓰기 정리` |
| `refactor` | 동작은 같고 구조만 개선 | `refactor(controller): 응답 생성 로직 분리` |
| `perf` | 성능 개선 | `perf(api): 목록 조회 캐시 적용` |
| `test` | 테스트 추가·수정 | `test(controller): 파라미터 누락 케이스 추가` |
| `build` | 빌드 설정 (`pom.xml` 등) | `build: jacoco 0.8.16으로 업그레이드` |
| `ci` | CI 설정 (`.github/`) | `ci: PR 제목 검사 추가` |
| `chore` | 그 밖의 잡무 | `chore: gitignore 정리` |
| `revert` | 이전 커밋 되돌림 | `revert: feat(api) 인사 메시지 조회 API 추가` |

- `scope`는 선택이며 **소문자**만 씁니다 (`api`, `deploy`, `workflow` …).
- 호환되지 않는 변경은 type 뒤에 `!`를 붙입니다: `feat(api)!: 응답 필드 이름 변경`
- `Merge …`, `Revert "…"`, `fixup! …`, `squash! …` 커밋은 검사하지 않습니다.

---

## 1. 처음 한 번: 템플릿·hook 켜기

clone한 뒤 저장소 최상위 폴더에서 **한 번만** 실행합니다.

```bash
./scripts/setup-git.sh
```

```
✔ 커밋 템플릿: .gitmessage
✔ hook 경로  : .githooks
```

이 스크립트는 **이 저장소에만** 아래 두 설정을 넣습니다(다른 저장소에는 영향 없음).

| 설정 | 값 | 효과 |
|---|---|---|
| `commit.template` | `.gitmessage` | `git commit` 할 때 편집기에 형식 안내가 미리 채워짐 |
| `core.hooksPath` | `.githooks` | 커밋할 때 `.githooks/commit-msg`가 메시지를 검사 |

**켜져 있는지 확인**

```bash
git config --local --get commit.template   # → .gitmessage
git config --local --get core.hooksPath    # → .githooks
```

**끄기**

```bash
git config --local --unset commit.template
git config --local --unset core.hooksPath
```

> 💡 **왜 clone만으로 자동으로 켜지지 않나요?** git은 보안상 clone한 저장소의 hook을 자동으로 실행하지 않습니다. 그래서 각자 한 번 스크립트를 실행해야 합니다.
> 이를 잊어도 PR 단계의 CI 검사가 같은 규칙으로 막아 주므로, 규칙을 어긴 커밋이 `develop`/`main`에 들어가지는 않습니다.

> ⚠️ `core.hooksPath`를 설정하면 `.git/hooks/` 폴더의 hook은 더 이상 실행되지 않습니다. 직접 만든 hook이 거기 있었다면 `.githooks/`로 옮기세요.

---

## 2. 터미널에서 템플릿 쓰기

**`-m` 없이** 커밋하면 편집기가 열리고 템플릿이 채워져 있습니다.

```bash
git add <파일>
git commit            # ← -m 을 붙이면 템플릿이 나오지 않음
```

```
                                   ← 1행: 여기에 제목 입력
# ─────────────────────────────────
# Conventional Commits 템플릿 ('#' 으로 시작하는 줄은 커밋에 포함되지 않음)
# <type>(<scope>): <subject>
# ...
```

1. 1행에 제목을 씁니다. 필요하면 한 줄 비우고 본문을 씁니다.
2. 저장하고 편집기를 닫으면 커밋됩니다. `#` 줄은 자동으로 빠집니다.
3. 아무것도 쓰지 않고 닫으면 커밋이 취소됩니다.

**편집기를 VSCode로 바꾸기** (기본은 vi)

```bash
git config --global core.editor "code --wait"   # 이 저장소에만: --global 대신 --local
```

짧은 커밋은 지금처럼 `-m`을 써도 됩니다. 이 경우에도 hook 검사는 동작합니다.

```bash
git commit -m "fix(api): testPara 빈 문자열 처리"
```

**규칙을 어기면**

```
✖ 커밋 메시지가 Conventional Commits 형식이 아닙니다: type/scope/콜론 형식 불일치 (scope 는 소문자)

  입력한 제목 : 커밋 규칙 추가
  형식        : <type>(<scope>): <subject>
  ...
  메시지는 .git/COMMIT_EDITMSG 에 남아 있습니다 → git commit -e -F .git/COMMIT_EDITMSG 로 다시 편집
```

커밋은 만들어지지 않고, 작성한 메시지는 남아 있으므로 마지막 줄 명령으로 고쳐서 다시 커밋합니다.

---

## 3. IDE에서 쓰기

### 3.1 VSCode

hook은 VSCode에서 커밋할 때도 그대로 실행됩니다. 1장의 설정만 해 두면 됩니다.

**템플릿 안내를 보면서 커밋하기**

1. 소스 제어 패널(⌃⇧G)에서 변경 파일을 stage합니다.
2. **메시지 입력창을 비워 둔 채** `Commit` 버튼을 누릅니다.
3. `COMMIT_EDITMSG` 탭이 열리고 템플릿 안내가 보입니다.
4. 1행에 제목을 쓰고 **저장 후 탭을 닫으면** 커밋됩니다. 커밋을 취소하려면 아무것도 쓰지 않고 닫습니다.

> 💡 패널의 **입력창에 바로 쓰는 경우**에는 템플릿 안내가 보이지 않습니다. VSCode가 템플릿의 `#` 주석 줄을 지우고 채우는데, 이 템플릿은 안내가 전부 주석이기 때문입니다. 형식을 외웠다면 입력창에 바로 써도 되고, hook 검사는 똑같이 동작합니다.

**규칙을 어기면** 오른쪽 아래에 git 오류 알림이 뜹니다. `Show Command Output`을 누르면 hook이 출력한 이유를 볼 수 있습니다.

**추천 설정** (⌘, → 오른쪽 위 `{}` 아이콘 → `settings.json`)

```jsonc
{
  // 입력창이 비어 있을 때 편집기 탭으로 커밋 (기본값 true — 꺼져 있다면 켜기)
  "git.useEditorAsCommitInput": true,
  // 입력창에서 제목 50자·본문 72자 초과 시 경고 표시 (기본값 false)
  "git.inputValidation": true,
  "git.inputValidationSubjectLength": 50,
  "git.inputValidationLength": 72,
  // hook 을 건너뛰는 커밋 메뉴 숨김 (기본값 false 유지 권장)
  "git.allowNoVerifyCommit": false
}
```

**Copilot으로 커밋 메시지 만들기 (선택)**

입력창의 ✨ 버튼(Generate Commit Message)으로 메시지를 만들 수 있습니다. 아래 설정을 넣으면 이 규칙대로 만들어 줍니다.

```jsonc
{
  "github.copilot.chat.commitMessageGeneration.instructions": [
    { "text": "Conventional Commits 형식(<type>(<scope>): <subject>)으로 한국어로 작성. type은 feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert 중 하나. scope는 소문자. 제목은 50자 안팎, 마침표 없음. 본문에는 변경 이유를 쓴다." }
  ]
}
```

> ⚠️ AI가 만든 메시지는 초안입니다. 특히 **"왜"(변경 이유)** 는 AI가 알 수 없으므로 직접 고쳐 씁니다.

### 3.2 IntelliJ IDEA

- **hook**: Commit 창(⌘K)의 ⚙️(Commit Options)에서 **Run Git hooks**가 체크돼 있으면 `commit-msg` hook이 실행됩니다(기본 체크). 규칙을 어기면 커밋이 실패하고 hook 출력이 표시됩니다.
- **길이 검사**: Settings → Version Control → Commit → **Commit message inspections**에서 제목 길이(50)·본문 줄 길이(72)·제목 아래 빈 줄 검사를 켭니다.
- **입력 도우미**: Marketplace의 *Conventional Commit* 플러그인을 설치하면 type·scope 자동 완성을 쓸 수 있습니다.

---

## 4. PR 단계 검사 (CI)

PR을 열거나, 커밋을 추가하거나, **PR 제목을 고칠 때마다** `PR Convention` 워크플로가 돌아갑니다 (`.github/workflows/pr-convention.yaml`, 규칙은 `commitlint.config.mjs`).

| 검사 | 대상 | 머지 차단 |
|---|---|---|
| `pr-title` | PR 제목 | ✅ 실패하면 머지 불가 |
| `commitlint` | PR에 포함된 각 커밋 메시지 | 팀 설정에 따름 |

**PR 제목이 가장 중요합니다.** `Squash and merge`로 머지하면 PR 제목이 그대로 `develop`/`main`의 커밋 메시지가 됩니다. 그래서 작업 중 커밋은 조금 자유로워도 PR 제목은 반드시 규칙을 지킵니다.

**검사가 실패하면**

| 실패한 검사 | 고치는 방법 |
|---|---|
| `pr-title` | PR 화면에서 제목 옆 `Edit` → 고치고 저장 → 자동 재검사 |
| `commitlint` (마지막 커밋) | `git commit --amend` → `git push --force-with-lease` |
| `commitlint` (여러 커밋) | `git rebase -i origin/develop` → 고칠 커밋을 `reword` → `git push --force-with-lease` |

> ⚠️ `--force-with-lease`는 **내 feature 브랜치에서만** 씁니다. `develop`, `main` 같은 공유 브랜치에는 강제 push를 하지 않습니다.

---

## 5. 자주 묻는 질문

**Q. 급해서 검사를 건너뛰고 커밋하고 싶어요.**
`git commit --no-verify`로 로컬 hook을 건너뛸 수 있습니다. 하지만 PR의 CI 검사는 건너뛸 수 없으므로, PR 전에는 메시지를 고쳐야 합니다.

**Q. type 목록을 바꾸고 싶어요.**
아래 세 파일을 함께 고칩니다. 하나만 고치면 로컬과 CI의 판정이 달라집니다.
- `commitlint.config.mjs` — CI 규칙 (`type-enum`)
- `.githooks/commit-msg` — 로컬 hook (`TYPES`)
- `.gitmessage` — 템플릿 안내

**Q. 로컬에서도 CI와 똑같이 commitlint로 검사해 보고 싶어요.** (Node 필요)

```bash
npm install --no-save @commitlint/cli@21.2.4 @commitlint/config-conventional@21.2.4
echo "feat(api): 테스트" | npx commitlint                   # 메시지 하나
npx commitlint --from origin/develop --to HEAD --verbose    # 내 브랜치의 커밋 전부
```

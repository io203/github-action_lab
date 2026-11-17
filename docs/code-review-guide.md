# 코드 리뷰 코멘트 가이드 (Conventional Comments)

리뷰 코멘트 맨 앞에 **라벨**을 붙여서, 읽는 사람이 "반드시 고쳐야 하는지, 참고만 하면 되는지"를 바로 알게 합니다.
규격: <https://conventionalcomments.org>

```
<label> [decorations]: <subject>

[discussion]
```

| 부분 | 설명 | 예 |
|---|---|---|
| `label` | 코멘트의 종류 (아래 표) | `issue`, `suggestion` |
| `decorations` | 선택. 괄호 안에 쉼표로 | `(blocking)`, `(non-blocking)`, `(if-minor)` |
| `subject` | 한 줄 요약 | `가격이 음수면 할인 결과도 음수가 됩니다` |
| `discussion` | 선택. 이유·근거·대안 | 재현 방법, 참고 링크, suggestion 블록 |

---

## 1. 라벨

| 라벨 | 의미 | 머지를 막나? | 예시 |
|---|---|---|---|
| `praise` | 칭찬. 잘한 점을 구체적으로 | ✘ | `praise: 경계값 테스트를 꼼꼼히 넣어 주셔서 리뷰가 편했습니다 👍` |
| `issue` | 실제 문제(버그·보안·요구사항 누락). **대안과 함께** | ✔ 기본 | `issue: desc 가 빈 문자열이면 그대로 200 이 반환됩니다` |
| `suggestion` | 개선 제안. 무엇을·왜 바꾸면 좋은지 | 데코레이션으로 표시 | `suggestion (non-blocking): 응답 생성 로직을 메서드로 분리하면 테스트가 쉬워집니다` |
| `question` | 이해가 안 되는 부분. 비난이 아닌 확인 | ✘ | `question: 여기서 IntStream 을 쓴 이유가 있을까요?` |
| `nitpick` (`nit`) | 사소한 취향 차이. **반영은 선택** | ✘ | `nitpick: d 보다 discountRate 가 의도를 더 잘 드러낼 것 같아요` |
| `todo` | 머지 전에 꼭 해야 하는 작은 일 | ✔ | `todo: application-prod.yml 의 actuator 노출 범위도 같이 줄여 주세요` |
| `thought` | 당장 반영할 필요 없는 아이디어 | ✘ | `thought: 나중에 버전 정보는 build-info 로 노출해도 좋겠네요` |
| `chore` | 머지 전 처리할 절차·잡무 | ✔ | `chore: CHANGELOG 갱신이 필요합니다` |
| `note` | 알아 두면 좋은 정보 | ✘ | `note: 이 API 는 모바일 앱에서도 호출합니다` |

## 2. 데코레이션

| 데코레이션 | 의미 |
|---|---|
| `(blocking)` | 해결 전에는 승인하지 않음 |
| `(non-blocking)` | 반영하지 않아도 승인함 |
| `(if-minor)` | 고치는 게 간단하면 이번에 반영해 주세요 |

다른 말로 자유롭게 붙여도 됩니다. 예: `(security)`, `(test)`

```
issue (blocking, security): 요청 헤더 전체를 로그에 남기고 있습니다

Authorization 헤더의 토큰이 로그 파일에 그대로 기록됩니다.
민감한 헤더는 마스킹하거나 출력 대상에서 빼야 합니다.
```

---

## 3. 이 저장소의 약속

| 약속 | 내용 |
|---|---|
| 머지를 막는 코멘트 | `issue`, `todo`, `chore`, `(blocking)` 이 붙은 코멘트 |
| 리뷰어 | `nitpick` 으로 머지를 막지 않는다. 스타일 지적은 Checkstyle 에 맡긴다 |
| 리뷰어 | 막는 코멘트가 없으면 **Approve**, 있으면 **Request changes** |
| 작성자 | 모든 코멘트에 **반영하거나 이유를 달아 답한다**. 반영했으면 커밋 링크를 남기고 Resolve |
| 모두 | 코드를 지적하되 사람을 지적하지 않는다 ("당신이" ✘ → "이 코드가" ✔) |

**작성자가 답하는 예**

```
반영했습니다 → 3f2a1c9
```
```
이번 PR 범위를 넘어서 별도 이슈로 남겼습니다 → #42
```
```
의도한 동작입니다. 빈 문자열도 유효한 desc 로 받기로 기획과 합의했습니다 (회의록 링크).
```

---

## 4. GitHub에서 쓰기

### 4.1 suggestion 블록 — 버튼 한 번으로 반영

줄 단위 코멘트에서 ± 아이콘(Add a suggestion)을 누르거나 직접 씁니다.
작성자는 `Commit suggestion` 버튼으로 바로 반영할 수 있습니다.

````
suggestion (if-minor): 변수 이름을 의도가 드러나게 바꾸면 좋겠습니다

```suggestion
		List<Simple> simpleList = IntStream.range(0, 10)
```
````

### 4.2 Saved replies — 라벨 빠르게 넣기 (각자 한 번 설정)

GitHub 개인 설정이라 저장소 파일로 공유할 수 없습니다. 각자 한 번 등록합니다.

1. GitHub 오른쪽 위 프로필 → **Settings** → **Saved replies**
2. 아래 항목을 하나씩 추가 (Title / Saved reply)
3. 코멘트 입력창의 ↩️ 아이콘(또는 `Ctrl + .`)을 누르고 골라서 넣기

| Title | Saved reply |
|---|---|
| `cc: praise` | `praise: ` |
| `cc: issue (blocking)` | `issue (blocking): ` |
| `cc: suggestion (non-blocking)` | `suggestion (non-blocking): ` |
| `cc: suggestion (if-minor)` | `suggestion (if-minor): ` |
| `cc: question` | `question: ` |
| `cc: nitpick` | `nitpick (non-blocking): ` |
| `cc: todo` | `todo: ` |
| `cc: thought` | `thought: ` |

### 4.3 Copilot 코드 리뷰

PR 의 **Reviewers** 에서 Copilot 을 지정하면, Copilot 도 이 형식으로 코멘트를 남깁니다.
리뷰 기준은 아래 파일에 있습니다. 팀 규칙이 바뀌면 이 파일들을 고칩니다.

| 파일 | 적용 범위 |
|---|---|
| `.github/copilot-instructions.md` | 저장소 전체 (리뷰 형식·공통 기준) |
| `.github/instructions/java.instructions.md` | `**/*.java` |
| `.github/instructions/workflows.instructions.md` | `.github/**/*.yaml`, `.github/**/*.yml`, `.github/**/*.sh` |

> ⚠️ Copilot 코멘트도 **제안**입니다. 틀린 지적은 이유를 달고 Resolve 합니다. Copilot 은 승인 권한이 없으므로 사람 리뷰를 대신하지 않습니다.

---

## 5. 자주 묻는 질문

**Q. 라벨을 빼먹으면 CI가 막나요?**
막지 않습니다. 리뷰 코멘트는 사람끼리의 대화라서 기계로 강제하지 않고, 리뷰 문화로 정착시킵니다.
(커밋 메시지·PR 제목은 CI가 강제합니다 → [commit-convention.md](commit-convention.md))

**Q. 교육 자료의 `nit` 과 `nitpick` 은 다른가요?**
같습니다. 규격의 정식 이름은 `nitpick` 이고, 줄여서 `nit` 이라고도 씁니다.

---
applyTo: ".github/**/*.yaml,.github/**/*.yml,.github/**/*.sh"
---

# GitHub Actions 워크플로·배포 스크립트 리뷰 기준

- `run:` 안에 `${{ github.event.* }}`, `${{ inputs.* }}` 처럼 외부에서 들어오는 값을 직접 넣으면 셸 주입 위험이 있다. `env:` 로 받아 `"$VAR"` 로 쓰도록 `issue (blocking, security)` 로 지적한다.
- `pull_request_target`, `workflow_run` 트리거에서 PR 코드를 checkout 해 실행하면 `issue (blocking, security)` 로 지적한다.
- `runs-on` 이 self-hosted runner 인데 fork 에서 온 PR 코드가 실행될 수 있으면 `issue (blocking, security)` 로 지적한다. (이 저장소는 fork PR 은 `ubuntu-latest` 에서만 돌린다)
- 액션은 정확한 버전 태그(예: `actions/checkout@v7.0.1`)로 고정한다. `@main`, `@master` 는 `issue` 로 지적한다.
- `permissions:` 가 없거나 필요 이상(`write-all` 등)이면 최소 권한으로 줄이도록 제안한다.
- 비밀값(`secrets.*`)을 `echo` 하거나 파일로 남긴 뒤 지우지 않으면 `issue (blocking, security)` 로 지적한다.
- 배포 스크립트(`.github/actions/deploy-systemd/deploy-remote.sh`)는 `set -euo pipefail` 을 유지하고, 변수는 따옴표로 감싸야 한다.
- 배포 job 의 `timeout-minutes`, `concurrency` 가 빠지면 `suggestion` 으로 알린다.

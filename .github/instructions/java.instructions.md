---
applyTo: "**/*.java"
---

# Java 코드 리뷰 기준

- Lombok(`@Slf4j`, `@Getter`, `@AllArgsConstructor` 등)을 쓴다. 직접 만든 getter/생성자/Logger 가 Lombok 으로 대체 가능하면 `suggestion (non-blocking)` 으로 알린다.
- 컨트롤러의 `@RequestParam`, `@RequestBody` 등 외부 입력에 검증(필수 여부, 길이, 범위)이 없으면 `issue` 로 지적한다.
- 로그에 요청 헤더·본문 전체, 토큰, 비밀번호, 개인정보(이름·전화번호·이메일)가 남으면 `issue (blocking, security)` 로 지적한다.
- 로그는 문자열 연결 대신 `{}` 플레이스홀더를 쓴다.
- 새 엔드포인트·분기가 추가되면 `src/test/java` 에 MockMvc 테스트가 있는지 확인하고, 없으면 `todo` 로 요청한다.
- 테스트 메서드 이름은 camelCase 영문, 설명은 `@DisplayName` 에 한국어로 쓴다 (Checkstyle MethodName 규칙).
- Java 25 기능(record, switch 패턴, `Stream.toList()` 등)으로 더 간결해지는 경우 `suggestion (if-minor)` 로 제안한다.

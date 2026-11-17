package com.example.simpleapi.controller;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

/**
 * SimpleApiController 단위 테스트 (스프링 컨텍스트 없이 standalone MockMvc 사용).
 */
class SimpleApiControllerTest {

	private MockMvc mockMvc;

	@BeforeEach
	void setUp() {
		mockMvc = MockMvcBuilders.standaloneSetup(new SimpleApiController()).build();
	}

	@Test
	@DisplayName("hello는 고정 문자열을 반환한다")
	void helloReturnsFixedText() throws Exception {
		mockMvc.perform(get("/api/hello"))
				.andExpect(status().isOk())
				.andExpect(content().string("hello world1"));
	}

	@Test
	@DisplayName("simple은 10개 항목을 반환한다")
	void simpleReturnsTenItems() throws Exception {
		mockMvc.perform(get("/api/simple"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$", hasSize(10)))
				.andExpect(jsonPath("$[0].num").value(0))
				.andExpect(jsonPath("$[9].title").value("Item 9"))
				.andExpect(jsonPath("$[9].content").value("Content for item 9"));
	}

	@Test
	@DisplayName("testPara는 desc 파라미터를 그대로 반환한다")
	void testParaEchoesDesc() throws Exception {
		mockMvc.perform(get("/api/testPara").param("desc", "abc"))
				.andExpect(status().isOk())
				.andExpect(content().string("abc"));
	}

	@Test
	@DisplayName("testPara는 desc가 없으면 400")
	void testParaWithoutDescIsBadRequest() throws Exception {
		mockMvc.perform(get("/api/testPara"))
				.andExpect(status().isBadRequest());
	}

	@Test
	@DisplayName("version은 버전 문자열을 반환한다")
	void versionReturnsVersionText() throws Exception {
		mockMvc.perform(get("/api/version"))
				.andExpect(status().isOk())
				.andExpect(content().string(containsString("version")));
	}

	@Test
	@DisplayName("logRequest는 본문과 헤더를 받아 성공 메시지를 반환한다")
	void logRequestReturnsSuccessMessage() throws Exception {
		mockMvc.perform(post("/api/log-request")
						.contentType(MediaType.TEXT_PLAIN)
						.header("X-Test", "1")
						.content("payload"))
				.andExpect(status().isOk())
				.andExpect(content().string("Request logged successfully"));
	}
}

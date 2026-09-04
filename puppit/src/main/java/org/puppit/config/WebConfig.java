package org.puppit.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig {
	 @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**") // 모든 경로 허용
                        .allowedOrigins("http://localhost:8080", "http://127.0.0.1:8080") // localhost 허용
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // 허용할 HTTP 메서드
                        .allowedHeaders("*") // 모든 헤더 허용
                        .allowCredentials(true); // 쿠키와 같은 인증 정보 허용
            }
        };
    }
	 @Bean
   public org.springframework.web.multipart.commons.CommonsMultipartResolver multipartResolver() {
       var resolver = new org.springframework.web.multipart.commons.CommonsMultipartResolver();
       resolver.setDefaultEncoding("UTF-8");
       // 파일 1개 최대 크기
       resolver.setMaxUploadSizePerFile(5L * 1024 * 1024); // 5MB
       // 요청 전체 최대 크기 (파일 여러 개 합)
       resolver.setMaxUploadSize(10L * 1024 * 1024); // 10MB
       // 메모리 임계값(바로 디스크에 쓸 최소 크기) - 기본값 사용 권장
       // resolver.setMaxInMemorySize(0);
       return resolver;
   }
}

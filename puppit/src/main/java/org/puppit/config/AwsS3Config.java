package org.puppit.config;

import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AwsS3Config {

    @Bean
    public AmazonS3 amazonS3() {
        // AWS_REGION이 없으면 SDK가 빈 생성 시점에 바로 예외를 던져서 Spring 컨텍스트 전체가
        // 뜨지 못한다(로그인/회원가입 등 S3와 무관한 기능까지 전부 막힘). 리뷰어가 AWS 키 없이도
        // 앱을 띄워볼 수 있도록 기본 리전으로 폴백한다 — 실제 업로드는 자격증명 없이는 그때 가서
        // 실패하지만(S3Service 호출 시점), 최소한 앱 자체는 정상 기동한다.
        String region = System.getenv("AWS_REGION");
        if (region == null || region.isBlank()) {
            region = "ap-northeast-2";
        }
        return AmazonS3ClientBuilder.standard()
                .withCredentials(new EnvironmentVariableCredentialsProvider())
                .withRegion(region)
                .build();
    }
}

package puppit;

import static org.junit.Assert.assertTrue;

import org.junit.Test;

/**
 * 빌드 파이프라인이 테스트를 실제로 컴파일/실행하는지 확인하는 최소 스모크 테스트.
 * 실질적인 테스트는 이후 단계(테스트 골격 + CI)에서 채운다.
 */
public class PuppitTest {

  @Test
  public void contextSmoke() {
    assertTrue(true);
  }
}

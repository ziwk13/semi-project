-- ---------------------------------------------------------------------------
-- 로컬 개발용 최소 시드 데이터
-- 조회용 마스터 테이블(카테고리/상태/컨디션/지역)만 채운다.
-- 운영 데이터가 아니며, docker-compose 로 DB 를 처음 띄울 때 1회 실행된다.
-- ---------------------------------------------------------------------------
SET NAMES utf8mb4;

INSERT INTO `product_status` (`status_id`, `status_code`, `status_name`) VALUES
  (1, 'SELLING',  '판매중'),
  (2, 'RESERVED', '예약중'),
  (3, 'SOLD',     '판매완료')
ON DUPLICATE KEY UPDATE `status_name` = VALUES(`status_name`);

INSERT INTO `product_condition` (`condition_id`, `condition_code`, `condition_name`) VALUES
  (1, 'BEST',  '최상 (미개봉/새상품)'),
  (2, 'GOOD',  '상 (사용감 적음)'),
  (3, 'NORMAL','중 (사용감 있음)'),
  (4, 'POOR',  '하 (하자/파손)')
ON DUPLICATE KEY UPDATE `condition_name` = VALUES(`condition_name`);

INSERT INTO `product_category` (`category_id`, `category_name`) VALUES
  (1, '사료'),
  (2, '간식'),
  (3, '장난감'),
  (4, '용품')
ON DUPLICATE KEY UPDATE `category_name` = VALUES(`category_name`);

INSERT INTO `location` (`location_id`, `region`) VALUES
  (1, '서울'),
  (2, '경기'),
  (3, '인천'),
  (4, '부산'),
  (5, '대구')
ON DUPLICATE KEY UPDATE `region` = VALUES(`region`);

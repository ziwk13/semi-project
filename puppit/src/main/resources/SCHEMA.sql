CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `account_id` varchar(20) NOT NULL,
  `user_name` varchar(20) NOT NULL,
  `nick_name` varchar(20) NOT NULL,
  `user_password` varchar(255) DEFAULT NULL,
  `user_email` varchar(50) DEFAULT NULL,
  `user_phone` varchar(15) DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `point` int NOT NULL DEFAULT '10000',
  `salt` binary(16) DEFAULT NULL,
  `profile_image_key` varchar(255) DEFAULT NULL COMMENT '프로필 이미지 S3 Key',
  `provider` varchar(20) DEFAULT NULL,
  `provider_id` bigint DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `account_id_UNIQUE` (`account_id`),
  UNIQUE KEY `nick_name_UNIQUE` (`nick_name`),
  UNIQUE KEY `user_email_UNIQUE` (`user_email`),
  UNIQUE KEY `uq_user_provider_providerid` (`provider`,`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `room` (
  `room_id` int NOT NULL AUTO_INCREMENT,
  `payment_id` int DEFAULT NULL,
  `product_id` int NOT NULL,
  `room_created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int NOT NULL COMMENT '채팅방 생성자 또는 참여자',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: not deleted, 1: deleted',
  PRIMARY KEY (`room_id`),
  KEY `FK_room_user` (`user_id`),
  KEY `fk_product_id` (`product_id`),
  CONSTRAINT `fk_product_id` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_room_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `chat` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `chat_room_id` int NOT NULL,
  `chat_sender` int NOT NULL,
  `chat_message` varchar(500) DEFAULT NULL,
  `chat_created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `chat_receiver` int NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: not deleted, 1: deleted',
  PRIMARY KEY (`message_id`),
  KEY `FK_chat_room` (`chat_room_id`),
  KEY `FK_chat_sender` (`chat_sender`),
  KEY `FK_chat_receiver` (`chat_receiver`),
  CONSTRAINT `FK_chat_receiver` FOREIGN KEY (`chat_receiver`) REFERENCES `user` (`user_id`),
  CONSTRAINT `FK_chat_room` FOREIGN KEY (`chat_room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_chat_sender` FOREIGN KEY (`chat_sender`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1543 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `alarm` (
  `alarm_id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `message_id` int NOT NULL,
  `user_id` int NOT NULL,
  `is_read` tinyint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0: not deleted, 1: deleted',
  PRIMARY KEY (`alarm_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_alarm_room` (`room_id`),
  KEY `alarm_ibfk_2` (`message_id`),
  CONSTRAINT `alarm_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`),
  CONSTRAINT `alarm_ibfk_2` FOREIGN KEY (`message_id`) REFERENCES `chat` (`message_id`) ON DELETE CASCADE,
  CONSTRAINT `alarm_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `fk_alarm_message` FOREIGN KEY (`message_id`) REFERENCES `chat` (`message_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_alarm_room` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=790 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;





CREATE TABLE `chat_image` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `message_id` int NOT NULL,
  `chat_image_file_name` varchar(255) NOT NULL,
  `chat_image_upload_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  KEY `FK_chat_image_message` (`message_id`),
  CONSTRAINT `FK_chat_image_message` FOREIGN KEY (`message_id`) REFERENCES `chat` (`message_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `location` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `region` varchar(100) NOT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `region` (`region`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `password_reset_token` (
  `token_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `uq_token` (`token`),
  KEY `idx_user_expires` (`user_id`,`expires_at`),
  CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `point_charge` (
  `charge_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `point_charge_amount` int DEFAULT NULL,
  `point_charge_order_number` varchar(250) NOT NULL,
  `point_charge_charged_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `charge_status` enum('PENDING','PAID','FAILED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`charge_id`),
  UNIQUE KEY `point_charge_order_number_UNIQUE` (`point_charge_order_number`),
  KEY `fk_point_charge_user` (`user_id`),
  CONSTRAINT `fk_point_charge_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL,
  `category_id` int NOT NULL,
  `seller_id` int NOT NULL,
  `condition_id` int NOT NULL,
  `status_id` int NOT NULL DEFAULT '1',
  `product_name` varchar(100) NOT NULL,
  `product_price` int DEFAULT NULL,
  `product_description` text NOT NULL,
  `product_created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `product_updated_at` timestamp NULL DEFAULT NULL,
  `thumbnail_id` int DEFAULT NULL,
  `is_read` int DEFAULT '0',
  PRIMARY KEY (`product_id`),
  KEY `fk_product_seller` (`seller_id`),
  KEY `fk_product_category` (`category_id`),
  KEY `fk_product_status` (`status_id`),
  KEY `fk_product_location` (`location_id`),
  KEY `fk_product_condition` (`condition_id`),
  KEY `fk_product_thumbnail` (`thumbnail_id`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `product_category` (`category_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_condition` FOREIGN KEY (`condition_id`) REFERENCES `product_condition` (`condition_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_seller` FOREIGN KEY (`seller_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `fk_product_status` FOREIGN KEY (`status_id`) REFERENCES `product_status` (`status_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_thumbnail` FOREIGN KEY (`thumbnail_id`) REFERENCES `product_image` (`image_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=218 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_condition` (
  `condition_id` int NOT NULL AUTO_INCREMENT,
  `condition_code` varchar(20) NOT NULL,
  `condition_name` varchar(100) NOT NULL,
  PRIMARY KEY (`condition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_image` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `image_key` varchar(255) NOT NULL,
  `is_thumbnail` tinyint(1) NOT NULL,
  PRIMARY KEY (`image_id`),
  KEY `fk_product_image_product` (`product_id`),
  CONSTRAINT `fk_product_image_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `product_status` (
  `status_id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(20) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  PRIMARY KEY (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `rds_test_check` (
  `id` int NOT NULL AUTO_INCREMENT,
  `message` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `seller_id` int NOT NULL,
  `buyer_id` int NOT NULL,
  `product_id` int NOT NULL,
  `content` varchar(500) NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uk_review_buyer_product` (`buyer_id`,`product_id`),
  KEY `fk_seller` (`seller_id`),
  KEY `fk_product` (`product_id`),
  CONSTRAINT `fk_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller` FOREIGN KEY (`seller_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `review_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



CREATE TABLE `search_log` (
  `search_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `search_keyword` varchar(20) DEFAULT NULL,
  `searched_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`search_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `search_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `trade_payment` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `uuid` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `buyer_id` int NOT NULL,
  `seller_id` int NOT NULL,
  `product_id` int NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uk_trade_payment_uuid` (`uuid`),
  KEY `idx_trade_payment_buyer` (`buyer_id`),
  KEY `idx_trade_payment_seller` (`seller_id`),
  KEY `idx_trade_payment_product` (`product_id`),
  CONSTRAINT `fk_tp_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_tp_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tp_seller` FOREIGN KEY (`seller_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE `user_status` (
  `login_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `account_id` varchar(20) NOT NULL,
  `login_at` timestamp NOT NULL,
  PRIMARY KEY (`login_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_status_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1446 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `wishlist` (
  `wishlist_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`wishlist_id`),
  KEY `user_id` (`user_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `wishlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `wishlist_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
















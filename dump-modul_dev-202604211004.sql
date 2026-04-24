-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: modul.cuy5c3u60hc2.us-east-2.rds.amazonaws.com    Database: modul_dev
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `acc_account`
--

DROP TABLE IF EXISTS `acc_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `number` varchar(100) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `type_id` bigint NOT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `acc_account_UN_uuid` (`uuid`),
  UNIQUE KEY `acc_account_UN` (`enterprise_id`,`number`),
  KEY `acc_account_FK_1` (`create_user_id`),
  KEY `acc_account_FK_2` (`type_id`),
  CONSTRAINT `acc_account_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_account_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `acc_account_FK_2` FOREIGN KEY (`type_id`) REFERENCES `acc_type` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=162436 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_card`
--

DROP TABLE IF EXISTS `acc_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_card` (
  `card_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `account_id` bigint NOT NULL,
  `number` varchar(20) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `expire_date` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`card_id`),
  UNIQUE KEY `acc_card_UN` (`uuid`),
  KEY `acc_card_FK` (`create_user_id`),
  KEY `acc_card_FK_1` (`type_id`),
  KEY `acc_card_FK_2` (`account_id`),
  CONSTRAINT `acc_card_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `acc_card_FK_1` FOREIGN KEY (`type_id`) REFERENCES `acc_card_type` (`type_id`),
  CONSTRAINT `acc_card_FK_2` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_card_type`
--

DROP TABLE IF EXISTS `acc_card_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_card_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `acc_card_type_UN_uuid` (`uuid`),
  UNIQUE KEY `acc_card_type_UN_name` (`enterprise_id`,`name`),
  KEY `acc_card_type_FK_1` (`create_user_id`),
  CONSTRAINT `acc_card_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_card_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_external_transaction`
--

DROP TABLE IF EXISTS `acc_external_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_external_transaction` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `external_transaction_id` varchar(100) NOT NULL,
  `internal_transaction_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `external_entity` varchar(100) NOT NULL COMMENT 'The external entity name who''s registering this transaction',
  PRIMARY KEY (`record_id`),
  KEY `acc_external_transaction_FK` (`internal_transaction_id`),
  CONSTRAINT `acc_external_transaction_FK` FOREIGN KEY (`internal_transaction_id`) REFERENCES `acc_transaction` (`transaction_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=29231 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_movement_old_new`
--

DROP TABLE IF EXISTS `acc_movement_old_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_movement_old_new` (
  `id` int NOT NULL AUTO_INCREMENT,
  `new_id` int NOT NULL,
  `old_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=279931 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction`
--

DROP TABLE IF EXISTS `acc_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `account_id` bigint NOT NULL,
  `setup` longtext,
  `parent_transaction_id` bigint DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `acc_transaction_UN` (`uuid`),
  KEY `acc_transaction_FK` (`account_id`),
  KEY `acc_transaction_FK_1` (`type_id`),
  KEY `acc_transaction_FK_2` (`create_user_id`),
  KEY `parent_transaction_id_FK` (`parent_transaction_id`),
  FULLTEXT KEY `idx_setup_fulltext` (`setup`),
  CONSTRAINT `acc_transaction_FK` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_FK_1` FOREIGN KEY (`type_id`) REFERENCES `acc_transaction_type` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `parent_transaction_id_FK` FOREIGN KEY (`parent_transaction_id`) REFERENCES `acc_transaction` (`transaction_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=956185 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_bank`
--

DROP TABLE IF EXISTS `acc_transaction_bank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_bank` (
  `bank_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`bank_id`),
  UNIQUE KEY `acc_transaction_bank_un` (`uuid`),
  KEY `acc_transaction_bank_FK` (`enterprise_id`),
  KEY `acc_transaction_bank_FK_1` (`create_user_id`),
  CONSTRAINT `acc_transaction_bank_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_bank_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_configuration`
--

DROP TABLE IF EXISTS `acc_transaction_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `acc_transaction_configuration_UN` (`enterprise_id`),
  CONSTRAINT `acc_transaction_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_distribution`
--

DROP TABLE IF EXISTS `acc_transaction_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_distribution` (
  `distribution_id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint NOT NULL,
  `movement_id` bigint NOT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`distribution_id`),
  KEY `acc_transaction_distribution_FK` (`transaction_id`),
  KEY `acc_transaction_distribution_FK_1` (`movement_id`),
  CONSTRAINT `acc_transaction_distribution_FK` FOREIGN KEY (`transaction_id`) REFERENCES `acc_transaction` (`transaction_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_distribution_FK_1` FOREIGN KEY (`movement_id`) REFERENCES `std_account_movement` (`movement_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=1431468 DEFAULT CHARSET=utf8mb3 COMMENT='This is how the transaction is distributed in the account movements.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_nullable`
--

DROP TABLE IF EXISTS `acc_transaction_nullable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_nullable` (
  `nullable_id` bigint NOT NULL AUTO_INCREMENT,
  `invalidator_id` bigint NOT NULL COMMENT 'The one that invalidates a transaction',
  `invalidated_id` bigint NOT NULL COMMENT 'The one that got reversed',
  `reverse_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nullable_id`),
  KEY `invalidated_id` (`invalidated_id`),
  KEY `invalidator_id` (`invalidator_id`),
  CONSTRAINT `acc_transaction_nullable_ibfk_1` FOREIGN KEY (`invalidator_id`) REFERENCES `acc_transaction` (`transaction_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_nullable_ibfk_2` FOREIGN KEY (`invalidated_id`) REFERENCES `acc_transaction` (`transaction_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `acc_transaction_nullable_chk_1` CHECK ((`invalidator_id` <> `invalidated_id`))
) ENGINE=InnoDB AUTO_INCREMENT=176 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_old_new`
--

DROP TABLE IF EXISTS `acc_transaction_old_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_old_new` (
  `id` int NOT NULL AUTO_INCREMENT,
  `new_id` int DEFAULT NULL,
  `old_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99895 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_register`
--

DROP TABLE IF EXISTS `acc_transaction_register`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_register` (
  `register_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `start_date` date NOT NULL,
  `final_date` date NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `uuid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT (uuid()),
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'P' COMMENT 'P = Pending, T = Transferred',
  PRIMARY KEY (`register_id`),
  KEY `acc_transaction_register_usr_enterprise_FK` (`enterprise_id`),
  KEY `acc_transaction_register_usr_user_FK` (`create_user_id`),
  CONSTRAINT `acc_transaction_register_ent_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_transaction_register_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_transaction_type`
--

DROP TABLE IF EXISTS `acc_transaction_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_transaction_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `acc_transaction_type_UN_uuid` (`uuid`),
  UNIQUE KEY `acc_transaction_type_UN_name` (`enterprise_id`,`name`),
  KEY `acc_transaction_type_FK_1` (`create_user_id`),
  CONSTRAINT `acc_transaction_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_transaction_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `acc_type`
--

DROP TABLE IF EXISTS `acc_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acc_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `acc_type_UN_uuid` (`uuid`),
  UNIQUE KEY `acc_type_UN_name` (`enterprise_id`,`name`),
  KEY `acc_type_FK_1` (`create_user_id`),
  CONSTRAINT `acc_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_endpoint`
--

DROP TABLE IF EXISTS `api_endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_endpoint` (
  `endpoint_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `url` varchar(250) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `setup` longtext,
  `create_user_id` bigint DEFAULT NULL,
  `create_dat` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`endpoint_id`),
  KEY `api_endpoint_FK` (`enterprise_id`),
  CONSTRAINT `api_endpoint_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_jwt`
--

DROP TABLE IF EXISTS `api_jwt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_jwt` (
  `jwt_id` bigint NOT NULL AUTO_INCREMENT,
  `access_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `token` longtext,
  `validity_time` varchar(10) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`jwt_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `api_jwt_FK` (`access_id`),
  CONSTRAINT `api_jwt_FK` FOREIGN KEY (`access_id`) REFERENCES `api_jwt_access` (`access_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_jwt_access`
--

DROP TABLE IF EXISTS `api_jwt_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_jwt_access` (
  `access_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `username` varchar(100) NOT NULL,
  `key` varchar(100) NOT NULL,
  `status_code` varchar(1) NOT NULL DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`access_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `api_jwt_access_FK` (`enterprise_id`),
  KEY `api_jwt_access_FK_1` (`create_user_id`),
  CONSTRAINT `api_jwt_access_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_jwt_access_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_log`
--

DROP TABLE IF EXISTS `api_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `endpoint_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `request_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `response_date` datetime DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  KEY `api_request_FK` (`endpoint_id`),
  CONSTRAINT `api_log_FK` FOREIGN KEY (`endpoint_id`) REFERENCES `api_endpoint` (`endpoint_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1198757 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_setting`
--

DROP TABLE IF EXISTS `api_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `api_setting_FK_1` (`create_user_id`),
  CONSTRAINT `api_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `api_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `apm_endpoint`
--

DROP TABLE IF EXISTS `apm_endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apm_endpoint` (
  `endpoint_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `url` varchar(250) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`endpoint_id`),
  KEY `apm_endpoint_FK` (`enterprise_id`),
  CONSTRAINT `apm_endpoint_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `apm_request`
--

DROP TABLE IF EXISTS `apm_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apm_request` (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `endpoint_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `request_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `response_date` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `apm_request_FK` (`endpoint_id`),
  CONSTRAINT `apm_request_FK` FOREIGN KEY (`endpoint_id`) REFERENCES `apm_endpoint` (`endpoint_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `apm_user`
--

DROP TABLE IF EXISTS `apm_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `apm_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `uuid` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `apm_user_UN` (`enterprise_id`,`username`),
  CONSTRAINT `apm_user_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arc_configuration`
--

DROP TABLE IF EXISTS `arc_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `arc_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `arc_configuration_FK` (`enterprise_id`),
  CONSTRAINT `arc_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `arc_piece`
--

DROP TABLE IF EXISTS `arc_piece`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `arc_piece` (
  `piece_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_user_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`piece_id`),
  KEY `arc_piece_FK` (`enterprise_id`),
  KEY `arc_piece_FK_1` (`create_user_id`),
  CONSTRAINT `arc_piece_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `arc_piece_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `automation_automation`
--

DROP TABLE IF EXISTS `automation_automation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_automation` (
  `automation_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive(I)',
  `group_id` bigint DEFAULT NULL,
  `engine` varchar(100) NOT NULL,
  `automator` varchar(500) NOT NULL,
  `arguments` longtext,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`automation_id`),
  UNIQUE KEY `automation_automation_UN` (`uuid`),
  KEY `automation_automation_FK` (`enterprise_id`),
  KEY `automation_automation_FK_1` (`create_user_id`),
  CONSTRAINT `automation_automation_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `automation_automation_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `automation_group`
--

DROP TABLE IF EXISTS `automation_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_group` (
  `group_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `automation_group_UN` (`uuid`),
  KEY `automation_group_FK` (`enterprise_id`),
  KEY `automation_group_FK_1` (`create_user_id`),
  CONSTRAINT `automation_group_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `automation_group_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `automation_task`
--

DROP TABLE IF EXISTS `automation_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `automation_task` (
  `task_id` bigint NOT NULL AUTO_INCREMENT,
  `automation_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `programmed_date` datetime DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'W' COMMENT 'Waiting (W), Cancelled (C), Executed (X), Errored (E)',
  `group_id` bigint DEFAULT NULL,
  PRIMARY KEY (`task_id`),
  UNIQUE KEY `automation_task_UN` (`uuid`),
  KEY `automation_task_FK` (`create_user_id`),
  KEY `automation_task_FK_2` (`group_id`),
  KEY `automation_task_FK_1` (`automation_id`),
  CONSTRAINT `automation_task_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `automation_task_FK_1` FOREIGN KEY (`automation_id`) REFERENCES `automation_automation` (`automation_id`),
  CONSTRAINT `automation_task_FK_2` FOREIGN KEY (`group_id`) REFERENCES `automation_group` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `brn_setup`
--

DROP TABLE IF EXISTS `brn_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `brn_setup` (
  `setup_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setup_id`),
  UNIQUE KEY `brn_setup_UN` (`enterprise_id`),
  KEY `brn_setup_FK_1` (`create_user_id`),
  CONSTRAINT `brn_setup_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `brn_setup_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cal_event`
--

DROP TABLE IF EXISTS `cal_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cal_event` (
  `event_id` bigint NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  PRIMARY KEY (`event_id`),
  KEY `cal_event_FK` (`create_user_id`),
  CONSTRAINT `cal_event_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cal_setting`
--

DROP TABLE IF EXISTS `cal_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cal_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `cal_setting_FK_1` (`create_user_id`),
  CONSTRAINT `cal_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cal_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clm_setup`
--

DROP TABLE IF EXISTS `clm_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clm_setup` (
  `setup_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setup_id`),
  KEY `clm_setup_FK` (`enterprise_id`),
  KEY `clm_setup_FK_1` (`create_user_id`),
  CONSTRAINT `clm_setup_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `clm_setup_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='Setup for Clothing meassurement';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_address`
--

DROP TABLE IF EXISTS `col_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_address` (
  `address_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `collegiate_id` bigint DEFAULT NULL,
  `address_type_id` bigint NOT NULL,
  `address` varchar(250) NOT NULL,
  `department_id` bigint DEFAULT NULL,
  `municipality_id` bigint DEFAULT NULL,
  `zone` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  UNIQUE KEY `col_address_UN` (`uuid`),
  KEY `col_address_FK` (`create_user_id`),
  KEY `col_address_FK_1` (`address_type_id`),
  KEY `col_address_FK_2` (`collegiate_id`),
  KEY `col_address_FK_4` (`department_id`),
  KEY `col_address_FK_5` (`municipality_id`),
  CONSTRAINT `col_address_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_address_FK_1` FOREIGN KEY (`address_type_id`) REFERENCES `col_address_type` (`address_type_id`),
  CONSTRAINT `col_address_FK_2` FOREIGN KEY (`collegiate_id`) REFERENCES `col_collegiate` (`collegiate_id`),
  CONSTRAINT `col_address_FK_3` FOREIGN KEY (`department_id`) REFERENCES `col_address_department` (`department_id`),
  CONSTRAINT `col_address_FK_5` FOREIGN KEY (`municipality_id`) REFERENCES `col_address_municipality` (`municipality_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_address_department`
--

DROP TABLE IF EXISTS `col_address_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_address_department` (
  `department_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `col_address_department_UN` (`uuid`),
  KEY `col_address_department_FK` (`enterprise_id`),
  KEY `col_address_department_FK_1` (`create_user_id`),
  CONSTRAINT `col_address_department_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_address_department_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_address_municipality`
--

DROP TABLE IF EXISTS `col_address_municipality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_address_municipality` (
  `municipality_id` bigint NOT NULL AUTO_INCREMENT,
  `department_id` bigint NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`municipality_id`),
  UNIQUE KEY `col_address_municipality_UN` (`uuid`),
  KEY `col_address_municipality_FK` (`enterprise_id`),
  KEY `col_address_municipality_FK_1` (`create_user_id`),
  KEY `col_address_municipality_FK_2` (`department_id`),
  CONSTRAINT `col_address_municipality_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_address_municipality_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_address_municipality_FK_2` FOREIGN KEY (`department_id`) REFERENCES `col_address_department` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_address_type`
--

DROP TABLE IF EXISTS `col_address_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_address_type` (
  `address_type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`address_type_id`),
  UNIQUE KEY `col_direction_type_UN` (`uuid`),
  KEY `col_direction_type_FK` (`enterprise_id`),
  KEY `col_direction_type_FK_1` (`create_user_id`),
  CONSTRAINT `col_direction_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_direction_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_beneficiary`
--

DROP TABLE IF EXISTS `col_beneficiary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_beneficiary` (
  `beneficiary_id` bigint NOT NULL AUTO_INCREMENT,
  `collegiate_id` bigint NOT NULL,
  `relation_type_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `genre` varchar(1) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `benefit_percentage` int DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`beneficiary_id`),
  UNIQUE KEY `col_beneficiary_UN` (`uuid`),
  KEY `col_beneficiary_FK` (`create_user_id`),
  KEY `col_beneficiary_FK1` (`collegiate_id`),
  KEY `col_beneficiary_FK2` (`relation_type_id`),
  CONSTRAINT `col_beneficiary_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_beneficiary_FK1` FOREIGN KEY (`collegiate_id`) REFERENCES `col_collegiate` (`collegiate_id`),
  CONSTRAINT `col_beneficiary_FK2` FOREIGN KEY (`relation_type_id`) REFERENCES `col_beneficiary_relation_type` (`relation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_beneficiary_relation_type`
--

DROP TABLE IF EXISTS `col_beneficiary_relation_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_beneficiary_relation_type` (
  `relation_type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`relation_type_id`),
  UNIQUE KEY `col_beneficiary_relation_type_UN` (`uuid`),
  KEY `col_beneficiary_relation_type_FK` (`enterprise_id`),
  KEY `col_beneficiary_relation_type_FK_1` (`create_user_id`),
  CONSTRAINT `col_beneficiary_relation_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_beneficiary_relation_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_collegiate`
--

DROP TABLE IF EXISTS `col_collegiate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_collegiate` (
  `collegiate_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `collegiate_number` varchar(25) NOT NULL,
  `nationality_country_id` bigint NOT NULL,
  `collegiate_type_id` bigint NOT NULL,
  `health_register_number` varchar(100) DEFAULT NULL,
  `collegiate_date` date DEFAULT NULL,
  `graduation_date` date DEFAULT NULL,
  `incorporate_date` date DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `second_name` varchar(100) DEFAULT NULL,
  `other_name` varchar(100) DEFAULT NULL,
  `first_surname` varchar(100) DEFAULT NULL,
  `last_surname` varchar(100) DEFAULT NULL,
  `marriage_surname` varchar(100) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `birth_place` varchar(100) DEFAULT NULL,
  `gender` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `graduation_university_id` bigint DEFAULT NULL,
  `graduation_high_school` varchar(100) DEFAULT NULL,
  `other_studies` varchar(100) DEFAULT NULL,
  `graduation_tesis_name` varchar(250) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `path_photo` varchar(250) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`collegiate_id`),
  UNIQUE KEY `col_collegiate_UN` (`uuid`),
  KEY `col_collegiate_FK_05` (`enterprise_id`),
  KEY `col_collegiate_FK_03` (`collegiate_type_id`),
  KEY `col_collegiate_FK_04` (`graduation_university_id`),
  KEY `col_collegiate_FK_02` (`create_user_id`),
  KEY `col_collegiate_FK_01` (`nationality_country_id`),
  CONSTRAINT `col_collegiate_FK_01` FOREIGN KEY (`nationality_country_id`) REFERENCES `col_country` (`country_id`),
  CONSTRAINT `col_collegiate_FK_02` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_collegiate_FK_03` FOREIGN KEY (`collegiate_type_id`) REFERENCES `col_collegiate_type` (`collegiate_type_id`),
  CONSTRAINT `col_collegiate_FK_04` FOREIGN KEY (`graduation_university_id`) REFERENCES `col_university` (`university_id`),
  CONSTRAINT `col_collegiate_FK_05` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_collegiate_type`
--

DROP TABLE IF EXISTS `col_collegiate_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_collegiate_type` (
  `collegiate_type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `collegiate_number_prefix` varchar(5) DEFAULT NULL,
  `current_number` bigint DEFAULT NULL,
  PRIMARY KEY (`collegiate_type_id`),
  UNIQUE KEY `col_collegiate_UN` (`uuid`),
  KEY `col_collegiate_FK` (`enterprise_id`),
  KEY `col_collegiate_FK_1` (`create_user_id`),
  CONSTRAINT `col_collegiate_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_collegiate_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_country`
--

DROP TABLE IF EXISTS `col_country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_country` (
  `country_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `iso_code` varchar(3) DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `col_country_UN` (`uuid`),
  KEY `col_country_FK` (`enterprise_id`),
  KEY `col_country_FK_1` (`create_user_id`),
  CONSTRAINT `col_country_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_country_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_setting`
--

DROP TABLE IF EXISTS `col_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `col_setting_UN` (`enterprise_id`),
  KEY `col_setting_FK_1` (`create_user_id`),
  CONSTRAINT `col_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_telephone`
--

DROP TABLE IF EXISTS `col_telephone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_telephone` (
  `telephone_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `collegiate_id` bigint DEFAULT NULL,
  `telephone_type_id` bigint NOT NULL,
  `telephone` varchar(250) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`telephone_id`),
  UNIQUE KEY `col_telephone_UN` (`uuid`),
  KEY `col_telephone_FK` (`create_user_id`),
  KEY `col_telephone_FK_1` (`telephone_type_id`),
  KEY `col_telephone_FK_2` (`collegiate_id`),
  CONSTRAINT `col_telephone_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_telephone_FK_1` FOREIGN KEY (`telephone_type_id`) REFERENCES `col_telephone_type` (`telephone_type_id`),
  CONSTRAINT `col_telephone_FK_2` FOREIGN KEY (`collegiate_id`) REFERENCES `col_collegiate` (`collegiate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_telephone_type`
--

DROP TABLE IF EXISTS `col_telephone_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_telephone_type` (
  `telephone_type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`telephone_type_id`),
  UNIQUE KEY `col_telephone_type_UN` (`uuid`),
  KEY `col_telephone_type_FK` (`enterprise_id`),
  KEY `col_telephone_type_FK_1` (`create_user_id`),
  CONSTRAINT `col_telephone_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_telephone_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_university`
--

DROP TABLE IF EXISTS `col_university`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `col_university` (
  `university_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `shortname` varchar(50) NOT NULL,
  `country_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`university_id`),
  UNIQUE KEY `col_university_UN` (`uuid`),
  KEY `col_university_FK` (`enterprise_id`),
  KEY `col_university_FK_1` (`create_user_id`),
  KEY `col_university_FK_2` (`country_id`),
  CONSTRAINT `col_university_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `col_university_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `col_university_FK_2` FOREIGN KEY (`country_id`) REFERENCES `col_country` (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cooldown_exhibit`
--

DROP TABLE IF EXISTS `cooldown_exhibit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cooldown_exhibit` (
  `exhibit_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`exhibit_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `cooldown_exhibit_UN_code` (`code`,`enterprise_id`),
  KEY `cooldown_exhibit_FK` (`enterprise_id`),
  KEY `cooldown_exhibit_FK_1` (`create_user_id`),
  CONSTRAINT `cooldown_exhibit_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cooldown_exhibit_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cooldown_visit`
--

DROP TABLE IF EXISTS `cooldown_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cooldown_visit` (
  `visit_id` bigint NOT NULL AUTO_INCREMENT,
  `exhibit_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`visit_id`),
  KEY `cooldown_visit_FK` (`exhibit_id`),
  CONSTRAINT `cooldown_visit_FK` FOREIGN KEY (`exhibit_id`) REFERENCES `cooldown_exhibit` (`exhibit_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_classroom`
--

DROP TABLE IF EXISTS `crs_assignation_classroom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_classroom` (
  `classroom_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `studying_cycle_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `branch_id` bigint DEFAULT NULL,
  `season_id` bigint NOT NULL,
  PRIMARY KEY (`classroom_id`),
  UNIQUE KEY `crs_assignation_classroom_un` (`uuid`),
  KEY `crs_assignation_classroom_std_studying_cycle_FK` (`studying_cycle_id`),
  KEY `crs_assignation_classroom_FK_1` (`branch_id`),
  KEY `crs_assignation_classroom_FK_2` (`season_id`),
  CONSTRAINT `crs_assignation_classroom_FK_1` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_classroom_FK_2` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`),
  CONSTRAINT `crs_assignation_classroom_std_studying_cycle_FK` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3474 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_classroom_career`
--

DROP TABLE IF EXISTS `crs_assignation_classroom_career`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_classroom_career` (
  `classroom_career_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `classroom_id` bigint NOT NULL,
  `career_id` bigint NOT NULL,
  PRIMARY KEY (`classroom_career_id`),
  UNIQUE KEY `crs_assignation_classroom_career_unique` (`uuid`),
  KEY `crs_assignation_classroom_career_crs_assignation_classroom_FK` (`classroom_id`),
  KEY `crs_assignation_classroom_career_std_career_FK` (`career_id`),
  CONSTRAINT `crs_assignation_classroom_career_crs_assignation_classroom_FK` FOREIGN KEY (`classroom_id`) REFERENCES `crs_assignation_classroom` (`classroom_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_classroom_career_std_career_FK` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=5123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_classroom_studying_time`
--

DROP TABLE IF EXISTS `crs_assignation_classroom_studying_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_classroom_studying_time` (
  `classroom_studying_time_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `classroom_id` bigint NOT NULL,
  `studying_time_id` bigint NOT NULL,
  PRIMARY KEY (`classroom_studying_time_id`),
  UNIQUE KEY `crs_assignation_classroom_studying_time_unique` (`uuid`),
  KEY `crs_assignation_classroom_st_crs_assignation_classroom_FK` (`classroom_id`),
  KEY `crs_assignation_classroom_studying_time_std_studying_time_FK` (`studying_time_id`),
  CONSTRAINT `crs_assignation_classroom_st_crs_assignation_classroom_FK` FOREIGN KEY (`classroom_id`) REFERENCES `crs_assignation_classroom` (`classroom_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_classroom_studying_time_std_studying_time_FK` FOREIGN KEY (`studying_time_id`) REFERENCES `std_studying_time` (`studying_time_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3377 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_distribution`
--

DROP TABLE IF EXISTS `crs_assignation_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_distribution` (
  `distribution_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `season_id` bigint NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`distribution_id`),
  UNIQUE KEY `crs_assignation_distribution_UN` (`uuid`),
  KEY `crs_assignation_distribution_FK` (`enterprise_id`),
  KEY `crs_assignation_distribution_FK_1` (`create_user_id`),
  KEY `crs_assignation_distribution_FK_2` (`season_id`),
  CONSTRAINT `crs_assignation_distribution_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_assignation_distribution_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `crs_assignation_distribution_FK_2` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_group`
--

DROP TABLE IF EXISTS `crs_assignation_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_group` (
  `group_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `season_id` bigint NOT NULL,
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `crs_assignation_group_UN` (`uuid`),
  UNIQUE KEY `crs_assignation_group_UN_s` (`name`,`season_id`),
  KEY `crs_assignation_group_FK` (`enterprise_id`),
  KEY `crs_assignation_group_FK_1` (`create_user_id`),
  KEY `crs_assignation_group_FK_2` (`season_id`),
  CONSTRAINT `crs_assignation_group_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_assignation_group_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `crs_assignation_group_FK_2` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_group_section`
--

DROP TABLE IF EXISTS `crs_assignation_group_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_group_section` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` bigint NOT NULL,
  `section_id` bigint NOT NULL,
  PRIMARY KEY (`record_id`),
  KEY `crs_assignation_group_section_FK` (`group_id`),
  KEY `crs_assignation_group_section_FK_1` (`section_id`),
  CONSTRAINT `crs_assignation_group_section_FK` FOREIGN KEY (`group_id`) REFERENCES `crs_assignation_group` (`group_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_group_section_FK_1` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=172 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_group_student`
--

DROP TABLE IF EXISTS `crs_assignation_group_student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_group_student` (
  `assignation_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `group_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `inscription_id` bigint NOT NULL,
  PRIMARY KEY (`assignation_id`),
  UNIQUE KEY `crs_assignation_group_student_UN` (`uuid`),
  KEY `crs_assignation_group_student_FK` (`create_user_id`),
  KEY `crs_assignation_group_student_FK_1` (`group_id`),
  KEY `crs_assignation_group_student_FK_2` (`student_id`),
  KEY `crs_assignation_group_student_FK_3` (`inscription_id`),
  CONSTRAINT `crs_assignation_group_student_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `crs_assignation_group_student_FK_1` FOREIGN KEY (`group_id`) REFERENCES `crs_assignation_group` (`group_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_group_student_FK_2` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_group_student_FK_3` FOREIGN KEY (`inscription_id`) REFERENCES `std_inscription` (`inscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_preinscription`
--

DROP TABLE IF EXISTS `crs_assignation_preinscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_preinscription` (
  `preinscription_id` bigint NOT NULL AUTO_INCREMENT,
  `season_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `setup` longtext,
  `branch_id` bigint DEFAULT NULL,
  `career_id` bigint DEFAULT NULL,
  `studying_time_id` bigint DEFAULT NULL,
  `taken_by_section_id` bigint DEFAULT NULL,
  `inscription_id` bigint DEFAULT NULL,
  `studying_cycle_id` bigint DEFAULT NULL,
  PRIMARY KEY (`preinscription_id`),
  UNIQUE KEY `crs_assignation_preinscription_course_UN` (`season_id`,`student_id`,`course_id`),
  UNIQUE KEY `crs_assignation_preinscription_UN` (`uuid`),
  KEY `crs_assignation_preinscription_FK` (`create_user_id`),
  KEY `crs_assignation_preinscription_FK_2` (`student_id`),
  KEY `crs_assignation_preinscription_FK_3` (`course_id`),
  KEY `crs_assignation_preinscription_FK_4` (`branch_id`),
  KEY `crs_assignation_preinscription_FK_5` (`career_id`),
  KEY `crs_assignation_preinscription_FK_6` (`studying_time_id`),
  KEY `crs_assignation_preinscription_FK_8` (`inscription_id`),
  KEY `crs_assignation_preinscription_std_studying_cycle_FK` (`studying_cycle_id`),
  KEY `crs_assignation_preinscription_FK_7` (`taken_by_section_id`),
  CONSTRAINT `crs_assignation_preinscription_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `crs_assignation_preinscription_FK_1` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_preinscription_FK_2` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `crs_assignation_preinscription_FK_3` FOREIGN KEY (`course_id`) REFERENCES `crs_course` (`course_id`),
  CONSTRAINT `crs_assignation_preinscription_FK_4` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_preinscription_FK_5` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_preinscription_FK_6` FOREIGN KEY (`studying_time_id`) REFERENCES `std_studying_time` (`studying_time_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_preinscription_FK_7` FOREIGN KEY (`taken_by_section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_preinscription_FK_8` FOREIGN KEY (`inscription_id`) REFERENCES `std_inscription` (`inscription_id`),
  CONSTRAINT `crs_assignation_preinscription_std_studying_cycle_FK` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2071766 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_season`
--

DROP TABLE IF EXISTS `crs_assignation_season`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_season` (
  `season_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_default` tinyint DEFAULT NULL,
  `period_id` bigint DEFAULT NULL,
  `is_secondary` tinyint DEFAULT NULL,
  PRIMARY KEY (`season_id`),
  UNIQUE KEY `crs_assignation_season_UN` (`name`,`enterprise_id`),
  UNIQUE KEY `crs_assignation_season_UUID_UN` (`uuid`),
  KEY `crs_assignation_season_FK` (`enterprise_id`),
  KEY `crs_assignation_season_FK_1` (`create_user_id`),
  KEY `crs_assignation_season_FK_2` (`period_id`),
  CONSTRAINT `crs_assignation_season_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_assignation_season_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `crs_assignation_season_FK_2` FOREIGN KEY (`period_id`) REFERENCES `std_period` (`period_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_section`
--

DROP TABLE IF EXISTS `crs_assignation_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_section` (
  `section_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `season_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `professor_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `branch_id` bigint DEFAULT NULL,
  `studying_cycle_id` bigint DEFAULT NULL,
  `classroom_id` bigint DEFAULT NULL,
  `record_code` bigint DEFAULT NULL,
  PRIMARY KEY (`section_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `crs_assignation_section_FK` (`enterprise_id`),
  KEY `crs_assignation_section_FK_1` (`course_id`),
  KEY `crs_assignation_section_FK_2` (`season_id`),
  KEY `crs_assignation_section_FK_3` (`create_user_id`),
  KEY `crs_assignation_section_FK_4` (`branch_id`),
  KEY `crs_assignation_section_FK_6` (`professor_id`),
  KEY `crs_assignation_section_FK_7` (`studying_cycle_id`),
  KEY `crs_assignation_section_crs_assignation_classroom_FK` (`classroom_id`),
  CONSTRAINT `crs_assignation_section_crs_assignation_classroom_FK` FOREIGN KEY (`classroom_id`) REFERENCES `crs_assignation_classroom` (`classroom_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_1` FOREIGN KEY (`course_id`) REFERENCES `crs_course` (`course_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_2` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_4` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_6` FOREIGN KEY (`professor_id`) REFERENCES `pfs_professor` (`professor_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_FK_7` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17577 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_setting`
--

DROP TABLE IF EXISTS `crs_assignation_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `crs_assignation_setting_UN` (`enterprise_id`),
  KEY `crs_assignation_setting_FK_1` (`create_user_id`),
  CONSTRAINT `crs_assignation_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_assignation_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_assignation_student`
--

DROP TABLE IF EXISTS `crs_assignation_student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_assignation_student` (
  `assignation_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `section_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `inscription_id` bigint DEFAULT NULL,
  `group_id` bigint DEFAULT NULL,
  `preinscription_id` bigint DEFAULT NULL,
  PRIMARY KEY (`assignation_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `crs_assignation_section_student_UN_std_sect` (`section_id`,`student_id`),
  KEY `crs_assignation_section_student_FK_1` (`student_id`),
  KEY `crs_assignation_section_student_FK_2` (`create_user_id`),
  KEY `crs_assignation_student_FK` (`inscription_id`),
  KEY `crs_assignation_student_crs_assignation_group_FK` (`group_id`),
  KEY `crs_assignation_student_crs_assignation_preinscription_FK` (`preinscription_id`),
  CONSTRAINT `crs_assignation_section_student_FK` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_student_FK_1` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_section_student_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_assignation_student_crs_assignation_group_FK` FOREIGN KEY (`group_id`) REFERENCES `crs_assignation_group` (`group_id`),
  CONSTRAINT `crs_assignation_student_crs_assignation_preinscription_FK` FOREIGN KEY (`preinscription_id`) REFERENCES `crs_assignation_preinscription` (`preinscription_id`),
  CONSTRAINT `crs_assignation_student_FK` FOREIGN KEY (`inscription_id`) REFERENCES `std_inscription` (`inscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=465416 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_course`
--

DROP TABLE IF EXISTS `crs_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_course` (
  `course_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `crs_course_UN` (`enterprise_id`,`name`),
  UNIQUE KEY `crs_course_uuid_UN` (`uuid`),
  KEY `crs_course_FK_1` (`create_user_id`),
  CONSTRAINT `crs_course_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_course_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=899 DEFAULT CHARSET=utf8mb3 COMMENT='Course table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_phase_record`
--

DROP TABLE IF EXISTS `crs_phase_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_phase_record` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `phase_uuid` varchar(100) NOT NULL,
  `section_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `crs_phase_record_phase_UN` (`phase_uuid`,`section_id`),
  KEY `crs_phase_record_FK` (`section_id`),
  KEY `crs_phase_record_FK_1` (`create_user_id`),
  CONSTRAINT `crs_phase_record_FK` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_phase_record_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=27448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_record`
--

DROP TABLE IF EXISTS `crs_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_record` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `branch_id` bigint NOT NULL,
  `career_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `professor_id` bigint NOT NULL,
  `studying_time_id` bigint NOT NULL,
  `section_id` bigint NOT NULL,
  `stages` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `detail` longtext,
  `group` varchar(100) DEFAULT NULL,
  `exam_date` date DEFAULT NULL,
  `record_type` varchar(100) DEFAULT NULL,
  `record_code` varchar(100) DEFAULT NULL,
  `record_correction_number` bigint DEFAULT NULL,
  `is_verified` tinyint DEFAULT NULL,
  `is_rejected` tinyint DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `crs_record_FK` (`studying_time_id`),
  KEY `crs_record_FK_1` (`branch_id`),
  KEY `crs_record_FK_2` (`career_id`),
  KEY `crs_record_FK_3` (`course_id`),
  KEY `crs_record_FK_4` (`professor_id`),
  KEY `crs_record_FK_5` (`section_id`),
  KEY `crs_record_FK_6` (`create_user_id`),
  CONSTRAINT `crs_record_FK` FOREIGN KEY (`studying_time_id`) REFERENCES `std_studying_time` (`studying_time_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_1` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_2` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_3` FOREIGN KEY (`course_id`) REFERENCES `crs_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_4` FOREIGN KEY (`professor_id`) REFERENCES `pfs_professor` (`professor_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_5` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_FK_6` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=66960 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_record_error`
--

DROP TABLE IF EXISTS `crs_record_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_record_error` (
  `error_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `section_id` bigint DEFAULT NULL,
  `reason` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `enterprise_id` bigint NOT NULL,
  `season_id` bigint DEFAULT NULL,
  `phase` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`error_id`),
  UNIQUE KEY `crs_record_error_unique` (`uuid`),
  KEY `crs_record_error_crs_assignation_section_FK` (`section_id`),
  KEY `crs_record_error_usr_enterprise_FK` (`enterprise_id`),
  KEY `crs_record_error_crs_assignation_season_FK` (`season_id`),
  CONSTRAINT `crs_record_error_crs_assignation_season_FK` FOREIGN KEY (`season_id`) REFERENCES `crs_assignation_season` (`season_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_error_crs_assignation_section_FK` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_error_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_record_setting`
--

DROP TABLE IF EXISTS `crs_record_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_record_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `crs_record_setting_FK_1` (`create_user_id`),
  CONSTRAINT `crs_record_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_record_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_score`
--

DROP TABLE IF EXISTS `crs_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_score` (
  `score_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `section_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`score_id`),
  UNIQUE KEY `crs_score_UN` (`student_id`,`section_id`),
  KEY `crs_score_FK_1` (`section_id`),
  CONSTRAINT `crs_score_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_score_FK_1` FOREIGN KEY (`section_id`) REFERENCES `crs_assignation_section` (`section_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=191995 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_scoring_setting`
--

DROP TABLE IF EXISTS `crs_scoring_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_scoring_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `crs_scoring_setting_FK_1` (`create_user_id`),
  CONSTRAINT `crs_scoring_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `crs_scoring_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `crs_setting`
--

DROP TABLE IF EXISTS `crs_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crs_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `crs_setting_UN` (`enterprise_id`),
  KEY `crs_setting_FK_1` (`create_user_id`),
  CONSTRAINT `crs_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `crs_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_account`
--

DROP TABLE IF EXISTS `ctm_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_account` (
  `relation_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `account_id` bigint NOT NULL,
  PRIMARY KEY (`relation_id`),
  KEY `ctm_account_FK` (`account_id`),
  KEY `ctm_account_FK_1` (`customer_id`),
  CONSTRAINT `ctm_account_FK` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`),
  CONSTRAINT `sctm_account_FK_1` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_account_configuration`
--

DROP TABLE IF EXISTS `ctm_account_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_account_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `ctm_account_configuration_UN_enterprise` (`enterprise_id`),
  KEY `ctm_account_configuration_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_account_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ctm_account_configuration_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_account_movement`
--

DROP TABLE IF EXISTS `ctm_account_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_account_movement` (
  `movement_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `account_id` bigint NOT NULL,
  `paid` decimal(10,2) DEFAULT '0.00',
  `expire_date` date DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'A' COMMENT 'Active (A), Expired (X), Paid (P)',
  PRIMARY KEY (`movement_id`),
  UNIQUE KEY `ctm_movement_UN` (`uuid`),
  KEY `ctm_movement_FK` (`account_id`),
  KEY `ctm_movement_FK_1` (`type_id`),
  KEY `ctm_movement_FK_2` (`create_user_id`),
  CONSTRAINT `ctm_movement_FK` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`),
  CONSTRAINT `ctm_movement_FK_1` FOREIGN KEY (`type_id`) REFERENCES `ctm_account_movement_type` (`type_id`),
  CONSTRAINT `ctm_movement_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_account_movement_type`
--

DROP TABLE IF EXISTS `ctm_account_movement_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_account_movement_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `ctm_movement_type_UN_uuid` (`uuid`),
  UNIQUE KEY `ctm_movement_type_UN_name` (`enterprise_id`,`name`),
  KEY `ctm_movement_type_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_movement_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ctm_movement_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_customer`
--

DROP TABLE IF EXISTS `ctm_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_customer` (
  `customer_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `ctm_customer_FK` (`enterprise_id`),
  KEY `ctm_customer_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_customer_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ctm_customer_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_customer_configuration`
--

DROP TABLE IF EXISTS `ctm_customer_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_customer_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `ctm_configuration_FK` (`enterprise_id`),
  CONSTRAINT `ctm_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_email`
--

DROP TABLE IF EXISTS `ctm_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_email` (
  `email_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`email_id`),
  KEY `ctm_email_FK` (`customer_id`),
  KEY `ctm_email_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_email_FK` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`),
  CONSTRAINT `ctm_email_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_email_configuration`
--

DROP TABLE IF EXISTS `ctm_email_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_email_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `ctm_email_configuration_FK` (`enterprise_id`),
  CONSTRAINT `ctm_email_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_phone`
--

DROP TABLE IF EXISTS `ctm_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_phone` (
  `phone_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`phone_id`),
  KEY `ctm_phone_FK` (`customer_id`),
  KEY `ctm_phone_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_phone_FK` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`),
  CONSTRAINT `ctm_phone_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_phone_configuration`
--

DROP TABLE IF EXISTS `ctm_phone_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_phone_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `ctm_phone_configuration_FK` (`enterprise_id`),
  CONSTRAINT `ctm_phone_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ctm_phone_sms`
--

DROP TABLE IF EXISTS `ctm_phone_sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ctm_phone_sms` (
  `sms_id` bigint NOT NULL AUTO_INCREMENT,
  `phone_id` bigint NOT NULL,
  `send_date` datetime DEFAULT NULL,
  `message` longtext,
  `status_code` varchar(1) DEFAULT 'W' COMMENT 'Waiting (W), Errored (E), Processed (P)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`sms_id`),
  KEY `ctm_phone_sms_FK` (`phone_id`),
  KEY `ctm_phone_sms_FK_1` (`create_user_id`),
  CONSTRAINT `ctm_phone_sms_FK` FOREIGN KEY (`phone_id`) REFERENCES `ctm_phone` (`phone_id`),
  CONSTRAINT `ctm_phone_sms_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `id` int unsigned DEFAULT NULL,
  `document_type_id` int unsigned DEFAULT NULL,
  `student_id` int unsigned DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `path` tinytext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedback_360_survey`
--

DROP TABLE IF EXISTS `feedback_360_survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_360_survey` (
  `feedback_survey_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `survey_template_id` bigint NOT NULL,
  `status_code` varchar(1) NOT NULL DEFAULT 'U' COMMENT 'Unfinished (U), Finished (F), Expired (E)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `tree_id` bigint NOT NULL,
  `response` longtext,
  `response_date` datetime DEFAULT NULL,
  `source_node` longtext,
  `reason` varchar(100) DEFAULT NULL,
  `target_node` longtext,
  `evaluated_user_id` bigint DEFAULT NULL,
  `source_node_id` varchar(100) DEFAULT NULL,
  `target_node_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`feedback_survey_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `feedback_360_survey_FK` (`user_id`),
  KEY `feedback_360_survey_FK_1` (`enterprise_id`),
  KEY `feedback_360_survey_FK_2` (`survey_template_id`),
  KEY `feedback_360_survey_FK_3` (`create_user_id`),
  KEY `feedback_360_survey_FK_4` (`tree_id`),
  KEY `feedback_360_survey_FK_5` (`evaluated_user_id`),
  CONSTRAINT `feedback_360_survey_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_survey_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_survey_FK_2` FOREIGN KEY (`survey_template_id`) REFERENCES `survey_template` (`template_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_survey_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_survey_FK_4` FOREIGN KEY (`tree_id`) REFERENCES `feedback_360_tree` (`tree_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_survey_FK_5` FOREIGN KEY (`evaluated_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedback_360_tree`
--

DROP TABLE IF EXISTS `feedback_360_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_360_tree` (
  `tree_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`tree_id`),
  KEY `feedback_360_tree_FK` (`create_user_id`),
  KEY `feedback_360_tree_FK_1` (`enterprise_id`),
  CONSTRAINT `feedback_360_tree_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `feedback_360_tree_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `felgt_bill`
--

DROP TABLE IF EXISTS `felgt_bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `felgt_bill` (
  `bill_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `template` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `uuid` varchar(50) DEFAULT NULL,
  `receiver_nit` varchar(15) DEFAULT NULL,
  `receiver_email` varchar(60) DEFAULT NULL,
  `receiver_name` varchar(100) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Requesting (R), Emmited (E), Errored (X)',
  `setup` longtext,
  `error` longtext,
  `response_date` datetime DEFAULT NULL,
  PRIMARY KEY (`bill_id`),
  UNIQUE KEY `felgt_bill_UN` (`uuid`),
  KEY `felgt_bill_FK` (`enterprise_id`),
  KEY `felgt_bill_FK_1` (`create_user_id`),
  CONSTRAINT `felgt_bill_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `felgt_bill_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `felgt_emitter`
--

DROP TABLE IF EXISTS `felgt_emitter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `felgt_emitter` (
  `emitter_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `provider` varchar(100) NOT NULL,
  `set_as_default` tinyint(1) DEFAULT NULL,
  `setup` longtext,
  `template` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`emitter_id`),
  UNIQUE KEY `felgt_emitter_UN` (`uuid`),
  KEY `felgt_emitter_FK` (`enterprise_id`),
  KEY `felgt_emitter_FK_1` (`create_user_id`),
  CONSTRAINT `felgt_emitter_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `felgt_emitter_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `felgt_log`
--

DROP TABLE IF EXISTS `felgt_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `felgt_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `bill_id` bigint NOT NULL,
  `operation` varchar(100) NOT NULL,
  `input_data` longtext,
  `output_data` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `felgt_log_FK` (`bill_id`),
  CONSTRAINT `felgt_log_FK` FOREIGN KEY (`bill_id`) REFERENCES `felgt_bill` (`bill_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `felgt_setting`
--

DROP TABLE IF EXISTS `felgt_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `felgt_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `felgt_setting_UN` (`enterprise_id`),
  KEY `felgt_setting_FK_1` (`create_user_id`),
  CONSTRAINT `felgt_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `felgt_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inst_preasig`
--

DROP TABLE IF EXISTS `inst_preasig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inst_preasig` (
  `season_id` int DEFAULT NULL,
  `student_id` bigint DEFAULT NULL,
  `course_id` bigint DEFAULT NULL,
  `create_user_id` bigint DEFAULT '1',
  `uuid` varchar(50) DEFAULT NULL,
  `setup` varchar(50) DEFAULT '{}',
  `branch_id` bigint DEFAULT NULL,
  `career_id` bigint DEFAULT NULL,
  `studying_time_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_closing`
--

DROP TABLE IF EXISTS `inv_closing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_closing` (
  `closing_id` bigint NOT NULL AUTO_INCREMENT,
  `comment` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `closing_date` date DEFAULT NULL,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`closing_id`),
  KEY `inv_closing_FK` (`enterprise_id`),
  KEY `inv_closing_FK_1` (`create_user_id`),
  CONSTRAINT `inv_closing_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `inv_closing_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_closing_input_product_log`
--

DROP TABLE IF EXISTS `inv_closing_input_product_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_closing_input_product_log` (
  `input_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,0) DEFAULT NULL,
  `attributes` longtext,
  `record_id` bigint NOT NULL,
  `provider_id` bigint DEFAULT NULL,
  `closing_id` bigint NOT NULL,
  PRIMARY KEY (`record_id`),
  KEY `inv_closing_input_product_log_FK` (`product_id`),
  KEY `inv_closing_input_product_log_FK_1` (`provider_id`),
  KEY `inv_closing_input_product_log_FK_2` (`closing_id`),
  CONSTRAINT `inv_closing_input_product_log_FK` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `inv_closing_input_product_log_FK_1` FOREIGN KEY (`provider_id`) REFERENCES `pvd_provider` (`provider_id`),
  CONSTRAINT `inv_closing_input_product_log_FK_2` FOREIGN KEY (`closing_id`) REFERENCES `inv_closing` (`closing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_closing_output_product_log`
--

DROP TABLE IF EXISTS `inv_closing_output_product_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_closing_output_product_log` (
  `output_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,0) DEFAULT NULL,
  `attributes` longtext,
  `record_id` bigint NOT NULL,
  `closing_id` bigint NOT NULL,
  PRIMARY KEY (`record_id`),
  KEY `inv_closing_output_product_log_FK` (`closing_id`),
  KEY `inv_closing_output_product_log_FK_1` (`product_id`),
  KEY `inv_closing_output_product_log_FK_2` (`output_id`),
  CONSTRAINT `inv_closing_output_product_log_FK` FOREIGN KEY (`closing_id`) REFERENCES `inv_closing` (`closing_id`),
  CONSTRAINT `inv_closing_output_product_log_FK_1` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `inv_closing_output_product_log_FK_2` FOREIGN KEY (`output_id`) REFERENCES `inv_output` (`output_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_closing_product`
--

DROP TABLE IF EXISTS `inv_closing_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_closing_product` (
  `product_id` bigint NOT NULL,
  `input_sum` decimal(10,0) DEFAULT NULL,
  `output_sum` decimal(10,0) DEFAULT NULL,
  `on_hand` decimal(10,0) DEFAULT NULL,
  `closing_id` bigint DEFAULT NULL,
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`record_id`),
  KEY `inv_closing_product_FK` (`closing_id`),
  KEY `inv_closing_product_FK_1` (`product_id`),
  CONSTRAINT `inv_closing_product_FK` FOREIGN KEY (`closing_id`) REFERENCES `inv_closing` (`closing_id`),
  CONSTRAINT `inv_closing_product_FK_1` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50409 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_configuration`
--

DROP TABLE IF EXISTS `inv_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `inv_configuration_FK` (`enterprise_id`),
  CONSTRAINT `inv_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_distribution`
--

DROP TABLE IF EXISTS `inv_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_distribution` (
  `distribution_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  PRIMARY KEY (`distribution_id`),
  KEY `inv_distribution_FK` (`enterprise_id`),
  CONSTRAINT `inv_distribution_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_distribution_configuration`
--

DROP TABLE IF EXISTS `inv_distribution_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_distribution_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `inv_distribution_configuration_FK` (`enterprise_id`),
  CONSTRAINT `inv_distribution_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_input`
--

DROP TABLE IF EXISTS `inv_input`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_input` (
  `input_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `reason_uuid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributes` longtext,
  `images` longtext,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  PRIMARY KEY (`input_id`),
  KEY `inv_input_FK` (`enterprise_id`),
  KEY `inv_input_FK_1` (`create_user_id`),
  CONSTRAINT `inv_input_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `inv_input_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_input_product`
--

DROP TABLE IF EXISTS `inv_input_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_input_product` (
  `input_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,0) DEFAULT NULL,
  `attributes` longtext,
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `provider_id` bigint DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  KEY `inv_input_product_FK` (`input_id`),
  KEY `inv_input_product_FK_1` (`product_id`),
  KEY `inv_input_product_FK_2` (`provider_id`),
  CONSTRAINT `inv_input_product_FK` FOREIGN KEY (`input_id`) REFERENCES `inv_input` (`input_id`),
  CONSTRAINT `inv_input_product_FK_1` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `inv_input_product_FK_2` FOREIGN KEY (`provider_id`) REFERENCES `pvd_provider` (`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_location`
--

DROP TABLE IF EXISTS `inv_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_location` (
  `location_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `inv_location_UN` (`enterprise_id`,`name`),
  KEY `inv_location_FK_1` (`create_user_id`),
  CONSTRAINT `inv_location_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `inv_location_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_output`
--

DROP TABLE IF EXISTS `inv_output`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_output` (
  `output_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `reason_uuid` varchar(50) NOT NULL,
  `attributes` longtext,
  `images` longtext,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  PRIMARY KEY (`output_id`),
  KEY `inv_output_FK` (`enterprise_id`),
  KEY `inv_output_FK_1` (`create_user_id`),
  CONSTRAINT `inv_output_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `inv_output_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_output_product`
--

DROP TABLE IF EXISTS `inv_output_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inv_output_product` (
  `output_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,0) DEFAULT NULL,
  `attributes` longtext,
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`record_id`),
  KEY `inv_output_product_FK` (`output_id`),
  KEY `inv_output_product_FK_1` (`product_id`),
  CONSTRAINT `inv_output_product_FK` FOREIGN KEY (`output_id`) REFERENCES `inv_output` (`output_id`),
  CONSTRAINT `inv_output_product_FK_1` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=271 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_ticket_setting`
--

DROP TABLE IF EXISTS `log_ticket_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_ticket_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `log_ticket_setting_unique` (`enterprise_id`),
  KEY `log_ticket_setting_usr_user_FK` (`create_user_id`),
  CONSTRAINT `log_ticket_setting_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `log_ticket_setting_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mmg_instance`
--

DROP TABLE IF EXISTS `mmg_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mmg_instance` (
  `instance_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `host` varchar(100) NOT NULL,
  `database_name` varchar(100) NOT NULL,
  `database_user` varchar(100) NOT NULL,
  `database_password` varchar(100) NOT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`instance_id`),
  UNIQUE KEY `mmg_instance_UN` (`name`),
  KEY `mmg_instance_FK` (`create_user_id`),
  CONSTRAINT `mmg_instance_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COMMENT='Modul instance manager';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_area`
--

DROP TABLE IF EXISTS `multimoney_staff_area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_area` (
  `area_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`area_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_area_FK` (`enterprise_id`),
  KEY `multimoney_staff_area_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_area_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_area_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_country`
--

DROP TABLE IF EXISTS `multimoney_staff_country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_country` (
  `country_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_country_FK` (`enterprise_id`),
  KEY `multimoney_staff_country_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_country_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_country_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_grouper`
--

DROP TABLE IF EXISTS `multimoney_staff_grouper`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_grouper` (
  `grouper_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`grouper_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_grouper_FK` (`enterprise_id`),
  KEY `multimoney_staff_grouper_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_grouper_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_grouper_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_job_position`
--

DROP TABLE IF EXISTS `multimoney_staff_job_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_job_position` (
  `job_position_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`job_position_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_job_position_FK` (`enterprise_id`),
  KEY `multimoney_staff_job_position_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_job_position_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_job_position_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_organization`
--

DROP TABLE IF EXISTS `multimoney_staff_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_organization` (
  `organization_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`organization_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_organization_FK` (`enterprise_id`),
  KEY `multimoney_staff_organization_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_organization_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_organization_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_staff`
--

DROP TABLE IF EXISTS `multimoney_staff_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_staff` (
  `staff_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  `id_number` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) NOT NULL,
  `second_name` varchar(50) DEFAULT NULL,
  `surname` varchar(50) NOT NULL,
  `second_surname` varchar(50) DEFAULT NULL,
  `ucontact_user` varchar(50) DEFAULT NULL,
  `soc_user` varchar(50) DEFAULT NULL,
  `core_sys_user` varchar(50) DEFAULT NULL,
  `printing_user` varchar(50) DEFAULT NULL,
  `status_id` bigint DEFAULT NULL,
  `country_id` bigint DEFAULT NULL,
  `area_id` bigint DEFAULT NULL,
  `job_position_id` bigint DEFAULT NULL,
  `team_id` bigint DEFAULT NULL,
  `grouper_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_staff_FK` (`enterprise_id`),
  KEY `multimoney_staff_staff_FK_1` (`user_id`),
  KEY `multimoney_staff_staff_FK_2` (`status_id`),
  KEY `multimoney_staff_staff_FK_3` (`area_id`),
  KEY `multimoney_staff_staff_FK_4` (`country_id`),
  KEY `multimoney_staff_staff_FK_5` (`grouper_id`),
  KEY `multimoney_staff_staff_FK_6` (`job_position_id`),
  KEY `multimoney_staff_staff_FK_7` (`create_user_id`),
  CONSTRAINT `multimoney_staff_staff_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_1` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_2` FOREIGN KEY (`status_id`) REFERENCES `multimoney_staff_status` (`status_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_3` FOREIGN KEY (`area_id`) REFERENCES `multimoney_staff_area` (`area_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_4` FOREIGN KEY (`country_id`) REFERENCES `multimoney_staff_country` (`country_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_5` FOREIGN KEY (`grouper_id`) REFERENCES `multimoney_staff_grouper` (`grouper_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_6` FOREIGN KEY (`job_position_id`) REFERENCES `multimoney_staff_job_position` (`job_position_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_staff_FK_7` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_status`
--

DROP TABLE IF EXISTS `multimoney_staff_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_status` (
  `status_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_status_FK` (`enterprise_id`),
  KEY `multimoney_staff_status_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_status_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_status_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `multimoney_staff_team`
--

DROP TABLE IF EXISTS `multimoney_staff_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multimoney_staff_team` (
  `team_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `multimoney_staff_team_FK` (`enterprise_id`),
  KEY `multimoney_staff_team_FK_1` (`create_user_id`),
  CONSTRAINT `multimoney_staff_team_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `multimoney_staff_team_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_automate_task`
--

DROP TABLE IF EXISTS `ngn_automate_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_automate_task` (
  `automate_task_id` bigint NOT NULL AUTO_INCREMENT,
  `interaction_id` bigint NOT NULL,
  `instance_id` bigint NOT NULL,
  `setup` longtext,
  `payload_in` longtext,
  `payload_out` longtext,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Waiting (W), Executed (X), Finished (F), Errored (E), Running (R)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) DEFAULT NULL,
  `outcome` varchar(100) DEFAULT NULL,
  `execution_result` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `executed_at` datetime DEFAULT NULL,
  `running_command` text,
  PRIMARY KEY (`automate_task_id`),
  KEY `ngn_automate_task_FK` (`interaction_id`),
  KEY `ngn_automate_task_FK_1` (`instance_id`),
  CONSTRAINT `ngn_automate_task_FK` FOREIGN KEY (`interaction_id`) REFERENCES `ngn_interaction` (`interaction_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_automate_task_FK_1` FOREIGN KEY (`instance_id`) REFERENCES `ngn_instance` (`instance_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_automate_task_queue`
--

DROP TABLE IF EXISTS `ngn_automate_task_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_automate_task_queue` (
  `queue_id` bigint NOT NULL AUTO_INCREMENT,
  `execute_info` text,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status_code` varchar(1) DEFAULT 'W' COMMENT 'Waiting (W), Ejecuted (X), Errored (E)',
  `execution_result` longtext,
  `end_execution_date` datetime DEFAULT NULL,
  `running_status_code` varchar(1) DEFAULT NULL COMMENT 'Running (R), Finished (F), Errored (E)',
  `start_execution_date` datetime DEFAULT NULL,
  PRIMARY KEY (`queue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_automate_task_timer`
--

DROP TABLE IF EXISTS `ngn_automate_task_timer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_automate_task_timer` (
  `timer_id` bigint NOT NULL AUTO_INCREMENT,
  `automate_task_id` bigint NOT NULL,
  `component` longtext,
  `deadline` datetime NOT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'P' COMMENT 'Pending (P), Running (R), Triggered (T), Dismissed (D)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`timer_id`),
  KEY `ngn_automate_task_timer_FK` (`automate_task_id`),
  CONSTRAINT `ngn_automate_task_timer_FK` FOREIGN KEY (`automate_task_id`) REFERENCES `ngn_automate_task` (`automate_task_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_conversation`
--

DROP TABLE IF EXISTS `ngn_conversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_conversation` (
  `conversation_id` bigint NOT NULL AUTO_INCREMENT,
  `source_instance_id` bigint NOT NULL,
  `target_instance_id` bigint NOT NULL,
  `source_interaction_id` bigint NOT NULL,
  `payload_in` longtext,
  `payload_out` longtext,
  `status_code` varchar(1) DEFAULT 'S' COMMENT 'Started (S), Finished (F)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `response_date` datetime DEFAULT NULL,
  `response_interaction_id` bigint DEFAULT NULL,
  PRIMARY KEY (`conversation_id`),
  KEY `ngn_conversation_FK` (`source_instance_id`),
  KEY `ngn_conversation_FK_1` (`target_instance_id`),
  KEY `ngn_conversation_FK_2` (`source_interaction_id`),
  KEY `ngn_conversation_FK_4` (`response_interaction_id`),
  CONSTRAINT `ngn_conversation_FK` FOREIGN KEY (`source_instance_id`) REFERENCES `ngn_instance` (`instance_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_conversation_FK_1` FOREIGN KEY (`target_instance_id`) REFERENCES `ngn_instance` (`instance_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_conversation_FK_2` FOREIGN KEY (`source_interaction_id`) REFERENCES `ngn_interaction` (`interaction_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_conversation_FK_4` FOREIGN KEY (`response_interaction_id`) REFERENCES `ngn_interaction` (`interaction_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_database`
--

DROP TABLE IF EXISTS `ngn_database`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_database` (
  `database_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`database_id`),
  KEY `ngn_database_FK` (`create_user_id`),
  KEY `ngn_database_FK_1` (`enterprise_id`),
  CONSTRAINT `ngn_database_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `ngn_database_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_datasource`
--

DROP TABLE IF EXISTS `ngn_datasource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_datasource` (
  `data_source_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `setup` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `table_name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`data_source_id`),
  UNIQUE KEY `ngn_datasource_UN` (`enterprise_id`,`name`),
  KEY `ngn_datasource_FK_1` (`create_user_id`),
  CONSTRAINT `ngn_datasource_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ngn_datasource_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_datasource_suscription`
--

DROP TABLE IF EXISTS `ngn_datasource_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_datasource_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `data_source_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `ngn_datasource_suscription_UN` (`role_id`,`data_source_id`),
  KEY `ngn_datasource_suscription_FK_1` (`data_source_id`),
  KEY `ngn_datasource_suscription_FK_2` (`create_user_id`),
  CONSTRAINT `ngn_datasource_suscription_FK` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`),
  CONSTRAINT `ngn_datasource_suscription_FK_1` FOREIGN KEY (`data_source_id`) REFERENCES `ngn_datasource` (`data_source_id`),
  CONSTRAINT `ngn_datasource_suscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_deployment`
--

DROP TABLE IF EXISTS `ngn_deployment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_deployment` (
  `deployment_id` bigint NOT NULL AUTO_INCREMENT,
  `partition_id` bigint NOT NULL,
  `version` varchar(10) DEFAULT NULL,
  `set_default` tinyint(1) DEFAULT NULL,
  `setup` longtext NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `enterprise_id` bigint NOT NULL,
  `environment` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`deployment_id`),
  KEY `ngn_deployment_FK` (`partition_id`),
  KEY `ngn_deployment_FK_1` (`create_user_id`),
  KEY `ngn_deployment_FK_2` (`enterprise_id`),
  CONSTRAINT `ngn_deployment_FK` FOREIGN KEY (`partition_id`) REFERENCES `ngn_partition` (`partition_id`),
  CONSTRAINT `ngn_deployment_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `ngn_deployment_FK_2` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=267 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_ds_999332b9_e76e_4539_aab3_ca44d0ec128a`
--

DROP TABLE IF EXISTS `ngn_ds_999332b9_e76e_4539_aab3_ca44d0ec128a`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_ds_999332b9_e76e_4539_aab3_ca44d0ec128a` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `instance_id` bigint NOT NULL,
  `reference_component` varchar(255) DEFAULT NULL,
  `Nuevo_campo` varchar(255) DEFAULT NULL,
  `Nuevo_campo2` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_enrollment`
--

DROP TABLE IF EXISTS `ngn_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_enrollment` (
  `enrollment_id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `ngn_enrollment_UN` (`role_id`,`user_id`),
  KEY `ngn_enrollment_FK_1` (`user_id`),
  KEY `ngn_enrollment_FK_2` (`create_user_id`),
  CONSTRAINT `ngn_enrollment_FK` FOREIGN KEY (`role_id`) REFERENCES `ngn_role` (`role_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_enrollment_FK_1` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `ngn_enrollment_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_human_task_compose`
--

DROP TABLE IF EXISTS `ngn_human_task_compose`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_human_task_compose` (
  `project_uuid` varchar(100) NOT NULL,
  `human_task_uuid` varchar(100) NOT NULL,
  `setup` longtext NOT NULL,
  PRIMARY KEY (`project_uuid`,`human_task_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_instance`
--

DROP TABLE IF EXISTS `ngn_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_instance` (
  `instance_id` bigint NOT NULL AUTO_INCREMENT,
  `process_id` bigint NOT NULL,
  `payload` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `last_update_date` datetime DEFAULT NULL,
  `process_definitions` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `last_interaction_id` bigint DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'C' COMMENT 'Created (C), Running (R), Waiting (W), Errored (E)',
  PRIMARY KEY (`instance_id`),
  KEY `ngn_instance_FK_1` (`create_user_id`),
  KEY `ngn_instance_FK` (`process_id`),
  KEY `ngn_instance_FK_2` (`last_interaction_id`),
  CONSTRAINT `ngn_instance_FK` FOREIGN KEY (`process_id`) REFERENCES `ngn_process` (`process_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_instance_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=654 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_instance_error`
--

DROP TABLE IF EXISTS `ngn_instance_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_instance_error` (
  `error_id` bigint NOT NULL AUTO_INCREMENT,
  `instance_id` bigint NOT NULL,
  `interaction_id` bigint NOT NULL,
  `error` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`error_id`),
  KEY `ngn_instance_error_FK` (`interaction_id`),
  KEY `ngn_instance_error_FK_1` (`instance_id`),
  CONSTRAINT `ngn_instance_error_FK` FOREIGN KEY (`interaction_id`) REFERENCES `ngn_interaction` (`interaction_id`),
  CONSTRAINT `ngn_instance_error_FK_1` FOREIGN KEY (`instance_id`) REFERENCES `ngn_instance` (`instance_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_interaction`
--

DROP TABLE IF EXISTS `ngn_interaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_interaction` (
  `interaction_id` bigint NOT NULL AUTO_INCREMENT,
  `instance_id` bigint NOT NULL,
  `component` longtext,
  `payload_in` longtext,
  `payload_out` longtext,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Waiting (W), Done (D), Errored (E), Cancelled (C)',
  `component_name` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `finished_date` datetime DEFAULT NULL,
  `preceding_interaction_id` bigint DEFAULT NULL,
  `component_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`interaction_id`),
  KEY `ngn_interaction_FK` (`instance_id`),
  KEY `ngn_interaction_FK_1` (`preceding_interaction_id`),
  CONSTRAINT `ngn_interaction_FK` FOREIGN KEY (`instance_id`) REFERENCES `ngn_instance` (`instance_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3119 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_monitor`
--

DROP TABLE IF EXISTS `ngn_monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_monitor` (
  `monitor_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `process_key` varchar(100) NOT NULL,
  `setup` longtext,
  `create_user_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`monitor_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `ngn_monitor_FK` (`create_user_id`),
  KEY `ngn_monitor_FK_1` (`enterprise_id`),
  CONSTRAINT `ngn_monitor_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ngn_monitor_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_partition`
--

DROP TABLE IF EXISTS `ngn_partition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_partition` (
  `partition_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`partition_id`),
  KEY `ngn_partition_FK` (`enterprise_id`),
  KEY `ngn_partition_FK_2` (`create_user_id`),
  CONSTRAINT `ngn_partition_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ngn_partition_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_process`
--

DROP TABLE IF EXISTS `ngn_process`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_process` (
  `process_id` bigint NOT NULL AUTO_INCREMENT,
  `deployment_id` bigint NOT NULL,
  `setup` longtext NOT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `source_process_uuid` varchar(50) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `partition_id` bigint NOT NULL,
  `public_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`process_id`),
  KEY `ngn_process_FK` (`deployment_id`),
  CONSTRAINT `ngn_process_FK` FOREIGN KEY (`deployment_id`) REFERENCES `ngn_deployment` (`deployment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=357 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_project`
--

DROP TABLE IF EXISTS `ngn_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_project` (
  `project_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `setup` longtext,
  PRIMARY KEY (`project_id`),
  KEY `ngn_project_FK` (`enterprise_id`),
  KEY `ngn_project_FK_1` (`create_user_id`),
  CONSTRAINT `ngn_project_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ngn_project_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_project_snapshot`
--

DROP TABLE IF EXISTS `ngn_project_snapshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_project_snapshot` (
  `snapshot_id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `setup` longtext,
  `snapshot_comment` mediumtext,
  PRIMARY KEY (`snapshot_id`),
  KEY `ngn_project_snapshot_FK` (`project_id`),
  KEY `ngn_project_snapshot_FK_1` (`create_user_id`),
  CONSTRAINT `ngn_project_snapshot_FK` FOREIGN KEY (`project_id`) REFERENCES `ngn_project` (`project_id`),
  CONSTRAINT `ngn_project_snapshot_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_report`
--

DROP TABLE IF EXISTS `ngn_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_report` (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `project` varchar(100) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `ngn_report_UN` (`uuid`),
  KEY `ngn_report_FK` (`enterprise_id`),
  KEY `ngn_report_FK_1` (`create_user_id`),
  CONSTRAINT `ngn_report_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `ngn_report_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_report_suscription`
--

DROP TABLE IF EXISTS `ngn_report_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_report_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `report_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `ngn_report_suscription_UN` (`uuid`),
  KEY `ngn_report_suscription_FK` (`report_id`),
  KEY `ngn_report_suscription_FK_1` (`role_id`),
  KEY `ngn_report_suscription_FK_2` (`create_user_id`),
  CONSTRAINT `ngn_report_suscription_FK` FOREIGN KEY (`report_id`) REFERENCES `ngn_report` (`report_id`),
  CONSTRAINT `ngn_report_suscription_FK_1` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`),
  CONSTRAINT `ngn_report_suscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_role`
--

DROP TABLE IF EXISTS `ngn_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `process_id` bigint NOT NULL,
  `bpmn_id` varchar(50) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  KEY `ngn_role__FK` (`process_id`),
  CONSTRAINT `ngn_role__FK` FOREIGN KEY (`process_id`) REFERENCES `ngn_process` (`process_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=629 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_role_interaction`
--

DROP TABLE IF EXISTS `ngn_role_interaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_role_interaction` (
  `interaction_id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `bpmn_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`interaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2015 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_user_task`
--

DROP TABLE IF EXISTS `ngn_user_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_user_task` (
  `user_task_id` bigint NOT NULL AUTO_INCREMENT,
  `interaction_id` bigint NOT NULL,
  `instance_id` bigint NOT NULL,
  `setup` longtext,
  `payload_in` longtext,
  `payload_out` longtext,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'W' COMMENT 'Waiting (W), Finished (F), Taken (T), Expired (E), Interrupted (I)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) DEFAULT NULL,
  `title` varchar(250) DEFAULT NULL,
  `priority` smallint DEFAULT NULL,
  `outcome` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`user_task_id`),
  KEY `ngn_user_task_FK` (`interaction_id`),
  KEY `ngn_user_task_FK_1` (`instance_id`),
  CONSTRAINT `ngn_user_task_FK` FOREIGN KEY (`interaction_id`) REFERENCES `ngn_interaction` (`interaction_id`) ON DELETE CASCADE,
  CONSTRAINT `ngn_user_task_FK_1` FOREIGN KEY (`instance_id`) REFERENCES `ngn_instance` (`instance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=486 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ngn_user_task_timer`
--

DROP TABLE IF EXISTS `ngn_user_task_timer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ngn_user_task_timer` (
  `timer_id` bigint NOT NULL AUTO_INCREMENT,
  `user_task_id` bigint NOT NULL,
  `component` longtext,
  `deadline` datetime NOT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'P' COMMENT 'Pending (P), Running (R), Triggered (T), Dismissed (D)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`timer_id`),
  KEY `ngn_user_task_timer_FK` (`user_task_id`),
  CONSTRAINT `ngn_user_task_timer_FK` FOREIGN KEY (`user_task_id`) REFERENCES `ngn_user_task` (`user_task_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COMMENT='	';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_brand`
--

DROP TABLE IF EXISTS `nvb_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_brand` (
  `brand_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`brand_id`),
  UNIQUE KEY `brand_id` (`brand_id`),
  KEY `nvb_brand_FK_1` (`create_user_id`),
  KEY `nvb_brand_FK_2` (`enterprise_id`),
  CONSTRAINT `nvb_brand_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_brand_FK_2` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_bundle`
--

DROP TABLE IF EXISTS `nvb_bundle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_bundle` (
  `bundle_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`bundle_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`),
  KEY `nvb_bundle_FK_1` (`create_user_id`),
  KEY `nvb_bundle_FK_2` (`enterprise_id`),
  CONSTRAINT `nvb_bundle_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_FK_2` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_bundle_code`
--

DROP TABLE IF EXISTS `nvb_bundle_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_bundle_code` (
  `code_id` bigint NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint NOT NULL,
  `code` varchar(100) NOT NULL,
  `comment` varchar(100) DEFAULT NULL,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Available (A), Taken (T), Closed (C)',
  `taken_by_send_id` bigint DEFAULT NULL,
  `taken_by_request_id` bigint DEFAULT NULL,
  PRIMARY KEY (`code_id`),
  UNIQUE KEY `nvb_bundle_code_UN` (`code`,`bundle_id`),
  KEY `nvb_bundle_code_FK` (`bundle_id`),
  KEY `nvb_bundle_code_FK_1` (`create_user_id`),
  KEY `nvb_bundle_code_FK_2` (`taken_by_send_id`),
  KEY `nvb_bundle_code_FK_3` (`taken_by_request_id`),
  CONSTRAINT `nvb_bundle_code_FK` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_code_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_code_FK_2` FOREIGN KEY (`taken_by_send_id`) REFERENCES `nvb_store_code_send` (`send_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_code_FK_3` FOREIGN KEY (`taken_by_request_id`) REFERENCES `nvb_code_request` (`request_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_bundle_graphic_card`
--

DROP TABLE IF EXISTS `nvb_bundle_graphic_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_bundle_graphic_card` (
  `assignation_id` bigint NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint NOT NULL,
  `graphic_card_id` bigint NOT NULL,
  PRIMARY KEY (`assignation_id`),
  KEY `nvb_bundle_graphic_card_FK` (`graphic_card_id`),
  KEY `nvb_bundle_graphic_card_FK_1` (`bundle_id`),
  CONSTRAINT `nvb_bundle_graphic_card_FK` FOREIGN KEY (`graphic_card_id`) REFERENCES `nvb_graphic_card` (`graphic_card_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_graphic_card_FK_1` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_bundle_request`
--

DROP TABLE IF EXISTS `nvb_bundle_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_bundle_request` (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `status_code` varchar(1) DEFAULT 'R' COMMENT 'Requested (R), Returned (T), Approved (A), Denied (D)',
  `store_id` bigint NOT NULL,
  `result` longtext,
  `message_status` varchar(1) DEFAULT 'U' COMMENT 'Unsent (U), Sent to approval (S)',
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `nvb_bundle_request_FK` (`store_id`),
  KEY `nvb_bundle_request_FK_1` (`bundle_id`),
  KEY `nvb_bundle_request_FK_3` (`create_user_id`),
  CONSTRAINT `nvb_bundle_request_FK` FOREIGN KEY (`store_id`) REFERENCES `nvb_store` (`store_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_request_FK_1` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_request_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_bundle_store`
--

DROP TABLE IF EXISTS `nvb_bundle_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_bundle_store` (
  `assignation_id` bigint NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint NOT NULL,
  `store_id` bigint NOT NULL,
  PRIMARY KEY (`assignation_id`),
  KEY `nvb_bundle_store_FK` (`store_id`),
  KEY `nvb_bundle_store_FK_1` (`bundle_id`),
  CONSTRAINT `nvb_bundle_store_FK` FOREIGN KEY (`store_id`) REFERENCES `nvb_store` (`store_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_bundle_store_FK_1` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_code_change`
--

DROP TABLE IF EXISTS `nvb_code_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_code_change` (
  `change_id` bigint NOT NULL AUTO_INCREMENT,
  `source_code_id` bigint NOT NULL,
  `target_code_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `image` longtext,
  PRIMARY KEY (`change_id`),
  KEY `nvb_code_change_FK` (`source_code_id`),
  KEY `nvb_code_change_FK_1` (`target_code_id`),
  KEY `nvb_code_change_FK_2` (`create_user_id`),
  CONSTRAINT `nvb_code_change_FK` FOREIGN KEY (`source_code_id`) REFERENCES `nvb_code_request` (`request_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_change_FK_1` FOREIGN KEY (`target_code_id`) REFERENCES `nvb_code_request` (`request_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_change_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_code_request`
--

DROP TABLE IF EXISTS `nvb_code_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_code_request` (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `bundle_id` bigint NOT NULL,
  `graphic_card_id` bigint NOT NULL,
  `brand_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `status_code` varchar(1) DEFAULT 'R' COMMENT 'Registered (R), Sent (S), Errored (X), Delivered to store (D)',
  `send_response` mediumtext,
  `store_id` bigint DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `nvb_code_request_FK` (`brand_id`),
  KEY `nvb_code_request_FK_1` (`bundle_id`),
  KEY `nvb_code_request_FK_2` (`graphic_card_id`),
  KEY `nvb_code_request_FK_3` (`create_user_id`),
  KEY `nvb_code_request_FK_4` (`store_id`),
  CONSTRAINT `nvb_code_request_FK` FOREIGN KEY (`brand_id`) REFERENCES `nvb_brand` (`brand_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_request_FK_1` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_request_FK_2` FOREIGN KEY (`graphic_card_id`) REFERENCES `nvb_graphic_card` (`graphic_card_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_request_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_code_request_FK_4` FOREIGN KEY (`store_id`) REFERENCES `nvb_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_exchange`
--

DROP TABLE IF EXISTS `nvb_exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_exchange` (
  `exchange_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status_code` varchar(1) DEFAULT 'R' COMMENT 'Requested (R), Approved (A), Denied (D), Deleted (X)',
  `message_status` varchar(1) DEFAULT 'U' COMMENT 'Unsent (U), Sent (S)',
  `result` text,
  PRIMARY KEY (`exchange_id`),
  KEY `nvb_exchange_FK` (`store_id`),
  CONSTRAINT `nvb_exchange_FK` FOREIGN KEY (`store_id`) REFERENCES `nvb_store` (`store_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_exchange_setting`
--

DROP TABLE IF EXISTS `nvb_exchange_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_exchange_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `nvb_exchange_setting_FK_1` (`create_user_id`),
  CONSTRAINT `nvb_exchange_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_exchange_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_graphic_card`
--

DROP TABLE IF EXISTS `nvb_graphic_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_graphic_card` (
  `graphic_card_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`graphic_card_id`),
  UNIQUE KEY `graphic_card_id` (`graphic_card_id`),
  KEY `nvb_graphic_card_FK_1` (`create_user_id`),
  KEY `nvb_graphic_card_FK_2` (`enterprise_id`),
  CONSTRAINT `nvb_graphic_card_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_graphic_card_FK_2` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_nvidia_setting`
--

DROP TABLE IF EXISTS `nvb_nvidia_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_nvidia_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `nvb_nvidia_setting_FK_1` (`create_user_id`),
  CONSTRAINT `nvb_nvidia_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_nvidia_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_setup`
--

DROP TABLE IF EXISTS `nvb_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_setup` (
  `setup_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setup_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `nvb_setup_FK_1` (`create_user_id`),
  CONSTRAINT `nvb_setup_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_setup_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_store`
--

DROP TABLE IF EXISTS `nvb_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_store` (
  `store_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`store_id`),
  UNIQUE KEY `store_id` (`store_id`),
  KEY `nvb_store_FK_1` (`create_user_id`),
  KEY `nvb_store_FK_2` (`enterprise_id`),
  CONSTRAINT `nvb_store_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_store_FK_2` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_store_code_send`
--

DROP TABLE IF EXISTS `nvb_store_code_send`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_store_code_send` (
  `send_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` bigint NOT NULL,
  `bundle_id` bigint NOT NULL,
  `quantity` smallint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`send_id`),
  KEY `nvb_store_code_send_FK` (`bundle_id`),
  KEY `nvb_store_code_send_FK_1` (`store_id`),
  KEY `nvb_store_code_send_FK_2` (`create_user_id`),
  CONSTRAINT `nvb_store_code_send_FK` FOREIGN KEY (`bundle_id`) REFERENCES `nvb_bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_store_code_send_FK_1` FOREIGN KEY (`store_id`) REFERENCES `nvb_store` (`store_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `nvb_store_code_send_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nvb_store_setting`
--

DROP TABLE IF EXISTS `nvb_store_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nvb_store_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `nvb_store_setting_FK_1` (`create_user_id`),
  CONSTRAINT `nvb_store_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `nvb_store_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `onf_setting`
--

DROP TABLE IF EXISTS `onf_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `onf_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `onf_setting_UN` (`enterprise_id`),
  KEY `onf_setting_FK_1` (`create_user_id`),
  CONSTRAINT `onf_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `onf_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `onf_verification`
--

DROP TABLE IF EXISTS `onf_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `onf_verification` (
  `verification_id` bigint NOT NULL AUTO_INCREMENT,
  `applicant_id` varchar(100) NOT NULL,
  `applicant` longtext NOT NULL,
  `plugin_init_data` longtext,
  `token` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `source` varchar(100) DEFAULT NULL COMMENT 'Verification source. Ex: robocredit, customer, etc..',
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'N' COMMENT 'New (N), Waiting for checks (W), Processed (P)',
  `uuid` varchar(100) NOT NULL,
  `reports` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `check_request_response` longtext,
  `check_result` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `check_status_result` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `media` longtext,
  `enterprise_id` bigint NOT NULL,
  `check_result_detail` longtext,
  PRIMARY KEY (`verification_id`),
  UNIQUE KEY `onf_verification_UN` (`uuid`),
  KEY `onf_verification_FK` (`enterprise_id`),
  CONSTRAINT `onf_verification_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_taking_item`
--

DROP TABLE IF EXISTS `order_taking_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_taking_item` (
  `item_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,0) NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `order_taking_item_UN` (`uuid`),
  KEY `order_taking_item_FK_1` (`product_id`),
  KEY `order_taking_item_FK_2` (`create_user_id`),
  KEY `order_taking_item_FK` (`order_id`),
  CONSTRAINT `order_taking_item_FK` FOREIGN KEY (`order_id`) REFERENCES `order_taking_order` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `order_taking_item_FK_1` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `order_taking_item_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_taking_order`
--

DROP TABLE IF EXISTS `order_taking_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_taking_order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `stablishment` varchar(100) NOT NULL,
  `comment` varchar(250) DEFAULT NULL,
  `advance_payment` decimal(10,2) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `total` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `order_taking_order_UN` (`uuid`),
  KEY `order_taking_order_FK` (`enterprise_id`),
  KEY `order_taking_order_FK_1` (`create_user_id`),
  CONSTRAINT `order_taking_order_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `order_taking_order_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_taking_payment`
--

DROP TABLE IF EXISTS `order_taking_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_taking_payment` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `payment_method_id` bigint NOT NULL,
  `payment_date` date DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `order_id` bigint NOT NULL,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `order_taking_payment_UN` (`uuid`),
  KEY `order_taking_payment_FK` (`order_id`),
  KEY `order_taking_payment_FK_1` (`create_user_id`),
  KEY `order_taking_payment_FK_2` (`payment_method_id`),
  CONSTRAINT `order_taking_payment_FK` FOREIGN KEY (`order_id`) REFERENCES `order_taking_order` (`order_id`),
  CONSTRAINT `order_taking_payment_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `order_taking_payment_FK_2` FOREIGN KEY (`payment_method_id`) REFERENCES `order_taking_payment_method` (`payment_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_taking_payment_method`
--

DROP TABLE IF EXISTS `order_taking_payment_method`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_taking_payment_method` (
  `payment_method_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`payment_method_id`),
  UNIQUE KEY `order_taking_payment_type_UN` (`uuid`),
  KEY `order_taking_payment_type_FK` (`enterprise_id`),
  KEY `order_taking_payment_type_FK_1` (`create_user_id`),
  CONSTRAINT `order_taking_payment_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `order_taking_payment_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_taking_setting`
--

DROP TABLE IF EXISTS `order_taking_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_taking_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `order_taking_setting_UN` (`enterprise_id`),
  KEY `order_taking_setting_FK_1` (`create_user_id`),
  CONSTRAINT `order_taking_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `order_taking_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `org_chart`
--

DROP TABLE IF EXISTS `org_chart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `org_chart` (
  `chart_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chart_id`),
  KEY `org_chart_FK` (`create_user_id`),
  KEY `org_chart_FK_1` (`enterprise_id`),
  CONSTRAINT `org_chart_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `org_chart_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `out_message`
--

DROP TABLE IF EXISTS `out_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `out_message` (
  `message_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `programmed_send_date` datetime DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'U' COMMENT 'Unsent (U), Sent (S), Errored (E)',
  `send_result` longtext,
  PRIMARY KEY (`message_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `out_message_FK` (`enterprise_id`),
  KEY `out_message_FK_1` (`template_id`),
  KEY `out_message_FK_2` (`create_user_id`),
  CONSTRAINT `out_message_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `out_message_FK_1` FOREIGN KEY (`template_id`) REFERENCES `out_template` (`template_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `out_message_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=36513 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `out_provider`
--

DROP TABLE IF EXISTS `out_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `out_provider` (
  `provider_id` bigint NOT NULL AUTO_INCREMENT,
  `library` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`provider_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `out_provider_FK` (`enterprise_id`),
  KEY `out_provider_FK_1` (`create_user_id`),
  CONSTRAINT `out_provider_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `out_provider_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `out_template`
--

DROP TABLE IF EXISTS `out_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `out_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `provider_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `out_template_FK` (`enterprise_id`),
  KEY `out_template_FK_1` (`create_user_id`),
  KEY `out_template_FK_2` (`provider_id`),
  CONSTRAINT `out_template_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `out_template_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `out_template_FK_2` FOREIGN KEY (`provider_id`) REFERENCES `out_provider` (`provider_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_transaction`
--

DROP TABLE IF EXISTS `payment_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_transaction` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `payment_id` int unsigned NOT NULL,
  `transaction_id` int unsigned NOT NULL,
  `paid` double NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98768 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `charge_type_id` bigint NOT NULL,
  `pay_date` date DEFAULT NULL,
  `charge` double NOT NULL,
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `paidAmount` float DEFAULT '0',
  `old_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1970020 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbcatcol`
--

DROP TABLE IF EXISTS `pbcatcol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pbcatcol` (
  `pbc_tnam` char(193) NOT NULL,
  `pbc_tid` int DEFAULT NULL,
  `pbc_ownr` char(193) NOT NULL,
  `pbc_cnam` char(193) NOT NULL,
  `pbc_cid` smallint DEFAULT NULL,
  `pbc_labl` varchar(254) DEFAULT NULL,
  `pbc_lpos` smallint DEFAULT NULL,
  `pbc_hdr` varchar(254) DEFAULT NULL,
  `pbc_hpos` smallint DEFAULT NULL,
  `pbc_jtfy` smallint DEFAULT NULL,
  `pbc_mask` varchar(31) DEFAULT NULL,
  `pbc_case` smallint DEFAULT NULL,
  `pbc_hght` smallint DEFAULT NULL,
  `pbc_wdth` smallint DEFAULT NULL,
  `pbc_ptrn` varchar(31) DEFAULT NULL,
  `pbc_bmap` char(1) DEFAULT NULL,
  `pbc_init` varchar(254) DEFAULT NULL,
  `pbc_cmnt` varchar(254) DEFAULT NULL,
  `pbc_edit` varchar(31) DEFAULT NULL,
  `pbc_tag` varchar(254) DEFAULT NULL,
  UNIQUE KEY `pbcatc_x` (`pbc_tnam`,`pbc_ownr`,`pbc_cnam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbcatedt`
--

DROP TABLE IF EXISTS `pbcatedt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pbcatedt` (
  `pbe_name` varchar(30) NOT NULL,
  `pbe_edit` varchar(254) DEFAULT NULL,
  `pbe_type` smallint DEFAULT NULL,
  `pbe_cntr` int DEFAULT NULL,
  `pbe_seqn` smallint NOT NULL,
  `pbe_flag` int DEFAULT NULL,
  `pbe_work` char(32) DEFAULT NULL,
  UNIQUE KEY `pbcate_x` (`pbe_name`,`pbe_seqn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbcatfmt`
--

DROP TABLE IF EXISTS `pbcatfmt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pbcatfmt` (
  `pbf_name` varchar(30) NOT NULL,
  `pbf_frmt` varchar(254) DEFAULT NULL,
  `pbf_type` smallint DEFAULT NULL,
  `pbf_cntr` int DEFAULT NULL,
  UNIQUE KEY `pbcatf_x` (`pbf_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbcattbl`
--

DROP TABLE IF EXISTS `pbcattbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pbcattbl` (
  `pbt_tnam` char(193) NOT NULL,
  `pbt_tid` int DEFAULT NULL,
  `pbt_ownr` char(193) NOT NULL,
  `pbd_fhgt` smallint DEFAULT NULL,
  `pbd_fwgt` smallint DEFAULT NULL,
  `pbd_fitl` char(1) DEFAULT NULL,
  `pbd_funl` char(1) DEFAULT NULL,
  `pbd_fchr` smallint DEFAULT NULL,
  `pbd_fptc` smallint DEFAULT NULL,
  `pbd_ffce` char(18) DEFAULT NULL,
  `pbh_fhgt` smallint DEFAULT NULL,
  `pbh_fwgt` smallint DEFAULT NULL,
  `pbh_fitl` char(1) DEFAULT NULL,
  `pbh_funl` char(1) DEFAULT NULL,
  `pbh_fchr` smallint DEFAULT NULL,
  `pbh_fptc` smallint DEFAULT NULL,
  `pbh_ffce` char(18) DEFAULT NULL,
  `pbl_fhgt` smallint DEFAULT NULL,
  `pbl_fwgt` smallint DEFAULT NULL,
  `pbl_fitl` char(1) DEFAULT NULL,
  `pbl_funl` char(1) DEFAULT NULL,
  `pbl_fchr` smallint DEFAULT NULL,
  `pbl_fptc` smallint DEFAULT NULL,
  `pbl_ffce` char(18) DEFAULT NULL,
  `pbt_cmnt` varchar(254) DEFAULT NULL,
  UNIQUE KEY `pbcatt_x` (`pbt_tnam`,`pbt_ownr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbcatvld`
--

DROP TABLE IF EXISTS `pbcatvld`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pbcatvld` (
  `pbv_name` varchar(30) NOT NULL,
  `pbv_vald` varchar(254) DEFAULT NULL,
  `pbv_type` smallint DEFAULT NULL,
  `pbv_cntr` int DEFAULT NULL,
  `pbv_msg` varchar(254) DEFAULT NULL,
  UNIQUE KEY `pbcatv_x` (`pbv_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pet_ctm_relationship`
--

DROP TABLE IF EXISTS `pet_ctm_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_ctm_relationship` (
  `relationship_id` bigint NOT NULL AUTO_INCREMENT,
  `pet_id` bigint NOT NULL,
  `customer_id` bigint NOT NULL,
  `relationship` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`relationship_id`),
  UNIQUE KEY `pet_ctm_relationship_UN` (`pet_id`,`customer_id`),
  KEY `pet_ctm_relationship_FK_1` (`customer_id`),
  KEY `pet_ctm_relationship_FK_2` (`create_user_id`),
  CONSTRAINT `pet_ctm_relationship_FK` FOREIGN KEY (`pet_id`) REFERENCES `pet_pet` (`pet_id`),
  CONSTRAINT `pet_ctm_relationship_FK_1` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`),
  CONSTRAINT `pet_ctm_relationship_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COMMENT='Pet customer relationship';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pet_document`
--

DROP TABLE IF EXISTS `pet_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_document` (
  `document_id` bigint NOT NULL AUTO_INCREMENT,
  `pet_id` bigint NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `pet_document_FK` (`pet_id`),
  KEY `pet_document_FK_1` (`create_user_id`),
  CONSTRAINT `pet_document_FK` FOREIGN KEY (`pet_id`) REFERENCES `pet_pet` (`pet_id`),
  CONSTRAINT `pet_document_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pet_pet`
--

DROP TABLE IF EXISTS `pet_pet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_pet` (
  `pet_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`pet_id`),
  KEY `pet_pet_FK` (`enterprise_id`),
  KEY `pet_pet_FK_1` (`create_user_id`),
  CONSTRAINT `pet_pet_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pet_pet_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pet_pet_configuration`
--

DROP TABLE IF EXISTS `pet_pet_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet_pet_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `pet_configuration_FK` (`enterprise_id`),
  CONSTRAINT `pet_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfs_professor`
--

DROP TABLE IF EXISTS `pfs_professor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pfs_professor` (
  `professor_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`professor_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `pfs_professor_UN` (`enterprise_id`,`user_id`),
  KEY `pfs_professor_FK_1` (`create_user_id`),
  KEY `pfs_professor_FK_2` (`user_id`),
  CONSTRAINT `pfs_professor_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pfs_professor_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pfs_professor_FK_2` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3433 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='professor table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pfs_setting`
--

DROP TABLE IF EXISTS `pfs_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pfs_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `pfs_setting_FK_1` (`create_user_id`),
  CONSTRAINT `pfs_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pfs_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pix_project`
--

DROP TABLE IF EXISTS `pix_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pix_project` (
  `project_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `setup` longtext,
  PRIMARY KEY (`project_id`),
  KEY `pix_project_FK` (`enterprise_id`),
  KEY `pix_project_FK_1` (`create_user_id`),
  CONSTRAINT `pix_project_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pix_project_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pnm_pensum`
--

DROP TABLE IF EXISTS `pnm_pensum`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pnm_pensum` (
  `pensum_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`pensum_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `pnm_pensum_UN` (`enterprise_id`,`name`),
  KEY `pnm_pensum_FK_1` (`create_user_id`),
  CONSTRAINT `pnm_pensum_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pnm_pensum_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='pensum table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pnm_pensum_assignation`
--

DROP TABLE IF EXISTS `pnm_pensum_assignation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pnm_pensum_assignation` (
  `pensum_assignation_id` bigint NOT NULL AUTO_INCREMENT,
  `pensum_id` bigint NOT NULL,
  `career_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`pensum_assignation_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `pnm_pensum_assignation_UN` (`career_id`,`pensum_id`),
  KEY `pnm_pensum_assignation_FK_1` (`pensum_id`),
  CONSTRAINT `pnm_pensum_assignation_FK_1` FOREIGN KEY (`pensum_id`) REFERENCES `pnm_pensum` (`pensum_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pnm_pensum_assignation_FK_2` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=233 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='pensum table assignation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pnm_pensum_distribution`
--

DROP TABLE IF EXISTS `pnm_pensum_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pnm_pensum_distribution` (
  `distribution_id` bigint NOT NULL AUTO_INCREMENT,
  `pensum_id` bigint NOT NULL,
  `course_id` bigint NOT NULL,
  `studying_cycle_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`distribution_id`),
  KEY `pnm_pensum_distribution_FK` (`pensum_id`),
  KEY `pnm_pensum_distribution_FK_1` (`course_id`),
  KEY `pnm_pensum_distribution_FK_2` (`studying_cycle_id`),
  CONSTRAINT `pnm_pensum_distribution_FK` FOREIGN KEY (`pensum_id`) REFERENCES `pnm_pensum` (`pensum_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pnm_pensum_distribution_FK_2` FOREIGN KEY (`course_id`) REFERENCES `crs_course` (`course_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `pnm_pensum_distribution_FK_3` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10268 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_account`
--

DROP TABLE IF EXISTS `pos_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  KEY `pos_account_FK` (`create_user_id`),
  KEY `pos_account_FK_1` (`enterprise_id`),
  CONSTRAINT `pos_account_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `pos_account_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_bill`
--

DROP TABLE IF EXISTS `pos_bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_bill` (
  `bill_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `receiver_nit` varchar(100) NOT NULL,
  `receiver_name` varchar(100) DEFAULT NULL,
  `receiver_address` varchar(100) DEFAULT NULL,
  `receiver_email` varchar(100) DEFAULT NULL,
  `setup` longtext,
  `amount` decimal(10,2) DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'C' COMMENT 'Created (C), Requested (R), Emmited (E), Error (X), Void (V)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `response_date` datetime DEFAULT NULL,
  `error` longtext,
  PRIMARY KEY (`bill_id`),
  KEY `pos_bill_FK` (`enterprise_id`),
  KEY `pos_bill_FK_1` (`create_user_id`),
  CONSTRAINT `pos_bill_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pos_bill_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_sale`
--

DROP TABLE IF EXISTS `pos_sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_sale` (
  `sale_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `customer_id` bigint DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `payment` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `session_id` bigint DEFAULT NULL,
  PRIMARY KEY (`sale_id`),
  KEY `pos_sale_ctm_customer_FK` (`customer_id`),
  KEY `pos_sale_usr_enterprise_FK` (`enterprise_id`),
  KEY `pos_sale_usr_user_FK` (`create_user_id`),
  KEY `pos_sale_FK` (`session_id`),
  CONSTRAINT `pos_sale_ctm_customer_FK` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`),
  CONSTRAINT `pos_sale_ent_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pos_sale_FK` FOREIGN KEY (`session_id`) REFERENCES `pos_session` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `pos_sale_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_session`
--

DROP TABLE IF EXISTS `pos_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_session` (
  `session_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `comment` varchar(250) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint NOT NULL,
  `closure_date` datetime DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `pos_session_UN` (`enterprise_id`,`uuid`),
  KEY `pos_closure_FK_1` (`create_user_id`),
  CONSTRAINT `pos_closure_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pos_closure_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_setting`
--

DROP TABLE IF EXISTS `pos_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `pos_setting_UN` (`enterprise_id`),
  KEY `pos_setting_FK_1` (`create_user_id`),
  CONSTRAINT `pos_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pos_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_sold_product`
--

DROP TABLE IF EXISTS `pos_sold_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_sold_product` (
  `sold_id` bigint NOT NULL AUTO_INCREMENT,
  `sale_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` decimal(10,2) DEFAULT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `discount` tinyint DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`sold_id`),
  KEY `pos_product_sold_pos_sale_FK` (`sale_id`),
  KEY `pos_product_sold_prd_product_FK` (`product_id`),
  CONSTRAINT `pos_product_sold_prd_product_FK` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `pos_sold_product_FK` FOREIGN KEY (`sale_id`) REFERENCES `pos_sale` (`sale_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=285 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prd_category`
--

DROP TABLE IF EXISTS `prd_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prd_category` (
  `category_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `prd_category_UN` (`uuid`),
  KEY `prd_category_FK` (`enterprise_id`),
  KEY `prd_category_FK_1` (`create_user_id`),
  CONSTRAINT `prd_category_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `prd_category_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prd_category_suscription`
--

DROP TABLE IF EXISTS `prd_category_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prd_category_suscription` (
  `category_suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`category_suscription_id`),
  UNIQUE KEY `prd_category_suscription_UN` (`uuid`),
  KEY `prd_category_suscription_FK_1` (`category_id`),
  KEY `prd_category_suscription_FK` (`product_id`),
  KEY `prd_category_suscription_FK_2` (`create_user_id`),
  CONSTRAINT `prd_category_suscription_FK` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `prd_category_suscription_FK_1` FOREIGN KEY (`category_id`) REFERENCES `prd_category` (`category_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `prd_category_suscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prd_picture`
--

DROP TABLE IF EXISTS `prd_picture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prd_picture` (
  `picture_id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`picture_id`),
  KEY `prd_picture_FK` (`product_id`),
  KEY `prd_picture_FK_1` (`create_user_id`),
  CONSTRAINT `prd_picture_FK` FOREIGN KEY (`product_id`) REFERENCES `prd_product` (`product_id`),
  CONSTRAINT `prd_picture_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prd_product`
--

DROP TABLE IF EXISTS `prd_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prd_product` (
  `product_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `barcode` varchar(100) DEFAULT NULL,
  `internal_reference` varchar(100) DEFAULT NULL,
  `available_for_sale` tinyint(1) DEFAULT '1',
  `available_for_purchase` tinyint(1) NOT NULL DEFAULT '1',
  `sale_price` decimal(10,2) DEFAULT '0.00',
  `cost` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`product_id`),
  KEY `prd_product_FK` (`enterprise_id`),
  KEY `prd_product_FK_1` (`create_user_id`),
  CONSTRAINT `prd_product_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `prd_product_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=120177 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prd_product_configuration`
--

DROP TABLE IF EXISTS `prd_product_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prd_product_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  KEY `prd_configuration_FK` (`enterprise_id`),
  CONSTRAINT `prd_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prj_payment`
--

DROP TABLE IF EXISTS `prj_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_payment` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `concept` varchar(100) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `paid` tinyint DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `prj_payment_FK` (`project_id`),
  KEY `prj_payment_FK_1` (`create_user_id`),
  CONSTRAINT `prj_payment_FK` FOREIGN KEY (`project_id`) REFERENCES `prj_project` (`project_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `prj_payment_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prj_project`
--

DROP TABLE IF EXISTS `prj_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prj_project` (
  `project_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(250) NOT NULL,
  `customer_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`project_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `prj_project_FK` (`enterprise_id`),
  KEY `prj_project_FK_1` (`create_user_id`),
  KEY `prj_project_FK_2` (`customer_id`),
  CONSTRAINT `prj_project_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `prj_project_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `prj_project_FK_2` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pvd_provider`
--

DROP TABLE IF EXISTS `pvd_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pvd_provider` (
  `provider_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext NOT NULL,
  PRIMARY KEY (`provider_id`),
  KEY `pvd_provider_FK` (`enterprise_id`),
  KEY `pvd_provider_FK_1` (`create_user_id`),
  CONSTRAINT `pvd_provider_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `pvd_provider_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qot_quotation`
--

DROP TABLE IF EXISTS `qot_quotation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qot_quotation` (
  `quotation_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) DEFAULT NULL,
  `enterprise_id` bigint NOT NULL,
  `customer_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`quotation_id`),
  UNIQUE KEY `qot_quotation_UN` (`uuid`),
  KEY `qot_quotation_FK` (`enterprise_id`),
  KEY `qot_quotation_FK_1` (`customer_id`),
  KEY `qot_quotation_FK_2` (`create_user_id`),
  CONSTRAINT `qot_quotation_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `qot_quotation_FK_1` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`),
  CONSTRAINT `qot_quotation_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qot_setting`
--

DROP TABLE IF EXISTS `qot_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qot_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `qot_setting_UN` (`enterprise_id`),
  KEY `qot_setting_FK_1` (`create_user_id`),
  CONSTRAINT `qot_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `qot_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qot_signature`
--

DROP TABLE IF EXISTS `qot_signature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qot_signature` (
  `signature_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`signature_id`),
  KEY `qot_signature_FK_1` (`create_user_id`),
  KEY `qot_signature_FK` (`enterprise_id`),
  CONSTRAINT `qot_signature_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `qot_signature_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_application`
--

DROP TABLE IF EXISTS `rbc_application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_application` (
  `application_id` bigint NOT NULL AUTO_INCREMENT,
  `soc_application_id` varchar(20) NOT NULL,
  `status_code` varchar(1) DEFAULT 'N' COMMENT 'New (N)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `request_body` longtext,
  `uuid` varchar(100) NOT NULL,
  `ngine_instance_uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `rbc_application_UN` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb3 COMMENT='Robocredit SOC credit application table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_banned_enterprise_name`
--

DROP TABLE IF EXISTS `rbc_banned_enterprise_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_banned_enterprise_name` (
  `enterprise_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_banned_occupation`
--

DROP TABLE IF EXISTS `rbc_banned_occupation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_banned_occupation` (
  `occupation_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`occupation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_department`
--

DROP TABLE IF EXISTS `rbc_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_department` (
  `department_id` bigint NOT NULL AUTO_INCREMENT,
  `soc_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `rbc_department_UN` (`soc_code`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_municipality`
--

DROP TABLE IF EXISTS `rbc_municipality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_municipality` (
  `municipality_id` bigint NOT NULL AUTO_INCREMENT,
  `department_id` bigint NOT NULL,
  `soc_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`municipality_id`),
  UNIQUE KEY `rbc_municipality_UN` (`soc_code`),
  KEY `rbc_municipality_FK` (`department_id`),
  CONSTRAINT `rbc_municipality_FK` FOREIGN KEY (`department_id`) REFERENCES `rbc_department` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=359 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_occupation`
--

DROP TABLE IF EXISTS `rbc_occupation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_occupation` (
  `occupation_id` bigint NOT NULL AUTO_INCREMENT,
  `soc_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`occupation_id`),
  UNIQUE KEY `rbc_occupation_UN` (`soc_code`)
) ENGINE=InnoDB AUTO_INCREMENT=329 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_relationship`
--

DROP TABLE IF EXISTS `rbc_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_relationship` (
  `relationship_id` bigint NOT NULL AUTO_INCREMENT,
  `soc_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`relationship_id`),
  UNIQUE KEY `rbc_relationship_UN` (`soc_code`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_setup`
--

DROP TABLE IF EXISTS `rbc_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_setup` (
  `setup_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setup_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `rbc_setup_FK_1` (`create_user_id`),
  CONSTRAINT `rbc_setup_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `rbc_setup_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_wait_formalization`
--

DROP TABLE IF EXISTS `rbc_wait_formalization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_wait_formalization` (
  `wait_id` bigint NOT NULL AUTO_INCREMENT,
  `outbox_id` bigint NOT NULL,
  `automate_task_id` bigint NOT NULL,
  `status_code` varchar(1) NOT NULL DEFAULT 'W' COMMENT 'Waiting (W), Finished (F)',
  PRIMARY KEY (`wait_id`),
  KEY `rbc_wait_onfido_FK_1` (`automate_task_id`),
  CONSTRAINT `rbc_wait_formalization_FK_1` FOREIGN KEY (`automate_task_id`) REFERENCES `ngn_automate_task` (`automate_task_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Electronic Formalization waiting line';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbc_wait_onfido`
--

DROP TABLE IF EXISTS `rbc_wait_onfido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbc_wait_onfido` (
  `wait_id` bigint NOT NULL AUTO_INCREMENT,
  `verification_id` bigint NOT NULL,
  `automate_task_id` bigint NOT NULL,
  `status_code` varchar(1) NOT NULL DEFAULT 'W' COMMENT 'Waiting (W), Finished (F)',
  PRIMARY KEY (`wait_id`),
  KEY `rbc_wait_onfido_FK` (`verification_id`),
  KEY `rbc_wait_onfido_FK_1` (`automate_task_id`),
  CONSTRAINT `rbc_wait_onfido_FK` FOREIGN KEY (`verification_id`) REFERENCES `onf_verification` (`verification_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rbc_wait_onfido_FK_1` FOREIGN KEY (`automate_task_id`) REFERENCES `ngn_automate_task` (`automate_task_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Onfido waiting line for report analysis finished';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rbt_robot`
--

DROP TABLE IF EXISTS `rbt_robot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rbt_robot` (
  `robot_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `setup` longtext NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`robot_id`),
  UNIQUE KEY `rbt_robot_UN` (`uuid`),
  KEY `rbt_robot_FK` (`enterprise_id`),
  KEY `rbt_robot_FK_1` (`create_user_id`),
  CONSTRAINT `rbt_robot_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `rbt_robot_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rpt_report`
--

DROP TABLE IF EXISTS `rpt_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rpt_report` (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `module_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `rpt_report_UN` (`uuid`),
  KEY `rpt_report_FK` (`create_user_id`),
  KEY `rpt_report_FK_1` (`module_id`),
  CONSTRAINT `rpt_report_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `rpt_report_FK_1` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rpt_suscription`
--

DROP TABLE IF EXISTS `rpt_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rpt_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `report_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `rpt_suscription_UN` (`uuid`),
  KEY `rpt_suscription_FK` (`report_id`),
  KEY `rpt_suscription_FK_1` (`role_id`),
  KEY `rpt_suscription_FK_2` (`create_user_id`),
  KEY `rpt_suscription_FK_3` (`enterprise_id`),
  CONSTRAINT `rpt_suscription_FK` FOREIGN KEY (`report_id`) REFERENCES `rpt_report` (`report_id`),
  CONSTRAINT `rpt_suscription_FK_1` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`),
  CONSTRAINT `rpt_suscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `rpt_suscription_FK_3` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=497 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rpt_template`
--

DROP TABLE IF EXISTS `rpt_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rpt_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `template` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `icon` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  KEY `rpt_template_FK` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serbipagos_setting`
--

DROP TABLE IF EXISTS `serbipagos_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `serbipagos_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `serbipagos_setting_FK_1` (`create_user_id`),
  CONSTRAINT `serbipagos_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `serbipagos_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `serbipagos_transaction`
--

DROP TABLE IF EXISTS `serbipagos_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `serbipagos_transaction` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_type` varchar(100) DEFAULT NULL,
  `request` longtext,
  `response` longtext,
  `request_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(100) DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  `response_args` longtext,
  `request_args` longtext,
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `serbipagos_transaction_FK` (`enterprise_id`),
  CONSTRAINT `serbipagos_transaction_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=171633 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sio_link`
--

DROP TABLE IF EXISTS `sio_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sio_link` (
  `link_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `original_url` tinytext,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `short_url` varchar(200) DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `sio_link_FK` (`enterprise_id`),
  KEY `sio_link_FK_1` (`create_user_id`),
  CONSTRAINT `sio_link_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `sio_link_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sio_setting`
--

DROP TABLE IF EXISTS `sio_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sio_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `sio_setting_FK_1` (`create_user_id`),
  CONSTRAINT `sio_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `sio_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_360_deployment`
--

DROP TABLE IF EXISTS `staff_rating_360_deployment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_360_deployment` (
  `deployment_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL,
  `version` varchar(20) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `organization_id` bigint NOT NULL,
  PRIMARY KEY (`deployment_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_360_deployment_FK` (`create_user_id`),
  KEY `staff_rating_360_deployment_FK_1` (`enterprise_id`),
  KEY `staff_rating_360_deployment_FK_2` (`organization_id`),
  CONSTRAINT `staff_rating_360_deployment_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_deployment_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_deployment_FK_2` FOREIGN KEY (`organization_id`) REFERENCES `staff_rating_organization` (`organization_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_360_feedback`
--

DROP TABLE IF EXISTS `staff_rating_360_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_360_feedback` (
  `feedback_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `status_code` varchar(1) NOT NULL DEFAULT 'U' COMMENT 'Unfinished (U), Finished (F), Expired (E)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `organization_id` bigint NOT NULL,
  `source_node` longtext,
  `reason` varchar(100) DEFAULT NULL,
  `target_node` longtext,
  `source_node_id` varchar(100) DEFAULT NULL,
  `target_node_id` varchar(100) DEFAULT NULL,
  `evaluation_id` bigint DEFAULT NULL,
  `expire_date` date DEFAULT NULL,
  `deployment_id` bigint DEFAULT NULL,
  PRIMARY KEY (`feedback_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_360_feedback_FK` (`deployment_id`),
  KEY `staff_rating_360_feedback_FK_1` (`enterprise_id`),
  KEY `staff_rating_360_feedback_FK_3` (`create_user_id`),
  KEY `staff_rating_360_feedback_FK_4` (`organization_id`),
  KEY `staff_rating_360_feedback_FK_6` (`evaluation_id`),
  CONSTRAINT `staff_rating_360_feedback_FK` FOREIGN KEY (`deployment_id`) REFERENCES `staff_rating_360_deployment` (`deployment_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_feedback_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_feedback_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_feedback_FK_4` FOREIGN KEY (`organization_id`) REFERENCES `staff_rating_organization` (`organization_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_360_feedback_FK_6` FOREIGN KEY (`evaluation_id`) REFERENCES `staff_rating_evaluation` (`evaluation_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_category`
--

DROP TABLE IF EXISTS `staff_rating_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_category` (
  `category_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `parent_category_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_category_FK` (`enterprise_id`),
  KEY `staff_rating_category_FK_1` (`parent_category_id`),
  KEY `staff_rating_category_FK_2` (`create_user_id`),
  CONSTRAINT `staff_rating_category_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_category_FK_1` FOREIGN KEY (`parent_category_id`) REFERENCES `staff_rating_category` (`category_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_category_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_evaluation`
--

DROP TABLE IF EXISTS `staff_rating_evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_evaluation` (
  `evaluation_id` bigint NOT NULL AUTO_INCREMENT,
  `source` varchar(100) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `evaluator_user_id` bigint DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `template_id` bigint NOT NULL,
  `evaluated_user_id` bigint DEFAULT NULL,
  `response` longtext,
  `response_date` datetime DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`evaluation_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_evaluation_FK` (`enterprise_id`),
  KEY `staff_rating_evaluation_FK_1` (`evaluator_user_id`),
  KEY `staff_rating_evaluation_FK_2` (`evaluated_user_id`),
  KEY `staff_rating_evaluation_FK_3` (`template_id`),
  KEY `staff_rating_evaluation_FK_4` (`create_user_id`),
  CONSTRAINT `staff_rating_evaluation_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_evaluation_FK_1` FOREIGN KEY (`evaluator_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_evaluation_FK_2` FOREIGN KEY (`evaluated_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_evaluation_FK_3` FOREIGN KEY (`template_id`) REFERENCES `staff_rating_template` (`template_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_evaluation_FK_4` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_organization`
--

DROP TABLE IF EXISTS `staff_rating_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_organization` (
  `organization_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`organization_id`),
  KEY `staff_rating_organization_FK` (`create_user_id`),
  KEY `staff_rating_organization_FK_1` (`enterprise_id`),
  CONSTRAINT `staff_rating_organization_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_organization_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_organization_setting`
--

DROP TABLE IF EXISTS `staff_rating_organization_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_organization_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `staff_rating_organization_setting_FK_1` (`create_user_id`),
  CONSTRAINT `staff_rating_organization_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_organization_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_teacher_evaluation`
--

DROP TABLE IF EXISTS `staff_rating_teacher_evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_teacher_evaluation` (
  `teacher_evaluation_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `evaluation_date` date DEFAULT NULL,
  `setup` longtext,
  `evaluation_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`teacher_evaluation_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_teacher_evaluation_FK` (`enterprise_id`),
  KEY `staff_rating_teacher_evaluation_FK_1` (`evaluation_id`),
  KEY `staff_rating_teacher_evaluation_FK_2` (`create_user_id`),
  CONSTRAINT `staff_rating_teacher_evaluation_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_teacher_evaluation_FK_1` FOREIGN KEY (`evaluation_id`) REFERENCES `staff_rating_evaluation` (`evaluation_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_teacher_evaluation_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_teacher_setting`
--

DROP TABLE IF EXISTS `staff_rating_teacher_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_teacher_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `staff_rating_teacher_setting_FK_1` (`create_user_id`),
  CONSTRAINT `staff_rating_teacher_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_teacher_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `staff_rating_template`
--

DROP TABLE IF EXISTS `staff_rating_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_rating_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `staff_rating_template_FK` (`enterprise_id`),
  KEY `staff_rating_template_FK_1` (`create_user_id`),
  CONSTRAINT `staff_rating_template_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `staff_rating_template_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_account`
--

DROP TABLE IF EXISTS `std_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_account` (
  `relation_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `account_id` bigint NOT NULL,
  PRIMARY KEY (`relation_id`),
  UNIQUE KEY `std_account_UN` (`student_id`),
  UNIQUE KEY `std_account_account_UN` (`account_id`),
  KEY `std_account_FK` (`account_id`),
  KEY `std_account_FK_1` (`student_id`),
  CONSTRAINT `std_account_FK` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`),
  CONSTRAINT `std_account_FK_1` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=135686 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_account_configuration`
--

DROP TABLE IF EXISTS `std_account_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_account_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `std_account_configuration_UN_enterprise` (`enterprise_id`),
  KEY `std_account_configuration_FK_1` (`create_user_id`),
  CONSTRAINT `std_account_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_account_configuration_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_account_movement`
--

DROP TABLE IF EXISTS `std_account_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_account_movement` (
  `movement_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  `account_id` bigint NOT NULL,
  `paid` decimal(10,2) DEFAULT '0.00',
  `expire_date` date DEFAULT NULL,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Active (A), Expired (X), Paid (P)',
  `period_id` bigint DEFAULT NULL COMMENT 'Period of the movement',
  `inscription_id` bigint DEFAULT NULL,
  `setup` longtext,
  `order_id` bigint DEFAULT NULL,
  PRIMARY KEY (`movement_id`),
  UNIQUE KEY `acc_movement_UN` (`uuid`),
  KEY `acc_movement_FK` (`account_id`),
  KEY `acc_movement_FK_1` (`type_id`),
  KEY `acc_movement_FK_2` (`create_user_id`),
  KEY `std_account_movement_FK` (`period_id`),
  KEY `std_account_movement_std_inscription_FK` (`inscription_id`),
  CONSTRAINT `acc_movement_FK` FOREIGN KEY (`account_id`) REFERENCES `acc_account` (`account_id`),
  CONSTRAINT `acc_movement_FK_1` FOREIGN KEY (`type_id`) REFERENCES `std_account_movement_type` (`type_id`),
  CONSTRAINT `acc_movement_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_account_movement_FK` FOREIGN KEY (`period_id`) REFERENCES `std_period` (`period_id`),
  CONSTRAINT `std_account_movement_std_inscription_FK` FOREIGN KEY (`inscription_id`) REFERENCES `std_inscription` (`inscription_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3247952 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_account_movement_type`
--

DROP TABLE IF EXISTS `std_account_movement_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_account_movement_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `acc_movement_type_UN_uuid` (`uuid`),
  UNIQUE KEY `acc_movement_type_UN_name` (`enterprise_id`,`name`),
  KEY `acc_movement_type_FK_1` (`create_user_id`),
  CONSTRAINT `acc_movement_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `acc_movement_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_branch`
--

DROP TABLE IF EXISTS `std_branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_branch` (
  `branch_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `code` varchar(25) DEFAULT NULL,
  `has_permission` tinyint(1) DEFAULT NULL,
  `setup` longtext,
  `type` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`branch_id`),
  UNIQUE KEY `std_branch_UN_name` (`name`,`enterprise_id`),
  UNIQUE KEY `std_branch_UN_uuid` (`uuid`),
  KEY `std_branch_FK` (`enterprise_id`),
  KEY `std_branch_FK_1` (`create_user_id`),
  CONSTRAINT `std_branch_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_branch_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_branch_classroom`
--

DROP TABLE IF EXISTS `std_branch_classroom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_branch_classroom` (
  `classroom_id` bigint NOT NULL AUTO_INCREMENT,
  `branch_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  PRIMARY KEY (`classroom_id`),
  UNIQUE KEY `std_branch_classroom_UN` (`uuid`),
  KEY `std_branch_classroom_FK` (`branch_id`),
  KEY `std_branch_classroom_FK_1` (`create_user_id`),
  KEY `std_branch_classroom_FK_4` (`enterprise_id`),
  CONSTRAINT `std_branch_classroom_FK_2` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`),
  CONSTRAINT `std_branch_classroom_FK_3` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_branch_classroom_FK_4` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_career`
--

DROP TABLE IF EXISTS `std_career`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_career` (
  `career_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `code` varchar(25) DEFAULT NULL,
  `is_technician` tinyint(1) NOT NULL,
  `technician_career` bigint DEFAULT NULL,
  PRIMARY KEY (`career_id`),
  UNIQUE KEY `std_carrer_UN_uuid` (`uuid`),
  UNIQUE KEY `std_carrer_UN_name` (`name`,`enterprise_id`),
  KEY `std_carrer_FK` (`enterprise_id`),
  KEY `std_carrer_FK_1` (`create_user_id`),
  KEY `std_career_std_career_FK` (`technician_career`),
  CONSTRAINT `std_career_std_career_FK` FOREIGN KEY (`technician_career`) REFERENCES `std_career` (`career_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_carrer_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_carrer_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_configuration`
--

DROP TABLE IF EXISTS `std_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `std_configuration_UN` (`enterprise_id`),
  CONSTRAINT `std_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_course`
--

DROP TABLE IF EXISTS `std_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_course` (
  `course_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `std_course_UN_uuid` (`uuid`),
  UNIQUE KEY `std_course_UN_name` (`name`,`enterprise_id`),
  KEY `std_course_FK` (`enterprise_id`),
  KEY `std_course_FK_1` (`create_user_id`),
  CONSTRAINT `std_course_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_course_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_document`
--

DROP TABLE IF EXISTS `std_document`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_document` (
  `document_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `files` longtext,
  `student_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  UNIQUE KEY `std_document_UN` (`uuid`),
  KEY `std_document_FK` (`student_id`),
  KEY `std_document_FK_1` (`type_id`),
  KEY `std_document_FK_2` (`create_user_id`),
  CONSTRAINT `std_document_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_document_FK_1` FOREIGN KEY (`type_id`) REFERENCES `std_document_type` (`type_id`),
  CONSTRAINT `std_document_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11838 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_document_type`
--

DROP TABLE IF EXISTS `std_document_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_document_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_document_type_UN_uuid` (`uuid`),
  UNIQUE KEY `std_document_type_UN_name` (`enterprise_id`,`name`),
  KEY `std_document_type_FK_1` (`create_user_id`),
  CONSTRAINT `std_document_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_document_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_history`
--

DROP TABLE IF EXISTS `std_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_history` (
  `history_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`history_id`),
  UNIQUE KEY `std_history_unique` (`uuid`),
  KEY `std_history_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_history_usr_user_FK` (`create_user_id`),
  CONSTRAINT `std_history_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_history_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_inscription`
--

DROP TABLE IF EXISTS `std_inscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_inscription` (
  `inscription_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `period_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `career_id` bigint NOT NULL,
  `branch_id` bigint DEFAULT NULL,
  `studying_cycle_id` bigint DEFAULT NULL,
  `studying_time_id` bigint DEFAULT NULL,
  `processes` longtext,
  `request_id` bigint DEFAULT NULL,
  `history_id` bigint DEFAULT NULL,
  PRIMARY KEY (`inscription_id`),
  UNIQUE KEY `std_inscription_UN` (`uuid`),
  UNIQUE KEY `std_inscription_ins_UN` (`student_id`,`period_id`,`career_id`,`branch_id`),
  KEY `std_inscription_FK_1` (`period_id`),
  KEY `std_inscription_FK_2` (`create_user_id`),
  KEY `std_inscription_FK_3` (`career_id`),
  KEY `std_inscription_FK_4` (`branch_id`),
  KEY `std_inscription_FK_5` (`studying_cycle_id`),
  KEY `std_inscription_FK_6` (`studying_time_id`),
  KEY `std_inscription_FK_7` (`request_id`),
  KEY `std_inscription_std_history_FK` (`history_id`),
  CONSTRAINT `std_inscription_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_inscription_FK_1` FOREIGN KEY (`period_id`) REFERENCES `std_period` (`period_id`),
  CONSTRAINT `std_inscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_inscription_FK_3` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`),
  CONSTRAINT `std_inscription_FK_4` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`),
  CONSTRAINT `std_inscription_FK_5` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`),
  CONSTRAINT `std_inscription_FK_6` FOREIGN KEY (`studying_time_id`) REFERENCES `std_studying_time` (`studying_time_id`),
  CONSTRAINT `std_inscription_FK_7` FOREIGN KEY (`request_id`) REFERENCES `std_request` (`request_id`),
  CONSTRAINT `std_inscription_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`),
  CONSTRAINT `std_inscription_std_history_FK` FOREIGN KEY (`history_id`) REFERENCES `std_history` (`history_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=250543 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_inscription_configuration`
--

DROP TABLE IF EXISTS `std_inscription_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_inscription_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `std_inscription_configuration_UN_enterprise` (`enterprise_id`),
  KEY `std_inscription_configuration_FK_1` (`create_user_id`),
  CONSTRAINT `std_inscription_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_inscription_configuration_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log`
--

DROP TABLE IF EXISTS `std_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `std_log_unique` (`uuid`),
  KEY `std_log_std_log_type_FK` (`type_id`),
  KEY `std_log_std_student_FK` (`student_id`),
  KEY `std_log_usr_user_FK` (`create_user_id`),
  CONSTRAINT `std_log_std_log_type_FK` FOREIGN KEY (`type_id`) REFERENCES `std_log_type` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_std_student_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=397801 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log_communication_type`
--

DROP TABLE IF EXISTS `std_log_communication_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log_communication_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `setup` longtext,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_log_communication_type_unique` (`uuid`),
  KEY `std_log_communication_type_usr_user_FK` (`create_user_id`),
  CONSTRAINT `std_log_communication_type_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log_ticket`
--

DROP TABLE IF EXISTS `std_log_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log_ticket` (
  `log_ticket_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `status_type_id` bigint DEFAULT NULL,
  `reassign_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`log_ticket_id`),
  UNIQUE KEY `std_log_ticket_unique` (`uuid`),
  KEY `std_log_ticket_usr_user_FK` (`create_user_id`),
  KEY `std_log_ticket_std_log_ticket_type_FK` (`type_id`),
  KEY `std_log_ticket_std_student_FK` (`student_id`),
  KEY `std_log_ticket_usr_user_FK_1` (`user_id`),
  KEY `std_log_ticket_std_log_ticket_status_type_FK` (`status_type_id`),
  KEY `std_log_ticket_usr_user_FK_2` (`reassign_user_id`),
  CONSTRAINT `std_log_ticket_std_log_ticket_status_type_FK` FOREIGN KEY (`status_type_id`) REFERENCES `std_log_ticket_status_type` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_std_log_ticket_type_FK` FOREIGN KEY (`type_id`) REFERENCES `std_log_ticket_type` (`type_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_std_student_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_usr_user_FK_1` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_usr_user_FK_2` FOREIGN KEY (`reassign_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=5220 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log_ticket_status_type`
--

DROP TABLE IF EXISTS `std_log_ticket_status_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log_ticket_status_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `status_code` varchar(1) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `module_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_log_ticket_status_type_unique` (`uuid`),
  KEY `std_log_ticket_status_type_usr_user_FK` (`create_user_id`),
  KEY `std_log_ticket_status_type_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_log_ticket_status_type_sys_module_FK` (`module_id`),
  CONSTRAINT `std_log_ticket_status_type_sys_module_FK` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`),
  CONSTRAINT `std_log_ticket_status_type_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_status_type_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log_ticket_type`
--

DROP TABLE IF EXISTS `std_log_ticket_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log_ticket_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `module_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_log_ticket_type_unique` (`uuid`),
  KEY `std_log_ticket_type_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_log_ticket_type_usr_user_FK` (`create_user_id`),
  KEY `std_log_ticket_type_sys_module_FK` (`module_id`),
  CONSTRAINT `std_log_ticket_type_sys_module_FK` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`),
  CONSTRAINT `std_log_ticket_type_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_ticket_type_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_log_type`
--

DROP TABLE IF EXISTS `std_log_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_log_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_log_type_unique` (`uuid`),
  KEY `std_log_type_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_log_type_usr_user_FK` (`create_user_id`),
  CONSTRAINT `std_log_type_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_log_type_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_old_new`
--

DROP TABLE IF EXISTS `std_old_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_old_new` (
  `id` int NOT NULL AUTO_INCREMENT,
  `new_student_id` bigint NOT NULL,
  `old_student_id` bigint NOT NULL,
  `account_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `new_student_id` (`new_student_id`),
  KEY `std_old_new_acc_account_account_id_fk` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=44478 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_order_movement`
--

DROP TABLE IF EXISTS `std_order_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_order_movement` (
  `movement_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `type_id` bigint NOT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `uuid` varchar(100) DEFAULT 'uuid()',
  `movement_account_id` bigint DEFAULT NULL,
  PRIMARY KEY (`movement_id`),
  KEY `order_id` (`order_id`),
  KEY `std_order_movement_FK` (`type_id`),
  CONSTRAINT `std_order_movement_FK` FOREIGN KEY (`type_id`) REFERENCES `std_account_movement_type` (`type_id`),
  CONSTRAINT `std_order_movement_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `std_payment_order` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=125246 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_payment_config`
--

DROP TABLE IF EXISTS `std_payment_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_payment_config` (
  `config_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `uuid` varchar(100) DEFAULT 'uuid()',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`config_id`),
  KEY `std_payment_config_FK` (`enterprise_id`),
  CONSTRAINT `std_payment_config_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_payment_order`
--

DROP TABLE IF EXISTS `std_payment_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_payment_order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `create_date` date DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'A= Active, P=Proceced, E=Expired',
  `processed_by` bigint DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(100) DEFAULT 'uuid()',
  `amount` decimal(18,2) DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  `discount` bit(1) DEFAULT NULL,
  `setup` longtext,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `std_payment_order_unique` (`uuid`),
  KEY `std_payment_order_FK` (`student_id`),
  KEY `std_payment_order_FK_1` (`enterprise_id`),
  KEY `std_payment_order_FK_2` (`create_user_id`),
  KEY `std_payment_order_uuid_IDX` (`uuid`) USING BTREE,
  CONSTRAINT `std_payment_order_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_payment_order_FK_1` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_payment_order_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=139568 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_period`
--

DROP TABLE IF EXISTS `std_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_period` (
  `period_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`period_id`),
  UNIQUE KEY `std_period_UN_name` (`enterprise_id`,`name`),
  UNIQUE KEY `std_period_UN_uuid` (`uuid`),
  KEY `std_period_FK_1` (`create_user_id`),
  CONSTRAINT `std_period_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_period_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_configuration`
--

DROP TABLE IF EXISTS `std_portal_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `std_portal_configuration_UN_enterprise` (`enterprise_id`),
  KEY `std_portal_configuration_FK_1` (`create_user_id`),
  CONSTRAINT `std_portal_configuration_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_portal_configuration_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_module`
--

DROP TABLE IF EXISTS `std_portal_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_module` (
  `module_id` bigint NOT NULL,
  PRIMARY KEY (`module_id`),
  CONSTRAINT `std_portal_module_FK` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_payment_ticket`
--

DROP TABLE IF EXISTS `std_portal_payment_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_payment_ticket` (
  `ticket_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_date` date DEFAULT NULL,
  `transaction_type_id` bigint NOT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  `receipt_file` json DEFAULT NULL,
  `status` varchar(15) DEFAULT 'waiting',
  `receipt_number` varchar(50) DEFAULT NULL,
  `selected_movement_types` json DEFAULT NULL,
  `settings` json DEFAULT NULL,
  PRIMARY KEY (`ticket_id`),
  KEY `std_portal_payment_ticket_std_student_FK` (`student_id`),
  KEY `std_portal_payment_ticket_acc_transaction_type_FK` (`transaction_type_id`),
  CONSTRAINT `std_portal_payment_ticket_acc_transaction_type_FK` FOREIGN KEY (`transaction_type_id`) REFERENCES `acc_transaction_type` (`type_id`),
  CONSTRAINT `std_portal_payment_ticket_std_student_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43799 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_payment_ticket_movement`
--

DROP TABLE IF EXISTS `std_portal_payment_ticket_movement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_payment_ticket_movement` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint NOT NULL,
  `movement_id` bigint NOT NULL,
  PRIMARY KEY (`record_id`),
  KEY `std_portal_payment_ticket_movement_std_portal_payment_ticket_FK` (`ticket_id`),
  KEY `std_portal_payment_ticket_movement_std_account_movement_FK` (`movement_id`),
  CONSTRAINT `std_portal_payment_ticket_movement_std_account_movement_FK` FOREIGN KEY (`movement_id`) REFERENCES `std_account_movement` (`movement_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_payment_ticket_movement_std_portal_payment_ticket_FK` FOREIGN KEY (`ticket_id`) REFERENCES `std_portal_payment_ticket` (`ticket_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21355 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_preinscription_configuration`
--

DROP TABLE IF EXISTS `std_portal_preinscription_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_preinscription_configuration` (
  `configuration_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`configuration_id`),
  UNIQUE KEY `std_portal_configuration_UN_enterprise` (`enterprise_id`),
  KEY `std_portal_configuration_FK_1` (`create_user_id`) USING BTREE,
  CONSTRAINT `std_portal_configuration_FK_1_copy` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_configuration_FK_copy` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_professor_evaluation`
--

DROP TABLE IF EXISTS `std_portal_professor_evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_professor_evaluation` (
  `evaluation_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `period_id` bigint NOT NULL,
  `assignation_id` bigint DEFAULT NULL,
  `professor_id` bigint DEFAULT NULL,
  `course_id` bigint DEFAULT NULL,
  `answers` longtext NOT NULL,
  `is_anonymous` tinyint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `enterprise_id` bigint NOT NULL,
  `setting_id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`evaluation_id`),
  UNIQUE KEY `std_portal_professor_evaluation_unique` (`uuid`),
  KEY `std_portal_professor_evaluation_crs_assignation_student_FK` (`assignation_id`),
  KEY `std_portal_professor_evaluation_std_period_FK` (`period_id`),
  KEY `std_portal_professor_evaluation_pfs_professor_FK` (`professor_id`),
  KEY `std_portal_professor_evaluation_crs_course_FK` (`course_id`),
  KEY `std_portal_professor_evaluation_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_portal_professor_evaluation_usr_user_FK` (`user_id`),
  KEY `std_portal_professor_evaluation__setting_FK` (`setting_id`),
  CONSTRAINT `std_portal_professor_evaluation__setting_FK` FOREIGN KEY (`setting_id`) REFERENCES `std_portal_professor_evaluation_setting` (`setting_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_crs_assignation_student_FK` FOREIGN KEY (`assignation_id`) REFERENCES `crs_assignation_student` (`assignation_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_crs_course_FK` FOREIGN KEY (`course_id`) REFERENCES `crs_course` (`course_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_pfs_professor_FK` FOREIGN KEY (`professor_id`) REFERENCES `pfs_professor` (`professor_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_std_period_FK` FOREIGN KEY (`period_id`) REFERENCES `std_period` (`period_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_usr_user_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=8269 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_professor_evaluation_setting`
--

DROP TABLE IF EXISTS `std_portal_professor_evaluation_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_professor_evaluation_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `active_from` date DEFAULT NULL,
  `active_to` date DEFAULT NULL,
  `state` enum('draft','published','archived') NOT NULL,
  `is_anonymous` tinyint DEFAULT NULL,
  `allow_multiple` tinyint DEFAULT NULL,
  `cooldown_days` bigint DEFAULT NULL,
  `enterprise_id` bigint DEFAULT '1',
  `audience_type` enum('student','role') NOT NULL,
  `role_id` bigint DEFAULT NULL,
  `target_type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  KEY `std_portal_professor_evaluation_setting_usr_user_FK` (`create_user_id`),
  KEY `std_portal_professor_evaluation_setting_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_portal_professor_evaluation_setting_usr_role_FK` (`role_id`),
  CONSTRAINT `std_portal_professor_evaluation_setting_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_setting_usr_role_FK` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_professor_evaluation_setting_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_request`
--

DROP TABLE IF EXISTS `std_portal_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_request` (
  `portal_request_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`portal_request_id`),
  UNIQUE KEY `std_portal_request_un_name` (`name`,`enterprise_id`),
  UNIQUE KEY `std_portal_request_un_uuid` (`uuid`),
  KEY `std_portal_request_FK` (`enterprise_id`),
  KEY `std_portal_request_FK_1` (`create_user_id`),
  CONSTRAINT `std_portal_request_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_portal_request_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_user`
--

DROP TABLE IF EXISTS `std_portal_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_user` (
  `portal_user_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `username` varchar(30) NOT NULL,
  `password` varchar(100) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `uuid` varchar(100) DEFAULT NULL,
  `student_id` bigint NOT NULL,
  PRIMARY KEY (`portal_user_id`),
  UNIQUE KEY `std_portal_user_UN` (`enterprise_id`,`username`),
  KEY `std_portal_user_FK_1` (`create_user_id`),
  KEY `std_portal_user_FK_2` (`student_id`),
  CONSTRAINT `std_portal_user_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_portal_user_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_portal_user_FK_2` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47349 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_user_recovery`
--

DROP TABLE IF EXISTS `std_portal_user_recovery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_user_recovery` (
  `recovery_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) DEFAULT NULL,
  `portal_user_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expire_date` datetime DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Used (U)',
  PRIMARY KEY (`recovery_id`),
  UNIQUE KEY `std_portal_recovery_UN` (`uuid`),
  KEY `std_portal_recovery_FK` (`portal_user_id`),
  CONSTRAINT `std_portal_recovery_FK` FOREIGN KEY (`portal_user_id`) REFERENCES `std_portal_user` (`portal_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=109093 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_visa_setting`
--

DROP TABLE IF EXISTS `std_portal_visa_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_visa_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `std_portal_visa_setting_UN` (`enterprise_id`),
  CONSTRAINT `std_portal_visa_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_portal_visa_transaction`
--

DROP TABLE IF EXISTS `std_portal_visa_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_portal_visa_transaction` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `visa_transaction_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `std_portal_visa_transaction_FK` (`student_id`),
  KEY `std_portal_visa_transaction_FK_1` (`visa_transaction_id`),
  CONSTRAINT `std_portal_visa_transaction_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_portal_visa_transaction_FK_1` FOREIGN KEY (`visa_transaction_id`) REFERENCES `vis_transaction` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45827 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_process`
--

DROP TABLE IF EXISTS `std_process`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_process` (
  `process_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `can_be_done_in_portal` tinyint(1) NOT NULL DEFAULT '0',
  `can_choose_studying_time` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`process_id`),
  UNIQUE KEY `std_process_un` (`uuid`),
  KEY `std_process_FK` (`enterprise_id`),
  KEY `std_process_FK_1` (`create_user_id`),
  CONSTRAINT `std_process_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_process_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_reference`
--

DROP TABLE IF EXISTS `std_reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_reference` (
  `reference_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`reference_id`),
  UNIQUE KEY `std_reference_un` (`uuid`),
  KEY `std_reference_FK` (`enterprise_id`),
  KEY `std_reference_FK_1` (`create_user_id`),
  CONSTRAINT `std_reference_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_reference_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_reinscription`
--

DROP TABLE IF EXISTS `std_reinscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_reinscription` (
  `reinscription_id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` bigint NOT NULL,
  `period_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `career_id` bigint NOT NULL,
  `branch_id` bigint DEFAULT NULL,
  `studying_cycle_id` bigint DEFAULT NULL,
  `studying_time_id` bigint DEFAULT NULL,
  `setup` json DEFAULT NULL,
  `status_code` varchar(100) NOT NULL,
  `administrative_check` tinyint(1) DEFAULT NULL,
  `inscription_id` bigint DEFAULT NULL,
  PRIMARY KEY (`reinscription_id`),
  UNIQUE KEY `std_reinscription_UN` (`uuid`),
  KEY `std_reinscription_FK_1` (`period_id`),
  KEY `std_reinscription_FK_3` (`career_id`),
  KEY `std_reinscription_FK_4` (`branch_id`),
  KEY `std_reinscription_FK_5` (`studying_cycle_id`),
  KEY `std_reinscription_FK_6` (`studying_time_id`),
  KEY `idx_std_reinscription_period_id` (`period_id`),
  KEY `idx_std_reinscription_student_id` (`student_id`),
  KEY `idx_std_reinscription_branch_id` (`branch_id`),
  KEY `idx_std_reinscription_career_id` (`career_id`),
  KEY `idx_std_reinscription_studying_cycle_id` (`studying_cycle_id`),
  KEY `idx_std_reinscription_studying_time_id` (`studying_time_id`),
  KEY `std_reinscription_std_inscription_FK` (`inscription_id`),
  CONSTRAINT `std_reinscription_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_reinscription_FK_1` FOREIGN KEY (`period_id`) REFERENCES `std_period` (`period_id`),
  CONSTRAINT `std_reinscription_FK_3` FOREIGN KEY (`career_id`) REFERENCES `std_career` (`career_id`),
  CONSTRAINT `std_reinscription_FK_4` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`),
  CONSTRAINT `std_reinscription_FK_5` FOREIGN KEY (`studying_cycle_id`) REFERENCES `std_studying_cycle` (`studying_cycle_id`),
  CONSTRAINT `std_reinscription_FK_6` FOREIGN KEY (`studying_time_id`) REFERENCES `std_studying_time` (`studying_time_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `std_reinscription_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`),
  CONSTRAINT `std_reinscription_std_inscription_FK` FOREIGN KEY (`inscription_id`) REFERENCES `std_inscription` (`inscription_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=28104 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_request`
--

DROP TABLE IF EXISTS `std_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_request` (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT NULL,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `std_requests_un` (`uuid`),
  KEY `std_requests_FK` (`enterprise_id`),
  KEY `std_requests_FK_1` (`create_user_id`),
  CONSTRAINT `std_requests_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_requests_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_scolarship`
--

DROP TABLE IF EXISTS `std_scolarship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_scolarship` (
  `scolarship_id` bigint NOT NULL AUTO_INCREMENT,
  `type_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`scolarship_id`),
  UNIQUE KEY `std_scolarship_UN` (`uuid`),
  KEY `std_scolarship_FK` (`student_id`),
  KEY `std_scolarship_FK_1` (`create_user_id`),
  KEY `std_scolarship_FK_2` (`type_id`),
  CONSTRAINT `std_scolarship_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`),
  CONSTRAINT `std_scolarship_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_scolarship_FK_2` FOREIGN KEY (`type_id`) REFERENCES `std_scolarship_type` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_scolarship_type`
--

DROP TABLE IF EXISTS `std_scolarship_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_scolarship_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `std_scolarship_type_UN` (`uuid`),
  KEY `std_scolarship_type_FK` (`enterprise_id`),
  KEY `std_scolarship_type_FK_1` (`create_user_id`),
  CONSTRAINT `std_scolarship_type_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_scolarship_type_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_student`
--

DROP TABLE IF EXISTS `std_student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_student` (
  `student_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `student_id_card` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(100) NOT NULL,
  `dpi` varchar(20) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'A- Activo\nS- Suspendido\nI-Inactivo',
  `suspension_reason` varchar(255) DEFAULT NULL,
  `suspension_date` date DEFAULT NULL,
  `suspension_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `std_student_UN` (`uuid`),
  UNIQUE KEY `std_student_card_UN` (`enterprise_id`,`student_id_card`),
  KEY `std_student_FK` (`enterprise_id`),
  KEY `std_student_FK_1` (`create_user_id`),
  KEY `std_student_FK_2` (`reference_id`),
  KEY `std_student_usr_user_FK` (`suspension_user_id`),
  CONSTRAINT `std_student_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_student_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_student_FK_2` FOREIGN KEY (`reference_id`) REFERENCES `std_reference` (`reference_id`),
  CONSTRAINT `std_student_usr_user_FK` FOREIGN KEY (`suspension_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=139220 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_student_appsheet`
--

DROP TABLE IF EXISTS `std_student_appsheet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_student_appsheet` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `numero_carne` varchar(20) NOT NULL,
  `nombre_completo` varchar(255) NOT NULL,
  `carrera` varchar(100) NOT NULL,
  `sede` varchar(100) NOT NULL,
  `formulario_inscripcion` text,
  `fotografias` text,
  `fotostatica_titulo_medio` text,
  `fotocopia_titulo` text,
  `certificacion_estudios_medio` text,
  `fotocopia_dpi` text,
  `partida_nacimiento` text,
  `verificacion_cgc_mineduc` text,
  `tipificacion_registro` text,
  `certificador_expediente` varchar(255) DEFAULT NULL,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `unique_carne` (`numero_carne`)
) ENGINE=InnoDB AUTO_INCREMENT=7893 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_student_portal_request`
--

DROP TABLE IF EXISTS `std_student_portal_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_student_portal_request` (
  `student_portal_request_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `uuid` varchar(100) NOT NULL,
  `portal_request_id` bigint NOT NULL,
  `student_id` bigint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(100) DEFAULT NULL,
  `expire_date` date DEFAULT NULL,
  `setup` longtext,
  `order_id` bigint DEFAULT NULL,
  PRIMARY KEY (`student_portal_request_id`),
  UNIQUE KEY `std_portal_student_request_unique` (`uuid`),
  KEY `std_student_portal_request_usr_enterprise_FK` (`enterprise_id`),
  KEY `std_student_portal_request_std_student_FK` (`student_id`),
  KEY `std_student_portal_request_std_portal_request_FK` (`portal_request_id`),
  CONSTRAINT `std_student_portal_request_std_portal_request_FK` FOREIGN KEY (`portal_request_id`) REFERENCES `std_portal_request` (`portal_request_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_student_portal_request_std_student_FK` FOREIGN KEY (`student_id`) REFERENCES `std_student` (`student_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `std_student_portal_request_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=7066 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_studying_cycle`
--

DROP TABLE IF EXISTS `std_studying_cycle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_studying_cycle` (
  `studying_cycle_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `is_active` tinyint DEFAULT NULL,
  `order` int DEFAULT NULL,
  PRIMARY KEY (`studying_cycle_id`),
  UNIQUE KEY `std_studying_cycle_UN_uuid` (`uuid`),
  UNIQUE KEY `std_studying_cycle_UN_name` (`name`,`enterprise_id`),
  KEY `std_studying_cycle_FK` (`enterprise_id`),
  KEY `std_studying_cycle_FK_1` (`create_user_id`),
  KEY `std_studying_cycle_enterprise_id_IDX` (`enterprise_id`) USING BTREE,
  CONSTRAINT `std_studying_cycle_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_studying_cycle_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_studying_time`
--

DROP TABLE IF EXISTS `std_studying_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_studying_time` (
  `studying_time_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`studying_time_id`),
  UNIQUE KEY `std_studying_time_UN_uuid` (`uuid`),
  UNIQUE KEY `std_studying_time_UN_name` (`name`,`enterprise_id`),
  KEY `std_studying_time_FK` (`enterprise_id`),
  KEY `std_studying_time_FK_1` (`create_user_id`),
  CONSTRAINT `std_studying_time_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `std_studying_time_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `std_user`
--

DROP TABLE IF EXISTS `std_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `std_user` (
  `user_id` bigint NOT NULL,
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `branch_id` bigint NOT NULL,
  `limit_to_branch_students` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`record_id`),
  KEY `std_user_FK` (`user_id`),
  KEY `std_user_FK_1` (`branch_id`),
  CONSTRAINT `std_user_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `std_user_FK_1` FOREIGN KEY (`branch_id`) REFERENCES `std_branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `student_inscriptions`
--

DROP TABLE IF EXISTS `student_inscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_inscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reinscription_for` datetime DEFAULT NULL,
  `year` int DEFAULT NULL,
  `cycle` int DEFAULT NULL,
  `current_semester` int NOT NULL DEFAULT '1',
  `inscription_id` int NOT NULL COMMENT 'References the current inscription period',
  `branch_id` bigint DEFAULT NULL,
  `career_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92827 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `student_request_ticket_setting`
--

DROP TABLE IF EXISTS `student_request_ticket_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_request_ticket_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `student_request_ticket_setting_unique` (`enterprise_id`),
  KEY `student_request_ticket_setting_usr_user_FK` (`create_user_id`),
  CONSTRAINT `student_request_ticket_setting_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `student_request_ticket_setting_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sup_service`
--

DROP TABLE IF EXISTS `sup_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sup_service` (
  `service_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `customer_id` bigint DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `support_hours` smallint DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`service_id`),
  KEY `sup_service_FK` (`enterprise_id`),
  KEY `sup_service_FK_1` (`create_user_id`),
  KEY `sup_service_FK_2` (`customer_id`),
  CONSTRAINT `sup_service_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `sup_service_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `sup_service_FK_2` FOREIGN KEY (`customer_id`) REFERENCES `ctm_customer` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sup_setting`
--

DROP TABLE IF EXISTS `sup_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sup_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `sup_setting_UN` (`enterprise_id`),
  KEY `sup_setting_FK_1` (`create_user_id`),
  CONSTRAINT `sup_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `sup_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sup_support`
--

DROP TABLE IF EXISTS `sup_support`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sup_support` (
  `support_id` bigint NOT NULL AUTO_INCREMENT,
  `service_id` bigint NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `elapsed_hours` decimal(10,2) DEFAULT NULL,
  `elapsed_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`support_id`),
  KEY `sup_support_FK` (`service_id`),
  KEY `sup_support_FK_1` (`create_user_id`),
  CONSTRAINT `sup_support_FK` FOREIGN KEY (`service_id`) REFERENCES `sup_service` (`service_id`),
  CONSTRAINT `sup_support_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `survey_template`
--

DROP TABLE IF EXISTS `survey_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `survey_template_FK` (`enterprise_id`),
  KEY `survey_template_FK_1` (`create_user_id`),
  CONSTRAINT `survey_template_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `survey_template_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_bug`
--

DROP TABLE IF EXISTS `sys_bug`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_bug` (
  `bug_id` bigint NOT NULL AUTO_INCREMENT,
  `description` text,
  `images` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`bug_id`),
  KEY `sys_bug_FK` (`create_user_id`),
  CONSTRAINT `sys_bug_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_home_module`
--

DROP TABLE IF EXISTS `sys_home_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_home_module` (
  `module_id` bigint NOT NULL,
  PRIMARY KEY (`module_id`),
  CONSTRAINT `sys_home_module_FK` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_module`
--

DROP TABLE IF EXISTS `sys_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_module` (
  `module_id` bigint NOT NULL AUTO_INCREMENT,
  `setup` longtext NOT NULL,
  PRIMARY KEY (`module_id`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_resource`
--

DROP TABLE IF EXISTS `sys_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_resource` (
  `resource_id` bigint NOT NULL AUTO_INCREMENT,
  `resource` varchar(200) NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `module_id` bigint DEFAULT NULL,
  PRIMARY KEY (`resource_id`),
  UNIQUE KEY `sys_resource_UN` (`resource`),
  KEY `sys_resource_FK` (`module_id`),
  CONSTRAINT `sys_resource_FK` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`)
) ENGINE=InnoDB AUTO_INCREMENT=861 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sys_template`
--

DROP TABLE IF EXISTS `sys_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `template` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `icon` varchar(50) DEFAULT NULL,
  `type` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  KEY `sys_template_FK` (`enterprise_id`),
  CONSTRAINT `sys_template_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbx_setup`
--

DROP TABLE IF EXISTS `tbx_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbx_setup` (
  `setup_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setup_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `tbx_setup_FK_1` (`create_user_id`),
  CONSTRAINT `tbx_setup_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tbx_setup_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbx_user`
--

DROP TABLE IF EXISTS `tbx_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbx_user` (
  `tibix_user_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) NOT NULL,
  `status_code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`tibix_user_id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `tbx_user_UN` (`enterprise_id`,`email`),
  CONSTRAINT `tbx_user_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbx_user_gbpay`
--

DROP TABLE IF EXISTS `tbx_user_gbpay`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbx_user_gbpay` (
  `user_gbpay_id` bigint NOT NULL AUTO_INCREMENT,
  `tibix_user_id` bigint DEFAULT NULL,
  `setup` longtext,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`user_gbpay_id`),
  KEY `tbx_user_FK_usr` (`tibix_user_id`),
  CONSTRAINT `tbx_user_FK_usr` FOREIGN KEY (`tibix_user_id`) REFERENCES `tbx_user` (`tibix_user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teacher_rating_rating`
--

DROP TABLE IF EXISTS `teacher_rating_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_rating_rating` (
  `rating_id` bigint NOT NULL AUTO_INCREMENT,
  `rating_user_id` bigint NOT NULL COMMENT 'User id who''s evaluating the rated user',
  `rated_user_id` bigint NOT NULL COMMENT 'User id who''s being rated',
  `rating_date` date NOT NULL,
  `setup` longtext NOT NULL,
  `scoring` decimal(10,0) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) NOT NULL,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `teacher_rating_rating_FK` (`rating_user_id`),
  KEY `teacher_rating_rating_FK_1` (`rated_user_id`),
  KEY `teacher_rating_rating_FK_2` (`create_user_id`),
  CONSTRAINT `teacher_rating_rating_FK` FOREIGN KEY (`rating_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `teacher_rating_rating_FK_1` FOREIGN KEY (`rated_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `teacher_rating_rating_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teacher_rating_setting`
--

DROP TABLE IF EXISTS `teacher_rating_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_rating_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `teacher_rating_setting_FK_1` (`create_user_id`),
  CONSTRAINT `teacher_rating_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `teacher_rating_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temp_inscription`
--

DROP TABLE IF EXISTS `temp_inscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_inscription` (
  `student_id` bigint DEFAULT NULL,
  `period_id` bigint DEFAULT NULL,
  `branch_id` bigint DEFAULT NULL,
  `career_id` bigint DEFAULT NULL,
  `cantidad` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tmp_no_del_inscription`
--

DROP TABLE IF EXISTS `tmp_no_del_inscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tmp_no_del_inscription` (
  `inscription_id` bigint DEFAULT NULL,
  `student_id` bigint DEFAULT NULL,
  `period_id` bigint DEFAULT NULL,
  `branch_id` bigint DEFAULT NULL,
  `career_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` tinytext,
  `student_id` int unsigned DEFAULT NULL,
  `total` double DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `paper_number` tinytext,
  `bank_transaction_id` tinytext,
  `bank_name` tinytext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73713 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tutorials`
--

DROP TABLE IF EXISTS `tutorials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tutorials` (
  `tutorial_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `link` varchar(100) NOT NULL,
  `uuid` varchar(50) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `role_id` bigint DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `target_type` enum('student','role') NOT NULL,
  PRIMARY KEY (`tutorial_id`),
  UNIQUE KEY `tutorials_unique` (`uuid`),
  KEY `tutorials_usr_enterprise_FK` (`enterprise_id`),
  KEY `tutorials_usr_user_FK` (`create_user_id`),
  KEY `tutorials_usr_role_FK` (`role_id`),
  CONSTRAINT `tutorials_usr_enterprise_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tutorials_usr_role_FK` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tutorials_usr_user_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_email_messaging`
--

DROP TABLE IF EXISTS `usr_email_messaging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_email_messaging` (
  `messaging_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `is_default` tinyint(1) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`messaging_id`),
  UNIQUE KEY `usr_email_messaging_UN` (`uuid`),
  KEY `usr_email_messaging_FK` (`enterprise_id`),
  KEY `usr_email_messaging_FK_1` (`create_user_id`),
  CONSTRAINT `usr_email_messaging_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `usr_email_messaging_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_enterprise`
--

DROP TABLE IF EXISTS `usr_enterprise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_enterprise` (
  `enterprise_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `codename` varchar(100) NOT NULL,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Active (A), Inactive (I), Deleted (D)',
  `configuration` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) DEFAULT NULL,
  `authentication` longtext,
  PRIMARY KEY (`enterprise_id`),
  UNIQUE KEY `usr_enterprise_UN` (`codename`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_job`
--

DROP TABLE IF EXISTS `usr_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_job` (
  `job_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `job_possition_id` bigint NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  `salary` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`job_id`),
  UNIQUE KEY `usr_job_UN` (`uuid`),
  KEY `usr_job_FK` (`user_id`),
  KEY `usr_job_FK_1` (`create_user_id`),
  KEY `usr_job_FK_2` (`job_possition_id`),
  CONSTRAINT `usr_job_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `usr_job_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `usr_job_FK_2` FOREIGN KEY (`job_possition_id`) REFERENCES `usr_job_possition` (`job_possition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_job_possition`
--

DROP TABLE IF EXISTS `usr_job_possition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_job_possition` (
  `job_possition_id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(50) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`job_possition_id`),
  UNIQUE KEY `usr_job_possition_UN` (`uuid`),
  KEY `usr_job_possition_FK` (`enterprise_id`),
  KEY `usr_job_possition_FK_1` (`create_user_id`),
  CONSTRAINT `usr_job_possition_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `usr_job_possition_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_module_suscription`
--

DROP TABLE IF EXISTS `usr_module_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_module_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `module_id` bigint NOT NULL,
  `setup` longtext,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `usr_module_suscription_UN` (`enterprise_id`,`module_id`),
  KEY `usr_module_suscription_FK_1` (`create_user_id`),
  KEY `usr_module_suscription_FK_2` (`module_id`),
  CONSTRAINT `usr_module_suscription_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `usr_module_suscription_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `usr_module_suscription_FK_2` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`)
) ENGINE=InnoDB AUTO_INCREMENT=319 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_resource_log`
--

DROP TABLE IF EXISTS `usr_resource_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_resource_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `resource_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `args` mediumtext,
  PRIMARY KEY (`log_id`),
  KEY `usr_resource_log_FK` (`user_id`),
  KEY `usr_resource_log_FK_1` (`resource_id`),
  CONSTRAINT `usr_resource_log_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `usr_resource_log_FK_1` FOREIGN KEY (`resource_id`) REFERENCES `sys_resource` (`resource_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12358252 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_role`
--

DROP TABLE IF EXISTS `usr_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `encrypted_id` varchar(100) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `godlike` tinyint(1) DEFAULT '0',
  `login_redirect_to` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `usr_role_UN` (`enterprise_id`,`name`),
  KEY `usr_role_FK_1` (`create_user_id`),
  CONSTRAINT `usr_role_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_role_module_suscription`
--

DROP TABLE IF EXISTS `usr_role_module_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_role_module_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `module_id` bigint NOT NULL,
  `setup` longtext,
  `status_code` varchar(1) DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `usr_role_module_suscription_UN` (`role_id`,`module_id`),
  KEY `usr_role_module_suscription_FK` (`enterprise_id`),
  KEY `usr_role_module_suscription_FK_1` (`create_user_id`),
  KEY `usr_role_module_suscription_FK_2` (`module_id`),
  KEY `usr_role_module_suscription_FK_3` (`role_id`),
  CONSTRAINT `usr_role_module_suscription_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_module_suscription_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_module_suscription_FK_2` FOREIGN KEY (`module_id`) REFERENCES `sys_module` (`module_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_module_suscription_FK_3` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=576 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_role_permission`
--

DROP TABLE IF EXISTS `usr_role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_role_permission` (
  `permission_id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `resource_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  KEY `usr_role_permission_FK` (`role_id`),
  KEY `usr_role_permission_FK_1` (`resource_id`),
  KEY `usr_role_permission_FK_2` (`create_user_id`),
  CONSTRAINT `usr_role_permission_FK` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_permission_FK_1` FOREIGN KEY (`resource_id`) REFERENCES `sys_resource` (`resource_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `usr_role_permission_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=99889 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_role_suscription`
--

DROP TABLE IF EXISTS `usr_role_suscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_role_suscription` (
  `suscription_id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `encrypted_id` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`suscription_id`),
  UNIQUE KEY `usr_role_suscription_UN_1` (`role_id`,`user_id`),
  UNIQUE KEY `usr_role_suscription_UN_2` (`encrypted_id`),
  KEY `usr_role_suscription_FK` (`user_id`),
  KEY `usr_role_suscription_FK_2` (`create_user_id`),
  CONSTRAINT `usr_role_suscription_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`),
  CONSTRAINT `usr_role_suscription_FK_1` FOREIGN KEY (`role_id`) REFERENCES `usr_role` (`role_id`),
  CONSTRAINT `usr_role_suscription_FK_2` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5090 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_session`
--

DROP TABLE IF EXISTS `usr_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_session` (
  `session_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` datetime DEFAULT NULL,
  `token` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `permissions` longtext,
  `uuid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `usr_session_UN` (`uuid`),
  KEY `usr_session_FK` (`user_id`),
  CONSTRAINT `usr_session_FK` FOREIGN KEY (`user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=83735 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_sms_messaging`
--

DROP TABLE IF EXISTS `usr_sms_messaging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_sms_messaging` (
  `messaging_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `is_default` tinyint(1) DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`messaging_id`),
  UNIQUE KEY `usr_sms_messaging_UN` (`uuid`),
  KEY `usr_sms_messaging_FK` (`enterprise_id`),
  KEY `usr_sms_messaging_FK_1` (`create_user_id`),
  CONSTRAINT `usr_sms_messaging_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `usr_sms_messaging_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usr_user`
--

DROP TABLE IF EXISTS `usr_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usr_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `username` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(100) NOT NULL,
  `password` varchar(100) DEFAULT NULL,
  `configuration` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'A' COMMENT 'Active (A), Inactive (I)',
  `encrypted_id` varchar(100) DEFAULT NULL,
  `origin` varchar(100) DEFAULT 'modul',
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `usr_user_UN` (`enterprise_id`,`username`),
  KEY `usr_user_FK_1` (`create_user_id`),
  CONSTRAINT `usr_user_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `usr_user_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8145 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vis_reverse`
--

DROP TABLE IF EXISTS `vis_reverse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vis_reverse` (
  `reverse_id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint NOT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Processed (P), Errored (E)',
  PRIMARY KEY (`reverse_id`),
  UNIQUE KEY `vis_reverse_UN` (`uuid`),
  KEY `vis_reverse_FK` (`transaction_id`),
  KEY `vis_reverse_FK_1` (`create_user_id`),
  CONSTRAINT `vis_reverse_FK` FOREIGN KEY (`transaction_id`) REFERENCES `vis_transaction` (`transaction_id`),
  CONSTRAINT `vis_reverse_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vis_setting`
--

DROP TABLE IF EXISTS `vis_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vis_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `vis_setting_UN` (`enterprise_id`),
  KEY `vis_setting_FK_1` (`create_user_id`),
  CONSTRAINT `vis_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `vis_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vis_transaction`
--

DROP TABLE IF EXISTS `vis_transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vis_transaction` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `setting_uuid` varchar(50) NOT NULL,
  `enterprise_id` bigint NOT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(50) NOT NULL,
  `status_code` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT 'Processed (P), Errored (E)',
  `type_code` varchar(1) DEFAULT NULL COMMENT 'Sale (S), Void (V)',
  `void_request_data` json DEFAULT NULL,
  `void_response_data` json DEFAULT NULL,
  `card_info` json DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `vis_transaction_UN` (`uuid`),
  KEY `vis_transaction_FK` (`enterprise_id`),
  CONSTRAINT `vis_transaction_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64095 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vis_void`
--

DROP TABLE IF EXISTS `vis_void`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vis_void` (
  `void_id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint NOT NULL,
  `request_data` longtext,
  `response_data` longtext,
  `uuid` varchar(50) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT NULL COMMENT 'Processed (P), Errored (E)',
  PRIMARY KEY (`void_id`),
  UNIQUE KEY `vis_void_UN` (`uuid`),
  KEY `vis_void_FK` (`transaction_id`),
  KEY `vis_void_FK_1` (`create_user_id`),
  CONSTRAINT `vis_void_FK` FOREIGN KEY (`transaction_id`) REFERENCES `vis_transaction` (`transaction_id`),
  CONSTRAINT `vis_void_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_generator_bulk`
--

DROP TABLE IF EXISTS `visalink_generator_bulk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_generator_bulk` (
  `bulk_id` bigint NOT NULL AUTO_INCREMENT,
  `status_code` varchar(1) DEFAULT 'W' COMMENT 'Waiting (W), Running (R), Finished (F), Errored (E), Stopped (S), Iddle (I)',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `bulk_size` decimal(10,0) DEFAULT NULL,
  `result` longtext,
  `scheduled_date` datetime DEFAULT NULL,
  PRIMARY KEY (`bulk_id`),
  KEY `visalink_bulk_FK` (`create_user_id`),
  CONSTRAINT `visalink_bulk_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_generator_imported`
--

DROP TABLE IF EXISTS `visalink_generator_imported`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_generator_imported` (
  `record_id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(100) DEFAULT NULL,
  `cycle` varchar(100) DEFAULT NULL,
  `quota` decimal(10,0) DEFAULT NULL,
  `load_date` datetime DEFAULT NULL,
  `message` varchar(500) DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `status_code` varchar(1) DEFAULT 'W' COMMENT 'Waiting (W), Created (C), Errored (E)',
  `bulk_id` bigint NOT NULL,
  `result` longtext,
  PRIMARY KEY (`record_id`),
  KEY `visalink_imported_FK` (`create_user_id`),
  KEY `visalink_imported_FK_1` (`bulk_id`),
  CONSTRAINT `visalink_imported_FK` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `visalink_imported_FK_1` FOREIGN KEY (`bulk_id`) REFERENCES `visalink_generator_bulk` (`bulk_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_generator_link`
--

DROP TABLE IF EXISTS `visalink_generator_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_generator_link` (
  `link_id` bigint NOT NULL AUTO_INCREMENT,
  `promissory_note` varchar(100) NOT NULL,
  `quota` decimal(10,0) DEFAULT NULL,
  `message` varchar(400) DEFAULT NULL,
  `link` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  `uuid` varchar(100) NOT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_generator_setting`
--

DROP TABLE IF EXISTS `visalink_generator_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_generator_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `visalink_generator_setting_FK_1` (`create_user_id`),
  CONSTRAINT `visalink_generator_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `visalink_generator_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_link`
--

DROP TABLE IF EXISTS `visalink_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_link` (
  `link_id` bigint NOT NULL AUTO_INCREMENT,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `uuid` varchar(100) DEFAULT NULL,
  `enterprise_id` bigint DEFAULT NULL,
  `link` longtext,
  `internal_code` varchar(100) DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `quotas` varchar(100) DEFAULT NULL,
  `internal_name` varchar(100) DEFAULT NULL,
  `description` longtext,
  `quota` decimal(10,2) DEFAULT NULL,
  `social_networks` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `visalink_link_FK` (`enterprise_id`),
  CONSTRAINT `visalink_link_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_setting`
--

DROP TABLE IF EXISTS `visalink_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_setting` (
  `setting_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `enterprise_id` (`enterprise_id`),
  KEY `visalink_setting_FK_1` (`create_user_id`),
  CONSTRAINT `visalink_setting_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `visalink_setting_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visalink_token`
--

DROP TABLE IF EXISTS `visalink_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visalink_token` (
  `token_id` bigint NOT NULL AUTO_INCREMENT,
  `request` longtext,
  `response` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `visalink_user` varchar(50) NOT NULL,
  PRIMARY KEY (`token_id`),
  KEY `visalink_token_FK` (`visalink_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vmo_module`
--

DROP TABLE IF EXISTS `vmo_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vmo_module` (
  `module_id` bigint NOT NULL AUTO_INCREMENT,
  `enterprise_id` bigint NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `uuid` varchar(50) DEFAULT NULL,
  `setup` longtext,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `create_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`module_id`),
  KEY `vmo_module_FK` (`enterprise_id`),
  KEY `vmo_module_FK_1` (`create_user_id`),
  CONSTRAINT `vmo_module_FK` FOREIGN KEY (`enterprise_id`) REFERENCES `usr_enterprise` (`enterprise_id`),
  CONSTRAINT `vmo_module_FK_1` FOREIGN KEY (`create_user_id`) REFERENCES `usr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'modul_dev'
--
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-21 10:10:08

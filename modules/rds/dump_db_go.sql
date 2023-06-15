-- CREATE DATABASE dummy_db;

USE dummy_db;

#
# TABLE STRUCTURE FOR: customers
#

-- DROP TABLE IF EXISTS `customers`;

-- CREATE TABLE `customers` (
--   `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
--   `name` varchar(100) NOT NULL,
--   `last_name` varchar(100) NOT NULL,
--   `age` varchar(255) NOT NULL,
--   `birthday` date DEFAULT NULL,
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `customers` (`id`, `name`, `last_name`, `age`, `birthday`) VALUES (1, 'debitis', 'Hilll', '2538', '1995-05-16') GO 1000;

#
# TABLE STRUCTURE FOR: item
#

-- DROP TABLE IF EXISTS `item`;

-- CREATE TABLE `item` (
--   `name` varchar(100) NOT NULL,
--   `price` decimal(10,2) NOT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `item` (`name`, `price`) VALUES ('est', '94391.63') GO 1000;

#
# TABLE STRUCTURE FOR: user
#

-- DROP TABLE IF EXISTS `user`;

-- CREATE TABLE `user` (
--   `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
--   `name` varchar(100) NOT NULL,
--   `last_name` varchar(100) NOT NULL,
--   `age` varchar(255) NOT NULL,
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `user` (`id`, `name`, `last_name`, `age`) VALUES (1, 'corrupti', 'Schaden', '634') GO 1000;

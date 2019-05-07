-- --------------------------------------------------------
-- Host:                         mysql-mariadb-oce02-11-101.zap-hosting.com
-- Server version:               10.1.34-MariaDB-1~jessie - mariadb.org binary distribution
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             10.1.0.5464
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for zap346582-1
CREATE DATABASE IF NOT EXISTS `zap346582-1` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `zap346582-1`;

-- Dumping structure for table zap346582-1.jam_drugzones
CREATE TABLE IF NOT EXISTS `jam_drugzones` (
  `zone` varchar(50) DEFAULT NULL,
  `players` int(11) DEFAULT NULL,
  `safelockout` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table zap346582-1.jam_drugzones: ~4 rows (approximately)
/*!40000 ALTER TABLE `jam_drugzones` DISABLE KEYS */;
INSERT INTO `jam_drugzones` (`zone`, `players`, `safelockout`) VALUES
	('Biker HQ', 0, 0),
	('Cocaine Lab', 0, 0),
	('Meth Sales', 0, 0),
	('Meth Lab', 0, 0);
/*!40000 ALTER TABLE `jam_drugzones` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

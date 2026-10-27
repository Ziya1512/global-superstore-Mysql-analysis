-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: superstore_analysis
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `monthly_orders`
--

DROP TABLE IF EXISTS `monthly_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `monthly_orders` (
  `Month_of_Order` varchar(9) DEFAULT NULL,
  `No_od_Orders` bigint NOT NULL DEFAULT '0',
  `Year_of_Order` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monthly_orders`
--

LOCK TABLES `monthly_orders` WRITE;
/*!40000 ALTER TABLE `monthly_orders` DISABLE KEYS */;
INSERT INTO `monthly_orders` VALUES ('April',564,2011),('August',878,2011),('December',1263,2011),('February',378,2011),('January',433,2011),('July',495,2011),('June',917,2011),('March',539,2011),('May',566,2011),('November',1139,2011),('October',774,2011),('September',1052,2011),('April',657,2012),('August',1083,2012),('December',1284,2012),('February',429,2012),('January',539,2012),('July',659,2012),('June',1136,2012),('March',662,2012),('May',840,2012),('November',1460,2012),('October',990,2012),('September',1223,2012),('April',785,2013),('August',1442,2013),('December',1602,2013),('February',605,2013),('January',709,2013),('July',925,2013),('June',1530,2013),('March',766,2013),('May',1057,2013),('November',1596,2013),('October',1100,2013),('September',1682,2013),('April',1051,2014),('August',1675,2014),('December',2153,2014),('February',756,2014),('January',918,2014),('July',1087,2014),('June',1748,2014),('March',1068,2014),('May',1284,2014),('November',2147,2014),('October',1625,2014),('September',2018,2014);
/*!40000 ALTER TABLE `monthly_orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-28  3:53:32

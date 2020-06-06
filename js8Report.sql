-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 06, 2020 at 08:08 PM
-- Server version: 5.7.30-0ubuntu0.16.04.1-log
-- PHP Version: 7.0.33-0ubuntu0.16.04.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `SpaceWeather`
--

-- --------------------------------------------------------

--
-- Table structure for table `js8Report`
--

CREATE TABLE `js8Report` (
  `ID` int(11) NOT NULL,
  `TimeStamp` datetime NOT NULL,
  `SignalLevel` int(5) NOT NULL,
  `Station` text COLLATE utf8_bin NOT NULL,
  `Receiver` text COLLATE utf8_bin NOT NULL,
  `Distance` int(5) DEFAULT NULL,
  `Bearing` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `js8Report`
--
ALTER TABLE `js8Report`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `TimeStamp` (`TimeStamp`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `js8Report`
--
ALTER TABLE `js8Report`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

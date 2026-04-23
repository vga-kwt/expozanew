-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 19, 2026 at 08:09 AM
-- Server version: 8.0.44-0ubuntu0.24.04.2
-- PHP Version: 8.2.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `expoza`
--

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `line_1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `line_2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` bigint UNSIGNED NOT NULL,
  `state_id` bigint UNSIGNED DEFAULT NULL,
  `city_id` bigint UNSIGNED DEFAULT NULL,
  `pincode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ads`
--

CREATE TABLE `ads` (
  `id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED DEFAULT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `link_type` enum('product','vendor','expo','external') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_id` bigint UNSIGNED DEFAULT NULL,
  `banners` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','suspended','draft') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `external_link` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ads`
--

INSERT INTO `ads` (`id`, `vendor_id`, `title_en`, `title_ar`, `description_en`, `description_ar`, `link_type`, `link_id`, `banners`, `status`, `external_link`, `priority`, `start_date`, `end_date`, `created_at`, `updated_at`, `deleted_at`) VALUES
(4, NULL, 'COMING SOON', 'قريباً', NULL, NULL, 'external', NULL, 'ads/banners/i2vCJAkZIgz6bodObHfwiDUUwSs0gRp4WJ8bWjcG.jpg', 'active', 'https://www.instagram.com/expoza.app?igsh=MWFyZng4YWw2aW8wbQ==', 50, '2026-01-16 22:59:00', '2026-02-04 02:30:00', '2026-01-17 01:27:01', '2026-01-17 01:28:45', NULL),
(5, NULL, 'Coming soon 2', 'قريباً.', NULL, NULL, 'external', NULL, 'ads/banners/8MKmduu107rFz0wyYobg2fJn1uaeGO10k9V8waFV.jpg', 'active', 'https://www.instagram.com/expoza.app?igsh=MWFyZng4YWw2aW8wbQ==', 1, '2026-01-16 23:03:00', '2026-02-04 23:59:00', '2026-01-17 01:31:03', '2026-01-17 01:31:20', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attributes`
--

CREATE TABLE `attributes` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` json DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `admin_id` bigint UNSIGNED NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `changes` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `admin_id`, `action`, `module`, `description`, `changes`, `created_at`, `deleted_at`) VALUES
(1, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-19 09:55:58', NULL),
(2, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-21 14:56:21', NULL),
(3, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-21 15:31:48', NULL),
(4, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-21 15:33:30', NULL),
(5, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-21 15:35:08', NULL),
(6, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-21 16:13:09', NULL),
(7, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-22 01:24:19', NULL),
(8, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-22 09:48:36', NULL),
(9, 1, 'create', 'expo', 'Created new expo: Arpit Test', '\"{\\\"expo_id\\\":2,\\\"name_en\\\":\\\"Arpit Test\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-22T09:50\\\",\\\"end_date\\\":\\\"2025-12-26T09:50\\\"}\"', '2025-12-22 09:50:44', NULL),
(10, 1, 'delete', 'expo', 'Deleted expo: Arpit Test', '\"{\\\"expo_id\\\":2,\\\"name_en\\\":\\\"Arpit Test\\\",\\\"name_ar\\\":\\\"Arpit Test\\\",\\\"status\\\":\\\"active\\\"}\"', '2025-12-22 09:52:30', NULL),
(11, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-22 14:55:53', NULL),
(12, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-22 14:57:37', NULL),
(13, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-22 15:32:13', NULL),
(14, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-23 13:15:42', NULL),
(15, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-23 13:31:43', NULL),
(16, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-23 13:32:59', NULL),
(17, 1, 'create', 'expo', 'Created new expo: Electronics', '\"{\\\"expo_id\\\":3,\\\"name_en\\\":\\\"Electronics\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-23T11:15\\\",\\\"end_date\\\":\\\"2025-12-31T11:15\\\"}\"', '2025-12-23 13:45:21', NULL),
(18, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-23 15:24:24', NULL),
(19, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-23 16:01:18', NULL),
(20, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-24 09:58:43', NULL),
(21, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-24 10:10:47', NULL),
(22, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-24 12:49:54', NULL),
(23, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-24 15:52:02', NULL),
(24, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-25 11:16:26', NULL),
(25, 1, 'update', 'expo', 'Updated expo: Electronics', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Electronics\\\",\\\"name_ar\\\":\\\"\\\\u0627\\\\u0645\\\\u062a\\\\u062d\\\\u0627\\\\u0646\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-23 11:15:00\\\",\\\"end_date\\\":\\\"2025-12-31 11:15:00\\\",\\\"vendor_slot_capacity\\\":10,\\\"product_capacity_per_slot\\\":10},\\\"new\\\":{\\\"name_en\\\":\\\"Electronics\\\",\\\"name_ar\\\":\\\"\\\\u0627\\\\u0645\\\\u062a\\\\u062d\\\\u0627\\\\u0646\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-25T11:15\\\",\\\"end_date\\\":\\\"2025-12-31 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"10\\\",\\\"product_capacity_per_slot\\\":\\\"10\\\"}}\"', '2025-12-25 11:24:16', NULL),
(26, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-25 15:43:17', NULL),
(27, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-26 17:14:22', NULL),
(28, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-26 18:00:42', NULL),
(29, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-26 18:30:21', NULL),
(30, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Electronics\\\",\\\"name_ar\\\":\\\"\\\\u0627\\\\u0645\\\\u062a\\\\u062d\\\\u0627\\\\u0646\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-25 11:15:00\\\",\\\"end_date\\\":\\\"2025-12-31 11:15:00\\\",\\\"vendor_slot_capacity\\\":10,\\\"product_capacity_per_slot\\\":10},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-26T13:10\\\",\\\"end_date\\\":\\\"2025-12-31 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"1\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-26 18:40:45', NULL),
(31, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-28 17:34:33', NULL),
(32, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-28 18:10:28', NULL),
(33, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2025-12-26 13:10:00\\\",\\\"end_date\\\":\\\"2025-12-31 11:15:00\\\",\\\"vendor_slot_capacity\\\":1,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08T09:00\\\",\\\"end_date\\\":\\\"2026-01-17T23:59\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:20:02', NULL),
(34, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:22:19', NULL),
(35, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:24:04', NULL),
(36, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:25:04', NULL),
(37, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:27:49', NULL),
(38, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:28:50', NULL),
(39, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-28 18:29:10', NULL),
(40, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-28 23:16:16', NULL),
(41, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 12:41:12', NULL),
(42, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-08 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-17 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11T09:00\\\",\\\"end_date\\\":\\\"2026-01-20T23:59\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-29 12:42:35', NULL),
(43, 1, 'create', 'expo', 'Created new expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-21T09:00\\\",\\\"end_date\\\":\\\"2026-01-30T11:15\\\"}\"', '2025-12-29 12:46:51', NULL),
(44, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 13:30:39', NULL),
(45, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 13:31:51', NULL),
(46, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 16:33:54', NULL),
(47, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2025-12-29 16:35:11', NULL),
(48, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 16:40:26', NULL),
(49, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 16:45:26', NULL),
(50, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2025-12-29 16:53:08', NULL),
(51, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-02 00:43:44', NULL),
(52, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-01T22:16\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-02 00:46:43', NULL),
(53, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-01 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-01 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-02 00:46:51', NULL),
(54, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-02 00:55:50', NULL),
(55, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-03 19:50:57', NULL),
(56, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-01 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11T22:16\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-03 19:51:30', NULL),
(57, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-11 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-11 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-04 03:11:58', NULL),
(58, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-05 20:10:45', NULL),
(59, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-06 18:55:59', NULL),
(60, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-06 19:00:01', NULL),
(61, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-06 19:01:28', NULL),
(62, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-06 19:01:51', NULL),
(63, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-06 19:02:30', NULL),
(64, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-06 19:02:51', NULL),
(65, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-06 19:08:04', NULL),
(66, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-06 21:47:51', NULL),
(67, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-08 13:02:25', NULL),
(68, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-08 14:55:28', NULL),
(69, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-10 20:49:59', NULL),
(70, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-11 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-11 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-10 20:50:42', NULL),
(71, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-10 20:51:25', NULL),
(72, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":26,\\\"full_name\\\":null,\\\"email\\\":\\\"user55500416@example.com\\\"}\"', '2026-01-12 16:04:00', NULL),
(73, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-12 18:27:18', NULL),
(74, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 11:08:47', NULL),
(75, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-11 22:16:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-13T08:42\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 11:11:37', NULL),
(76, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 11:21:28', NULL),
(77, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 11:55:16', NULL),
(78, 1, 'create', 'expo', 'Created new expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":5,\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05T09:00\\\",\\\"end_date\\\":\\\"2026-02-15T23:59\\\"}\"', '2026-01-13 12:00:07', NULL),
(79, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":5,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 12:01:37', NULL),
(80, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":5,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 12:02:16', NULL),
(81, 1, 'delete', 'expo', 'Deleted expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":5,\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\"}\"', '2026-01-13 12:06:04', NULL),
(82, 1, 'create', 'expo', 'Created new expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05T09:00\\\",\\\"end_date\\\":\\\"2026-02-15T23:59\\\"}\"', '2026-01-13 12:07:07', NULL),
(83, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 12:09:21', NULL),
(84, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 13:02:54', NULL),
(85, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-13 08:42:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-13 08:42:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 13:03:33', NULL),
(86, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 14:15:08', NULL),
(87, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 14:46:25', NULL),
(88, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 14:46:52', NULL),
(89, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 14:55:06', NULL),
(90, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 15:27:31', NULL),
(91, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-13 08:42:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-13T13:35\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 16:05:34', NULL),
(92, 1, 'update', 'expo', 'Updated expo: Winter Expo', '\"{\\\"expo_id\\\":3,\\\"old\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-13 13:35:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Winter Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u0634\\\\u062a\\\\u0627\\\\u0621\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-13 13:35:00\\\",\\\"end_date\\\":\\\"2026-01-20 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 16:06:45', NULL),
(93, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 16:26:31', NULL),
(94, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 16:52:17', NULL),
(95, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 17:15:18', NULL),
(96, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 17:50:26', NULL),
(97, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 17:50:58', NULL),
(98, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-13 20:32:35', NULL),
(99, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-13 20:32:56', NULL),
(100, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":30,\\\"full_name\\\":null,\\\"email\\\":\\\"user50763634@example.com\\\"}\"', '2026-01-14 17:24:17', NULL),
(101, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":9,\\\"full_name\\\":null,\\\"email\\\":\\\"user99946432@example.com\\\"}\"', '2026-01-14 17:24:27', NULL),
(102, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":33,\\\"full_name\\\":null,\\\"email\\\":\\\"user50763634@example.com\\\"}\"', '2026-01-14 17:25:47', NULL),
(103, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-15 12:52:44', NULL),
(104, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-15 13:01:29', NULL),
(105, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-15 15:33:33', NULL),
(106, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-15 16:10:38', NULL),
(107, 1, 'delete', 'user', 'Deleted user: User', '\"{\\\"user_id\\\":17,\\\"full_name\\\":\\\"User\\\",\\\"email\\\":\\\"qt6n88wzk2@privaterelay.appleid.com\\\"}\"', '2026-01-15 16:15:00', NULL),
(108, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":38,\\\"full_name\\\":null,\\\"email\\\":\\\"user56547750@example.com\\\"}\"', '2026-01-15 16:15:02', NULL),
(109, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":36,\\\"full_name\\\":null,\\\"email\\\":\\\"user50763634@example.com\\\"}\"', '2026-01-15 16:15:05', NULL),
(110, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":27,\\\"full_name\\\":null,\\\"email\\\":\\\"user55500416@example.com\\\"}\"', '2026-01-15 16:15:08', NULL),
(111, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":24,\\\"full_name\\\":null,\\\"email\\\":\\\"user69992108@example.com\\\"}\"', '2026-01-15 16:15:10', NULL),
(112, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":23,\\\"full_name\\\":null,\\\"email\\\":\\\"user97311699@example.com\\\"}\"', '2026-01-15 16:15:14', NULL),
(113, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":21,\\\"full_name\\\":null,\\\"email\\\":\\\"user69030609@example.com\\\"}\"', '2026-01-15 16:15:16', NULL),
(114, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":13,\\\"full_name\\\":null,\\\"email\\\":\\\"user67747698@example.com\\\"}\"', '2026-01-15 16:15:19', NULL),
(115, 1, 'delete', 'user', 'Deleted user: User', '\"{\\\"user_id\\\":16,\\\"full_name\\\":\\\"User\\\",\\\"email\\\":\\\"d85z7qnz7q@privaterelay.appleid.com\\\"}\"', '2026-01-15 16:15:23', NULL),
(116, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":39,\\\"full_name\\\":null,\\\"email\\\":\\\"user56547750@example.com\\\"}\"', '2026-01-15 16:16:58', NULL),
(117, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"suspended\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-16 22:22:11', NULL),
(118, 1, 'update', 'expo', 'Updated expo: Dara\'at Expo', '\"{\\\"expo_id\\\":4,\\\"old\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"active\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Dara\'at Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0644\\\\u062f\\\\u0631\\\\u0627\\\\u0639\\\\u0627\\\\u062a\\\",\\\"status\\\":\\\"inactive\\\",\\\"start_date\\\":\\\"2026-01-21 09:00:00\\\",\\\"end_date\\\":\\\"2026-01-30 11:15:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-16 22:39:22', NULL),
(119, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-16 23:17:47', NULL),
(120, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-16 23:20:31', NULL),
(121, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-17 00:00:41', NULL),
(122, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-17 00:01:24', NULL),
(123, 1, 'update', 'expo', 'Updated expo: Expoza Ramadhani Expo', '\"{\\\"expo_id\\\":6,\\\"old\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-15 23:59:00\\\",\\\"vendor_slot_capacity\\\":50,\\\"product_capacity_per_slot\\\":50},\\\"new\\\":{\\\"name_en\\\":\\\"Expoza Ramadhani Expo\\\",\\\"name_ar\\\":\\\"\\\\u0645\\\\u0639\\\\u0631\\\\u0636 \\\\u0627\\\\u0643\\\\u0633\\\\u0628\\\\u0648\\\\u0632\\\\u0627 \\\\u0627\\\\u0644\\\\u0631\\\\u0645\\\\u0636\\\\u0627\\\\u0646\\\\u064a\\\",\\\"status\\\":\\\"upcoming\\\",\\\"start_date\\\":\\\"2026-02-05 09:00:00\\\",\\\"end_date\\\":\\\"2026-02-19T23:59\\\",\\\"vendor_slot_capacity\\\":\\\"50\\\",\\\"product_capacity_per_slot\\\":\\\"50\\\"}}\"', '2026-01-17 00:05:15', NULL),
(124, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-17 01:28:09', NULL),
(125, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-17 17:31:55', NULL),
(126, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-18 13:48:42', NULL),
(127, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-18 14:08:18', NULL),
(128, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-19 12:15:40', NULL),
(129, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-19 12:46:20', NULL),
(130, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":40,\\\"full_name\\\":null,\\\"email\\\":\\\"user97908068@example.com\\\"}\"', '2026-01-19 12:49:44', NULL),
(131, 1, 'delete', 'user', 'Deleted user: Test Test', '\"{\\\"user_id\\\":10,\\\"full_name\\\":\\\"Test Test\\\",\\\"email\\\":\\\"testing@gmail.com\\\"}\"', '2026-01-19 12:49:57', NULL),
(132, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-19 12:52:12', NULL),
(133, 1, 'delete', 'user', 'Deleted user: ', '\"{\\\"user_id\\\":42,\\\"full_name\\\":null,\\\"email\\\":\\\"user90040117@example.com\\\"}\"', '2026-01-19 12:52:18', NULL);
INSERT INTO `audit_logs` (`id`, `admin_id`, `action`, `module`, `description`, `changes`, `created_at`, `deleted_at`) VALUES
(134, 1, 'login', 'auth', 'User Admin User logged in', '\"{\\\"user_id\\\":1,\\\"email\\\":\\\"admin@example.com\\\",\\\"role\\\":\\\"admin\\\"}\"', '2026-01-19 13:34:39', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint UNSIGNED NOT NULL,
  `cart_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint UNSIGNED NOT NULL,
  `parent_id` bigint UNSIGNED DEFAULT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `parent_id`, `name_en`, `name_ar`, `content`, `image`, `status`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Electronics', 'إلكترونيات', NULL, 'categories/JzYWgFeQGFBPrCJW5Vu9VMU74cslYkxu8AS0miuj.png', 'active', NULL, '2025-12-23 13:42:04', '2025-12-23 13:42:04');

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` bigint UNSIGNED NOT NULL,
  `country_id` bigint UNSIGNED NOT NULL,
  `state_id` bigint UNSIGNED NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`id`, `country_id`, `state_id`, `name_en`, `name_ar`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 1, 'Al Asimah City', 'مدينة العاصمة', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(2, 1, 2, 'Hawalli City', 'مدينة حولي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(3, 1, 3, 'Farwaniya City', 'مدينة الفروانية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(4, 1, 4, 'Ahmadi City', 'مدينة الأحمدي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(5, 1, 5, 'Mubarak Al-Kabeer City', 'مدينة مبارك الكبير', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(6, 1, 6, 'Jahra City', 'مدينة الجهراء', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(7, 1, 7, 'Sabah Al Ahmad City', 'مدينة صباح الأحمد', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(8, 1, 8, 'Wafra City', 'مدينة الوفرة', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(9, 1, 9, 'Fintas City', 'مدينة الفنطاس', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(10, 1, 10, 'Salwa City', 'مدينة سلوى', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(11, 1, 1, 'Kuwait City', 'مدينة الكويت', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(12, 1, 1, 'Sharq', 'شرق', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(13, 1, 1, 'Mirqab', 'مرقاب', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(14, 1, 1, 'Dasman', 'دسمان', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(15, 1, 2, 'Hawalli', 'حولي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(16, 1, 2, 'Salmiya', 'السالمية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(17, 1, 2, 'Jabriya', 'الجابرية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(18, 1, 2, 'Rumaithiya', 'الرميثية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(19, 1, 3, 'Farwaniya', 'الفروانية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(20, 1, 3, 'Khaitan', 'خيطان', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(21, 1, 3, 'Jleeb Al-Shuyoukh', 'جليب الشيوخ', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(22, 1, 3, 'Abdullah Al-Mubarak', 'عبدالله المبارك', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(23, 1, 4, 'Ahmadi', 'الأحمدي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(24, 1, 4, 'Fahaheel', 'الفحيحيل', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(25, 1, 4, 'Mangaf', 'المنقف', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(26, 1, 4, 'Abu Halifa', 'أبو حليفة', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(27, 1, 5, 'Mubarak Al-Kabeer', 'مبارك الكبير', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(28, 1, 5, 'Sabhan', 'صبحان', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(29, 1, 5, 'Qurain', 'القرين', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(30, 1, 5, 'Qusour', 'القصور', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(31, 1, 6, 'Jahra', 'الجهراء', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(32, 1, 6, 'Saad Al Abdullah', 'سعد العبدالله', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(33, 1, 6, 'Al Oyoun', 'العيون', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(34, 1, 6, 'Al Naseem', 'النسيم', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(35, 1, 5, 'Adan', 'العدان', 'active', '2026-01-02 00:59:49', '2026-01-02 00:59:49', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cms_pages`
--

CREATE TABLE `cms_pages` (
  `id` bigint UNSIGNED NOT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_en` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_ar` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `meta_title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_description` text COLLATE utf8mb4_unicode_ci,
  `meta_keywords` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','suspended','draft') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cms_pages`
--

INSERT INTO `cms_pages` (`id`, `title_en`, `title_ar`, `content_en`, `content_ar`, `slug`, `meta_title`, `meta_description`, `meta_keywords`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'EXPOZA Vendor Agreement', 'اتفاقية تسجيل البائعين في EXPOZA', '<p>This Vendor Signup Agreement (the \"Agreement\") is entered into</p><p>between EXPOZA, a mobile application marketplace (the</p><p>\"Platform\"), and the individual or business entity registering as a</p><p>vendor (the \"Vendor\"). By creating an account or listing</p><p>products/services on EXPOZA, the Vendor agrees to the terms and</p><p>conditions set forth below.</p><p>---</p><p>1. Definitions</p><p>\"Platform\" refers to the EXPOZA mobile application and its related</p><p>services.</p><p>\"Vendor\" refers to any individual, company, or entity that registers</p><p>to sell products or services on EXPOZA.</p><p>\"User\" refers to customers or individuals browsing or purchasing on</p><p>the Platform.</p><p>\"Content\" refers to product listings, images, descriptions, pricing,</p><p>branding, and any other material uploaded by the Vendor.</p><p>---</p><p>2. Vendor Eligibility</p><p>To register as a Vendor on EXPOZA, you must:</p><p>Be at least 18 years old.</p><p>Have the legal authority to operate a business or sell</p><p>products/services.</p><p>Provide accurate, complete, and up‑to‑date information during</p><p>registration.</p><p>Comply with all applicable laws and regulations in Kuwait.</p><p>EXPOZA reserves the right to approve or reject Vendor applications</p><p>at its sole discretion.</p><p>---</p><p>3. Vendor Obligations</p><p>The Vendor agrees to:</p><p>Provide truthful, accurate, and lawful product/service listings.</p><p>Ensure all products are genuine, safe, and not prohibited under</p><p>applicable laws.</p><p>Maintain updated stock availability and pricing.</p><p>Promptly fulfill orders placed through the Platform.</p><p>Handle returns, refunds, and customer issues professionally and</p><p>promptly.</p><p>Ensure uploaded Content does not infringe third‑party rights.</p><p>---</p><p>4. Prohibited Products and Activities</p><p>Vendors may not list or sell:</p><p>Illegal or counterfeit goods.</p><p>Products prohibited under Kuwait law.</p><p>Items that promote hate, violence, or discrimination.</p><p>Hazardous items not permitted for public sale.</p><p>EXPOZA reserves the right to remove prohibited listings without</p><p>prior notice.</p><p>---</p><p>5. Fees and Payments</p><p>EXPOZA may charge transaction fees, commission percentages,</p><p>subscription fees, or service charges. The Vendor will be notified of</p><p>applicable fees during onboarding or via updates.</p><p>Payments will be processed according to EXPOZA’s payout</p><p>schedule. Vendors are responsible for:</p><p>Providing valid banking details.</p><p>Paying any taxes, duties, or VAT required by law.</p><p>---</p><p>6. Content Ownership and License</p><p>The Vendor retains ownership of its Content. By uploading Content</p><p>to EXPOZA, the Vendor grants EXPOZA a non‑exclusive,</p><p>royalty‑free, worldwide license to use, display, reproduce, and</p><p>promote the Content for Platform-related purposes.</p><p>EXPOZA may remove Content that violates this Agreement or any</p><p>applicable policies.</p><p>---</p><p>7. Data Protection and Privacy</p><p>EXPOZA will collect and process Vendor information in accordance</p><p>with its Privacy Policy. Vendors are responsible for safeguarding</p><p>their account login credentials.</p><p>Any misuse of customer data by the Vendor is strictly prohibited.</p><p>---</p><p>8. Termination</p><p>EXPOZA may suspend or terminate a Vendor account if the Vendor:</p><p>Violates this Agreement or applicable policies.</p><p>Engages in fraudulent or harmful activities.</p><p>Fails to meet performance standards.</p><p>Vendors may terminate their account at any time by submitting a</p><p>written request to EXPOZA.</p><p>Termination does not relieve the Vendor of obligations related to</p><p>outstanding orders or payments.</p><p>---</p><p>9. Limitation of Liability</p><p>EXPOZA is not liable for:</p><p>Losses resulting from Vendor errors, delays, or product issues.</p><p>Any indirect, incidental, or consequential damages.</p><p>Disputes between the Vendor and customers.</p><p>The Platform is provided on an \"as‑is\" basis without warranties of</p><p>any kind.</p><p>---</p><p>10. Indemnification</p><p>The Vendor agrees to indemnify and hold harmless EXPOZA, its</p><p>owners, employees, and affiliates from any claims, losses, damages,</p><p>liabilities, or expenses arising from:</p><p>The Vendor\'s Content or listings.</p><p>Violations of this Agreement.</p><p>Transactions or interactions between the Vendor and Users.</p><p>---</p><p>11. Modifications to the Agreement</p><p>EXPOZA may update or modify this Agreement at any time. Vendors</p><p>will be notified of major changes. Continued use of the Platform</p><p>constitutes acceptance of updated terms.</p><p>---</p><p>12. Governing Law</p><p>This Agreement is governed by the laws of the State of Kuwait. Any</p><p>disputes shall be resolved through competent courts within Kuwait.</p>', '<p class=\"ql-direction-rtl ql-align-justify\">تُعد هذه اتفاقية تسجيل البائعين (\"الاتفاقية\") مبرمة بين EXPOZA، وهي منصة سوق عبر تطبيق الهاتف المحمول (\"المنصة\")، وبين الفرد أو الكيان التجاري الذي يقوم بالتسجيل كبائع (\"البائع\"). وبمجرد إنشاء حساب أو إضافة منتجات/خدمات على EXPOZA، فإن البائع يوافق على الشروط والأحكام الواردة في هذه الاتفاقية.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;1. التعريفات</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المنصة\" تشير إلى تطبيق EXPOZA والخدمات المرتبطة به.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"البائع\" هو أي فرد أو شركة أو جهة تقوم بالتسجيل لبيع منتجات أو خدمات عبر EXPOZA.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المستخدم\" هو العميل أو الشخص الذي يقوم بتصفح أو شراء المنتجات عبر المنصة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المحتوى\" يشمل القوائم، الصور، الأوصاف، الأسعار، العلامات التجارية، وأي مواد يقوم البائع برفعها.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;2. أهلية البائع</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">للتسجيل كبائع في EXPOZA، يجب عليك:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أن تكون فوق 18 عامًا.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أن تملك الصلاحية القانونية لإدارة نشاط تجاري أو بيع منتجات/خدمات.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تقديم معلومات دقيقة وصحيحة ومحدّثة أثناء التسجيل.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;الالتزام بجميع القوانين والأنظمة المعمول بها في دولة الكويت.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تحتفظ EXPOZA بالحق في قبول أو رفض طلب البائع وفقًا لتقديرها الخاص.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;3. التزامات البائع</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يوافق البائع على ما يلي:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تقديم معلومات وصور وقوائم صحيحة وقانونية.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;ضمان أن المنتجات أصلية وآمنة وغير مخالفة للقوانين.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تحديث الأسعار وتوافر المنتجات بشكل مستمر.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تنفيذ الطلبات بسرعة وبطريقة احترافية.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;التعامل مع المرتجعات وردّ الأموال وشكاوى العملاء بكفاءة.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;التأكيد على أن المحتوى المرفوع لا ينتهك حقوق الغير.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;4. المنتجات والأنشطة المحظورة</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يُمنع على البائع عرض أو بيع:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;السلع غير القانونية أو المقلدة.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;المنتجات المحظورة بموجب قوانين الكويت.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;المواد التي تروج للكراهية أو العنف أو التمييز.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;المواد الخطرة غير المصرح ببيعها.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يحق لـ EXPOZA إزالة أي محتوى مخالف دون إشعار مسبق.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;5. الرسوم والمدفوعات</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">قد تفرض EXPOZA رسومًا على المعاملات، أو عمولات، أو اشتراكات، أو رسومًا خدمية. وسيتم إبلاغ البائع بالرسوم المطبقة أثناء التسجيل أو عبر تحديثات لاحقة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تتم معالجة المدفوعات وفق جدول الدفعات المعتمد من EXPOZA. ويكون البائع مسؤولًا عن:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تقديم بيانات حساب بنكي صحيحة.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;دفع الضرائب أو الرسوم أو ضريبة القيمة المضافة حسب القانون.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;6. الملكية الفكرية للمحتوى</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يحتفظ البائع بملكية المحتوى الخاص به. وبمجرد رفع المحتوى على EXPOZA، يمنح البائع المنصة ترخيصًا عالميًا غير حصري وخاليًا من الرسوم لاستخدام المحتوى وعرضه وإعادة إنتاجه وترويجه لأغراض تشغيل المنصة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">لـ EXPOZA الحق في إزالة أي محتوى مخالف.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;7. حماية البيانات والخصوصية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تقوم EXPOZA بجمع ومعالجة بيانات البائع وفق سياسة الخصوصية الخاصة بها. ويكون البائع مسؤولًا عن الحفاظ على سرية بيانات الدخول إلى حسابه.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يُحظر إساءة استخدام بيانات العملاء بأي شكل.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;8. الإنهاء</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يمكن لـ EXPOZA تعليق أو إنهاء حساب البائع في الحالات التالية:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;مخالفة شروط هذه الاتفاقية أو السياسات.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;ممارسة أي نشاط احتيالي أو ضار.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;عدم الالتزام بمعايير الأداء.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">كما يمكن للبائع طلب إغلاق حسابه في أي وقت من خلال طلب كتابي.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">لا يعفي الإنهاء البائع من إكمال الطلبات أو تسوية المدفوعات المعلّقة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;9. تحديد المسؤولية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">لا تتحمل EXPOZA مسؤولية:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أي خسائر ناتجة عن أخطاء أو تأخير من البائع.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;الأضرار غير المباشرة أو العرضية أو التبعية.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;النزاعات بين البائع والمستخدمين.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يتم توفير المنصة \"كما هي\" دون أي ضمانات.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;10. التعويض</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يوافق البائع على تعويض EXPOZA وموظفيها ووكلائها من أي مطالبات أو خسائر ناتجة عن:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;المحتوى الخاص بالبائع.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;مخالفة هذه الاتفاقية.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أي تعاملات أو نزاعات بين البائع والمستخدمين.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;11. التعديلات على الاتفاقية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">قد تقوم EXPOZA بتحديث أو تعديل هذه الاتفاقية في أي وقت. وسيتم إخطار البائع بالتغييرات الكبرى. ويُعد استمرار استخدام المنصة موافقة على التعديلات.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;12. القانون المختص</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تخضع هذه الاتفاقية لقوانين دولة الكويت، وتُحل أي نزاعات أمام المحاكم المختصة داخل الكويت.</p><p class=\"ql-direction-rtl\"><br></p>', 'terms-of-vendor', 'EXPOZA Vendor Agreement', 'EXPOZA Vendor Agreement', 'EXPOZA Vendor Agreement', 'active', '2025-12-18 17:18:28', '2025-12-24 10:48:07', NULL),
(2, 'Privacy Policy', 'Privacy Policy', '<h1>Privacy Policy</h1><p>Last updated: December 19, 2025</p><p>This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.</p><p>We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.</p><h2>Interpretation and Definitions</h2><h3>Interpretation</h3><p>The words whose initial letters are capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.</p><h3>Definitions</h3><p>For the purposes of this Privacy Policy:</p><ul><li><strong>Account</strong>&nbsp;means a unique account created for You to access our Service or parts of our Service.</li><li><strong>Affiliate</strong>&nbsp;means an entity that controls, is controlled by, or is under common control with a party, where \"control\" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.</li><li><strong>Application</strong>&nbsp;refers to Expoza, the software program provided by the Company.</li><li><strong>Company</strong>&nbsp;(referred to as either \"the Company\", \"We\", \"Us\" or \"Our\" in this Agreement) refers to EXPOZA COMPANY / OWNER NORAH YOUSEF ALYAQOUB.</li><li><strong>Country</strong>&nbsp;refers to: Kuwait</li><li><strong>Device</strong>&nbsp;means any device that can access the Service such as a computer, a cell phone or a digital tablet.</li><li><strong>Personal Data</strong>&nbsp;is any information that relates to an identified or identifiable individual.</li><li><strong>Service</strong>&nbsp;refers to the Application.</li><li><strong>Service Provider</strong>&nbsp;means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.</li><li><strong>Usage Data</strong>&nbsp;refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).</li><li><strong>You</strong>&nbsp;means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.</li></ul><h2>Collecting and Using Your Personal Data</h2><h3>Types of Data Collected</h3><h4>Personal Data</h4><p>While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:</p><ul><li>Email address</li><li>First name and last name</li><li>Phone number</li><li>Address, State, Province, ZIP/Postal code, City</li><li>Usage Data</li></ul><h4>Usage Data</h4><p>Usage Data is collected automatically when using the Service.</p><p>Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.</p><p>When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device\'s unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.</p><p>We may also collect information that Your browser sends whenever You visit Our Service or when You access the Service by or through a mobile device.</p><h3>Use of Your Personal Data</h3><p>The Company may use Personal Data for the following purposes:</p><ul><li><strong>To provide and maintain our Service</strong>, including to monitor the usage of our Service.</li><li><strong>To manage Your Account:</strong>&nbsp;to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.</li><li><strong>For the performance of a contract:</strong>&nbsp;the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.</li><li><strong>To contact You:</strong>&nbsp;To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application\'s push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.</li><li><strong>To provide You</strong>&nbsp;with news, special offers, and general information about other goods, services and events which We offer that are similar to those that you have already purchased or inquired about unless You have opted not to receive such information.</li><li><strong>To manage Your requests:</strong>&nbsp;To attend and manage Your requests to Us.</li><li><strong>For business transfers:</strong>&nbsp;We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.</li><li><strong>For other purposes</strong>: We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.</li></ul><p>We may share Your personal information in the following situations:</p><ul><li><strong>With Service Providers:</strong>&nbsp;We may share Your personal information with Service Providers to monitor and analyze the use of our Service, to contact You.</li><li><strong>For business transfers:</strong>&nbsp;We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.</li><li><strong>With Affiliates:</strong>&nbsp;We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.</li><li><strong>With business partners:</strong>&nbsp;We may share Your information with Our business partners to offer You certain products, services or promotions.</li><li><strong>With other users:</strong>&nbsp;when You share personal information or otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside.</li><li><strong>With Your consent</strong>: We may disclose Your personal information for any other purpose with Your consent.</li></ul><h3>Retention of Your Personal Data</h3><p>The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.</p><p>The Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer periods.</p><h3>Transfer of Your Personal Data</h3><p>Your information, including Personal Data, is processed at the Company\'s operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to — and maintained on — computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ from those from Your jurisdiction.</p><p>Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.</p><p>The Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information.</p><h3>Delete Your Personal Data</h3><p>You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You.</p><p>Our Service may give You the ability to delete certain information about You from within the Service.</p><p>You may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us.</p><p>Please note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so.</p><h3>Disclosure of Your Personal Data</h3><h4>Business Transactions</h4><p>If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy.</p><h4>Law enforcement</h4><p>Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).</p><h4>Other legal requirements</h4><p>The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:</p><ul><li>Comply with a legal obligation</li><li>Protect and defend the rights or property of the Company</li><li>Prevent or investigate possible wrongdoing in connection with the Service</li><li>Protect the personal safety of Users of the Service or the public</li><li>Protect against legal liability</li></ul><h3>Security of Your Personal Data</h3><p>The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially reasonable means to protect Your Personal Data, We cannot guarantee its absolute security.</p><h2>Children\'s Privacy</h2><p>Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.</p><p>If We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent\'s consent before We collect and use that information.</p><h2>Links to Other Websites</h2><p>Our Service may contain links to other websites that are not operated by Us. If You click on a third party link, You will be directed to that third party\'s site. We strongly advise You to review the Privacy Policy of every site You visit.</p><p>We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.</p><h2>Changes to this Privacy Policy</h2><p>We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.</p><p>We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the \"Last updated\" date at the top of this Privacy Policy.</p><p>You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.</p><h2>Contact Us</h2><p>If you have any questions about this Privacy Policy, You can contact us:</p><ul><li>By email:&nbsp;info@expoza.app</li></ul>', '<h1>Privacy Policy</h1><p>Last updated: December 19, 2025</p><p>This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.</p><p>We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.</p><h2>Interpretation and Definitions</h2><h3>Interpretation</h3><p>The words whose initial letters are capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.</p><h3>Definitions</h3><p>For the purposes of this Privacy Policy:</p><ul><li><strong>Account</strong>&nbsp;means a unique account created for You to access our Service or parts of our Service.</li><li><strong>Affiliate</strong>&nbsp;means an entity that controls, is controlled by, or is under common control with a party, where \"control\" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.</li><li><strong>Application</strong>&nbsp;refers to Expoza, the software program provided by the Company.</li><li><strong>Company</strong>&nbsp;(referred to as either \"the Company\", \"We\", \"Us\" or \"Our\" in this Agreement) refers to EXPOZA COMPANY / OWNER NORAH YOUSEF ALYAQOUB..</li><li><strong>Country</strong>&nbsp;refers to: Kuwait</li><li><strong>Device</strong>&nbsp;means any device that can access the Service such as a computer, a cell phone or a digital tablet.</li><li><strong>Personal Data</strong>&nbsp;is any information that relates to an identified or identifiable individual.</li><li><strong>Service</strong>&nbsp;refers to the Application.</li><li><strong>Service Provider</strong>&nbsp;means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.</li><li><strong>Usage Data</strong>&nbsp;refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).</li><li><strong>You</strong>&nbsp;means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.</li></ul><h2>Collecting and Using Your Personal Data</h2><h3>Types of Data Collected</h3><h4>Personal Data</h4><p>While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:</p><ul><li>Email address</li><li>First name and last name</li><li>Phone number</li><li>Address, State, Province, ZIP/Postal code, City</li><li>Usage Data</li></ul><h4>Usage Data</h4><p>Usage Data is collected automatically when using the Service.</p><p>Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.</p><p>When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device\'s unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.</p><p>We may also collect information that Your browser sends whenever You visit Our Service or when You access the Service by or through a mobile device.</p><h3>Use of Your Personal Data</h3><p>The Company may use Personal Data for the following purposes:</p><ul><li><strong>To provide and maintain our Service</strong>, including to monitor the usage of our Service.</li><li><strong>To manage Your Account:</strong>&nbsp;to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.</li><li><strong>For the performance of a contract:</strong>&nbsp;the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.</li><li><strong>To contact You:</strong>&nbsp;To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application\'s push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.</li><li><strong>To provide You</strong>&nbsp;with news, special offers, and general information about other goods, services and events which We offer that are similar to those that you have already purchased or inquired about unless You have opted not to receive such information.</li><li><strong>To manage Your requests:</strong>&nbsp;To attend and manage Your requests to Us.</li><li><strong>For business transfers:</strong>&nbsp;We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.</li><li><strong>For other purposes</strong>: We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.</li></ul><p>We may share Your personal information in the following situations:</p><ul><li><strong>With Service Providers:</strong>&nbsp;We may share Your personal information with Service Providers to monitor and analyze the use of our Service, to contact You.</li><li><strong>For business transfers:</strong>&nbsp;We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.</li><li><strong>With Affiliates:</strong>&nbsp;We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.</li><li><strong>With business partners:</strong>&nbsp;We may share Your information with Our business partners to offer You certain products, services or promotions.</li><li><strong>With other users:</strong>&nbsp;when You share personal information or otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside.</li><li><strong>With Your consent</strong>: We may disclose Your personal information for any other purpose with Your consent.</li></ul><h3>Retention of Your Personal Data</h3><p>The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.</p><p>The Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer periods.</p><h3>Transfer of Your Personal Data</h3><p>Your information, including Personal Data, is processed at the Company\'s operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to — and maintained on — computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ from those from Your jurisdiction.</p><p>Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.</p><p>The Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information.</p><h3>Delete Your Personal Data</h3><p>You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You.</p><p>Our Service may give You the ability to delete certain information about You from within the Service.</p><p>You may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us.</p><p>Please note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so.</p><h3>Disclosure of Your Personal Data</h3><h4>Business Transactions</h4><p>If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy.</p><h4>Law enforcement</h4><p>Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).</p><h4>Other legal requirements</h4><p>The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:</p><ul><li>Comply with a legal obligation</li><li>Protect and defend the rights or property of the Company</li><li>Prevent or investigate possible wrongdoing in connection with the Service</li><li>Protect the personal safety of Users of the Service or the public</li><li>Protect against legal liability</li></ul><h3>Security of Your Personal Data</h3><p>The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially reasonable means to protect Your Personal Data, We cannot guarantee its absolute security.</p><h2>Children\'s Privacy</h2><p>Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.</p><p>If We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent\'s consent before We collect and use that information.</p><h2>Links to Other Websites</h2><p>Our Service may contain links to other websites that are not operated by Us. If You click on a third party link, You will be directed to that third party\'s site. We strongly advise You to review the Privacy Policy of every site You visit.</p><p>We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.</p><h2>Changes to this Privacy Policy</h2><p>We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.</p><p>We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the \"Last updated\" date at the top of this Privacy Policy.</p><p>You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.</p><h2>Contact Us</h2><p>If you have any questions about this Privacy Policy, You can contact us:</p><ul><li>By email:&nbsp;info@expoza.app</li></ul>', 'privacy-policy', NULL, NULL, NULL, 'active', '2025-12-18 17:18:28', '2025-12-23 16:05:31', NULL),
(3, 'About Us', 'About Us', '<h3 class=\"ql-align-justify\"><strong>What is Expoza?</strong></h3><p class=\"ql-align-justify\">An integrated digital environment for organizing and hosting various exhibitions that enables business owners to showcase their products in an attractive and professional way through an online booth within a digital exhibition, accessible via the ease-to-use Expoza application on mobile phones or tablets.</p><p class=\"ql-align-justify\"><br></p><p class=\"ql-align-justify\">License: 2025/15802 </p>', '<h3 class=\"ql-align-justify ql-direction-rtl\">ما هو اكسبوزا ؟</h3><p class=\"ql-align-justify ql-direction-rtl\">&nbsp;بيئة رقمية متكاملة لتنظيم واستضافة المعارض المختلفة تمكن أصحاب المشاريع من عرض منتجاتهم بطريقة جذابة واحترافية بمحل الكتروني في معرض رقمي متاح عبر تطبيق اكسبوزا سهل الاستخدام من خلال الهاتف أو التابلت.</p><p class=\"ql-align-justify ql-direction-rtl\"><br></p><p class=\"ql-align-justify ql-direction-rtl\">رقم الترخيص: 2025/15802</p>', 'about-us', NULL, NULL, NULL, 'active', '2025-12-18 17:18:28', '2025-12-25 11:19:28', NULL),
(4, 'Contact us', 'Contact us', '<h3>Whatsapp: +96550763634</h3><h3>Email: info@expoza.app</h3><h3>Instagram: expoza.app</h3>', '<h3>Whatsapp: +96550763634</h3><h3>Email: info@expoza.app</h3><h3>Instagram: expoza.app</h3>', 'contact-us', NULL, NULL, NULL, 'active', '2025-12-18 17:18:28', '2025-12-24 11:18:16', NULL);
INSERT INTO `cms_pages` (`id`, `title_en`, `title_ar`, `content_en`, `content_ar`, `slug`, `meta_title`, `meta_description`, `meta_keywords`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(5, 'EXPOZA User Agreement', 'اتفاقية مستخدم منصة EXPOZA', '<p>This User Agreement (\"Agreement\") outlines the terms and conditions</p><p>governing your use of the EXPOZA mobile marketplace application (the</p><p>\"Platform\"). By creating an account, browsing, or making purchases</p><p>through EXPOZA, you agree to comply with and be bound by this</p><p>Agreement.</p><p>---</p><p>1. Definitions</p><p>\"Platform\" refers to the EXPOZA mobile application and all related</p><p>services.</p><p>\"User\" refers to any individual who browses, registers, or makes</p><p>purchases through EXPOZA.</p><p>\"Vendor\" refers to individuals or businesses offering products or services</p><p>through the Platform.</p><p>\"Content\" includes text, images, videos, reviews, comments, and any</p><p>material posted by Users.</p><p>---</p><p>2. User Eligibility</p><p>By using EXPOZA, you confirm that you:</p><p>Are at least 18 years old.</p><p>Have the legal capacity to enter into this Agreement.</p><p>Will provide accurate and up-to-date information during registration.</p><p>Will use the Platform legally and responsibly.</p><p>---</p><p>3. User Account</p><p>Users are responsible for maintaining the confidentiality of login</p><p>credentials.</p><p>Any activity under the user account is the responsibility of the account</p><p>holder.</p><p>EXPOZA may suspend or delete accounts involved in suspicious, harmful,</p><p>or illegal activity.</p><p>---</p><p>4. Platform Usage Rules</p><p>Users agree not to:</p><p>Post illegal, harmful, misleading, or offensive content.</p><p>Attempt to hack, disrupt, or misuse the Platform.</p><p>Manipulate reviews, ratings, or transactions.</p><p>Violate intellectual property rights of others.</p><p>---</p><p>5. Purchases and Transactions</p><p>Purchases made on EXPOZA are directly between the User and the</p><p>Vendor.</p><p>EXPOZA does not manufacture, store, or ship products.</p><p>Users are responsible for reviewing product details before purchasing.</p><p>Prices, availability, shipping, and return policies are determined by</p><p>Vendors.</p><p>---</p><p>6. Ratings and Reviews</p><p>Reviews must reflect genuine experiences.</p><p>Fake, abusive, or misleading reviews may be removed.</p><p>EXPOZA may moderate or delete content that violates its policies.</p><p>---</p><p>7. Privacy and Data Protection</p><p>By using EXPOZA, Users agree to the collection and processing of their</p><p>data in accordance with the EXPOZA Privacy Policy.</p><p>EXPOZA will not sell or misuse user data but may share information with</p><p>Vendors to complete transactions.</p><p>---</p><p>8. Limitation of Liability</p><p>EXPOZA is not responsible for:</p><p>Disputes or transactions between Users and Vendors.</p><p>Product quality, accuracy of product descriptions, or delivery issues.</p><p>Any direct, indirect, incidental, or consequential damages arising from</p><p>Platform use.</p><p>The Platform is provided on an \"as-is\" basis without warranties of any</p><p>kind.</p><p>---</p><p>9. Modifications to the Agreement</p><p>EXPOZA may update or modify this Agreement at any time. Users will be</p><p>notified of major changes.</p><p>Continued use of the Platform after updates signifies acceptance of the</p><p>new terms.</p><p>---</p><p>10. Governing Law</p><p>This Agreement is governed by the laws of the State of Kuwait. Any</p><p>disputes will be resolved in the competent courts of Kuwait.</p>', '<p class=\"ql-direction-rtl ql-align-justify\">توضح هذه \"اتفاقية المستخدم\" الشروط والأحكام التي تحكم استخدامك لتطبيق EXPOZA وخدماته. باستخدامك للمنصة أو بإنشائك حسابًا، فإنك توافق على الالتزام بهذه الشروط.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;1. التعريفات</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المنصة\" تشير إلى تطبيق EXPOZA والخدمات التابعة له.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المستخدم\" هو أي شخص يقوم بإنشاء حساب أو يتصفح أو يشتري من المنصة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"البائع\" هو أي جهة أو فرد يعرض منتجاته أو خدماته عبر المنصة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">\"المحتوى\" يشمل النصوص، الصور، الفيديوهات، المراجعات، والتعليقات التي ينشرها المستخدم.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;2. أهلية المستخدم</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">باستخدام المنصة، فإنك تقر بأنك:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تبلغ 18 عامًا أو أكثر.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;تمتلك الأهلية القانونية لإبرام هذه الاتفاقية.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;ستقدم معلومات صحيحة ومحدثة أثناء التسجيل.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;ستستخدم المنصة لأغراض قانونية فقط.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;3. حساب المستخدم</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;يتحمل المستخدم مسؤولية الحفاظ على سرية بيانات الدخول.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أي نشاط يتم عبر الحساب يعتبر تحت مسؤولية المستخدم.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;يحق لـ EXPOZA تعليق أو إغلاق الحساب في حال وجود نشاط غير قانوني أو مخالف.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;4. استخدام المنصة</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يوافق المستخدم على عدم:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;نشر محتوى غير قانوني أو مسيء أو مضلل.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;محاولة اختراق المنصة أو استغلالها بشكل ضار.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;التلاعب بعمليات الشراء أو المراجعات.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;انتهاك حقوق الملكية الفكرية لأي طرف.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;5. عمليات الشراء</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;جميع المشتريات تتم مباشرة من البائعين وليس من EXPOZA.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;يتحمل المستخدم مسؤولية مراجعة تفاصيل المنتجات قبل الشراء.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;الأسعار، التوافر، وسياسات الشحن والمرتجعات يحددها البائعون.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;6. المراجعات والتقييمات</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;يجب أن تكون المراجعات صادقة وغير مضللة.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;يحق لـ EXPOZA حذف أي مراجعة مخالفة.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;7. سياسة الخصوصية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">يوافق المستخدم على جمع ومعالجة بياناته وفق سياسة الخصوصية الخاصة بـ EXPOZA.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;8. تحديد المسؤولية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">لا تتحمل EXPOZA مسؤولية:</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أي تعاملات أو نزاعات بين المستخدم والبائع.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;أي أضرار مباشرة أو غير مباشرة ناتجة عن استخدام المنصة.</p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;محتوى البائعين أو دقة معلومات المنتجات.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تُقدم المنصة كما هي دون أي ضمانات.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;9. التعديلات على الاتفاقية</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">قد تقوم EXPOZA بتعديل هذه الاتفاقية في أي وقت، وسيتم إخطار المستخدم بالتغييرات الجوهرية. ويعتبر استمرار استخدام المنصة موافقة على التعديلات.</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">---</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">&nbsp;10. القانون المختص</p><p class=\"ql-direction-rtl ql-align-justify\"><br></p><p class=\"ql-direction-rtl ql-align-justify\">تخضع هذه الاتفاقية لقوانين دولة الكويت، وتُحل أي نزاعات أمام المحاكم المختصة داخل الكويت.</p><p class=\"ql-direction-rtl\"><br></p>', 'terms-of-service', NULL, NULL, NULL, 'active', '2025-12-18 17:31:55', '2025-12-24 10:49:16', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `contact_queries`
--

CREATE TABLE `contact_queries` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','in_progress','resolved') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `id` bigint UNSIGNED NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `countries`
--

INSERT INTO `countries` (`id`, `name_en`, `name_ar`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Kuwait', 'الكويت', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `coupon_usages`
--

CREATE TABLE `coupon_usages` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expos`
--

CREATE TABLE `expos` (
  `id` bigint UNSIGNED NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `background_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `background_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_family` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_style` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_weight` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `banner_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'upcoming',
  `vendor_slot_capacity` int DEFAULT NULL,
  `product_capacity_per_slot` int DEFAULT NULL,
  `slot_pricing` json DEFAULT NULL,
  `free_participation` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `expos`
--

INSERT INTO `expos` (`id`, `name_en`, `name_ar`, `description_en`, `description_ar`, `background_color`, `background_image`, `font_family`, `font_style`, `font_size`, `font_color`, `font_weight`, `banner_image`, `start_date`, `end_date`, `status`, `vendor_slot_capacity`, `product_capacity_per_slot`, `slot_pricing`, `free_participation`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 'Kids Expo', 'معرض الأطفال', '<p>Kids Expo</p>', '<p>Kids Expo</p>', '#ffffff', 'expos/GBN55uHA5P326w4cdBSx3gOsz1p0ZlnsP3GsZiWc.png', NULL, 'normal', '16', NULL, '400', 'expos/ySClKgwUS86JSC9Nq2yy5nPMlfrzRDFXsLJrgCXs.png', '2025-12-18 18:09:00', '2025-12-19 18:09:00', 'expired', 100, 100, '\"[{\\\"slot\\\":1,\\\"price\\\":\\\"10\\\"}]\"', 0, '2025-12-18 18:10:24', '2025-12-18 18:09:49', '2025-12-22 09:48:42'),
(2, 'Arpit Test', 'Arpit Test', '<p><strong>Arpit Test</strong></p>', '<p><strong>Arpit Test</strong></p>', '#ffffff', 'expos/O4VcQeH1WQ4iImGq7jrkcxkqmh0OzFOvt6Ts7CPl.png', NULL, 'normal', '16', NULL, '400', NULL, '2025-12-22 09:50:00', '2025-12-26 09:50:00', 'expired', 10, 5, '\"[{\\\"slot\\\":1,\\\"price\\\":\\\"10\\\"}]\"', 0, '2025-12-22 09:52:30', '2025-12-22 09:50:44', '2025-12-26 18:32:31'),
(3, 'Winter Expo', 'معرض الشتاء', '<p><span style=\"color: rgb(0, 0, 0);\">A seasonal expo held during winter where stores and local businesses showcase their winter-related products, services, and activities.</span></p>', '<p><span style=\"color: rgb(0, 0, 0);\">معرض موسمي يُقام خلال فصل الشتاء، حيث تعرض المتاجر والشركات المحلية منتجاتها وخدماتها وأنشطتها المرتبطة بفصل الشتاء.</span></p>', '#ffffff', 'expos/NLwUCx07ijNVMP0kGPYR4TstA4nz6CguaDe3kLIm.jpg', 'Arial', 'normal', '20', '#ffffff', '600', 'expos/COzKThk2JuAgxVXwhmxVGEo8nAVo0YMRBmVzWr8Y.png', '2026-01-13 13:35:00', '2026-01-20 23:59:00', 'inactive', 50, 50, '\"[{\\\"from\\\":1,\\\"to\\\":50,\\\"price\\\":\\\"0\\\"}]\"', 1, NULL, '2025-12-23 13:45:21', '2026-01-13 16:06:45'),
(4, 'Dara\'at Expo', 'معرض الدراعات', NULL, NULL, '#ffffff', 'expos/I9Z6tnidJ69F0coExwb53XJv8ENaVqirTvHhb5vl.jpg', 'Arial', 'normal', '16', '#ffffff', '400', NULL, '2026-01-21 09:00:00', '2026-01-30 11:15:00', 'inactive', 50, 50, '\"[{\\\"from\\\":1,\\\"to\\\":5,\\\"price\\\":\\\"200\\\"},{\\\"from\\\":6,\\\"to\\\":50,\\\"price\\\":\\\"\\\"}]\"', 0, NULL, '2025-12-29 12:46:51', '2026-01-16 22:39:22'),
(5, 'Expoza Ramadhani Expo', 'معرض اكسبوزا الرمضاني', '<p><span style=\"background-color: rgb(245, 245, 245); color: rgb(60, 64, 67);\">A seasonal exhibition held before the holy month of Ramadan, where local shops and companies display their distinctive products in preparation for Ramadan.</span></p>', '<p>معرض موسمي يُقام قبل شهر رمضان المبارك، حيث تعرض المتاجر والشركات المحلية منتجاتها المميزة الخاصة بالتجهيز لشهر رمضان.</p>', '#ffffff', 'expos/1gpflarFrAzyqhEbbSNozOTka5zGz5fFWgzH1VtQ.png', 'Arial', 'normal', '18', '#ffffff', '500', NULL, '2026-02-05 09:00:00', '2026-02-15 23:59:00', 'upcoming', 50, 50, '\"[{\\\"from\\\":1,\\\"to\\\":10,\\\"price\\\":\\\"0\\\"},{\\\"from\\\":11,\\\"to\\\":50,\\\"price\\\":\\\"100\\\"}]\"', 0, '2026-01-13 12:06:04', '2026-01-13 12:00:07', '2026-01-13 12:06:04'),
(6, 'Expoza Ramadhani Expo', 'معرض اكسبوزا الرمضاني', '<p>A seasonal expo held before the holy month of Ramadan, where local shops and companies display their distinctive products in preparation for Ramadan.</p>', '<p>معرض موسمي يُقام قبل شهر رمضان المبارك، حيث تعرض المتاجر والشركات المحلية منتجاتها المميزة الخاصة بالتجهيز لشهر رمضان.</p>', '#ffffff', 'expos/f3SFAfslYjoMxwwoPiHBM63LjOiSWY2SnW6orR9T.jpg', 'Arial', 'normal', '16', '#ffffff', '400', NULL, '2026-02-05 09:00:00', '2026-02-19 23:59:00', 'upcoming', 50, 50, '\"[{\\\"from\\\":1,\\\"to\\\":10,\\\"price\\\":\\\"0\\\"},{\\\"from\\\":11,\\\"to\\\":50,\\\"price\\\":\\\"100\\\"}]\"', 0, NULL, '2026-01-13 12:07:07', '2026-01-17 00:05:15');

-- --------------------------------------------------------

--
-- Table structure for table `expo_category`
--

CREATE TABLE `expo_category` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED NOT NULL,
  `category_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expo_products`
--

CREATE TABLE `expo_products` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED DEFAULT NULL,
  `product_id` bigint UNSIGNED DEFAULT NULL,
  `vendor_id` bigint UNSIGNED DEFAULT NULL,
  `slot_id` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expo_product_coupons`
--

CREATE TABLE `expo_product_coupons` (
  `id` bigint UNSIGNED NOT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rule` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `per_user_limit` int UNSIGNED DEFAULT NULL,
  `total_limit` int UNSIGNED DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expo_sections`
--

CREATE TABLE `expo_sections` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `section_id` bigint UNSIGNED NOT NULL,
  `slot_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expo_slots`
--

CREATE TABLE `expo_slots` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `regular_price` decimal(10,2) NOT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expo_vendor`
--

CREATE TABLE `expo_vendor` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `address_id` bigint UNSIGNED DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slot` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `products_count` int NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `approved_at` timestamp NULL DEFAULT NULL,
  `joined_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faqs`
--

CREATE TABLE `faqs` (
  `id` bigint UNSIGNED NOT NULL,
  `question_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `answer_en` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_ar` text COLLATE utf8mb4_unicode_ci,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_transactions`
--

CREATE TABLE `finance_transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `vendor_id` bigint UNSIGNED DEFAULT NULL,
  `user_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `summery` text COLLATE utf8mb4_unicode_ci,
  `payment_processor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_reference_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `charge` decimal(10,2) NOT NULL DEFAULT '0.00',
  `attempted_at` timestamp NULL DEFAULT NULL,
  `attempt_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `finance_transactions`
--

INSERT INTO `finance_transactions` (`id`, `user_id`, `vendor_id`, `user_type`, `transaction_id`, `type`, `summery`, `payment_processor`, `payment_reference_id`, `amount`, `charge`, `attempted_at`, `attempt_status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, NULL, NULL, 'vendor', 'TXN090919174473918092709394', 'subscription', 'subscription purchase payment', 'KNET', 'REF090919174473918092709394', 0.50, 0.00, '2025-12-21 13:10:05', 'InProgress', '2025-12-21 15:40:42', '2025-12-21 15:40:42', NULL),
(2, NULL, NULL, 'vendor', 'TXND3B0F51A596A8C8B', 'expo_booking', 'Vendor expo slot 1 booking (Free Participation)', 'free', 'REFFE0EC5B7442D7D3A', 0.00, 0.00, '2025-12-23 15:15:10', 'success', '2025-12-23 15:15:10', '2025-12-23 15:15:10', NULL),
(3, NULL, NULL, 'vendor', 'TXN55549B7904AE6E50', 'expo_booking', 'Vendor expo slot 2 booking (Free Participation)', 'free', 'REF1DE9AB38E4A8CFB5', 0.00, 0.00, '2025-12-23 15:57:25', 'success', '2025-12-23 15:57:25', '2025-12-23 15:57:25', NULL),
(4, NULL, NULL, 'user', '535820001511361', 'order', 'Order Placed', 'knet', '535820001511361', 399.00, 0.00, '2025-12-24 18:57:57', 'pending', '2025-12-24 18:57:57', '2025-12-24 18:57:57', NULL),
(5, NULL, NULL, 'vendor', 'TXNE0415B308E72A236', 'subscription', 'Vendor subscription purchase payment', 'myfatoorah', 'REF82BD622EE9D732EF', 1.00, 0.00, '2025-12-26 17:56:39', 'success', '2025-12-26 17:56:39', '2025-12-26 17:56:39', NULL),
(6, NULL, NULL, 'vendor', 'TXN7DCBBF04C99F76EF', 'subscription', 'Vendor subscription purchase payment', 'myfatoorah', 'REFA81E73EF48702AAF', 1.00, 0.00, '2025-12-29 13:32:09', 'success', '2025-12-29 13:32:09', '2025-12-29 13:32:09', NULL),
(7, NULL, NULL, 'vendor', 'TXN71A1EB6DCDBDDC91', 'subscription', 'Vendor subscription purchase payment', 'myfatoorah', 'REF2C192AED0021B8F7', 1.00, 0.00, '2026-01-02 00:44:05', 'success', '2026-01-02 00:44:05', '2026-01-02 00:44:05', NULL),
(8, NULL, NULL, 'vendor', 'TXN738F4914876367F6', 'expo_booking', 'Vendor expo slot 1 booking (Free Participation)', 'free', 'REF18E4859279080971', 0.00, 0.00, '2026-01-02 00:52:13', 'success', '2026-01-02 00:52:13', '2026-01-02 00:52:13', NULL),
(9, NULL, NULL, 'vendor', 'TXN3E5319354131F875', 'subscription', 'Free subscription activation', 'free', 'REFBC2375ED6A8B014D', 0.00, 0.00, '2026-01-07 15:18:39', 'success', '2026-01-07 15:18:39', '2026-01-07 15:18:39', NULL),
(10, NULL, NULL, 'vendor', 'TXNEE3D0E4EEB152C42', 'subscription', 'Vendor subscription purchase payment', 'myfatoorah', 'REFC55FF924E336978E', 0.00, 0.00, '2026-01-13 13:01:51', 'success', '2026-01-13 13:01:51', '2026-01-13 13:01:51', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `fulfillments`
--

CREATE TABLE `fulfillments` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `courier_partner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_ready` tinyint(1) DEFAULT '0',
  `is_ready_at` timestamp NULL DEFAULT NULL,
  `is_dispatched` tinyint(1) DEFAULT '0',
  `is_dispatched_at` timestamp NULL DEFAULT NULL,
  `in_transit` tinyint(1) DEFAULT '0',
  `in_transit_at` timestamp NULL DEFAULT NULL,
  `is_delivered` tinyint(1) DEFAULT '0',
  `is_delivered_at` timestamp NULL DEFAULT NULL,
  `is_rto` tinyint(1) DEFAULT '0',
  `is_rto_at` timestamp NULL DEFAULT NULL,
  `is_rto_recieved` tinyint(1) DEFAULT '0',
  `is_rto_recieved_at` timestamp NULL DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fulfillment_items`
--

CREATE TABLE `fulfillment_items` (
  `id` bigint UNSIGNED NOT NULL,
  `fullfilment_id` bigint UNSIGNED NOT NULL,
  `item_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_06_24_063651_create_permission_tables', 1),
(5, '2025_06_25_085940_create_expos_table', 1),
(6, '2025_06_25_113343_create_categories_table', 1),
(7, '2025_06_25_130000_create_subscriptions_table', 1),
(8, '2025_06_25_135000_create_vendors_table', 1),
(9, '2025_06_25_140000_create_ads_table', 1),
(10, '2025_06_25_150000_create_orders_table', 1),
(11, '2025_06_25_160000_create_products_table', 1),
(12, '2025_06_26_050000_create_countries_table', 1),
(13, '2025_06_26_060000_create_cms_pages_table', 1),
(14, '2025_06_26_070000_create_finance_transactions_table', 1),
(15, '2025_06_26_080000_create_vendor_payouts_table', 1),
(16, '2025_06_26_090000_create_states_table', 1),
(17, '2025_06_26_100000_create_cities_table', 1),
(18, '2025_06_26_120000_create_settings_table', 1),
(19, '2025_06_26_130000_create_audit_logs_table', 1),
(20, '2025_06_27_041212_create_addresses_table', 1),
(21, '2025_06_27_041213_create_expo_vendor_table', 1),
(22, '2025_06_27_060000_create_vendor_subscriptions_table', 1),
(23, '2025_06_27_072321_create_expo_category_table', 1),
(24, '2025_06_27_093236_create_sections_table', 1),
(25, '2025_06_28_000000_create_expo_product_coupons_table', 1),
(26, '2025_07_01_000001_create_wishlists_table', 1),
(27, '2025_07_01_000002_create_notifications_table', 1),
(28, '2025_07_01_000003_create_faqs_table', 1),
(29, '2025_07_01_000004_create_support_requests_table', 1),
(30, '2025_07_01_000005_create_cart_tables', 1),
(31, '2025_07_01_000006_create_otps_table', 1),
(32, '2025_07_01_000007_create_notification_views_table', 1),
(33, '2025_07_01_000008_create_contact_queries_table', 1),
(34, '2025_07_01_000011_create_attributes_table', 1),
(35, '2025_07_01_000013_create_waiting_lists_table', 1),
(36, '2025_07_01_000014_create_order_items_table', 1),
(37, '2025_07_01_000015_create_reviews_table', 1),
(38, '2025_07_01_000016_create_fulfillments_table', 1),
(39, '2025_07_01_000017_create_fulfillment_items_table', 1),
(40, '2025_07_01_000018_create_expo_slots_table', 1),
(41, '2025_07_01_000019_create_section_products_table', 1),
(42, '2025_07_01_000020_create_coupon_usages_table', 1),
(43, '2025_07_09_130423_create_expo_products_table', 1),
(44, '2025_07_10_000001_create_cart_items_table', 1),
(45, '2025_07_18_061011_create_personal_access_tokens_table', 1),
(46, '2025_07_22_050623_add_city_id_and_drop_city_to_addresses_table', 1),
(47, '2025_07_28_000000_create_slot_bookings_table', 1),
(48, '2025_08_01_000000_create_expo_sections_table', 1),
(49, '2025_08_02_000007_add_slot_number_to_slot_bookings_table', 1),
(50, '2025_08_02_000008_add_status_at_to_fulfillments_table', 1),
(51, '2025_08_02_151559_add_slot_id_to_expo_sections_table', 1),
(52, '2025_08_03_001600_add_slot_id_to_expo_products_table', 1),
(53, '2025_08_06_180157_add_slot_id_to_expo_sections_unique_constraint', 1),
(54, '2025_08_06_180424_drop_old_expo_sections_unique_constraint', 1),
(55, '2025_08_18_162153_add_order_id_to_notifications_table', 1),
(56, '2025_08_19_122944_add_vendor_id_to_finance_transactions_table', 1),
(57, '2025_09_01_114706_add_socialite_ids_to_users_table', 1),
(58, '2025_11_17_142933_add_armada_fields_to_orders_table', 1),
(59, '2025_12_08_000001_add_use_armada_delivery_to_vendors_table', 1),
(60, '2025_12_08_000002_add_multilang_fields_to_faqs_table', 1),
(61, '2025_12_09_105242_add_free_participation_to_expos_table', 1),
(62, '2025_12_09_154451_add_vendor_expo_id_to_slot_bookings_table', 1),
(63, '2025_12_22_163822_add_variant_fields_to_cart_items_and_order_items', 2),
(64, '2025_01_07_000001_add_price_and_type_to_vendor_subscriptions_table', 3);

-- --------------------------------------------------------

--
-- Table structure for table `model_has_permissions`
--

CREATE TABLE `model_has_permissions` (
  `permission_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `model_has_roles`
--

CREATE TABLE `model_has_roles` (
  `role_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `model_has_roles`
--

INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES
(1, 'App\\Models\\User', 1),
(2, 'App\\Models\\User', 2),
(3, 'App\\Models\\User', 3),
(2, 'App\\Models\\User', 4),
(2, 'App\\Models\\User', 5),
(2, 'App\\Models\\User', 6),
(2, 'App\\Models\\User', 8),
(2, 'App\\Models\\User', 11),
(2, 'App\\Models\\User', 12),
(2, 'App\\Models\\User', 18),
(2, 'App\\Models\\User', 19),
(2, 'App\\Models\\User', 20),
(2, 'App\\Models\\User', 31),
(2, 'App\\Models\\User', 35),
(2, 'App\\Models\\User', 37),
(2, 'App\\Models\\User', 41);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint UNSIGNED NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8mb4_unicode_ci,
  `content` text COLLATE utf8mb4_unicode_ci,
  `icon_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `user_id` bigint UNSIGNED NOT NULL,
  `order_id` bigint DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification_views`
--

CREATE TABLE `notification_views` (
  `id` bigint UNSIGNED NOT NULL,
  `notification_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint UNSIGNED NOT NULL,
  `order_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `armada_order_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `armada_tracking_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `armada_response` json DEFAULT NULL,
  `is_armada_synced` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `coupon_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `billing_address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_items` int NOT NULL,
  `sub_total_amount` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `shipping_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL,
  `order_summary` text COLLATE utf8mb4_unicode_ci,
  `order_status` enum('pending','confirmed','processing','ready_for_pickup','shipped','out_for_delivery','delivered','cancelled','returned','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `payment_status` enum('pending','paid','cancelled','failed','refunded','unpaid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `refund_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_status` enum('pending','processing','shipped','out_for_delivery','delivered','returned','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refund_approved_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refund_requested_at` timestamp NULL DEFAULT NULL,
  `refund_rejection_reason_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refund_rejection_reason_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `quantity` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount_applied` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL,
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delivery_status` enum('pending','processing','shipped','out_for_delivery','delivered','returned','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otps`
--

CREATE TABLE `otps` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `otp` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_in` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'view_role', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(2, 'create_role', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(3, 'edit_role', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(4, 'delete_role', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(5, 'view_permission', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(6, 'create_permission', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(7, 'edit_permission', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(8, 'delete_permission', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(9, 'manage_users', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(10, 'view_users', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(11, 'create_users', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(12, 'edit_users', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(13, 'delete_users', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(14, 'manage_vendors', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(15, 'view_vendors', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(16, 'edit_vendors', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(17, 'delete_vendors', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(18, 'approve_vendors', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(19, 'manage_expos', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(20, 'manage_orders', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(21, 'manage_categories', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(22, 'manage_products', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(23, 'manage_subscriptions', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(24, 'manage_ads', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(25, 'manage_cms', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(26, 'manage_finance', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(27, 'manage_settings', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(28, 'view_audit_logs', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(29, 'view_own_dashboard', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(30, 'manage_own_profile', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(31, 'view_own_kyc_status', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(32, 'change_own_password', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(33, 'delete_own_account', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(34, 'manage_own_products', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(35, 'create_own_product', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(36, 'edit_own_product', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(37, 'delete_own_product', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(38, 'suspend_own_product', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(39, 'assign_product_to_category', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(40, 'assign_product_to_section', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(41, 'view_expos', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(42, 'join_expo', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(43, 'manage_own_expo_participation', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(44, 'assign_products_to_expo', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(45, 'create_section_in_expo', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(46, 'add_coupon_to_expo_product', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(47, 'manage_own_orders', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(48, 'view_own_orders', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(49, 'approve_refund_request', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(50, 'reject_refund_request', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(51, 'generate_invoice', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(52, 'view_own_finance', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(53, 'view_own_payouts', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(54, 'export_own_finance_csv', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(55, 'manage_own_ads', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(56, 'create_own_ad', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(57, 'edit_own_ad', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(58, 'delete_own_ad', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(59, 'suspend_own_ad', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(60, 'view_own_subscription', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(61, 'upgrade_own_subscription', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(62, 'renew_own_subscription', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(63, 'cancel_own_subscription', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(64, 'view_own_analytics', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(65, 'export_own_analytics_csv', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 7, 'auth-token', '2b210ff1f05b7b0b28ae54b1364c9935b336d1af58c089b84c4b428ee1efc02c', '[\"*\"]', '2025-12-23 15:35:05', NULL, '2025-12-23 15:17:58', '2025-12-23 15:35:05'),
(2, 'App\\Models\\User', 7, 'auth-token', '12ecbec01c38b38d1804013eee2bfdf2e1c9aebf41714ae7ce2360070de75f74', '[\"*\"]', '2025-12-24 12:56:34', NULL, '2025-12-24 12:56:34', '2025-12-24 12:56:34'),
(3, 'App\\Models\\User', 6, 'auth-token', '773f6d6073db230133dfe4b3103334f49c0831ef705ea3d9ae7340d5511edccc', '[\"*\"]', '2025-12-24 16:07:17', NULL, '2025-12-24 15:57:50', '2025-12-24 16:07:17'),
(4, 'App\\Models\\User', 6, 'auth-token', '5a49fa70a67617f7b467abd5bf8ba42af61c5444ed749b79ed04491dd0a4c0fe', '[\"*\"]', '2025-12-25 18:45:16', NULL, '2025-12-24 18:02:53', '2025-12-25 18:45:16'),
(5, 'App\\Models\\User', 10, 'auth-token', 'd0bbc356d6435abd304a3f296485c41d9adbced62b993c0f2f39ff080f8636cb', '[\"*\"]', '2025-12-24 19:00:22', NULL, '2025-12-24 18:53:51', '2025-12-24 19:00:22'),
(6, 'App\\Models\\User', 10, 'auth-token', '571254333daeb841a1303650f1fdd0ccaec95b19cc8a70aece820032e0dba1e5', '[\"*\"]', '2025-12-29 16:44:46', NULL, '2025-12-24 19:01:12', '2025-12-29 16:44:46'),
(7, 'App\\Models\\User', 10, 'auth-token', '4d054d1bcbca02ae32bece07d0b2d972d2493fe8b486fa4ccbbb55b020c57157', '[\"*\"]', '2025-12-25 17:54:00', NULL, '2025-12-25 17:51:02', '2025-12-25 17:54:00'),
(8, 'App\\Models\\User', 10, 'auth-token', '32e0245416c353434ed792f510cb696a177a0c15fcafe1dc854bd619bc47c078', '[\"*\"]', '2025-12-26 17:52:09', NULL, '2025-12-26 17:49:16', '2025-12-26 17:52:09'),
(9, 'App\\Models\\User', 10, 'auth-token', 'a09ec73b0353f7c600a2f0888b3caba09832e337064d962b3c24925790864f02', '[\"*\"]', '2025-12-27 08:11:30', NULL, '2025-12-27 08:09:35', '2025-12-27 08:11:30'),
(10, 'App\\Models\\User', 7, 'auth-token', '161fa1883d57c032ceaa21cf90af889caf3aff71508fb040f575d97161c776d2', '[\"*\"]', '2025-12-29 16:41:07', NULL, '2025-12-29 16:41:06', '2025-12-29 16:41:07'),
(11, 'App\\Models\\User', 14, 'auth-token', '384fed44de1e5dd597288290c42ae2fe4bd6fb187c45f383ccd1d7540f1a5a3f', '[\"*\"]', '2025-12-29 17:53:16', NULL, '2025-12-29 17:53:15', '2025-12-29 17:53:16'),
(12, 'App\\Models\\User', 15, 'auth-token', '5bfe1a03886b3604f0fd4e187aa68c606796904222c8300ffebf6634e6a85498', '[\"*\"]', '2025-12-29 18:11:04', NULL, '2025-12-29 18:10:54', '2025-12-29 18:11:04'),
(13, 'App\\Models\\User', 15, 'auth-token', 'd4e7e6cbf659d29427908e1c736cf177eb25b7ceea24b8c4c5a2083588c95c17', '[\"*\"]', '2025-12-29 18:11:33', NULL, '2025-12-29 18:11:33', '2025-12-29 18:11:33'),
(14, 'App\\Models\\User', 16, 'auth-token', 'e96ae85717982540947cbde7ed9166d7e24c62a2ff5470cf49287dc54b5f17bf', '[\"*\"]', '2025-12-30 16:37:59', NULL, '2025-12-30 16:36:38', '2025-12-30 16:37:59'),
(15, 'App\\Models\\User', 17, 'auth-token', 'ad5f616e31e4d18e8d298ca209f1fd3fc521ad6cd0c04f09da0e586b4811b3ed', '[\"*\"]', '2026-01-06 21:13:22', NULL, '2025-12-30 19:29:26', '2026-01-06 21:13:22'),
(16, 'App\\Models\\User', 7, 'auth-token', 'd3e516299c11a82fe90d5b1031980d54306fbf98cfbe89b2b722470d70cbebe0', '[\"*\"]', '2026-01-05 20:13:25', NULL, '2026-01-05 20:08:46', '2026-01-05 20:13:25'),
(17, 'App\\Models\\User', 7, 'auth-token', '5890da48c6df1a9a5393d7fb990b8034a0dcd4d4f8d6fe1f909afee8cc9d914c', '[\"*\"]', '2026-01-11 16:08:28', NULL, '2026-01-06 18:58:55', '2026-01-11 16:08:28'),
(18, 'App\\Models\\User', 7, 'auth-token', '3117fa97977a693ee16ad18bde6bad98d43f5c67efbf9c04680ab2fd9e01a2fb', '[\"*\"]', '2026-01-08 14:57:45', NULL, '2026-01-08 13:07:12', '2026-01-08 14:57:45'),
(19, 'App\\Models\\User', 10, 'auth-token', '7537678c9224dff355af9e4a0f74fa93fee7fdb729f6ea17a4900d976c095924', '[\"*\"]', '2026-01-08 14:37:26', NULL, '2026-01-08 14:34:22', '2026-01-08 14:37:26'),
(20, 'App\\Models\\User', 10, 'auth-token', '56fb2fd6d9dbb73d11cd81f15814615a6e78ca9645a643afcd95f0485f671153', '[\"*\"]', '2026-01-08 14:42:55', NULL, '2026-01-08 14:39:48', '2026-01-08 14:42:55'),
(21, 'App\\Models\\User', 22, 'auth-token', 'd01b85c6b07d826f24430d802d238d0288ff10123f2c5e4759cbef27fe47af5f', '[\"*\"]', '2026-01-08 15:38:30', NULL, '2026-01-08 15:35:06', '2026-01-08 15:38:30'),
(22, 'App\\Models\\User', 25, 'auth-token', '5ab9eb808d875c9f319c6a6f8f8b9814e183139d1797eab55c11dcbff604fc95', '[\"*\"]', '2026-01-14 13:20:03', NULL, '2026-01-11 11:14:01', '2026-01-14 13:20:03'),
(23, 'App\\Models\\User', 10, 'auth-token', '90c91a2cdffe1127fc264105ab50079fa05d65619234e422734f9c341dc6c0f2', '[\"*\"]', '2026-01-12 17:27:52', NULL, '2026-01-12 17:24:51', '2026-01-12 17:27:52'),
(24, 'App\\Models\\User', 28, 'auth-token', '812ca33de205dff5399cbee38105d65c72c045e2e79b596172eb2b32b619ee2c', '[\"*\"]', '2026-01-13 11:10:49', NULL, '2026-01-13 11:10:07', '2026-01-13 11:10:49'),
(25, 'App\\Models\\User', 10, 'auth-token', 'bf2bcd92fb83e9e2d0faaf3367374b1bee4e4fb690f4d7432ee478b9467fb03c', '[\"*\"]', '2026-01-13 15:42:54', NULL, '2026-01-13 15:40:39', '2026-01-13 15:42:54'),
(26, 'App\\Models\\User', 10, 'auth-token', 'f8115ea33a8955ab61ca5d83996fd9c6303035863a71d0c24e5101e7db1b9d8e', '[\"*\"]', '2026-01-13 15:49:51', NULL, '2026-01-13 15:46:57', '2026-01-13 15:49:51'),
(27, 'App\\Models\\User', 32, 'auth-token', 'be66ae02ac34f6c2505bba761dfebbaf02043bcd3b0da3acf98a8dd69a9734ef', '[\"*\"]', '2026-01-13 16:03:21', NULL, '2026-01-13 16:03:21', '2026-01-13 16:03:21'),
(28, 'App\\Models\\User', 10, 'auth-token', 'c14f27608b1627691fb9dd8bffe75133d74d2838668cf0a10250ef39c0f73cf0', '[\"*\"]', '2026-01-15 22:36:34', NULL, '2026-01-15 22:36:15', '2026-01-15 22:36:34');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint UNSIGNED NOT NULL,
  `parent_id` bigint UNSIGNED DEFAULT NULL,
  `category_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `views` int NOT NULL DEFAULT '0',
  `attributes` json DEFAULT NULL,
  `regular_price` decimal(10,2) DEFAULT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gallery` json DEFAULT NULL,
  `status` enum('active','suspended','deleted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `stock` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `rating` int NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(2, 'vendor', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27'),
(3, 'user', 'web', '2025-12-18 17:18:27', '2025-12-18 17:18:27');

-- --------------------------------------------------------

--
-- Table structure for table `role_has_permissions`
--

CREATE TABLE `role_has_permissions` (
  `permission_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_has_permissions`
--

INSERT INTO `role_has_permissions` (`permission_id`, `role_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(11, 1),
(12, 1),
(13, 1),
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 1),
(20, 1),
(21, 1),
(22, 1),
(23, 1),
(24, 1),
(25, 1),
(26, 1),
(27, 1),
(28, 1),
(29, 2),
(30, 2),
(31, 2),
(32, 2),
(33, 2),
(34, 2),
(35, 2),
(36, 2),
(37, 2),
(38, 2),
(39, 2),
(40, 2),
(41, 2),
(42, 2),
(43, 2),
(44, 2),
(45, 2),
(46, 2),
(47, 2),
(48, 2),
(49, 2),
(50, 2),
(51, 2),
(52, 2),
(53, 2),
(54, 2),
(55, 2),
(56, 2),
(57, 2),
(58, 2),
(59, 2),
(60, 2),
(61, 2),
(62, 2),
(63, 2),
(64, 2),
(65, 2);

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `section_products`
--

CREATE TABLE `section_products` (
  `id` bigint UNSIGNED NOT NULL,
  `section_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('01zv5TWh3xsE5LCF9S5prgR1S9SdVrabuAJYCwis', NULL, '35.187.132.229', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTdXdjZuRTc2WjhLTTZOTWZ6M044TXlEeElhck95d0tCTXNjQldZWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625624),
('02E8yGO21H6gTlPTo905Twc2bFeDqnaBOP9IXSUQ', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMmt6eGNtWmZWM2F6VVRsOE9vNVhmMjBoRnRiMVNRSGR6YWFadlR0eSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy9jcmVhdGUiO3M6NToicm91dGUiO3M6MTI6ImV4cG9zLmNyZWF0ZSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768285477),
('08zcUHp5NUrq4LrTPrYTudI74Lpp5cC6iyl3bKjr', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTdidkJBZ3F2OUVHS2x2NTFlbHhQemJ2eXhIeG5oanBJT1RveEpYVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('09vV459oRxYWixlpwflHQCJGTVhcmA9r8PmQa7Ab', NULL, '54.91.83.49', 'Mozilla/5.0 (X11; CrOS x86_64 14588.98.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.59 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid2pZMlJIWjVWcnl5QTF2U2RDRm9FYkRhR0VncnQ0NGtEZGp1OTFEMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768245516),
('0b6L7jytYSfWjLxQKy7y1mfqRu5qScLIgIG79sBP', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGZncjBtYlRWdHUzdlUySm1ZVGljTHJSd3ZCcnRiQnMxc3QzamV3diI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768150523),
('0l19xc8qi63UF25kgYNWPVDrb6kEqVe9TY5q7fIs', NULL, '43.157.179.227', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYWR4UVNnQ0hISENNR1N2WWhTNjQwektpTlhSVzV6WElHSXlQMlBHViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768159834),
('0MHUYObuWUrF8C94saNmFzJ1XIT4eXKQf530rc83', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic0N6dWpNM1FjR2g3Q3p3MkZlekpmdndhMDZtYlJxRlAyZmlUVU9xdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767862307),
('0NTe4U8a9vOeQW0wRle0zU89Cmx48odOaQ026XUE', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibnEwVTVCN0hvSmo1c3hJak1pYmllSUZtQkhNWnRlUVJ6ZkxZUUdKTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767860362),
('0OlgvACVeJWxPQLY4FXm9P4DtM6daWQ0tSEwBfuS', NULL, '74.7.227.129', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjh2ekg1TEVYaWc0dzl5eFpuc2tua2xlTmFrN0NRM0lUWWFBNWQ2MSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767818699),
('0RiY1MxuGEbDugiCn8vbhfcnI68NqT8j4HLIvS0g', NULL, '54.175.86.167', 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.1 (KHTML, like Gecko) Ubuntu/11.04 Chromium/14.0.825.0 Chrome/14.0.825.0 Safari/535.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibEtDckNvYVVtV1hUMHVFMVZEYTQxRXVBZkNIa1N3MGJqVWE2QzVKTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767548574),
('0t8menr1Wuv3hiBr6tj2gc1EhNZdPh5CBBvk7ZMm', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSlIwU0w5bFBTdmQ4eGtITWhjeGFFWGhkTG5MUVI4SXZRYU9GNDNETSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767759077),
('0XbBKZBgCEQhrpZ1gjduRtSH55ZPI1aXaD58FCqJ', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUY0VlRzNm9Rc2c3eTZkNFR6eVlVWWIzWndtc21telBhTkFyYzVFWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121885),
('0xiefEplrSbXZsOpaXAldcCtnzUjs2YB6crsnRFH', NULL, '150.109.46.88', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYkdnOFc2cVl2a1AwdlhSdU9JbWFrMmZycldXeVBHYUo3aG8wcGZDeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768012629),
('0YteIPAAcdOZvPFlZOtTRsOvhFGiRvmqr6UFhtAD', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMjM5UjhRY3g0R0RzNVNZak9CaE5TOEdaYWdvN2lYS3VTa216aWJZSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767584936),
('0yukU4V4GumzFIm30wE4FFhKmxaGnUdLWATWJkV1', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRll3OWNDR1FnQXhabEU2OG1aS01OeUZHd0dUZEt0emNQNXR5SWY0ZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768708135),
('1A9eH7bp2fQCa1piFuUaUaVemkusXD2y8x9INeE7', NULL, '209.85.238.65', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiemlNQXF2SVlyMlI5Nm51aFFjYnRSUnRObnFZem53SXEwbEpwQ0ZEVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768371596),
('1DxnJwZwLQjZSFEWb9mk631wA7kf9baNeZloJZiv', NULL, '34.1.25.201', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko; compatible; BW/1.3; rb.gy/qyzae5) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ3NCVll0ekFQSHVUSjMxTmdhcEJHc2pyZ3Z3Q2dLc0IyS1lKTWR5QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768348289),
('1EWoFbK0S7jjF9GfJemsnzIZsaYXszSbtchrtdT7', NULL, '40.77.167.43', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiemdRSUY2Tk1KWDFqTUJMMWQwQURHcE41QTdaakVKdHFkUjY0V3A5MyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767828828),
('1HTsXRt4qx8WM7EFKPvUIUBO9wJu86I97UqkSeEd', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidjdzdkJGNjc3eFY5NGZydmlpZ2ZlM0JWUEoxUzQxTktyU2FTYXNzaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768287729),
('1jMsXlQ4DB3AOmH8GpUzfe9yVsr84hxm9tjJylbv', NULL, '43.166.226.186', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibmtFekdrcG9jSkc2dzVWYUdBZHNOeW1UbUlaeGh4bVc5eE9FMWlqSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768514035),
('1KinGaJ3KcohMgiW0qYe1TeEhqZErMhWZqDIHCHZ', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibUpUQUF6MHNuaGRwcHdkME1zdU5Da2JScFdDQVBZMnM1blk5ZFQ5SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767673620),
('1LJVrVYffhHr83NzSoJBl4s0d6jIkw3B9LctJPQo', NULL, '209.85.238.4', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaTRCU0pyY1hBZThkREJUaFBKbGhzMzNkRWxCamhCNFB6blJURTFkSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768708910),
('1n0H4MwdRDIjDaXN71z1BEbL1mPwPvTezRc6bWDp', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlJBdzJDZko5RFFmcHFrdlBWNFFuOXlyZFVGb1RDNjRiTDdOR0dUQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716284),
('1pFuj7yZZsIf8HWbMQ8RwwdbgnSKYAYkUT1eqA6G', NULL, '51.83.243.160', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQTlORUpKemxrZXB1dlp5RElGYjFRTXJzQUNLTkc1SnBqOUU2b3hlWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767636957),
('1pvlvFknfRz7xjh7WLq1o3tmDEukdgujoLD7Yr2A', NULL, '34.23.140.116', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQVIwVGJ3SXcxUFE3dExFMGc2Z0VrZElnRVk5RVc4N3pLTE5QNWJUOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767633803),
('1qC6SdfdFHSH5hvifaDo9wdDPUV7tmbWX5wlWQcV', NULL, '45.94.31.42', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicFpKUDN1bGZpSzA2eE5YT21aRkt1ZWE0N01aU0xtQUdJZjJsWjd0RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767523479),
('1uIjGV5l7T0TIulRnIm0FNQQ6w9RfjlrWqkDYXgs', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoienM5azVQdlF0T1d1NUM2bkx0aExjVTM5TXN0cmNxTXRpYXlBVXE4NSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3JzIjtzOjU6InJvdXRlIjtzOjEzOiJ2ZW5kb3JzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768295803),
('1vBXQ3rLAQNaLQMRWrFveKPHn3KxrGXfu0cMbG5T', NULL, '135.148.195.4', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUFR6aHdselJBVHBSVmRyZE5MNDE5VkpheWQ0UGhURFZIS3ZsRUwxUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767958956),
('1YTNTqMfA2yqrLM31WU6mEtjWMlsZxcGRHcxTXdS', NULL, '66.249.73.129', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzFPQXZDODFXY1dwcnVkOHFOV0NNM0E0S0NucHVTZGJkTzJsUXpDRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768769042),
('204DgTnIQrsiipO41ZH3Xyw8gJJ0LX4vhkFemKXG', NULL, '195.178.110.132', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGJnNXFKbEM5SnIwZTJGWVJlYm1mRU50SFNPNG5ydEp4bmtwWXNVNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767892920),
('20v6n8MvaHb7pjsQJ1G16jzrjVyy2vU3q0yVLKwI', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR3FBbDlIeU41R3BDTzFGZ2lURU9BQW92Z0IxM3VJN0thbzBGUlU5SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471405),
('21xXORPqJ3Qj8gCPuutx8lU9Wg04MxYpg2yfySWp', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic2pUVVZKcHUyUHNLaEgxSkJ1ZURuOTUySzA1SkpuU1Z1SkxYMGtGdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768305032),
('2Acnb8NyijTpHNDwvm4uI3qzSmAU6XjN4FKrmg80', NULL, '93.158.90.72', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Viewer/99.9.8853.8', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicWd3djF5Tjk1dXlyMmp6ZG1HVlJ0RkJxbURWbVM5MDV0enA5VzdkRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768729018),
('2bALL2NQi37C9RzfNCJ2R2RlBvqPorewG8G7X4H6', NULL, '43.166.136.202', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieXBsNGhEbWpmdWxScURzU1E1bEJmNGpFenBxM3FEU1RhYVl5Q1VjTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768765216),
('2cAVIpnXt3aCwfY3AkbmoQbOr3WnQqDuMu24uSFG', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOWoxMnRxQUlWbmtBaUVwZzlZMmk0YXEzUXZycHFlZUYzeXkyTjVsaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767869135),
('2dAJSZxUHnVW6vmJJg7vfeDNB9DnLjItYiQ70teU', NULL, '134.122.27.211', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibDJtNmtjMDA2OUxlMnQySUVxRTJ6TkdsQ1hYQjJvRU1jZGFXbnJjRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767680598),
('2eeNPcU6LAFiWKHo5pSO7BX5wFg9G4GCzJF2xZWV', NULL, '91.221.70.4', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSEMyQ05JZWRMQndZTjBoRHRLVDJnc3BqYllRT0lWQ3E5VDBQZnJvNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768316207),
('2gIP3Ys8YnzLTTZ6IoNYO9qu7n06f674lRXS7FiG', NULL, '3.139.242.79', 'air.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ1VKdkt6ZUhuMXZicWNpdHZwNHRDYmNNZGgwc0tEUktJbXVKZjRKbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768505697),
('2GtxMrqB4oriK9C9vCOhTvFvviD87JwbOKa4rgKs', NULL, '64.233.172.101', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZTRybXk0S0xkN1JsSHZuZHFFTGtuTnVsSXJDeFZsVHZhcExGWFgxTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767671583),
('2H1e62sxbPjiafbKw4ugBWt76U4fCWLZYpY31EGK', NULL, '43.156.168.214', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieDVxdGJXakUwSGZ6SExPODFiclJ2T05vUjljdWFvY3Y4T1RLVTlpWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767577911),
('2HabVSgJlVMcQhZZWxmDrrQbEMM6vzsPKxapGCzH', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib3o1dEZqeGZsM0U2MGVjcm5SNGswWXd4Q1pzdVNaNTRnd2pBdEQ0cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767535117),
('2kgLd84G2EVBGwtHqv2wUsjIT9yLBqy51bY0BByw', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibVZpeUJwTHQzZHltaExkTG5CZWFBcWJSVncweFZ6b1ZxUERjQVh4SiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767822247),
('2NLUqXhzKXCOXECYVj7wdWLfF5f5vHgg9GXKXkAN', NULL, '74.176.56.30', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/118.0 Mobile/15E148 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFNnRUtzUXcwMmNRS3VFdjB2VWFabDk1ZmdFV1JuU1U5cDRINjhqMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767673976),
('2pJx8dFcta87YymQzjjyeZz7qvigHchXFQWp07aw', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUWJISnRibVZMM2tYbmNSb3lxamxoYWplcTJEVVdqdnRTWThtU09tYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768054885),
('2PT1PYyNOPtGmw5vCHnWLGdb5FNt4ye3Vzkq0pgV', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDNMemwwSDVEQ0hDQ0JDNkZsT3R1cXNNdDgwNTM1VFladUdFS2NZZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767982282),
('2t6742QabqzOmcQX6f9gqkcYL9RyOVAaGKi8TgKZ', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRFRzSEViaGVQRXJIUjJualI3alVsZ3ZMcHFtUGlucVNWeE9CWmgxMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767626384),
('2WeBE4sHxzQZ13uqRRcFhqMHZwws5g9sZzX2Qvcp', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2Eza1Jod3NEaXAwUndXVGcydGd2ZGdmOFpLT2hMcVBYZmlMVVVjOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767987346),
('2Ykz1O9vS0A0Tt1t5LmJZBg8jg9mMjMmBO1qYOfC', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZUdvc0M5SE9pWjBTN0J5MzVUVElVV3M3R0Nlb05ydXN0UDJxQW5WRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767600570),
('2zEeYIPPj0MP0Xr16xNPnFIRgF7Zf2ftBG8CvbVS', NULL, '5.133.192.94', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUEJGM0xUdkd1VnJBT0t0eDBBaEE3czBvRjBOdnJIQnhyZzhnb1J6byI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767740718),
('2zgcpfHPmpwUgTqE4esKQ8H0CavmBIFiStYYvmAz', NULL, '139.59.69.206', 'Mozilla/5.0 (X11; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMXhSNFFmaXJTR3NkbXIyZk4zMm1hdGc5c3EyQjZDNDFMVnFOSEw1cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767681181),
('32854bhtKWw81zebAm0TAOi5Dn9xOzNCLjlycTXa', NULL, '173.252.79.114', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTRpcUdkV2N5TWFSejJBWkRwaHRUeFBaSEVwZ2pIczhOMlNHOWtxVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567672),
('3AAm4iD1Xid2aOTWL2Uu4KCg4n9CnVovsRnCGJ0T', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibnpnNzBEZTJYTVQyVWVoTjluUjlZaTA0S1hnalBVWGk0TnRmYUNKZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768120608),
('3axRzxmlqMB4ZUGFwe1ZNEjw03kXdIN466kM0xSm', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicTN4RlRFMU8yVTNiZ3R4cW1QN2g4dEZRaFA2MGZiVUFpWmFxeUIzRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767801563),
('3bKyjQyGyOR4MTNEyUFeGomGDjUOcHyHV7tljdIY', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaURzSjFoaElsbEhGcm9VMmQ2ZG9aTnBuSTdsTFNkSWdBS2wxWnJGTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767986308),
('3dT8ZEgghtMatPgUwJRft3QMMLyIWV4OjG9ORd0M', NULL, '35.187.132.228', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZU9TZEJwTm55Z1dEZ3lqMm5hMEVGV1pjalAweXREcU11YklXRDA5MyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625635),
('3fYdZlxfIjoY3x0SpJjzoLa9H0ayTDZTwIrXVTwI', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYTRjTUUxVkZDejFpeDRjbkpXRTluOHhGTFdXOXRPckphaVY2ZlVLdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767860363),
('3GbxlESopiYkxQZMGSkdZFlSPUOOpoCDHqsZR0Rw', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHNVZEJKYmFVdE5jZHFPSURrZlFwREhiYzZuc1BzWWhzVmJDQUR5bSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767794598),
('3lHiO28K6RKzXvPJG2ExKiZRxfVLtBw86X1DSf7Q', NULL, '195.178.110.132', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWVIa3hEQ1FkV0lGVGtLNFpxUEZPSlp6bkVnWTFaUFQwNHNRSFBNbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767892920),
('3mjimexEgaOsyN7GJMglylO0GjuxYyyrnJLI5io6', NULL, '107.172.58.36', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU2Rqa0oyd1FaQWE3Yk1QUjNHTmMyZkt5VUxONURsdXBFUmJoUTJ1YiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767628807),
('3PARhwOvGhZ7yIv4DFgXP4Sr8vusxR0lJGSvL2ob', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVVN0czk3WlNSNmJEMDZyYTByaHo3WUx3T3B6dWY4RUpBWTlISmw1TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768535454),
('3PEg680OXVzecDUqgjj1O6gfwiWBUjS29KKwKm4z', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTlJHenZGOGtqamhBY1NGOTlXNEp0bWpoZkRLS0NLUVRYVmNOTTRnbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767782640),
('3UfRAJiaGLNa5vwBkt0q6WEZUVymEZ0RAySU2LX2', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmRxaVlYYnNqbGYwdlJFempqWnB5YmNBek1XQktnOXRhQ0E2dHVSUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768504007),
('3Yo50BMnpNvUVHmTRsShF9xIqoVkpLGEXm5X0XzL', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQUk4SWltWWxxWThvaFdKeTNyV1VDbUJNTVgwWWdGWjY1WkxGSUxZciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9zdWJzY3JpcHRpb25zLzMiO3M6NToicm91dGUiO3M6MTg6InN1YnNjcmlwdGlvbnMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768288846),
('40MTWLNsF7NNrkYs8LkL1K25cyJC6wJQA8TdMMU5', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHNrcnZzblI5TWFkVUY2SVc2Z1JEUXJEOFpzZllwZDZocnJHQTZiNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy8zL2VkaXQiO3M6NToicm91dGUiO3M6MTA6ImV4cG9zLmVkaXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768289602),
('46Ce3Y6hfFXRxsMIH4XvyGa6OZ65pIaW8VtHYfQj', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWlB2NHlqUkNxeFk1aEVCeWtRd3pTbDh3cDhUT3RCRzZkc1cxM1ZNQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767930865),
('47Ri0qVSfnOSO006tMsEPKgBsveBTqmqznKZIZOq', NULL, '98.81.205.141', 'Mozilla/5.0 (Linux; Android 4.4.2; SAMSUNG-SM-T537A Build/KOT49H) AppleWebKit/537.36 (KHTML like Gecko) Chrome/35.0.1916.141 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYnI4NlNoVjk2WUJtQ0xJV0N1dGlXUzF4T1daWlozck5xYzFkdzAybiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768056376),
('49oFGXTlSMCZNS7yVFyViwZgilAmsA6VgwvdEOYj', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTzczRWpEMjQ4bk9WaEtMd0F1VG5xckhETHg2Sjc3N3Z4bHZ4aHRZdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3JzL2F2YWlsYWJsZS1zdWJzY3JpcHRpb25zIjtzOjU6InJvdXRlIjtzOjMxOiJ2ZW5kb3JzLmF2YWlsYWJsZS1zdWJzY3JpcHRpb25zIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768289493),
('4a4LUCl48jHreI8GkbavnchX7AhQb6StBukvBQUu', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWTMyZU5WZjAxYXdnU3NtQW56dnpIMUVKRUVTY0Jwa0FkczBhbmxROCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767995246),
('4AnGbJjztWV54Pp6gUJta9WE2sMjwYjrGtHDcDKP', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT3BBNWhtZE9VaHpaOE1kWjB6QVBYNERCQXVGdk1NcHd6OVRGNkM2aSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768105198),
('4DgXia7Gx2XepTVvkXyBn9HnA11pYtKtvnoFn8V3', NULL, '182.43.70.143', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRTJZT01BSU1Kc09hbFdvcFBHVVFCR3N2VHBJWTN6dGsySVlmS1M5NCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767591434),
('4JRzL91qadJaSYeLAHMldyQRw7OFaCTRJ3FZaG8e', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSlVXSElhenFIZFA1T0VlUWdocnZNaDdiRklOQWJhTVFndGYySmdVcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC91c2VycyI7czo1OiJyb3V0ZSI7czoxMToidXNlcnMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768471418),
('4mTFfWwHtbexJ0MT1eecYarc3bXvg9HywTa2kAcW', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWDNncWpkVVhzS1NVMDRDT3pQT0xMbEJ6bFIyNWhWTnRyY0pIdWVCcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767864311),
('4N0BEdfPy8CJ2XP9h2yB54hqzsSqJeZKBI7I214u', NULL, '2.58.56.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWhBV2FPSEpoalJkRkprbDRLamN6eDJKckJocDd2ZkJUUFd6STlFUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767983775),
('4RDFgKhMfabqGKceYvDQoqR4OXC4fvjfKLP2wssz', NULL, '43.128.67.187', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNzdPbTEzWU95aTk3dlNUcGZtM3VLMjA4cUJDVWxZeUVYcWVacFJDZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768222316),
('4SekMuEYhqYB8FEQ3uvnqL9kNqWwYWlsJvQ42XWl', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7499.169 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMnNvcEdxOEg3djFjbDNWSlFvVG9TWVZBNFpSbGEyQnZ6djhxNGw5ayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768181976),
('4vuZE8IJQ7t5YWiohMDZ2KnkgbjBAODQDG1H7ROc', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiemI5SVdGUlR6SEZNbGNtbEllM0EyTWVYeXZUMXNaRU0yRzRkY2taYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767708125),
('4xPAsqZ7UVtSpyXGrLJF397FgXJk14YJm4AwR7I0', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZHZTSk9tbE5FY3JoN1E5eEg2VjhKcEZjN2E0MjRMajdqdUFnVWxKTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcHJvZHVjdHMiO3M6NToicm91dGUiO3M6MjE6InZlbmRvci5wcm9kdWN0cy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293988),
('4xydvZRW367A8rwZ8BMusiMQamHWqHne27Nz40Pq', NULL, '209.85.238.66', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUjRkWk9HTkZZb1pEZkh1eU9DbFQ0d1RMS1RLRmM5OG1lVzVBS2JkaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768386130),
('4zwPNHg9RkASSdBIxBkhMvtpJTRsoyOuFsWHN46C', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMTduNHM5dkZDUU1SM3lYSTZoeXJpYTg1U3paQnpxVGlqbWZhaDIzMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767866420),
('598IJy4ksWdfNRwIAsuSKbeoR2F8WkJZWngNCbyE', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibkE2NWJVekJ6YmJEQlJFM2FWdUp0dHNyU2xYSW5FVFgxVmNaNXVERiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('5Ba86gq8dNzVOksLAcwxEqWPaQr08wF4YWvhXzQs', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOUZuaURXeHY5WjZJVWdTeWtsNFlxajNEbVpGYzJkSFUxTVBpRkg0NSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768123180),
('5E5WxHOqWRt9Ai7UvUYvzhyJOzllULhIfsu7adKn', NULL, '34.31.208.178', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOTNHSUZpYnl6SVRtdks2aGZRdnV6TTc0YTBOdGRZcnNVZFlMY3FGSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625932),
('5E6qUM6cR9TClJ1S9orcTuydY6WS4uHFLiKVoj74', NULL, '54.173.22.58', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNmJNYjN0dWpCakJkendHOEoxbWZIb3dDTFpVVGNXdXFMaE9tdGxTTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767891401),
('5eqlN0UOZ5rDpJg7AvNMSPQvShFwTRq0G5PViMkc', NULL, '209.85.238.67', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicVo3dEJZYWFtbmdSTHo0Q0RXQ21kY2xIRk5mTU1naUV0UnljOENjWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768411958),
('5gAPIeRlDHFebY85cX5BVXy75Y9K0n02E76OvFLq', NULL, '51.81.245.138', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiek5kYlF5MnN1RnpTVlVRQkgzeG5xckQ3bTNEWXBPNUZnNTRzcjBkZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767511372),
('5gB68KaB5KK8d4pKArc2mWZyJY7Qbyd0rE1J2JfU', NULL, '151.80.144.77', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQUVFRk1wSXNDYXQzQ0RNQXBWcGNNZXJnaG1CYnlPQWpwY2tUdU56bCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767524469),
('5iFC60FhbQl4a8sCgf9JPl8wG0aIizGxJHDjf4NX', NULL, '54.196.169.29', 'okhttp/5.3.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZWNEYWVJN2VMcUdOSDAxczhPTWMxUXFtQWVCQ0JhV3RTU3ptODRjMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768735955),
('5IiVtID6VMNEdZTQ1hPL7aSc7w59vTPfwDZyGSP0', NULL, '209.85.238.4', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGF2UE4wVEs1NnpqTzVaYUVpMHZ1bUF3ZnNxTllPRkhPQlZhdVk4ZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768666631),
('5kf3GLtT1mGXYLL5XvLTWnvBIoiWJUOfvokpnH14', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ2lyYzI1dktyUms0eWZ6WTJaZDVEekRZMWVmSFBJT0VBVjVLSFI1ayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767806061),
('5nCOAq1MDWpbufK6yfBe4qz3WZWfy0gyyl7oxwUK', NULL, '188.57.71.176', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.7.2 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVRhMEVxamFCUWdUMk5oWEF5SkkyTXpuRWROY090ZHFTYW1nWTU0RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQ/cGVyaW9kPW1vbnRoIjtzOjU6InJvdXRlIjtzOjk6ImRhc2hib2FyZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768739553),
('5nqyywskEFCAO0hZv1aUWQLiiPAx2mzwy74oh6nb', NULL, '195.178.110.155', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV3E2V0M3bllHcHVGRHR2T3FMSUZ4YmJZeFFVNFpubWI1Q0FBVVQ3byI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768490316),
('5ObrblotmZwnsCvgCZnPjrTWeNU9wmtZULbjAL5z', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiakJCNkVzeUVlU3lScjdmaTdWVkxKUkFZbU1wM0dha1Zvdjg0eXRTUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767979525),
('5pIOmpJ1AZOSSMsNWCFGxrjViymbRvo8olOxxx2P', NULL, '103.196.9.112', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRTAyVEt1UEhUZmE5dG1ZZGIwRXRPdjJWc3ZoT0xNbmZuWmtDTTUxMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767511384),
('5QNZcvn7epzg9IllTylDaWeUXUYaHVm79BqXsVdg', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiREV2aWxHNE45a2w3dHRIdFNhaXl6eXd5UXZiWFRCaVZLZDYyUlpCZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767740429),
('5t5TauM6vGLQWzMI5duhYXvdiMlcj1N5wyalxS28', NULL, '43.130.47.33', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicTNoTG9ZNTFLUG1QbUNmZzdmUW1GUmd0RkJkSTFpeW1FUzBKbzk0WiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768696912),
('5XOCVlAxkOfIFFZ3nsdY2gnw8CnRxolxaUtf6uTL', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVjNoTDRDazJVbWd5VlFCaWtMeFF1UW9NcG16b1ZFTEFDNERrUVlOOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768066140),
('61f2PuF3ANRrJfU4BzVnsf4aUNRwwPnowgPseQpp', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGpuOVl4cWVkRlY1U1U2SWFlRjlBSmVzRTdZbm04OVdZeml5TUl5MiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('62X7d3VO2Zg8V3nqAaFZTpKeSL4ljdzBAX7l3t4e', NULL, '195.178.110.155', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVFUyaTZCOGJkQnJuNzh0VDVzaFh4c2pwUHdwSGJuV3ZOQ2VtWk5CWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767884979),
('65XL5qfjfCtelWpWvHK9PmXWlHMjy2wyX2yxj57Q', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib3ZFMTZOcm8xaHRjVUNDV2VxNHc0VEdreWhHRk9lOVdLaHY0WGdFRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768120607),
('67Pme53Svwp8bnBrT6c5lbiCqK6LMbjEqaAc9gSA', NULL, '209.85.238.4', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidHhrMW8yTlU3ZjBZUlV1MkY4bjhIUEllbDhsS0J2OFA5dVgwVEJqdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768666055),
('68FZBju8cQ6eZPhzatKZPdM5hiyF4uR9Cx8rKayH', NULL, '43.130.3.120', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRDMxemRXcUtOMThpUTRiemc1UEtHVDJFNkd6alo2T0RpZkNVM0tvcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768242340),
('6do2oWpsbLzmIZloFlbyF9LJiF5sZLVrZX1LfhZD', NULL, '43.156.168.214', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWU9IdFRyZTVqTFNMQkVLb1ZOOHZ1SE5SUUhEbkR4dWhpamtETXlsVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767577912),
('6EHwx6QuytOP6z8qnFXColpeiJ7e6rS2MuLKbAFU', NULL, '4.190.203.84', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQWRxbUw3dVhnOWhGeGdsVmp2Z0VCcHNaSWlzWWgzclVWaDJ2UjlQaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767639310),
('6GAUSNIkqub3swtTce9AjM3PmyEgysKX3bfEwmpc', NULL, '128.192.12.116', 'Mozilla/5.0 (compatible; UGAResearchAgent/1.0; Please visit: NISLabUGA.github.io)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGllR0Z5ZHA3VXhLSHFyVXV1VWpJN2FvQ1RZQk1vRGp2bW42aEN2ZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767512022),
('6GnSRS7GdxzwtlkhxF1DWFiUD5XQNkJ8AQ50HCTV', NULL, '129.226.213.145', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDJCNGJMN1dnZHJKTnNEN2UxaUZtc25TdGF4b2g4SjkzRnNXNVF3ciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767930876),
('6pinY9j2dd86G2C2rPXn1Gxz7TnDhdCHm3OXKeLX', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRDRDUzlVVGJQOUZwenZNeG9GeTcwVG5tRzVQVmdKa1JKYXhUV2pwQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3JzIjtzOjU6InJvdXRlIjtzOjEzOiJ2ZW5kb3JzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768287653);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('6QMtcCz7fTl1xwQDXrZKDg15kyISSAhEicsI1d7t', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTzYzeFo1RUpuSVZiUHoxd1E0d1VJQzdqOThwYWVOR2pGQml5a1VnMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('6sVNieSvfYmBE1WCxcDq6bWXf530hCOMylGUIM52', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVUs1TG55SVd1VFRpb0c2RERqMWdxek02dzVXeG1kVU1oNGtJSW53dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768040483),
('6SXQNn2y2opNdYLLZ03L7FWeUZftPeuMo7tlU7lW', NULL, '43.166.244.251', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicXZMQ0NaWXk5eXlTNmNxRHI4NlZnaDYwZkpVdkRFemlIQnF5a1BwSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767952688),
('6wqg4ZSiujez8Ri52XhhrV1Gr37OC7VNqWU1d921', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnl1VmtwQ3ZzUkRoYmMwRGVCazEwcEdvSDN4UU5ZSkMwYkxIS3hiRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768670257),
('6ZAhlSjbMSuaf4rvf7q70PG1jWk4ey3Q6gSlX8EA', NULL, '74.125.213.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQWd6OUh5cTdrZmFmYlllcXdPcTdzQVdKaDI4cHZVSUFvY3hFa1NvZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768300075),
('79ixDzyCfJ9cVyZi4v0dmDwv4NdeQasUXNmmApg4', NULL, '52.167.144.233', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS2JPVDVUcEhCN2YyMmQ2WGpiMTFMSGJrYm1UV0JTNTU5MGZEZlMwZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768738304),
('7aLHPhk51blFFs32i4eCnbHGMMwe2k0FnVGypaOe', NULL, '3.138.185.30', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSEtoV0VLdVQ3MDZnZXdCWHJUQnNwcXMzQm1IamdUMlNaa3JQSlRVMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767864113),
('7DmSAtNozUKAYJ7MgyiguBxwHRNq4jzFsYTIFx5J', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWZab1hxVVlQaml0bXBOTmdnYzhIclRiRVZzdTVHaDFFeXFlaDdwdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('7emUDYeFxjuO2zOUBdMU2miBpwAhqraXwUACdocz', NULL, '34.145.204.214', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOHdrbXNzN0VPRnVTNXBzaXBzQlJkcExKSWN1QWZpaFV6WjY0N1BtOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767627723),
('7jG15ByUH7F5XcqA8oV5vseveYqrfU4vX9R8U7Ly', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoickZjcnI4b1gwTXRkWGlTdG9Ubk9jMmNraXZhUGdpdFU5NkZxN2pVYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('7l2KOfwE1nQnHjnhojQXyN8b0y5WRh6o5hfbwEWn', NULL, '174.129.106.157', 'okhttp/5.3.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMG9BaVNGRlVyTVk1WDNkcnBNWGtCdkRjM3pwR3IxRVFVVTdwVVVsQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767745424),
('7lSjmm9xLbntb73f7QPxUNpaKXyxZAG5ZfXvwf0p', NULL, '35.187.132.227', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoieG82Rm02QktWWUlNWkRZcEFEQjJCNnRWaGlIdzhRblphZUNabkFzdyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625645),
('7RbSqlmBTYpNHuFjLgdjPKPVeEs7uqdNv9QZZIoQ', NULL, '3.151.194.164', 'air.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2FnYXY0eXo4YkZYTlBYaUdYN0sxNXhqdG85bUVXRlRTU3ZERTJiayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768505889),
('7rfsSK9gBXRJGXhkouV4dSKJDn5gN1qXPJ3OHuRi', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDlmbzZtbWNwVE5FVVVZMWgzT2M3d3NnVmFkTEs1eVYzUWwweHdpUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768278170),
('7sZR7hcVuHwG223bwLMKLHB65zMr8R6dJmHaUu5T', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS3dEbk1DcmJhN1phVlNXWUNNb1NDMllXaVQ1ekpqT3VJNjkzWnJMcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768150917),
('7TGlFw2pTTPyzh56egTy9KbPqJzb7DGBlHpLX2qO', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOGRlcFZBOG5pTHZTdHA5RERQTzFsaEZwUXhsRmJ1NXlEQ3h4SHdqbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768295791),
('7TPLOCOgkhhs1WnuoUksD8igBo7xQrZiwORRf2Az', NULL, '101.32.208.70', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRURoSGtZcWdBMkhGMnBmeWg4Z0Y2Rkl1VHI1czJqS0Y5cWlIa0VIdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767691439),
('860PL6XfHwvM6YGcAM38szVQUGvHbJyqH1nPV2gZ', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSUVMQk0wUVg3Z2dtc3cxQzFYTFFhMVJTVlFuVUFqdUxJY2czdkpHVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767572131),
('881YJt3zsRORMxQWh7iXLaZMzDAnz7qWOue22tci', NULL, '52.34.76.65', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVUpjUnFFYW9vc1RaUVN0bHY0ZHA2d3duazZPNWZ4U1UxSW5CRVdkaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625699),
('8BB0eWlMz8C5MOiIipo9elFUErEKOp8tqUdsn1cL', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHBRbVhCNDNYUXRnbGFPV1dFb0hHNnRDQWpNSDk1VVhEWkpncGlVRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283311),
('8d9HvKMvp5gzCYhyeaokoqkQlgjXoChdKF3PnqBF', NULL, '138.68.144.227', 'Mozilla/5.0 (l9scan/2.0.630323e2834323e29323e233; +https://leakix.net)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmpXNEUxZmpXUkZyeFVtdGM2eVJDNEtCSUl4SXVPbVVraGFSVHl0VSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZXhwb3phLmFwcC8/cmVzdF9yb3V0ZT0lMkZ3cCUyRnYyJTJGdXNlcnMlMkYiO3M6NToicm91dGUiO3M6Mjc6ImdlbmVyYXRlZDo6bzlpcXhaY01OR2d6SUY3eSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767511418),
('8DGv2VnqM4UVo7uxPFfnaHZFVNLxkoYZHtkXKZ18', NULL, '87.236.176.141', 'Mozilla/5.0 (compatible; InternetMeasurement/1.0; +https://internet-measurement.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUVlsdDRqMk80a0RjcDd0cVZJRmFUQ2VhcXQ3a2tSb1VCd1h2WVAyWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768642106),
('8FUpQ7QBw6htY3FCCXwzLFECcANrcfPxCRak89cx', NULL, '121.36.45.149', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4021.2 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUkp5WHhtdFVpMWNyN2lhTzhRSEFRaWE5NXlyVmU1bU1TZzZJODZXeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768526445),
('8JfhHe9GiLzw94PhFcKcKzuAGbyTAlzC0J7unrlq', NULL, '34.168.205.123', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUWF5b052alcyeXZ4aXRLNG9UU0NKVkRDdUFCUWhXcHpDeWk2elFnSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767716625),
('8JOwTCCxH4eafLgh7n36GRsdy7z0BMO0ngKjFRxS', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaVJadlpJRFl4ZUNsQXlJdlZsbHVlQzg5S3FKbTBnMVVpZE03SGRXQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767625436),
('8kVBP8vpiAEZWmGxo6sytMw4u7PLxIE0PT4LrCZT', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicWFoZWdhUkwxczBOSENERGxWZWhSQkw4WURBRHJUbTc5TGFMS2FBcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768205679),
('8maHOI060BP3Evo3WVdfNz3Q4Fen60i839kiyBNg', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicE95VFhLdnNoTVhTZnViZ0lGeWNvdkkzYUtDWkZWRjR1SHNnTmZhbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768621083),
('8mQvawWZ5WbNfbRLTyd11JMXP6PFYNSoIEExc0Ym', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRTk0ZmtXZlhCRVlpNkFjU2RmbThDdFBUaENvdEVBM0djTnY1eVBaciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767803305),
('8Nsi6AZ8K7FuqPjuKLytyBye4Qk9QZtXEeYSl3J1', NULL, '37.231.91.244', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTZGR25tYldSajNSVndzYlVCMTBFREhnNm1hQzJmc2VrRzJoSjFTZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767621557),
('8Olh2vzQ1U7EdrAySxfUNSs8KjYVv2eaanVggrqa', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNU5ZaENSUTg5V1JuTzFkMGQ3b3czY3BzZXJaQ1REWlV2dVFyblNyRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767930886),
('8P1cnevF6NORsBNvE4Kxgs5g34iP5d0dC8u8f26f', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieG9aNzVrUTlEa1JXRklBcnN1SzdEalplWXVVUVFiY3RBUHdESkRUcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768333445),
('8pdxH4F8dc2C1fOQ9qB0RJA9sS5eqR1ZPrILOmZA', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWDRRS2ZIczM2R2VCMUROMzYwRTZ2VzFlZUtCZGE2Nm91SHpiY1ZjYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768092577),
('8pe5q7cgIneAa7fGmwHkuBA1OrR0ZGjaBPWPwrFB', NULL, '34.125.230.24', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicUhFVmRmZjEwbGZiaFREMDZXWmdUc0EzZVRleWVuYlA4ZW5ITGtxRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625641),
('8ptVq7xzMfGCgaWD22v8b1AKNSBX8xUs5MMDOAmt', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS1dQSjRMWGk5NnJPU05neko4RUE3V25XM2pqOUFta2dUcGhUR05VbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283307),
('8UCaoYsYs8j7exj7ZfbsrfP2vWLqnis3NwdGZBtM', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYUx2RkFJNmZpR09nV1BrYTFTR3psOTZoUU05eGVnb3RqeVREbzdBZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767584397),
('8uUrkoBbge61hC8aPuP3dJdwerUnVf8GWR354Ctj', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidzBGYWQwb3pxb1k0SGc1ZlBiRUc4NjRFYzBiUXcxcmM1QzJsTUxZSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768213164),
('96pbkgETQ6o9L7BKtftz4VEvfoC98o4EbThKDvMg', NULL, '74.7.243.128', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQVFhSWdKUXFhUFhkZFpSbjlDRURpUFNaSmVOUUx3cDhjbWlSb29LZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768442174),
('96TK3ony6qoG33L70ohcAHxzTDzWFEZFzkwpzmt1', NULL, '43.166.226.186', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVXBiSUJDZWxpRHl4VnFTNm1yZG9sN3pWSFFmTmFjVWx1YnF3MFNXUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768514033),
('9Cbqu3RFWbFR6n8MhhQQnWknkmr5i9majs7Ppneb', NULL, '170.106.82.209', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNjFjVUFpSnBKOWI5bFlTY2ZaMTVsZERuaEtoN3ZYZlZuVEdoMVllMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768116110),
('9cHRLIWw0r4qSjKFnKAad6asrpxhDGbfPE1ta7v2', NULL, '18.97.9.101', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; PerplexityBot/1.0; +https://perplexity.ai/perplexitybot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTm8zN2NORVY1Wkc5Tktwa2hINU5CMzFiU052OG43Q0lWc2ZWWGx5ViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768517351),
('9dDnR76zpm3Ctnv1lvplhGuFdue8DDf4wLOy7pXw', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidk5YSzlwODBaVFVXZlFCSG9HVHVpMkE5NUR5TExhdkJKUFA2RFdXZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768284845),
('9e14Hy4qlwJ4p4jhChWMTjfPqHyruow5KBQpeP2e', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVEM5M3I0aUxWbkQyWmp0NGtTMnc0cFFDdDhIOW1STFJyMEhlTWFKZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768498744),
('9mLAFdvtukH4Y6arFRdLPMVASxGiDXGjGMUKUJ8o', NULL, '43.135.115.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS3I4eEhMUHFxMG1ROFM3RHRKRk14d3J3ZVJIYXdIek42U0FVQ2xqQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768385746),
('9njEKvQmaUZYzLgIn3DtktsxOMxksbpcmIfnQdRh', NULL, '43.166.244.192', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYjMwNWhUU1hBTVNSR2hId3YyWEpiSVpsdXRydkpiMG1rUzFpRkRwRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768202245),
('9o9UJEVHWjFvPEBezTffzJ2rS77xvtUkSmFduVUo', NULL, '35.187.132.228', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiQmJCSGVVTkRhbUd4bUl0Tmx1WnBxZEgxcWZpUVFWdUNQWm9Ra2k5ZyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625635),
('9qEQngCgdNZ1yjPSFEVHtgO5BehP5f7HTT8ZPVqL', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibXljN2NuQ0IwZnBOQm1odmFzbmkwbzNtNlA2Q05pQms1NU9RcnZPYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768148560),
('9vJsH3QlOsYsMnAM34rjW9FMiHcppnCzIRAWqd04', NULL, '43.153.96.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib0IxaFVCeG5JSmJHdG1zRklmbEVaUTdBTVh3WEtZU2RJOVk2d25VeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768786766),
('9vLqEjQXLvFrTHUJU9nHZXdMvIUs6cJTUOGkHOEw', NULL, '100.24.208.151', 'Mozilla/5.0 (X11; U; SunOS i86pc; en-US; rv:1.8.1.12) Gecko/20080303 SeaMonkey/1.1.8', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidmpqZ3k5WXZmYWV3UTdmN2szb1BxdXhXQTMxV3NYN2RHams4QkJuOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768168580),
('9VygGyN7F6cvcudaKRz4WsBUZB9DWIpdOAoWXzfg', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNnc4OTV3MjJ4RjdxRll4NzVpTlk5aGRld3E0RFEzOWxZelFmc2piQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716280),
('9x1rBCgAths685zDJ27Jza26O7qmHcbvpibqsW78', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR3lLUlY4b0NxTmJDNlhxeGZBSnBnT0lNZUVoTVd2UUZCU25rTGU4dSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767849327),
('9XhfvIAn4RY1hH1yrExAZOQGGsQ6qSGQuWCkLcO5', NULL, '151.80.144.77', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibllVNWhBelFXaWhGbWhwREhlM1BJTDV2VG5kNmd0UjNnOG1FREoyYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768736676),
('9yBoJBGW7lWbfmhh6WGVMvwxkmRr5K9OMRZYHRus', NULL, '100.50.77.146', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHNXMk1HMlRudnhNUmE2djVtT21ha3lLdWFoc09Pb1NNMHhPYzlTMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767528210),
('A1lIGUuv9mfTR3UvvtD0fk4hyCU7Jg4pNmsk6NgP', NULL, '45.94.31.82', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVRhblF2aVF1cEtta21nVXhyZTkwWkRBRVdzdmNhM0pOWExKMjE5SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768022745),
('A1mijNpMfgvyA5StuiI2OsLY5RQbGwzhkrzqMQfb', NULL, '173.252.83.7', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaVNtdTN0MHNCdFJUamx3UHExeGVONUhRR2szb2ZtdHZTQ1NNRTgwcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768568002),
('a5IFGZSI3E6ngVxKkH8yaiBm5zKFnE8L9VhN0i3P', NULL, '209.85.238.66', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzJtdGNYMWlzdEtUQXNHTTc3TVBYV1JRV2ZLN0Rjb2pvSnZJVjB2MyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768375441),
('A6IgBA1T3LwBAbSKgTWHDKYnWsOH4kk54p6W37Hq', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRWU2a2huTjRRVW5Yd0NVNzJyM2pFblBoaEI4U2NoUkswUmZRQUFFUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767976386),
('a9DyGqSvyerfwergrKoEzJKnvisRm9Xnf3Ri9r0N', NULL, '54.39.6.103', 'Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN0RQWUlyUVhBc1MxT0poZ3lkNDJVZVN1dXVzRnZ2M05KR0pEcGF0dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767666201),
('a9V42P21n8x8vIg5Hofeb6lPVaKyaiz68hnXTVWK', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUW50cGVsdWpwVElJdGw1dVl5UTBPSlBlYXRNUkdTUzhBcUd0WGM3MyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768288543),
('Ab8S3BDCv1rJhBQWrrbuG6OAQOXp0fU2M57VSczX', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRjNZTXFDQUVpWWJoU3haU0FSMGZZdDBQY1R4TlJxRExtMDR2cmo1byI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768364050),
('AbmxAY2snsliTIbEVLU3z3q9vhcCYmBNJjMlayLu', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS2x6bGx6ZkVqNFdrMGlPd1paeUNDdkYwSnJ0cUhlc3lRdFRkWWNRdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767695333),
('acTeAarU0GL9OpOSQADtooTqfi0pe3bYfjPMqbeh', NULL, '5.175.47.176', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiVWI3VnNtWmt5bUpzN0dkSktlOGpOUEQxbHgwUnlGa2FBeXpoVGtRdCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768699492),
('aedll5cnCLZmF6qTHggoE1Q0htsoxCBtOS3b3NBS', NULL, '66.249.73.129', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM0JJYm95T3pBUm9XcUFxcTNNQWlpTDM2b0tpOHZiVWQ4NUhHRlBsQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768770082),
('af1Lef4vV7cK6OrtQyp0k1Ck4o9xJT7y7MIPyt8Y', NULL, '34.73.65.120', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVDBGaFpVUFpabmV4U2VXWmxqRmUyQ3Qxb0l2TzI4WVZkNGNFWll2ViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767547436),
('aFkAYNYlqjCWtGJhFFeqOkk5pgxkjISbGoyHy4mr', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTDljWEJHNlVwbHZKc20wUDhnWTA4M2NPdWRDV3RoRWpYb0VkazhSZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767604524),
('AfnXF5uHqlT60aRRL7zf7ky7X6owBen4SMIMUaAL', NULL, '88.198.208.16', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOVVjNUd3MDFmS1NPcElWZFRFMnkwVUhCVEhONDBmTGJxbUpSdTBmSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768736271),
('aGwknK3OgfzSjHGhtVT3txzJSspUfBVrsF1tD2fk', NULL, '193.118.38.74', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVjBZNGRRNnhsMDVBdGVaS3JidG9CR2tWeVRvOGdqSGcxb1lYRmpzeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767662280),
('Ai1DjF0QKa7Ka0Xy6ppRe0GbxiHHrtzdLaKnskll', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicVB0OTM2UEphTUxIRlc1d0JXbGNaY0JoSVhZYmtwMFZhU3p6VG5VWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768294661),
('AI6mbDNwhaM1n6ITHcmcFFXmwXSh9DmUeMtIn9AG', NULL, '192.36.136.8', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVVdLcDhwWkpIMXdhRXkzdlZoMjNXV0dxdDlJNW05ZFRpYlNWOU1wMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767647603),
('aJDWGkwXbpfoxtGLpbuNT3W9cxPW5e8M3i2IUGXE', NULL, '66.249.73.98', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS3g3dTdTWldKc28xc3UzVDk1RVNGNUlwSEVkREhXcHpYZDJCUk5HWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768092577),
('aJlDHZ8O7yvcgWDlCZCC1nitG6dAL1C9bZTTFQdB', NULL, '195.178.110.54', 'Mozilla/5.0 (SymbianOS/9.1; U; en-us) AppleWebKit/413 (KHTML, like Gecko) Safari/413', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmQwUDl3c0lhTFNrVHJ2OUl4N0VsSjlDNEVXd3BENWtvZGYxUFZBTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767853801),
('akRzMey9eSa3oJADJrOX9ZkXvt8Emn6pCgO5J9WR', NULL, '182.40.104.255', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTEZMR29UV3BuZWNDR2NFMkNGUXhkeUwzdmF3WGRLZEd1WGk0dGJibyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767873249),
('aLhZWksk2qw2aLvcQvmHZy0JDW3Q5PEk8ljc6xsm', NULL, '2.58.56.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicUNndWhCQUFVdDdlTHk0Nm9JemhpMVZhYTRhb0xBbThrRk9HalhqViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768092127),
('AmLZ8MYkK4nThzxrFAICmoSW45VVZWpS36KnBBQ3', NULL, '2.58.56.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibzRJSkFBWHJoSWI5am5PU1hvT2VSd3BFSnJIekdUQ0dvVGlmMzU5SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767983775),
('amWwgxZfRkPXion9z9crdIdjwco4c2ECEuXi5DFa', NULL, '205.169.39.58', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.132 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDllV21GVU4yZ3l6M1dvbDBrYkREeXB3ZXhjUUR6UXBzRnZFMjN4MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629292),
('ANsnDm8HwTupyF2PGJtFT1Efdaw3K2RJg2CCx4NL', NULL, '198.235.24.54', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNUJhQldKWUFyOWJUOFNRUlN1eUhNZEhiMlB4QXFERk5aUUxzeEFRViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768804061),
('aNTGkyxin7zLymijBgiCxWhPvSet93mSXU1BfZPS', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWTZSWjQ2aUJRYzBSa2F3M1lGdUdsYmJLN29lb2Z5ajR6TjVVVVl1cCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768189940),
('ao2MFd1ABF571X0DLRxejxPKKRSmP9hc8UQtiJKF', NULL, '195.178.110.144', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieU42SHJSd2tzZE1Iemp6SXA5YzNCcldNVXdQdm9ZZGJDNk1mWDFqWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767920685),
('AOK8aIkgFrk3LhWuvIg09Xf9t5aaX2YlbSlwFSlf', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaWlpRDBBWG1ob01tRVBuVFpvY0ZtOHQxbjdzb21yZjE3bWpjVXc0ZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768234667),
('Aq2U170DfENcxVaBFlrHQr4Xb0U9fDghzVf75KgG', NULL, '31.203.157.208', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_7_10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRExzOG9ROGwzN2NzeGt2SUw2eGdEOVhZZ21ZamJsT0RpQUZOQ0F5ayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768391853),
('ARTh9dEBRmWc63qCw6Xurqq9jHBaOa3jDKmg7ngQ', NULL, '135.148.195.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/114.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaXJnd1A1dDNDczRzWFFvNjhyZ09HODF2RVp3dGZucldkVjVOcGNLcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768037395),
('aSf8KDZGYSo1Mv9mr3tCK5xLGrQ1hsRv77iZZ6oS', NULL, '54.175.86.167', 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; en-us) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkZPeEMwZGpRcDVSQjR1UktzOHJwRFBFQXVMNDdjWnk5M2tDVDZPbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767548574),
('AsI2s8mu5yvNRR6J0EE1JJATKLpdkFvWJ9d05px4', NULL, '93.158.90.71', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Viewer/99.9.8853.8', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ2lJbEhlZWoxZVk3aHowUWhqekF5N01IWGdlclJXU3hBdUM3TWZiNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768447050),
('ASSrAs42azYuaQW9b2dUzvK1HbJtJlVZcRfmvT8v', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWHVZcXpZT01HUmpWdDUxQ2JEelRPVWYxUVRpRE1KSEhlT3M2anI3RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768258713),
('aTEEP63HhrnbhzR51V7EbRd65Ug0OcXOpcKjzvqI', NULL, '106.54.62.156', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT1JaN1J6c3dvUThNQ0dwMDc1NnYzMHNwUDI2VnZKUHYxUjlheTBIRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768242391),
('AtleeWJXQY882njAfDgdvrW2XTTJparDlcWtHSHt', NULL, '159.65.178.113', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicmNYMkt6eGFKVlZzM0F0VVl2dWR4NFRZMFBqWTFVYUtYVVA5TlhxYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768551434),
('Au4jvuP7dfBRBz7uJePHY9tKuTomWZ3xRyyu5V7X', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZWpVeGZZaDBBWUhtam5nbUxwT1R6ZzJWQWZDN1RGd2dOQzJrTE5GRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767626367),
('AxLtDjqWMIW4NhAOjEfoB3uEhU1yuMJwfGKFWYQw', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVTB3eTNQTUgyMFFzOGg3ZmJaSlhxM05kMWxxNzJmVHBiMnFFVTBiSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768289331),
('AYeBPGeerH1Uku0qe12be7N3IKvUVIBHtgdXkQQk', NULL, '49.51.52.250', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTVN6YkhHQ2ZMeXhXZ29sT2l2ZUI0bkppMnRzNXRJY3VQeDJ6QlNWaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768089397),
('AyQ393kBNVFO6xbRLteDwUG8Y7FCYafZKrORobor', NULL, '31.13.115.114', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM0hMak8yQkNIMWk2N3lobVg4cm5UZm5OUXBnbXg1dTFrWmJKc2NubSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768514275),
('azVtbgeQXyEGJrEZTuI9F4d3LNPQHccSKPfjmQb0', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNWNkd2lIUTVlREZkbndKRWN6U3h1dDZCYkpqT1JTd2xubEJaZlJEQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768362030),
('B0i83X73wGkmr94kxCxYXQtrmusVUXQaUNL4UXoo', NULL, '209.85.238.65', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNmJCSVpMdWRoYWo0U2g2dGY2NVhLTHFabzJFQkJ2V0pWSllGekltWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768366620),
('B1qqENJaYXqd1NanXXH3mhp5WSR2m0ICT9Hdi6v5', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7499.169 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidjNLRmRYM2NHejNWc3IweUtxV0lkQzhVTGNwOXVDcFVvQlJpTTk4SSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768165505),
('b3Ebnrenisg2Dy2hKJjNqbfAV6Mm0pIslGdvZA9Q', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMmJQT1BDM0JyRGtLZWI4RENIZ0RzVXE4bDNUb0t3OENxNnRZSllRaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767535119),
('B3LLnuIJtGRl2E891yUBOcVIu1r7ksRMRxdON5xd', NULL, '3.151.194.164', 'air.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibGdBNHB4amc0TlFrQkdTaTF4ZUtGWXlPbVk2bXJQY1pxaHVrNWF3VSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768505888),
('B51hWRPFWR2d6eqtL8m3Xbc7PHKUSWl6lxWx7djw', NULL, '173.252.95.113', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNVQ4cXRJdmFWMlhjYk4zT3ZaeTlBVUVjUnQ2Tzl6TVpzR1lUSkRTVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567649),
('b6InbYdgcvTBFUXY7v9RkAQBY9ncXdRaweMvZUxg', NULL, '100.31.89.111', 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-US) AppleWebKit/528.16 (KHTML, like Gecko, Safari/528.16) OmniWeb/v622.8.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUWlDQWxaaEpOZmJ5d1AzektETzV0N1NTMTZmUDVJZkFscUpwU0s4TiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768586897),
('B7Elz4RSsyt0Kh1ijBvSLdn4SgkBfXFosA51q7ej', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUGkxUFZqRDFzNkdEZXg0S2p1dlFTU29LUmlmdFpWcm5oMlp5ODVVWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767592738),
('be9o0EoIJOQUmobztBK09l2UGiu6I1q0vqmh61KS', NULL, '43.130.34.74', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR0Via0czZ1FXTVpHRFB5aXN0bEtWSjRva24zMlJ5UkYwdzNZZmtNTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768138676),
('bFZJemUyMS37DQ0ajUIQGATsPCJQMJr56KuNVw95', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmw1dGk1ZVNPQVl5VHBoUW9wakNNd09WY21lMEFWeU1Vd3p4R3JITyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('bHiolXxHdEqjlgYtjjC7FA5DC591VCgiiPnmC1Od', NULL, '205.169.39.17', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.132 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmg1RlFMVTBLM0hEZmNOcmJvYWRBR1JZZWZMWDJHMVRqallybzRLUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629300),
('BjBMMbCNzuHp7HHc0Z2bSUSYJpCd79kSAZoK26lH', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1RabzFkYm14TXFZUk5abUxub2p2cXE1a0Fqa1BibUlmcDJpZW1yeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768451471),
('BkNmcxrQBBBsPWN07bjOnNC3ObgdQcnRahmBwA4r', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTBZSlNxZllEUGJVTG84OFhlWVAwZ2dNZ1dhSXhmRFpIM0hWODZyZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('blRpmj2e3vOk2zdCiroArkdf80PiLE2q4bTVwNpN', NULL, '43.130.116.87', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUFPY3lCZUIxTEdXY0U3a3BCNTNVSTRtTlpuTlpvRTlMSmI4SGF5QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768807103),
('BMGES6d6ysg8revosjp1SykGigcTivRhqN72rMCe', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWjVTbHV2TXlRMVNFMHhsZ1E4b04yU2ZzUXkyZXR6Z1JqYjVoM2FzWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767862307),
('bMgjhq1VBycTBz7OoQBlSR3EtMUHbz3WrgtphyRQ', NULL, '195.24.236.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieVBFMndQMlkyalZ4NEpYMTZEWmZlRGppR3VvclU1UHVjSlVrem81SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767639164),
('BMofhtVq10E0L5zDdAKs7dTYBphbaCNNNoVMa203', NULL, '43.164.197.224', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHRVQnJUOHFTU3RzRU5LenhZWm02ajFnMVJ0T2duR1h6MlhZRE1qZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768284014),
('Bqas8knElX11kbKFyEtP0ZkydC8HUFOerFymtr6z', NULL, '35.187.132.228', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiM1JhTFNYalRjN3ZTV1F0SGNDbEQ5dFdPUW9VTkxIWmVJVGs4d3BIQyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625635),
('BQjXY2szBdYg0UoS1KUSa9O4GQB1fLsjEw1NL2zG', NULL, '207.246.126.50', 'Java/1.8.0_332', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoidmo3ZW16QUdRQ1JOWlF2YVM2aGJNdVo3WHhON3l3Qjl0RE0xTVJjeSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767714498);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('BQsIUITfMkQV4gUUMgf3k1d4Wj7HF9K8GeWvvvy9', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZDJSenVoenRDZFBmQlhxTDhyWWhod1NITXpxOUZVRFR6aGhRZ3BMSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768289331),
('bRTw38LNqvmX9EXZkLdrb0lMYRxI6nedYbOtizzg', NULL, '223.244.35.77', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOEY4eTBZUWdKd01sTjNsNVBkQnlCOVRBZHdCVWpyVG1xVjhqSmxYTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768424201),
('buNpsRgHyrSkENlMV9P9QaWNftFfJGAlEOqT6kcu', NULL, '100.50.77.146', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUWNySXVNSENaSzg5N1A3V2E4cVpXWmJPeldGWE8weTRsdk1aRFhSRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767528210),
('bwM1ONW5tu8WFIDPdxZHQeZrwITC7TtTPjxEm7n2', NULL, '34.73.65.120', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSG9wNXhpRzNObEVCMG15bEdoZVNuWVpMbHV0UTNibmhVSHE4WmNoMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767547436),
('bxSE6I63H0phGnQ7nfWw9eXB3m1gpULmLpdeXKR2', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieTlsUlpkSlBiSE1xNnJockJydmk0dW82bVF6Qk5tNWxJUGc5ZmY3TSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767889866),
('BzbzxluJs8exUprGbWlUX4qrIxoLS90DxzEshE0N', NULL, '104.215.29.182', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/118.0 Mobile/15E148 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTlNuTVFqc01ScEFmcnh3RGI2UzUzZnVOQ3ZQVnNiNnZPUk9SMExkUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768057546),
('C12cZDP6UwJEYBf2H5SzJ60V8sArSVUqa2o6GaZw', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWFmeE5JU0FYOGhZQmFmRlRaNUdsSlUzSnRwVUd1UE85cUdZQmVCbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768463490),
('c1bPlFOCYSYvBSrWEBjtsXJrryuMm2BALbodYopG', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZXJIZHNodmcxYXN6MVlTeDNFT0diT1pEYXJFcTVnanBKbFU3UDRnNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768283360),
('c1p04hJqp80SIPLJ4pNzCz0kMYBBYk86KJSZItdI', NULL, '43.130.3.120', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieGNXUnF4OXlzTU9pUXVlZE1xUlltc2lvNzYyQ3JYMWRGWVNyZ0kxdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768242342),
('c1TogVEyaGSD3EJKWtTbR8J7qXST2DzGGv51mMtM', NULL, '66.249.73.98', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7499.169 Mobile Safari/537.36 (compatible; GoogleOther)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVjJSZnpqTFJ3R1FjbklLVDdXa3A1ckp3UTk2V0pPdERiMUtPWElTUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767728887),
('C2TkWtrLPs1EuH79qpp2eJYYEF4YjLVIrZ0ehEat', NULL, '185.102.115.120', 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid1F3Y3JjWFpCTnVrc2FNalZsYXFRcjBQTTRVdFJkZmJOMWF6SW92bSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768154141),
('c43iSFkMSsLdT4E0J41bZ44LaQayhOKSGOFkEY7i', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNGgyNjVJNkRzUjZVQmpRM285Z016dEZsNzZqRWNDQ21URkN2MTRtRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767608634),
('C47S1EWsQl96m6fbwLkz4ZS2T16tocpnojBjJDHo', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHA3N1Z3Y2JZdHdZWDNRNEJGVlBqU1kyRVA1RzR6UjZwT3VYYzlpRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767887932),
('C5OuTPD9mhBC45lDT9P9RDqfCfbse5g1WADSmsBU', NULL, '43.131.32.36', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOXVab2VpSGViYUJnZFVieE9vWGZVSmZHWlh0d0MxalVJQkFiRnIwVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768450326),
('C6qUWX2DjDerDSRwbXtBOpMNw1BDq0ptgV60NKxp', NULL, '43.166.224.244', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieXVGZmF5NVlMazBPbWd2Nmx6OW1yV2xVN1RyRm5JSWFKam9uaFE5NyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767905179),
('c9HRu2mtBQEKT4Dik66sAfF60XtjY8c1sMeomeuw', NULL, '49.7.227.204', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVE9XbEt2RGhzTmcwSnZ3WmdTUG1lMlVTdTc3WXVyQXBZcGt1cXRLMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768468596),
('CbmCyvnVt9YQEtvuFzavCQ9WCvXQoeEEs0A9URyL', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiblNDb1QzdlJhM01TdWFSQkQ3OTUxMHFoWkVvTFVGOHRNeHdOUEV2USI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768447782),
('cbvCMmaGBvvOaJdY7v4qkbVLplIJCrba2DMns5Kh', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ1lJcENJZnlIREJ4bGc5eURqUjl5elhaUHdpeGhnNFMwd05TU0dRQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768125049),
('ccoL9JtDx6OZKlFCUbsJccRPzeOlT0jAJMITtuwz', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDdvUzcxcUQ5VTdMdzJvc29lbnlIajgxOG5zZmRkMDFHQTB5VldleCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471405),
('cCT64qo9h8YjMlHiGQe8rPHmG1Ppn4CUTFIhWeGH', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR1ZCNEZmRTZlMjJSQ3NPRkFhOG4yM3dXMzVSTzZjcm9aZnZOTUIxMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768125683),
('CeXnrPRNmgkWM0z3BW6JWtDmOb1GkgYrHF9a9Fja', NULL, '54.173.22.58', 'Mozilla/5.0 (compatible; archive.org_bot; Wayback Machine Live Record; +http://archive.org/details/archive.org_bot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHV3VUxHV2FjM1FWRUljYk9kUDVmSVpRRnhlUkxoVmxJVFB1dUx2QiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767891402),
('cg3sJJDijXetKysu7Ty4fZQQxNFD9vZAl945uy6Q', NULL, '45.148.10.174', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzRuR1hkenpKWVl2ZDQyNVNLbzc5WkhqSHpKRWY0eFV1RXVoNEQ0MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768313624),
('cgvyZadV2Dbi1XTsSsUY0OBptj2F4W8xxQBvbGh5', NULL, '198.235.24.12', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFNUYXlLV1lTWFF4TDZKaFNTdnlEcGdHTjJtMWhaVlBJejFGUUFnOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121148),
('CIgGGTVp6AA1SqIvl6VdKyBGULahmFOt5AvZBY6u', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTFF6TnRNUFMydjVieEhoTlM1WkJIVW9QeHlXRkFweUxRSGlPOW9UNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767715327),
('cK4PLvI5b1dtZtyfPU2bKeQtG5bvI8EyrV3xzjoo', NULL, '44.244.32.34', 'Mozilla/5.0 (X11; Linux x86_64; rv:49.0) Gecko/20100101 Firefox/49.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnlzWmVDSGQxdVBZeE5hODBCYUdpdTBibjFqSERaYTYxN25GdVZ1bCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768197427),
('CKcik625W7nTFqJxoTQuhmUwosOZqy0OmPJYGFKT', NULL, '34.229.67.133', 'Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.7 (KHTML, like Gecko) Chrome/7.0.514.0 Safari/534.7', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2ZCeEFXTzVEZFBkQW9Sc1ZmZXlwVThMWk0wRTJQYk5kWEJTcjlLMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768758573),
('clx9hPGNUSYqxf2WUgzwx5eD9PcIv70G2LzzTIbz', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQzhzVWFTUEhDenRScnpFbTBiZ1hFVXNMVWhVcDVTdzFFbTZSaUVPUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767590827),
('CLYObtMuueAUOrduRlfnAuLhdcQHBxjlj7UnWgsX', NULL, '205.169.39.30', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.132 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS2NXTXFqb1ZoaTdBUFRWc2d6RlFnaDBFOUV0QktCVDZDbDBiaWR0cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629408),
('CNiR5xQxP8fGq8Nmr4Hkot6faWmxylASvBiNI1LL', NULL, '43.130.67.33', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWVh4VTRJc29PNnpPWXpScTAzM2xkNnB6ZGpFSEVjRTR5dXNQbFFEcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768262721),
('CnPSaIkIiFLcWLpaaVFVgsE7ZtdCFNQy6tfGp06W', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMVI0VzJZME5wd2Rnc1g2U1RpbDRxWklqQUprSmk3cVNDUmpFSU9jWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767828013),
('CnV23bIM5PCY6vSEkD89vrNebxiD33SYb2XW2xWb', NULL, '43.130.34.74', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiejJiZVJ1TjU1OHFVaDhPRDdoaTRIT2VBaHd0SzFlVTh6TGxBNHhseSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768538464),
('COhv7hrTN0RoKuAlCcTd7bp8PEbh9ynu98MqRJd1', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicU96cEtxZEdIOHpwSG9GQjlQeFNoa3NualY0S3VmbTRrUGlhQ3o2WiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767862201),
('CozJFbsK8GDTX87UTNoMRVx7XPT2mfohFI9QMpur', 1, '94.129.64.92', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.85 Mobile/15E148 Safari/604.1', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiUTk5b21vZWpnVzlOMGRwVGhSR0haN1BuZkJKQlZrWHlkaklySzBPbSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==', 1768805147),
('CPX0fFVbGf0Tx24JXHIqgexrv5limE2IvO345xKM', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaGpMOXJyd3ZMQUE3dTkxU1VHV3h2YVdyWkhkWmRiSEJhdDdBcWJtUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471400),
('crl4KkggPvPt08E7Sskhss0ZnRVF9IhNsdID2FtK', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaXVTeDlXdERZSkp2TUtkdzZJZXd6OExPdktCTnJ1SzI0b3FWaWxqViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767540010),
('cSL3bUVFbGwFAbIWp3uOMABgZcq7UeDm5vicriAG', NULL, '159.65.118.6', 'Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZkljZnRlU1FYUm5SSXF1ODhOdWlVOE1HbU54cG5UUE9tNUFPc1ZRViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767854083),
('CTHcQD0sl9RWmGpmN9lzugSHTHzHBZBZsgExElG3', NULL, '18.97.9.102', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; PerplexityBot/1.0; +https://perplexity.ai/perplexitybot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVHN2dVo5QjVpSHFOUHAzcEdTbHJNSzdDVW5tUkNyVnYzZmF3UjM0WiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768517354),
('CugWI32LTPUhkbR1K5VyOpHVkC4YbOfoACgjKQoN', NULL, '43.157.174.69', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0hKQUNIYjVBbGJ6NnM5czBGZUxLaXhITjJ0S0dYd0cxRW5KckxxRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767973467),
('Cv3sdaL6Xnq42Pol0WVpiGZIu93jrzSAox99POYG', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS1dCMWtvSTdHNGd5eElxZ2lNNW5RYmFlOWV1WXgyblNGTXRBa3BUeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767523946),
('CVr0heqmtnKTWQXfgHjkLNoROLawrbjVyhtxkcnn', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidWtFSDBXN1ZtaUpWTDJrakM5cVpGSGVoNG93ZnFUMnM3d0hzOE9wSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768303593),
('cW17Gj4MvEjBoaJc3wpqZeoEKGmA66b1qnUBIAKN', NULL, '66.249.73.129', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS2h3UXdvQXdEbUFLNEFYVnVnMldFcGJqSHd2QzB2U2N4c0NqSmlYRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768604457),
('Cw5P9WL1kjUl3VzE4qhqFVaE6gW8ypnWe1vwvsmq', NULL, '209.85.238.3', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiejZIQVFITFI1RlRLMDNsYUJHZTNnaFZYYnVaUUdVM29CWllDcjRQbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768535312),
('cW7ec5QFCbUN8fvpLm2dnIM6txRofwvd48v8B7sE', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidUZUU1k1dmIzamowazVuMEhrY3NpaHljdE9hZkcyajl1cmpXWDcxSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768276165),
('CwWZBMq5K4tIcGVGp3ruMDfmOhtWn3guCI7YAsXN', NULL, '209.85.238.67', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoialRlOGtzeUVsTkRkYTY4bDg2dnpQQ3RuRklKMEFhUXRrRk9RWnNFRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768407916),
('Cy7ujpLo3I0UZwHbnQvpl9xr22anIsgh3qIyDHn4', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZnp3N3VPTFdUWDNOdkt3RjNubTg2RUtuYVh6cFMzMGt4UkpwOUFmeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767845307),
('CyBGHrsIcGe04MZqGLDnJBPuZJidQLbuZ3GjE0g3', NULL, '182.44.12.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNVE3U1NZcUViVGthRFptcHZvcHo5MVZMY0tQTEM3RDVpWmJZVnZPRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767778142),
('D0PT2ReBRKBXFFFsK1wBkEU2iLyMwMn5Z3TtBsA6', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibGRDbmNBQVdaVXNSMXRyZlNJOG9nMTJtSjFwZ1lQUTkyUUQzS2RqNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768290895),
('D111jCifCAnBrkcAAa6qnqBfaxsPqz6KETZle7Ob', NULL, '209.85.238.3', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibFpTbU5reWJUdmpMMkNFQjQ5NHdENnA3THN4ejhuTEFqQzk2ZjFkaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768667296),
('d5KMqy2T3kQ5TMjLRFD1BMNmsfPv0bj5OWEzFw0J', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieEVKcVpnRkFsejRMaFJHSXg1VjRlTnVGUk9UNkFjb0dLSWFMMXlFOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767584622),
('d7xEw4uOmGFdi0cz6Pqv4P4n49QwXMuvcWWlFrUi', NULL, '185.247.137.125', 'Mozilla/5.0 (compatible; InternetMeasurement/1.0; +https://internet-measurement.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic0N3YVU4YTA5bzFqNTVrQmtCSTFxN1pSOWRPNVN3c0k1a3VxWkdOcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768638325),
('d8QG0NxGIfqBW2QRKCkFzdxyVJd3cSquFH2xNdG0', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0tDeEJlamtRVmdFaXJSYXVpQjd6RWtydkNrMHMzeUVCUm5XZ3k2YiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('db2v7Z2Cwr83ROLO1zKlUzR7gJNQ2OTdD7K6eR6m', NULL, '173.252.95.10', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVjZPMUJVbHV5WlhHaktlbm9jbFhReW5ydWlIdWR4cjVzZTQza2lReSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567655),
('Ddf8AjC1DEjGADkv6GXyzrNHmrG4DJDRG1ftQNQb', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZDI2aTJlajkyTEs1N1JnNGhBWVdEZ3NYOWJCREd1V09uTHpzbE9qNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767869137),
('DGINzPntMm5ZEVTbyqZKLAqfLOVlSbjXMhGGdI93', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUkRqaEN3Z3VtVXNaU0FrSHJ2UFZSY0NjWjJMTm5TazVudzhOeEJnUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767626368),
('dGjFmAlErF28AAJC8KNH5UJovheDWft1eGy7swVd', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1RWTmFpQkJ6cVVkS045eTBKT3lHRDZLQkluT1YxZWZmdVM2Wno5SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767627468),
('DHAHxIZ85MJhQ6QNyuhHf68idaAGNzaqn6Mqi9Az', NULL, '45.94.31.82', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmFXTXpIbjBoZzhic3doa0gycm04RU5IMGlNWThUZUtKTklXWGVmVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768022745),
('Dj05tv2YxflQCojqdAHyms007zmosPY2tW7Fus7I', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHgxTXhIcTJIbFhUc3lWTXFyckJLMkZqbmNkRTZkQ0ZXMzJCWUpWZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768472327),
('DJ1Du3yOMIcDUiDehEgytr8ymmW9TPp9yHB0vfNF', NULL, '43.156.202.34', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjVoSjBKdlNYZVFIVk03N1NibFRUMGRxcTAyZFBJbGEyVVE3MFJpeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767776102),
('DjBAyGizumjFcl6Dk96BTON0xKuUzG0vbpgXWg7K', NULL, '34.239.119.53', 'Mozilla/5.0 (Windows; U; WinNT4.0; en-US; rv:1.2b) Gecko/20021001 Phoenix/0.2', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidzFkbGZudmJuNmdVTUNqV3FiQ1dxOVZlY1h2akowUWlnZVdwSHF5MSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767717677),
('DKRqTfpIQsGmNfixczpJorY1Of53BQqBXmhwEzgI', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiczF3ZjlHTGpQNjFMUlpRbDFiZEw4ZnBWdTdRS2M0eUFPSUpjZ0xGSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767914508),
('Dld4evJQzn2FFW4xMXPwVNccOIx68V6mknmfXhmf', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRjVJSkI3bGEzTmtKTkExYlh3NzVrRTFDSWVSb21PSzNJVnFibW1UayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767886575),
('DLt3QGjeASl7us2n7CsDOpyq9fcRDqrKM8uoIDRD', NULL, '3.129.57.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTzVvRzRIOFgybkNZMlMwYUQzME5RaFExekFBYjhnMEhxcWF4MVBGUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625636),
('DnC7LSyZ14Ciatrn1qLoEIjYHTv1We1ei0V8sD09', NULL, '100.24.208.151', 'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A5362a Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZjRnR2UxaVg2SE1SUm9VdUhGZHp1OU53N2MzNHl4Qkk5cjdpZVQ2cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768168580),
('DomCHYPjTQeedXkixSNkmeHMtDmqbxMTX0H5mH2j', NULL, '54.91.83.49', 'Mozilla/5.0 (X11; CrOS x86_64 14588.98.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.59 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidXVvdnBaN0VkcFNlTGVSQTk2dmpXWGVLOE1xWDNEZzZubWlRZUIxYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768245516),
('dOq2CbCYSAsTj3a9aROpy1NpFJxuvOWDPFYCI4nM', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiazRmdEw5U0hoRGJPMHJoM081R2dGU3A2M0lycDVHTnVsWWtSWThDZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768582050),
('DouZJv94OeRcqYgtySmOBtHUEj3TXA8Z8JJJtXR7', NULL, '170.106.73.216', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieTJRdzkwNzN6bXFzT2JPY1Y0TWpKalljeVZmTmROc2FJUHdqTzZieiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767647156),
('DQadkP9GGpKBelU0of8q9iRWKlwfgCqwghKGSfpo', NULL, '65.52.164.198', 'Mozilla/5.0 (iPad; CPU OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid2lnYU1QZ1lBc05mSktURjV2VjcwckN5alhjMWtXM01pVE43OG5saSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767575835),
('DqKLhAb2n2YXCeqP8JK5VzWf5VqZHLVWZ9w02Hm1', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY1Buck9IN3lqWUE2aDUzS3N6TTBlWUhBVHJkaFJCVUt0QlFkV211WCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767606707),
('Ds2wKuy15QWFcMTC3W4TIkLULci78JepOEj9mlPc', NULL, '43.167.236.228', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibXdqMXJ1TXBjdkZub3k0MmRNd1RZdThwam00RTBhWkhSajZjZXV0OCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767669317),
('DU078Tbg3neVxIZxhMOaAI8xZ0mDNSPpS4VrNA5b', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibDZpT3BtandLOU9BbzZPRWhzcGVGM1pCaHlxaHBSTmk3TG52V0hQWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHBzOi8vZXhwb3phLmFwcC9vcmRlcnMiO3M6NToicm91dGUiO3M6MTI6Im9yZGVycy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768285520),
('DUTMSpSrP0G7QKtndT8wpEtldD2K5WEUDjv64Zrd', NULL, '43.155.140.157', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTkJyTDQ1UjUzcnJGQ1JVQ1NHOExvYU91ZVRlYXZWMjVmQ0FyeHNzOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767732615),
('dVocUXWn6PQr8LeFWnkfLvgc0hnod6ExnzCo6rGu', NULL, '51.83.243.160', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVUNtWTM2enI3eFlZN1dNOFpDTmU2OEd2UjdlbWJKeTVxNzlsODZObyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767637003),
('dz7NdiFed0Jfc0edJjecaypFGe0sL9oA6si40t3s', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkM2czh5M1A2Zlh3NVBHWG1sS0xLeWMxb1ZiRDhhNkgzck8zTHlqRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768048591),
('e1UzcTTa7pbsmcB5BrAZnBiOZnnxlFNG1pdiGlhJ', NULL, '173.252.95.62', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM01hVjBvYVVYV3pyVXVKR3pROEUzbmQ3WVBXSUhNTXpDa0RhaExrSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567658),
('E4Bb7QKgcctyih6oJ78VbyzlIt9ZerzjiI3NoXVM', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWFidGdITVpMdEM2bTgySjNxVGxvVEFXZFZMdVEzdkI3UmZHaFQ0cCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjI6Imh0dHBzOi8vZXhwb3phLmFwcC9hZHMiO3M6NToicm91dGUiO3M6OToiYWRzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768287600),
('Ea9V2ChJ3DcXDp1KBK4rfgntbQThX3bzOPtVddnl', NULL, '66.249.73.98', 'GoogleOther', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUExrRVA1TnNOMkhUbkFFUWk4SVNzZ0oyWFZDZFlTTFl4RjVsTlpzWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625635),
('eb8Vq5ufjZ8hMJdjPObfh8Y8D8xZjuHbZO1ETIKp', NULL, '34.239.119.53', 'Mozilla/5.0 (Windows; U; WinNT4.0; en-US; rv:1.2b) Gecko/20021001 Phoenix/0.2', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZURlU1pPMmtzamgzbXlGRHFOTWdLMEFaemxUV0hudWxScWQwcVo3YyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767717677),
('EbFi8QxISP62fbMdKsUBdmPWPhJMWpl5bkFgUgFS', 1, '94.129.201.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiejdsZXI4ZnpnOGJPSG5XdWhUTUJKaERaY2o0clp5elBVNmFiOWtiQyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==', 1768809890),
('eD0inKUjjdEdJMa2VTDZqijgbufox48swrU1O7r5', NULL, '162.142.125.121', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicjFsUTV2aDVUclJiWEU4T3JoaDJFbHZwa2l4RHkyRTFLU3pnVm9HYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767743761),
('eGDLoPV5oMTsIHOlDY9b3T13CJWEYXfahvWujdGK', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZjBuQnBpZDloVEtSZUxFcGtqeWxFMGV1OUMyTlpjWnd4UFdSU0tCdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768233295),
('EGXwQtrNbIABpM1N7cvjHYo4QMc9G6sZz7RjTQAR', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTUhtbDNRWWI5UzhBajRoSXVUSHNqbjdHNmV0N0hZN25kRFZqaGIzZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283311),
('Ej7Hnu2gxlDyq2MRI018X6nQnMFYCsxFsPHHHGxD', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSU1LaTNET0oxb2JiS01Ua0FmUkdtZWVEcGgwenRNdFZZelhNMGtSUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMtcGFnZXMiO3M6NToicm91dGUiO3M6MTU6ImNtcy1wYWdlcy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768287599),
('eOlXPgKDjqu9IIHkLlPI4iC6qMtT01KiPl8g4vpM', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTm1EV3YzRzV4eUx6TjBUbDVJSTYwRk9yd0hvZWRRWkVJZVhwMXRnUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767782927),
('ep9NszR1Y72emt63ZGBlSmb3tkjHHN56FyEVdJUt', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY3NMNXhDY2VEYkR2bjZyTG1CQkdCVDV5VmF6YUx3b2ZKUlkyQk5ENyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768237055),
('ePbVkHi2LjPp0d4C8Ba9ZjjUlrsHTrzVio0HzCfW', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTXpwaHVEdkRNQkZGMDczZGR6V1ZXazEyWlZPano3WFVETHVBSklEdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767794599),
('EpENdY6N9mJ1mvoH1vqvdsDczSJhLvXr51cDYRo1', NULL, '13.231.33.219', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieXZKVUZ5ZjR1c05UZTBZY2lzTlM5aHF2c0FacGdXc0QwTjNmTTRvUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767729209),
('Eq05zIzrAYG8PAhfJeqLx5Y9chL4baPEVeeQycGo', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMTZjT3BzOUZlWmx4T0F3S1lNWFN4RUZObWsxQ3IydFphU0NOS2JtZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbXktZXhwb3MiO3M6NToicm91dGUiO3M6MjE6InZlbmRvci5teS1leHBvcy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293962),
('eUDkIg3Ej1konxlhcBFophguU9f1sRM31Fv16kcx', NULL, '153.0.49.180', 'Go-http-client/1.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnJJdHNpa1pBT09sRVhab0FvRjlJdldZaDE1Q1lKbUdyNVVqU2cweiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768654770),
('eUM1DP6VSoiuKyrkifoTww8qiAX5GeKiqXNheJkz', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVmFRNGlyUjZKTjd1ck0zaUVDQXdOdXBJZWQ1M3R1TUtVOEU5S1FmUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768285494),
('euTkfY0hH7cKObF5s1MPuv96HsfP5DXnVkHyU2Zv', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZjUzdHN1ZTZRbzhHVUlZOWtPbjBMTlg5UFVkTXpIcWxjSDlzVjgwYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716277),
('EUW9Yi9arhVNkN2HCCDwkaRAjnSZRvLMkZzL35xB', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY05MNmhGSVFXUG9HM1JtMlU0cUlJVVE4Y05IZEcyWDNBb3BKaGRxMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767715423),
('EvwN9ObwaiyF8Apd1Gaq2Q5VCfTziCj9TKORVy4N', NULL, '195.178.110.144', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2hjZDRDd0FBMVNMQkQ1akgxU01TczVlckdOZTJ6MUNIVHBucmtFeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767836833),
('ewzOdSqKJReakiSQ0nnuRIjMgDTTQ5xjRSbGmVqi', NULL, '100.24.208.151', 'Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A5362a Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU2xnMXFBbjBJREhza2dtRW9jVm52UkVVZVJrM290THlWb2doVHBmaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768168580),
('eYKoF6kuh9A3Fgce3khL5gz9EG4aGzFeRfoJLh6L', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMllPNkJSOTZ4T1dsQ2hvTWVqSm1aZllacGlTMnJCeEVzeTJVcUFITyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('F0eF1ne5WEnsK1u6pBo06JPHLC4ks2HLpiiFEinS', NULL, '54.167.203.142', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/138.0.7204.23 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmtydmtId1RKVFhucW1WTjJxbXVBeE1PdkFYYk42Rk9FZkk0QUdKNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767745447),
('f4MDrHbTgQ6FP3GTIAXHO8PcZj0FQNF1zHNLEDPn', NULL, '199.45.154.112', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQjdlSnY4TWwxMVhYTzFGZmZNbmtkY2hDYjFFajdLVTN2T2ZEOVFCWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767892741),
('F4qVYRRWnHnVnjhOdSvGJmstqgD3dyezJiU3NJw0', NULL, '209.85.238.65', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib1FLcFpjeVpGeTJHRUlScFZyU1gwQW54UDVWZURiSWliUkNBQ1pLOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768412405),
('f8bZQ1NdsEgwkjcKbHe5amVeXg0xYacfvKUe2Itl', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0VhSVNseVlWY2ZiT2hmTTBMNmxTNXFtQkYzMzAyOHo1Y0Q3STJiRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768213162),
('f8yyPDWI8C3kSPKyBVjrapEQzEaC5ldnCcJb7GPH', NULL, '43.155.140.157', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicTFpZzFud3dLeGNuRHZwRWNRa0xMb0lYR1FNdmZqRmVzYXpvd3FzbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767732613),
('F9JWF9iCPehNRVRu691dCu1SlnMle1bbrICogHU0', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia3ZkTFBBQlhaRFFJaHpESXlmSTFrMmFrTHY3Zzl0TklaTjhCVjkwRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767693990),
('fBcReSU6xQEVV7CeU95Qg1T5IkJpn08s1GG4T9UH', NULL, '111.172.249.49', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidzMzNkdYMTRIWXV3TFRjQ0kwazRXVlUxOGlURHludTZReDZBQzNsciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768012265),
('fBN36W4GZpOUglxZuvJWO3ELRrxUhbdDFHsrGOtJ', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTzNqQVZYODNVZzd0YjMwNTJwczJUY0hKNHlNeEduWEV5cWMwZlZySSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHBzOi8vZXhwb3phLmFwcC9wcm9kdWN0cyI7czo1OiJyb3V0ZSI7czoxNDoicHJvZHVjdHMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768295803),
('fbvxVuGkVj2LrNBVfcCJjsX06lXLqebnYNnTeUuV', NULL, '3.129.57.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT3JGcDVsVnpNenBmSWZ2ZFd3M3pBM1pId0pONTdqSHFvSE1RRnN1TCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625630),
('FC6LfHxbt7wcVeEpwfMfaZN5PUrwNwT4iyWZI8ww', NULL, '43.164.197.224', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT25TRHZGMTRYWUhCU1d2TExTNHM1SE01NlRvdmhXQXpYZWlLT3Z2MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768284017),
('fCEPTdlaehMyvvgebb2TciZ9Uzo8oJCyZXxoprUF', NULL, '74.125.210.97', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidWMwNWVVa2lDMmVJU2ExZHBOQWI0TnlGWGl3bmlNY21sZ3YzOWpPbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767864040),
('FCqyDBkHDq3MpTvE4ogLwAwPwVGY79aclLQzGMpG', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlVQUlZ2OE5xc0lXcWYyRU5SSGlwOFRoekY2aTR0b2wzbGpOcldObyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768189987);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('fcsAQmfqucngPLaT4cT8eI8RuS2kB8Q7RtKzTmsr', NULL, '36.111.67.189', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmZGbHQ3OEdLRGlvT3EzQVFLN2pjV1BaQXVxaUN5eDhOS2hqRVFCTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768150413),
('FDCGyDO4MjkW5LQ7hm2qe1vrnHUJnuFwKCvDDtkp', NULL, '43.133.69.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUThSamV4Z1daejdqNDlsRTd6YnRmeGM1S0xSUXl6NThSdEMwaTJGbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768722356),
('ffkKBpljHjNtUEqoPQKc215TaM8rm6jwfDYE7Tdd', NULL, '18.116.97.22', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRzJBR0pCc2FQOWh5RHd2TzVFczMzN01JaU9zUm0yRTdydHhWNXRsNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625636),
('ffm5G4ay6Vb1o0eL3gS9USOdBtmkucz60tWCTFvd', NULL, '195.178.110.132', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDZYVGoxbWdwTnZuWmxIYnZ3ckp4REdONW1YN3l4amNxYWk3VTRLOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767892921),
('Fh5BxZSprrRhKRwSRgoOczyqyoO3y8RbsG80OzLs', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUnpsNTBJOG5NUUVpQ294b0lpd3dFTHd6U0pnaVpxVDZxWGZRWFN0VCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767627414),
('fLagUKElV2JjLDhEDkYBJqlIkWo8aKla5h871J8R', NULL, '209.85.238.66', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicldNQTFibjdUcHM1ZFdoZDNZdFl4ODFvQm9ORktDSXNXenpKQUNPbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768398810),
('flGfCKS3HDIQPENZoOO2P8EepR4qgAOaQUA52Cha', NULL, '43.131.32.36', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVldjWW1rbTM3RmlKODBGY0xFcGZVckZEcDhwbEMwUnpCaTRpQUlIayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768450327),
('Flqz4TpOYep85tEnr0QN4dHA2lZMq8Iq1E7IALc0', NULL, '43.153.102.138', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ3BGbFFTNHFkVDN3MVZpWmxwMUV0T2xObk93OGFZV2tzdUVBUXFDQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768405886),
('FMbteFIlj8qxdIc2WoyH5mLNSFLQ8maR7UTh5QGC', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVVEUm9jcWJhQzN3Q2FXdWdKVk9uSEdhTFV0OWlBU0FGbm5ycVZRYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767999974),
('fMmHubA8Fg4cbKQYFeZ49ihWWnMviZILyg9zdDuP', NULL, '45.139.104.168', 'Download Demon/3.5.0.11', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRjRvYmV4cDlOSDRJWTh6SEJYcEIzajdUU0VBeVdpa2pGY1ZIc2t1eSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768127762),
('FMmZq6nJzIKmaw6ZVHEaJ2jmZ1yGvPlJSHXViGxl', NULL, '34.168.205.123', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY0x4NjZFWGRqVU1yQWZnbnpBMlpueHVFc2xLUXNBY0V2WHVNTEdsRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767716625),
('FO2ZBTnaHJK1n6gbNvl6deD3CXWhJQXYaWqCsyLj', NULL, '74.7.243.215', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSk9acDg2akdXbzVPY3MybXVyTUhRYlJqSTNmNnIyblp6ZkhmYjg1QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767535186),
('FO5HZOUlr9fDt6IvPYF8lc7o6KAZEieg1SlM3m8e', NULL, '182.42.105.85', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidTdKOGtJeGpGR3FuSjZHeWRFSmpVa3NEcEhLaDhNclhDbWhkNmJBQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768378586),
('FPdIxTP7DMTUHIZgFB87FxMy5n10hjV9NomaUnUg', NULL, '173.252.95.20', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSlgxN1NLZmZBTWNDZ1pQVEFOaGJES0VWMUtWT0pwVVZZZHVOV3NoTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567657),
('fpI4n1TsZni320O9NF982qvVepWqrdjHRv0IKdfo', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSnRZbDRpdmljQ3ExRWw2Q3dWb21JYjBrMzIyY0RZSWc5TWY4UkJ3VSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy81L2VkaXQiO3M6NToicm91dGUiO3M6MTA6ImV4cG9zLmVkaXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768285834),
('FR33Weu3jvURwjRo0HaC5hxhpTl2m4gBr5c0Raz4', NULL, '205.210.31.56', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHJFZEdTVE5RU1MyYVhNNU0zdTVmYzMwdWFiZEl3b3Z6cll3MmU4MyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768084808),
('FrvOtFcKs3lhYFruBofNeR4QBNjO0N0aWDYb8Rat', NULL, '192.36.173.21', 'Mozilla/5.0 (Linux; Android 14; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.280 Mobile Safari/537.36 OPR/80.4.4244.7786', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzUyWjl2YzM1YUd4VVl4N1hkc1h5MThDT2VRNzBCWTh5MEdVVTZoZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768211723),
('fTeL4Hn3IAt5CqcY4o2SyNNQUJLGfYJwErYNHr02', NULL, '192.36.248.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMWNoRkt0OVN1N0FOekVsQ2s4VDZMZHQ0cWZFQXcydThZVWxlcHczTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767690682),
('fTR8xMHxUi0yUBjdSvNpHOblCHRytIjjMsqIWD4o', NULL, '43.153.113.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1dDS3lPT3pCaE1NcklIM3VxdE5zZGowSUpUTlBqbm00dWRKUmdPYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767599487),
('fu3ygQtQCjVODm3HMdawqTfSESQ4myC7yJNc15XF', NULL, '52.167.144.220', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2J2T2o5Ykh5a0I3RGhpcXRIZEU1VFJ5YXZqVjkwem5vMzljRkF5TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767719590),
('FUHFopEcb8VV8rmbEm4dwlqh0zsdGXVdUSIpmOp4', NULL, '173.252.87.5', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTk9RT3VNYmY2SURRSnBVdld5NDlPV2I2VTJlb0paMzVDUWNpQlk4aiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567954),
('fUmstQZeiQ2yAfgKqfwXNNzOWUMxGkQEoUtkVV5o', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSGdqbncyVW9aa0x5N2V4SnJ2dDZya0tUUWF2UGZ3am1QdjNXa3UxSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768221410),
('FVw60vv0Qg93qxvlUU9p2Z1Ft2JVGr04pLvOLNoY', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM3Y0NWRVVUtqSVhnQWc3V3BuSldwb3ZxWGUxWjNUUU92UE9WdHEwQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767690263),
('FX1LxArmwZkOTJfMLANtcAWIZxu0ApPE2a7CuPY6', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaVpHdERPRE5XdkUxWk9HRENTM05YZVd6OHVaUkdPSmk4bEdkWGt6ZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767595084),
('FZCaNftnw4oEt92kY0VGRUM4u1rlUfBjqpysZuC8', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZHloS09Hd1JWUDdPRTRJUm5xYzY3bUNZa0R5UmRUNzlCS3d2OHNLSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767911928),
('g29MeJDqGD1Y6p2pvZkyRVEwCQYuOUPlAOsatfEG', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieUMwM2tPUGlJclhEUko4b21ua0paUDFpMElHZklBSFpBZEVzbHkyeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768058754),
('g2ngg6PLs8XRvzkDDHkQGGl3nJvZuQ58c7twv6Ro', NULL, '100.24.208.151', 'FAST-WebCrawler/3.8 (crawler at trd dot overture dot com; http://www.alltheweb.com/help/webmaster/crawler)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTXRUdTUxRWJIVTdRbXJ0OFhzaWJMNElRRlU4WDlFWEhuTE9BTXZTUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768168580),
('G2zp8iPAtKCrQyLHIzz9en6WWheP7FYbuVdSwFv6', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2xqZG1nM0dHaGpsVGQ1Q2hnTGpXdm52Y0hHRmFDTFN4NHA4N2FwaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9jb3VudHJ5IjtzOjU6InJvdXRlIjtzOjEzOiJjb3VudHJ5LmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768287603),
('G33XaWxlabM8R3r7uDJHNwLFD00eOkSZTvOkdukW', NULL, '98.81.205.141', 'Mozilla/5.0 (compatible; Exabot/3.0;  http://www.exabot.com/go/robot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib21QSnVXWUJQaVpGdTBRd0lNQngyODJvTk16YldwakdrZ2dMMGVoeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768056376),
('g3WQJP1DL6SowQOyqYTY1x40fUdbvuA9gCc2Nhql', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzk4Y21MemhsbEwxUWVkUjFndmtCMXJ1RXREbWhuSE92bDZTSFo3MSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768205680),
('G4tHwEzJrflVLrRIlpt5jExDKzu6zhuwzmMuRs1b', NULL, '43.135.134.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYUhwbFY3VFZBbUZTSUYwWFdKQVNtU25QWFNrOWxxajJVZklya1FOdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768621071),
('g4vzgVVZnibaZPAzhbZwiACEkdg0XGP73oadLbZB', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2J4QVVNVzBDZ0R6akQ1ZDUzMFlTSWFqMmYwZmlySEZlZEpoTUJJMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716277),
('G52CQNcmEFX5DkwCYUNvMvkXOgxBBZnByPkwPJAo', NULL, '185.247.137.125', 'Mozilla/5.0 (compatible; InternetMeasurement/1.0; +https://internet-measurement.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUjFvWGR6eDVjSFVGbDRZOU1LUHVQZ2dtN2puYlNkWWJKa01zNjNacyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768638325),
('G6hLaarSXf50QsDL9bZwKNBAl3ASqC1SmhfOlXKl', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoielBKcGUxdHhMRnBuQ0NNOVNURmIwUHZqRmdrdWdhMmxOams2M1QwSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767823595),
('g7NhmxYUCIQViX1EBRQ708UR9yexi95HgTd66kNB', NULL, '192.71.23.211', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR0NkZDY3bzFoWXowZk5hSzVYMURuRUc3blhjNzlvRzBFZWZLb1VvTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767690682),
('G8SAulL9RThzCu06ulMY9MgKcAW61Mr6KHcYewX0', NULL, '82.80.249.203', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiem5tbGp3Y0JXa3JPZ3pxRlloT0NhWG5wYnZLVUR3cHdHWjZGZmhHVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767738110),
('GaGreYu15o7pfWQE0eFGG7sVZSlzFDDhtGV9369A', NULL, '103.196.9.112', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUW84eXczOEdJNlREcGJxTElKcjFLTlpaUFpaZ3JDYnhERkNiZEo2ciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767511374),
('Gaxiw5waJDNT2LDXdsjnUcRy5fxdUbvJX5TOioK7', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUHVVUkdvZzY4ZWdOeXNKbVMxWFdvYmVrdmY0eXIzNGNKeXRTa3d2RiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767585527),
('Gb8tE9zeUGFHFmrioS5alSLayrk03LXaCX38oAsg', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHlEZGFoRDBDRTh6ZW5DR01IWWdtZHdNTnN3OE1tajBVT0ZDVFluTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471404),
('gbcZu2PrSSftAd0eHm4yIsIXSsCf4kpWHREO2lcX', NULL, '93.159.230.84', 'Mozilla/5.0 (Linux; arm_64; Android 12; CPH2205) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 YaBrowser/23.3.3.86.00 SA/3 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOGVKbUxDanlRdGpTRlhZc0VxYzJhYk9OV3Y2TjhRdDllNVpuWXJtVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767626201),
('gbhs6JsL1BRzMcwtEpwQlzrwKKzALihNgsNHCebB', NULL, '74.125.210.99', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRG9HTUVRbG1UWTJ5V3J3aE45RElMZFprUkJoZ2VBWk9qaW5SeXFlTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767864040),
('GbqeHC0ZSTYqDdrn4w4AEM4lRrC1OoA6DJ4RtfEM', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSXVqM01mVXNOQVc2NTdRV2o3d3hsSUR4eTBRaWJ5a3pCYXVaRm44RiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768476545),
('gC81iX4W5fpZHPo9rgYnK4kMbMbrv7cmPthwNMcX', NULL, '91.221.71.170', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicmNrTVNxNTB0bjRQNWhydHpBeVpQd3V0S2V4aExNZzFVdlhUcnY4SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768314198),
('GcPcn3BVQ3fntbDvrfugZwDqCdmFdwXgwHg1mJNM', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQm9leHNtY21qYkMyZnVFY1Z1dUtabDBDNXlFMXh6Q010UkZSRVFZeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767693991),
('gcWbyExuZSiOw98vZSmMxIlEPCjUZoQIRl0SvReV', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibll6U01jOWFZNjZFZHdqOE9hbG1XdmhOMmtQSkROcDJRVVhkUzdHNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768795129),
('gdUCMGffweGDWKd7WFyaPTvtIMMLvTJgAJRXO4V5', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTlZQ1NFbG9DbGhoN0V3T0ZadURxY3VzSWtaT0JSS0dGY0l6ZFlzeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767780369),
('GDugoLPX458FSFEfF50gd68v2DXBwRnjaNg06zDP', NULL, '165.22.60.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnhOcjlFSjlhc3RPaHNIWGFUNmdRdHRYZ3Bxb2lSNlhiMzZad3d6ciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768510312),
('gfu4GMFTBO2FHL2RAGNQDRoPoYNjsxVEU4Tybm1T', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNFprbWNLVUI2eUZTZXJCUHZQWENpQkFZSDlVQTRWNVhhS3hES1hkNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768476546),
('ggRrGyxz4PjQ4WXubT8s972ta7O4O3DjxDQS44PH', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieU5CcDRvcGlxeW9rR2U4ODhYbGdPSmxsblN3QTB6SnRTdkVUNEo5cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768485931),
('GhBBiIAhuN8LKcGY08TZKWqmHXOtxHNHlq88MhAu', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaGtjTVBOQzFNeEt0V2NISk5jV1VkeU9nSDFIZkpHV0pYSHJOWXdrOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768558345),
('GHViXoWDFlWhzTvI1A82iV84NpMXGl81OMPCoU6H', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ3BrVjM2dWtwNjBpWjNOQ2d2Tm5paUhveUFDUUZxT2tOVXplQmlKYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3JzIjtzOjU6InJvdXRlIjtzOjEzOiJ2ZW5kb3JzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768471418),
('gIU2PhhfJgkj8TrbInqR3fnB06LNjApNxfe1FTty', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMEowMWlGbzVMN1BIUUxuWmhlTmpXMDMzbFdKUlVWazJFZFN3NXJleiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768283790),
('GjfJFQX3BGcyZU3QHL5zTwQxk3rjjTGqsHDjRIBy', NULL, '54.91.83.49', 'Mozilla/5.0 (Linux; Android 11; Pixel 2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.61 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWW4zc0FwS2dXQXlPbmxvQ2lwMzFsZHBYS05seG5ldlRGZDNPd0hsQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768245515),
('GjqwpZkHeha3N9bXynZv5l9PDFiMH7IG9sNqHx1s', NULL, '150.109.46.88', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDlTM1lqejBnU0dNdlM4dDVVbnhId0xBTFhhVlhsWTBhQnQ4VUFOdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768012634),
('gk1RYppcdD5ULfaWzUdqHooAWkI30A5qbTpvZVAR', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWmVwalY4aVd6NDlqV1lsUXlBVFBSNFBSMU5jOGE0OXNvRU5HcjRZTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768016537),
('GKsREN2gZOuO3wN90D7ibUQjMcbiOiuUWiMExZev', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWXJjQkU5S29tTG4wc0t1V1lGVzlpdFBSVTZhU2toWlUxOElUcUlOOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcHJvZmlsZSI7czo1OiJyb3V0ZSI7czoyMDoidmVuZG9yLnByb2ZpbGUuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768283389),
('gl0nkN2vmCp0czlyD6c60M6DImWOhCXmfrVdhAio', NULL, '34.221.21.250', 'Mozilla/5.0 (X11; Linux i686; rv:124.0) Gecko/20100101 Firefox/124.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUUp2OFJGZmplSEJBY2lVN0hMNTdxSG52dG5taTFOdWtNYTVtWUNSaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767899405),
('GLMqPu683jkFslGk2Pu6v5UfYxizgxBXJxDUVKEC', NULL, '135.148.195.4', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWEJ2Mk5ZOHRPYVNCN0c2aTFldW9tWU9jb1A1YXo5UUQwV0RRRDdmTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767958958),
('glu7B23hTRwpKUWb5IVz7O3oUyGj29W6861U71ml', NULL, '34.239.119.53', 'Mozilla/5.0 (Linux; Android 12; ASUS_I005DA) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36 EdgA/100.0.1185.50', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid2RWNE5EUHlQS3hFQjE5MnVzZVljbGFPM1diZGZISHRkRDdIQ2hJSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767717677),
('GLUPIiGyA5CARJspox6pGVtzsM35D2ZkbGpU0nf7', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWVHNDVxVXVIRTJza2V6UDJnZUhSYlJJQjVMd2tValFSVkNNRE1QeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768305824),
('gnwSaOb37oF9Ll8NrGn5KyqQsDcRUh4g7cFGLSnL', NULL, '35.187.132.229', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoidDJXaDRlakR2M09kVVd2Y1A2dVZQcVBZV2RLRmFZeGZycklVcUhpRSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625632),
('GOipFPZ9tT2dU1ZVL8ka4m5U1I0r5MBLJZP15Avx', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibWpqMGpSa2oybzdVajE4R2lPMzlCVFU5MW5OamZsSWR4d3JNWHI4SSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767589889),
('goknJPD4zyjZADkGiJQb3yCV6XZApsEmR9jz5pbU', NULL, '64.227.36.211', 'Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiek15OFFTaGhJZG5iczBrNElrQWlqdzdGV0dURlNiZXZEV0x1eW9lMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768371580),
('GPsGvH3W9GYUEfBJGDp3faorGBb2hnrew3pJWFyM', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicDExcU56RGY0NXdSdzdvTVlWU3hHa1BJMm5IaWRMeE8ySHVKTWtzeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768287581),
('gqfmwMfFT4LAd9F3HEJUn7dyhL7bXHfHqjw0qkv7', NULL, '138.68.144.227', 'Mozilla/5.0 (l9scan/2.0.630323e2834323e29323e233; +https://leakix.net)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSUxCOE9sU05EU3N6c1luVXo0OVFCWWVyenNGQkxRVnZ3bkE0MmRXcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767511384),
('GRVcvGa2Cj13YensAJx2KbkhMw3faWNCrErxsDYW', NULL, '35.187.132.228', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidmZaR0lvMWNVcHlPQjdZbXE5WWtvallnck9Ga3BsNWROSXhEMk9sNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625646),
('gSm20naARolO3LSj318iqYcEDAqybuFev9DTp1bo', NULL, '3.139.242.79', 'air.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTHU1MDlMVjBOODBubXN0ZWlMTGROSWFvS0w3RExaeGx0eXhWOXc4MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768505697),
('GTCx3PQval6UAubXUb5fR2LLzNxDQ9gXYF7ThEo7', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS05qWFQ1aWpKZkZXWGFsWlg4VVR3b256ZEZ0d0ZoM0hxeGNWVUw4RiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768540085),
('gTUImgXSEaW5AOsor5xpPnG9Y8dxATiBFrSboeD7', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN0tIRmRzUGRjc1hab2l6c0lJblBGSWt1c2hYWkRneGV3cG44MXNXayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768034166),
('gWHR1CGHN6u8KLE9zui7MHT4DLbqHw2wDTG6SSSY', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVGgwUE8wZkdnTFdSS2VLYUpyd2lBcU4zZGNuUjZUSTJmSWJkYmIyRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767627626),
('GyqjExUG4UM0odRHPseWyB1SlCnwy7h8V46EdNWx', NULL, '176.31.139.3', 'Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaW56ZFo0U3gyR3ZYb3NPdDEzT21BVm1DMjNWTVRjTkxmY2k4aTdjRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768038308),
('H2EhWocWS7hX5aD2DcXP4LK3YhadpfU7ikO0jnlv', NULL, '3.87.247.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieEFOVGdyYjVlUjBYdlVzM0tCM2U2aDB3S3ZxcG1wU05PeTRTbm9RUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767516580),
('h5k5O3qK7sMdHhG1S19gbDAK7XnERYRGEmGanOs3', NULL, '43.138.68.113', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSjI5NWFEWUtqand4VFJsZEpJd0dFbzRXRmU0bWN5RnZ2SzE1VFJ1YyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768791814),
('H5N7AtVT6uWqrCadjsZXCY7MJsjmsQfz8Exj8HLo', NULL, '62.133.47.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNkZDSlp1aVJmSEJ6dklQRUNZTndIS0dvNkxSM1JIbm1tZnFhdVByRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629640),
('h6tuRPCsLuG8M4IZGzRRPg1PErVji7UUqALJlLMs', NULL, '34.229.67.133', 'Mozilla/5.0 (Linux; Android 5.1.1; Coolpad 3622A Build/LMY47V) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWmR3Q2RTeWV4VmlGQm5MWWtyQlVUdVpqWUZpc0g5QlBWNHZEODB0ayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768758573),
('H7SoQdPU46Vw1ym45WLs5o1EiccRwcGb1n98oKRh', NULL, '2.58.56.87', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieE9pcWhlT2kzWGE2cE1Dc3VJR2hBR2wwVVhheTczQXVZeXpEajdUMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767517477),
('h7WS3r3crfFwAY6QTgSxr7AHMLFoNe06ODKVji7K', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiclZZNU52ZXJET1RWT0xaSFFkMVhPMHhPWlYxQUtEeEF6ZG1aaXdiQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768586859),
('h9aXAtVVJLi4UrMgkpK8qhVt5bhUWaMi3kDOwEDO', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVTJWbGpvYTZBQlZrajZrTnBxbmZlNTc5eGFjczl6NTRHREVaYjdLSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768472129),
('Hb4WwIPZ3fYLLoD2v4LQotCD6x6ivLxgBKSzuFPq', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR1hMeUYyS3RnbzhxcXk3TzBHaVhQb2lRZVZ2cnBlTkg4MHFLOXBjRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767779064),
('HBb8JM3AvnAZxhWgW9AGELUdTmZczpqT79KEvis0', NULL, '151.80.144.77', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY1RYZ29RakFENzBjWVBlNjZPRElKMUhLaVUxVUt6ZkJsd2FCeng2eCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768410843),
('HbLDKYsTKohwgRJoD15pE4HWwDrlqdz3MNIiQBit', NULL, '43.165.189.206', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicnFacjhQaDJQemJ5UnBMbTI2cTYwaXVVeEpiZXdBT1RlOGh3bDZKOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767754450),
('HBno8VGu6lnEkcHZsZT8LQfTQzLgMfUbXOeYyQim', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFBwQkY5WGFpQnBEM3Y5RWhVNUg1bkRKRDBNa2lTVTJsRHNBNnRnciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768152049),
('hdKrg6fKkkmt8Ms0m36xyRpKC7gZ1Djh7tdCtrPm', NULL, '43.157.95.239', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzNyOHVDeDRUOVFlSGJIU0pvWFBpTVFzS1I5ak8yTk9zNTE0d01iSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768304045),
('HEf9GFyuKpaAh3wNynwQta5gx598s4I9i7amlxTr', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSDRWQ0ViaEpaSjZHYmwxdjRuajBEc25NS1llRG1YRlE2Qml5ZnNMMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767931118),
('hFH9w3vfLS9JbzTfODaLETCnrjShATNNcbA1IY0S', NULL, '3.138.185.30', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicVN4NVB6dUNvZ0lPamw1NkRPSGI3Qmh4YjBYQ2NTaDZvTzkyeHcwcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768194834),
('hGlhkZ3L11fK0remJWEa2YGGS6ge5EkEvsi51ufs', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTmM2WUFzWGQxQk50aUpYazI1ZVpqdk5CSWphWGhvTFJFSFAzcHVEciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767828229),
('HhbIYwLj6qdkE7mOcpc0DMrGfcty0mTt8J4Gjxa5', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2s3TFE3OXBoalBTTVBqdzhoNXN4SWdUekxXOVdoNUFtY2lQT2Z0RiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768573719),
('hi8fsIrWAcY7FA1JQNSbQJttJ4N1BtvI2VVCigIA', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU00ybEFIY0xCZkQ1MUJlRXFyZmgxSkZadE9VbU9VSHljUXBRdGMzZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471404),
('hLNZWKd3Q15qp5y2UYKEmEtuN58j8v4aRvJT2RMY', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaGRCNjJpU1BlUXlWY0lqZEVYcVpHSU01OXU2dVducWZnTEhKMHIwYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768314353),
('HlYEbrvNtCm4eJ2lktVAIxqhV2OK9eqSFbhAafqh', NULL, '43.166.237.57', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib3NVSEZ1NW9SM0w5MnN0cE5yV1dTTUhsdmZGQzNZT3JzZTRKbmZyMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768646390),
('hMASbn7QHdnyDUWbzDXHC6xH2roMAEvIhpY48me8', NULL, '192.36.109.73', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZm5xMFhXNmxIMUFER1NhQ3NUczVBdGRTQ2k4M1llakE1Sm1HNlE3NiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768490268),
('hmV6LWBaekCFqvAL2FumM7j0CVEYtwzKLXu6c891', NULL, '209.85.238.4', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieXJuaVBrdWpXWGs2NVI3WTNSSjdNU256VmJHUkViWFlsYVZvVEpuZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768794488),
('hnBbr95EiTPIIC8gOHcJIRQKYNTIjhFIdwy5DLwU', NULL, '182.43.70.143', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieTV5eDBiSGpPSjlYdlpjTlR5WmhxZDdQYzZGUlUwWXQ0U3k0b05JTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767591436),
('HNhIRVug1YEb8Pih5Jk03tlFdQUGeIefNZURR91H', NULL, '52.167.144.162', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSGR2dFN6b2NscjByMXl0akxmRGkxNnExaEhWdkhYVk5Va1JrbGlVYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768067714),
('HpLhj6xi7GLluT5KASL6ZhBTqJpOhGguHFtoBfVC', NULL, '109.172.93.45', 'Mozilla/5.0 (X11; Linux x86_64) Chrome/19.0.1084.9 Safari/536.5', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTUpHUjJQZzN1dHZUZGEzYUZEMzMydFZRUmtPbm80MnZPUjdIUWtPMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768560656),
('HpN7kTAB5CBjK7Gtt9bPNRghE43wLaTqtm4THjbE', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoickltbElCVlZuUXNva1AzbjBNUVdTYkVkdzBPaW5oVHpBTTk4TU8waSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768285516),
('hPqIxxxoMvIRpqvWQNCwFKdWT6QH00cY8srWpeRj', NULL, '93.158.90.151', 'Mozilla/5.0 (Linux; U; Android 13; sk-sk; Xiaomi 11T Pro Build/TKQ1.220829.002) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/112.0.5615.136 Mobile Safari/537.36 XiaoMi/MiuiBrowser/14.4.0-g', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjEwV1V4TzZEcmdCR1hSRWlRb204ODRZUnpybnZYbU11TGNqUm16OCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767975943),
('HQjCve6FOonh8i5sYrRLyTLas8frSkTR2xMP5JUB', NULL, '182.44.12.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZEJUeVMyUmxlTlk1WlZ2enpRekVvUmJPclRZVGpTcGV2T1BuSTRpOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768103239),
('Hr3PyUktLRFhHtcOc5CfVyRzwI4pNbVSnTwRR9Ur', NULL, '93.158.91.19', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTTY4cjZBUVdGdDdKYWMyWXRzNDJFcWZ6azJIUWt1TVdhdUV6SGR2cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768638901),
('HR9IOlaOtYDaRN9xl0wWp88SZuy6zmIebgXrNYbj', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieW1uZmZNZzlISjZhOGwwVklORWlTaVdVUWpEb2RVV0hScEZqaHYwQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471405),
('Hrx97sGirbrFzdBzCSfkZKYBQWhgSOVnfXfLT3z6', NULL, '43.130.116.87', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieDFwU3RKTnByR0NybWtiTXVHdFRlb0xXV0h4YWdGbElma0xYOXpvcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768807105),
('HTJ0mRd7l86yP2kTYyCtM7SdL6xnWpJf0AuSjKMR', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic0VJN2kwNWcxU3hBU3hoaFJueVhQWFpnemN1eGlZbDhxUTJGMGRITSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767718007),
('htPnw0heR28JHyi5uTcaBv47EdH3Sxh2dC1tlK9B', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVB3ZjZTaDhSdzluRnlTREt4dnJrbWRGUWJiQ3F1UnN5NXZnZElpSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283344),
('HVyOQZPUdzhREKnT3gUIWC2FAXZRkzQOo9erfm81', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia3FibElzRnA5TFFMbEdSNFhEelZkYWZ6NjlCUFBGY1Z4WFFIaGtwVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767857955),
('hXblvvSKmlQYSJo0gVobSHvC9H7VWoPGMe7h0C8Z', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicmZ4SnZGaTBBYmFKdzBER0hQbnhvSTQxa2JEcUVaQ0dVdDhjd0NKaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvZXhwb3MiO3M6NToicm91dGUiO3M6MTg6InZlbmRvci5leHBvcy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293960),
('HZHrKBtPgzYmoNhdGmyP0LHkOHALSwpemsISZEHi', NULL, '165.22.60.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWFuYnppYk1ZYVBkZDVqYUZyV1hhQjR2T0paZkNrakJlUUZBeG1tOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768638704),
('hzTWpNXoGuIO7C9J6dr9NTg1kzhyaZGxJ95MbNrJ', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidkdUczBQY2xGNjRDcHQwMlBBM3N1NkFyMHRSUDQ5WmYwVXp0bFNBOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768573719);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('I0QmeIemOgipLc44Texuof27iCh8modime7zArty', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSTQ1bk9nWlVvU1V4TEpqVlNoRW1XMFQ5UHRVNklWazcwQTN6ZlZnUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3Ivc2VjdGlvbiI7czo1OiJyb3V0ZSI7czoxMzoic2VjdGlvbi5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293988),
('i5mltCavqxSaWixFSWdX5Re214SKGD5fsvqezh6x', NULL, '134.209.194.70', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVkU0TlBuSkM2Q0RPdmJaS0loN21sVGdqV1B2c3NNQWFaY21iMHNKUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768723130),
('I65bSwimvlQ8RPQFAX7NKfkZsLI2ARtrcTCyYmPc', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVpORHp1aWtsdEVlM2ZPZHdkYlA3ZHVJa0ZWZXBtSUJDVHNzVFNaZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768212987),
('i9tEyGjKghmwrohTa3WIOFxk74Z6gcAosnzl3p3a', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR0FhZU1ncUM0QXdXZk5la25yZEFNTU96WjY0V0x5UVJORjViMWFaMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283311),
('Icc4P74vpZamevnReTXuAk2adyhxr1OQNgxHI9oE', NULL, '93.158.90.37', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT2Q0aUVyckE3Yjl2RTZTdDB1MnF0T1VUMDFGZFI0TG1SemlXU2VSYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768679178),
('IDM6NZ94xwc486jQjLI2u8HOTwY0BptHjYp9h0WP', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQXNRenFUSWdQV0VJbnRRYnQyQW9Ua0hFSndQRm5TR25wc3BnUE1PTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471404),
('iewc1gZFgZzSTyBjNALTSfOYzCiv2ekRU55xlTRS', NULL, '43.157.147.3', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVUNDSU9qU09iS3JXeWJKa2pEbmtQY2pnWFIyRzdNVmRsN3lZQXVSZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768060616),
('ih8bWDz1ob9ASFgA9EpcgoIUdxaRcs9koxhfa8Fr', NULL, '173.252.95.5', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTUx3WXVRY0lqUmlwN1p1TXJCb0plOVNOaU1ESzByOUZORlJTc2U4SiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567654),
('IhaVkIkgU7x70oo1VISNr359AVA0rUlSe4tGf7f8', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR09WeWVQMEs5TUN2SEdUR2FGYUlCVFdqQlVrU3NZdlhMbUFRRU4xaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768320568),
('ihc03yQzICZZRFGKjqpufTTs92UT8TVroQSrSKWe', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiclpXNzBISERSS2Nka3lId0V1dlZ0N3Vkemp2b1lUWU5BTDRZUGp0ZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767976467),
('IHqT5wJnp4t6wIW3cEIJ6f6e8LpV31jOdDtoJxng', NULL, '209.85.238.65', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibkY1dDUxOFFLT1pNdDZxanN1QWdjSFB1THlUWW9wbG1JOVp0bzRmNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768398809),
('IiPiI8Yvhuiff1RRnpmoPK1wO68jiZWpW42BNWdY', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYUFMM1BTaFV6RlRMM3FKQ0hOWE53NndGaEMwV0hiNjBHRFJjSDBBQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768239570),
('IjNhVa8IBD4g98GMNfvIXekHUv0B1xR8ik921GaW', NULL, '3.238.42.216', 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZXpPZkJidWtqMm4zRDdrbUNGVjd6SDg5eVdXc1c5S044TXJaODJQWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768515667),
('imB2wPbCHpndbCCbsmjlORDwPFkeIa6NmRtxh1YW', NULL, '170.106.72.93', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYlV0bTQ2ZXc5Ymx5V2ZaYlNIUnBCTjY3YjFTeFdPZEtlNGl2Y3RRZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767841927),
('IMNQcUlNMqvgZM26990CS4CyuufnYIwuHxduh7VO', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSlZXbEczQVUyeDhrMFN4Rzk2WnBvc2pScUh6TkR1UjROSG40QmJwaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768295487),
('irsnv2GQbGAcnNnfmGchqJUGBlOQeL1mEj0x7MJx', NULL, '74.125.212.162', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYm9lZ3o4WTE2RlNTVFU2YjU5Y1dRUURrZm05aGV5WFBBWmxBZGs5dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768298602),
('itGALwo3tN1Qxo6ut1w2aPipb63RlvUssCNIsuh9', NULL, '94.129.201.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoid291S1h1Rko0ZXFBdHQ2UzV3elNucHl3NGRhOGQ1ZlJ2QnllcXFueSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJuZXciO2E6MDp7fXM6Mzoib2xkIjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6MTk6InZlbmRvcl9yZWdpc3RyYXRpb24iO2E6Nzp7czo5OiJmdWxsX25hbWUiO3M6NjoiSGFzc2FuIjtzOjU6ImVtYWlsIjtzOjE1OiJoYXNzYW5AbWFpbC5jb20iO3M6NToicGhvbmUiO3M6ODoiOTAwNDAxMTciO3M6ODoicGFzc3dvcmQiO3M6ODoiVGVzdEAxMjMiO3M6MjE6InBhc3N3b3JkX2NvbmZpcm1hdGlvbiI7czo4OiJUZXN0QDEyMyI7czoxMjoiYWNjZXB0X3Rlcm1zIjtiOjE7czoxOToidXNlX2FybWFkYV9kZWxpdmVyeSI7YjoxO31zOjEwOiJ2ZW5kb3Jfb3RwIjtpOjEyNTg4Nzt9', 1768807214),
('ItTYe58b5g08CnyUB0uRWxNckXFV9ATVRZ32FiM4', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidmVJNVBFTnZ4Y0pReXlxWXBXd3llcGxqNGV5bjFLWXdTeW9mYkt2TiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHBzOi8vZXhwb3phLmFwcC9wcm9kdWN0cyI7czo1OiJyb3V0ZSI7czoxNDoicHJvZHVjdHMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768287599),
('iUbtolgLQzsUvZbhqYZa52NnMym2XtLoMaaWfp0T', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieHBWNWROb2xlMEpKRWJPU0ZuSFVscWJ0Q3Q5RHlsUlp5RTdzZDNmdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768658853),
('iuJrdZEBlYnxDdqNzI6tQdORtEsZz0O3vYMiZlH5', NULL, '18.116.97.22', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNVZ0eG5BbVpjUGhES3lUbEZCWThVQWZpdGZXZnd2amVlRjV3cnMzWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625630),
('iuV50G7gywpM6zun9tPOIDR9xYlAvoewGLCElSay', NULL, '31.13.115.116', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWGF2M0RYWTRRMGFuSWpjbVNld0xScGdIZWlVZGxtTU50cXFTVHloZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768514278),
('IvDfUjLcE0sORgVyVIHELlGBVngqTZYYIgtVj50C', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUXk3N3RxVkpJN0dWTzNWb0dzS3lZRFViR1FqNHdXbWpVWmJ2cDZaSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768485931),
('iX8xJcyVnNeQPpwgjAhY13zDaT4pz1tSsOHAFuQn', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQThtUW1pOFE1aXJxQjFxa2hpbDhkRVRhbXFha2taV0pMbXBnNWgyYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768472130),
('Iz8nPj3ybEfyQksj5w2L617f8RiLsgFYUA8W0Cvh', NULL, '199.45.154.112', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU2pBNGVkbDJHYWJmbm9sYTNFZWZCR28zN2RNZk9KajFWbXJDMnlWZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767892737),
('izObCyiXeJzS0yEzJCkQ5Dso29KVH32yAsRo12o7', NULL, '182.42.111.213', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMlZFQUMxQ0ZGTU4yOXUwWHZsajhKb2V0U01LQlF1Ym96STRyMEdSciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768654084),
('J13vEtVSGhrH9Hx8RbTxNsXqgFupVZqfPtfyfyOC', NULL, '169.40.135.85', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4240.193 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTHlMYmZoNnVZa2N2czZublVLRXY4eDR5VHh5TUoyaUltTXpzRWtLcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768553407),
('J2ajFPvMyOD6M9XQLx3uEurRyxaOIQkS3x719Be3', NULL, '170.106.179.68', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM1BCbUZBbVJpRkpWcU9NMDFWME94Q3Vwczg0eEdacnRIOXNDNkxQRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768323617),
('j4Fhj60MD0VAtkUkTzmdsgXo2JliMjImBdjD6w2b', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRnFsem5rV1o0ZjFraHNBMjdQTW44NVlHakJ5OUpmTWNYUUNFdEJQNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716283),
('j9Ky3IHScJOM8gGtR7S5aPTuObkmjivTRFBpFB2j', NULL, '34.72.176.129', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibDJIYW12eXB4WGNoUnR2aDl1T2kxQTZCRHdjcHBFMDNGSGJHeklxNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629290),
('JB9HwXT07Jwlxewbwt8Yd1DgEWY18VuzfkPLLmI5', NULL, '182.44.12.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMzlIbFRKeFVLSGliNlBjSTVaSUlCS2wwck1iVXJzWTNmckdadnlWWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768103243),
('jBKXnkt7Iex5bYznUlpckjqhZCpEvFflP1wj92yh', NULL, '195.24.236.199', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSUtJWkxFenN1dFdNOGY5OGUxSlpicEQ3dllNVUtmNjA3VGEwWmdzRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768089263),
('jdBKoJALIfXo2DRzCQOat9UvoejgVGBhMcbQW93j', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGZOMVNkTkFXOVhhU3U3R3dwbEYza1RHNEkyZlBZTG9BcXhnMTYzbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768058391),
('JgUw7fYKa0zKfDx1yyoAL7XPGksce7Tn9BZMtZSE', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicFZoUnZiUklsM29DQW81SWFjT0RPVzFBZ201QUtTTmFiSmdWYUtsTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768472331),
('jHTdwMdjCRDtWhRf7hrxUiT1chrFZQXzwLOwYsDg', NULL, '173.252.79.2', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieHowa3FCVjlkRk9KeW91eHFBdFl6cGdjbGtBOHRNcUY4UlZHQktmQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567668),
('jizbQLU0bBNPvF0EIp4NEsShbmG7dzdo9dCLwY1Y', NULL, '43.155.140.157', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOVdseHlLRHVKbUM0MWxKWmJ5czhBNDJUNWdIUzU2dDF6MVNBWDEzOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767554974),
('jLwEL0DPn7RYM4BI8kJjsQiBapiwk9Pf6cms6GQa', NULL, '34.217.50.244', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNVpyM2pFREZJbmNvbHFHZDBXRDA4anNJZjlaZW9TQlB1NU4xM2VDeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767687053),
('JlxNV4c3TQncJbel2Ruh1VwjxDaGCSY9BY0qpngE', NULL, '104.252.110.116', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/138.0.7204.156 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVFwVDdNdjF0YWhZZ3hDaElNREY1NVBib2hGZkN3Vk1wOE5PRXNSUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767633706),
('jmX4qmxua979Ox85pJqwFN9N0xws597JKvUqsPyO', NULL, '123.187.240.242', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR0tsT0FEbVpRVkJZZUN2OFVDWkdPZFR2VEduMFNVQm85UG9QeE4wWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768058578),
('jNH7zYmCtW2HRaVlJTQgIVEmbECnJgG9CSsSv7nv', NULL, '137.184.121.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicDk5ZjFNSmptWlBKQm5nb2I0Q1FIaFFOVkxpeFE5M21UZXdlQW9qQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767513733),
('Jnmyx4w4O4uD89GTF5ePFhQLcGMz6d4KA28jDXQM', NULL, '98.81.205.141', 'Mozilla/5.0 (OS/2; Warp 4.5; rv:45.0) Gecko/20100101 Firefox/45.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1oxSmE2Y2dkbE9yYkFLa1RVWWppQlJlNGs3RDlEdUc0M1RxN1ljSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768056376),
('JNvx4AMjTMC44dAbbk9oTZ3rPRh6gnDAFSIjbfWZ', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidEdvQUs2WlZPVGszemJubzUwT1ljVGZXY1NYSVhmOFU1S2FVQUxZUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvZXhwb3MiO3M6NToicm91dGUiO3M6MTg6InZlbmRvci5leHBvcy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289524),
('jp4dFGI1VRB0NknFCSAEPEPSriN8DBZO2CXQrm1z', NULL, '101.33.81.73', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVNpQXlkTG0wUFFhTHJxMlI4V2Z4Mk9rQmh2d2puRENVY1hJTnJxdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767532631),
('jQMFUJY30hpZzP38NMrhEwanwTprpEtkUmylEgam', NULL, '4.194.99.179', 'Mozilla/5.0 (Linux; Android 11; 21081111RG) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzAwQ1hJTUNNREczbFlENzFkVkE5OTZZVVpVclBhblZ0ZXZxYTk2SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768015889),
('jTgEZ66XfIQxo30d3OWEsuMLuoS8kdd11foV4rlS', NULL, '64.64.112.146', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidkdsT1Q0VlhnN1R2Z21lcG9WZUc2SFFIeWFrY01wT0J0U3F1cGRYSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767629550),
('jvDPEcDYBxUkL2FI1B2Zd1sT7K2lXAni6iTpuu2I', NULL, '43.156.202.34', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibmhvMkNyQWJnRDY5ZTN0bWtVNmVQdnJTVng3NDBOWE4ySmhzaXZnWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767776104),
('JYdiiRdl70JfBASzzBKq3TXDOpCltat6Tw40w08L', NULL, '52.167.144.238', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU09NOFBwNGI2U1U3SFVOSk15UUdJQ0ZxYlo3cGpWTGNKZG5FbkZydyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768115702),
('JyF10dNg6JFOssaoKomYzGKZ9FNTT66sdWbJ06mk', NULL, '110.166.71.39', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1ViZVo2ZHN2ZWlnWmJVN3h6TW1lWnBKZmhxTWc2VFcwclFsSXFhNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767685066),
('jypV57yzv03e1Py8SugS9qjs5bVAN48yhlqAk7Nd', NULL, '165.22.60.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWEh0cDU3d2FReTZocU9BSUJXZzRtaEtqaXdwQXNSWTljM2hFQ0ptdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768558644),
('JzjdchJJxV0k9KujieW4FMqkz8ijYTypCvXBe7tm', NULL, '43.156.156.96', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicjNTQWdsTHY5SWhHU0xBWjRveEtDMUF1THpKUGFUWFJJdElYa1REaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767795924),
('K1hGWM10isWqofS6QCRpsPlcDfTlAgoS0fROnIzd', NULL, '43.164.197.177', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYnZxN0FKSFZuZmFJTmVjd0E5bmFtSjVuVW5GZUo5SWJpbXJIQmJaQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767882131),
('K2QvRmcU9iqw9XHrLIC5NlmDOJAOQ4XTlf0hyeXg', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0R5UnNGaW55N3FsREExMkVYZ3MwTEdxdTB4eFFrY2JETDVxVkNHQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcmVnaXN0ZXIiO3M6NToicm91dGUiO3M6MTU6InZlbmRvci5yZWdpc3RlciI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289363),
('K4o4MN67pkWEacrYR9By8Elq3CHVp0nL6u0LeHTu', NULL, '40.77.167.48', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlFmRjRMODdKU3FkZEFEVUZOT1dCVjVlVW96V0l2Y3VxaUU5ZkxSeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768021535),
('k8W3lA2H6QppEzqacjDmNUflRDQ07gJCcBOW45PB', NULL, '205.210.31.158', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMU5BRkpwOVlIaEIzbG5YT2tVNFo2dHFMWEppUHlyWTR3c3owMUllNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768779466),
('K9dHalaIzh2L4wKjvNCZlBBVrM2dDZ8Q6eYwkDq3', NULL, '72.153.230.168', 'Mozilla/5.0 (Linux; Android 9; itel A27) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.6943.143 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUVVYNmJXVENEc00zc0gxTXNmVzNhU2M3SDV6OXQ2ZFo4TWRPVkRsTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767636537),
('KboyTF1birzLpCKIDetLDacRQ7xEcv7LemJsMt0J', NULL, '182.42.110.255', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1RsTEQ5bllnM3M3bHNqeXdSNXI1NTdNajIyNDN0UFZWbWR0Z205eiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767826025),
('KbpR6xI0iVk8AxLTcxINlAYArAYWVKcDjI454IGR', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUE52ZWtjQlViclFMVVVkV1dWVWtrdjZWV3o5RzVnM1Z5bGlMUTFaWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768498745),
('kBR0CwsfxreVZmSeSLVjDVeMNjmfS3zYcDHNUZOU', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSE5PWGlmTmFzcXhleGl2UEp2dUJRRGtJZVFjdFZUblJVZFBmT0NGMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768754457),
('kCkT9Xsw6w1FkEfJFoLd4uPFCtJXgCb0kOioxXcS', NULL, '72.153.230.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.74 Safari/537.36 Edg/79.0.309.43', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiZEVrSjNpSFR4YnVHN2pqc0JMeEJUS1c5UUNxUE8wWWx2YTc1SmQyRSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767636556),
('KeiU8PtQMijvJA82EOQ5g5XS2zUCdvAH0z3xSWjh', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTXgyelc1dERmUlVETVVxMElvVjlTM3k5bnBqa3RTNDZLenhGaGptQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767807195),
('kfELXcVXKs4B3IQc2hxcWGou7J2GyCkGIYWgxgui', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMXJwbHRZR2taMEdiNEJyM3RiQklSZWY3R2ZRRXQzU283aVFiS3U5TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('kFeUYhsCuGfFrGr8oVFDgmrnhplquaVJMIYQnmjh', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1J3T1J4ODNWSHRGR1NEQkJBT1ZPTGxXd0Z3cE4zOU9PbnhUaUlIYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767931644),
('KFTs4YvTmuXDzurE4N95b9X5NKU3xmVT7AvyZOCx', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWVNJRlp4SWsxZTNKU0h4bjNMWlNnazRWbWVZN0lVa05rUTVsbVI2dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767672328),
('kGwAD6r8JYLt69jcMZmy8uCftoViHkyakFz1wFKt', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN1pLS0x4VkJIaE40MUNRejlJODhidlJwRVZkUlliczlobG5iaWJSVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHBzOi8vZXhwb3phLmFwcC9wcm9kdWN0cyI7czo1OiJyb3V0ZSI7czoxNDoicHJvZHVjdHMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768471417),
('KgwZ36HMcwyUp7qh8wJZ9G3sG3rEQ9zNVwa6HX0a', NULL, '121.36.45.149', 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYmhuTFRJQWZBdGEwdG45anFqTHJRWWh5cW8wSTdXQkpQN0tPd2w4USI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768526447),
('Kj6Lb4XzqMayXF1TZ8O0R5h58pc8YYhrpValeTBd', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicXRDV3Z4VGQ0eEZOazFqRE1SZFlEVVRab3d5dWI4RE5BZ1ZwTDlVWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716279),
('KJXd8VYFHKptX1v6U9e2pRr3z4PRwzvojFtkIySc', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1FiRXpMMllhZlQ2OU5SRE1qTUlNVHRDcmoxeE1zRUJsUE9SSzhIYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767708124),
('KKhLD2jbNTRRF94WZp7AoPlc63etUmlgOBmwJAIb', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiakdVVHcxaFlCNHlBMm1CRHpiZGtnSmE4S25qUFZFNHVDWVhGRkRnUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767959231),
('kMIcd0epl4YPDZUTC2xUTZpyxFbHCFZW1SNQxn9w', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHY0a3FuNHFPMkZiRHBkTVhhSUFVdnBMbXVTM1RNYU9qT0pDMVJXNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('KNNlpuyWmcaJn2hbSqC9OntSRe3Lzkov2fBHFe33', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0xLeFh4MmZnSTNyYjY3MndKOXFrbGEzeVBUWm5seHVNYWgxcW9kQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768040481),
('kozPf0OXChU2f1yWyZ59vlVz3UweZz3Bb7sxqxjF', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ0tyNDE5T0lERE5oMVlEeWt0RVVhWGh0MzhlaHZNa3AzSWVYQndFNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767540009),
('KpKqjtYlO7kxTkGqZCKe68EMi44GPoKcx6rFHxWd', NULL, '209.85.238.4', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVBXZ3NRRHptU0Jadnk5a1BqSDA5Um9rYVVnRE81TGpGSlJjRlk3TSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768586217),
('KroPwTG9VQrHJrTedO3OvoWuoD4EGJoMkmozgKnx', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzl2a2FwSmpsUHlkUG55VDB6Zkxtb2FKRmluUThnRmlOcFBKUWtJayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767899671),
('Ktj6zietn0vAN8GjNWJZTAFTH5abz1Yy2y4cUtXo', NULL, '170.106.72.93', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUUUyYzRhNWFYQ0UzVUd3bDFOSFJqcFlyaGRrZ2IwSEp4djJFbTE1QyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767841929),
('KUqsa5R4mwtXGsAlxgBocMxVNdUqjWGt0Qx4X5NT', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWW1HcUh6bzEwQW5xNHdXNWg1bmZGR3Z5UzhlNUFKcFVjdXo5ZDlKOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjM6Imh0dHBzOi8vZXhwb3phLmFwcC9jaXR5IjtzOjU6InJvdXRlIjtzOjEwOiJjaXR5LmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768287602),
('KW5bIev6HnLy1ohpLGKeWncH7u9IkTKyz7eYaQVu', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibzBSSzBUTWdiN0FDUEFSMUFrdlFjOGRWRW9XdHdhV243eko3R0dQdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768309709),
('KWaVDiHbuKiJ8eqIVCmmkSsyYsg3jESbmpPWO1k9', NULL, '205.169.39.56', 'Mozilla/5.0 (Linux; Android 7.0; SM-G930V Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.125 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZkpZbXAyMURjTXk2UFptd25jbEMwb29Kckdmbm9BWERiZVN4RXZ1SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629292),
('KxOOa5cm6R5hiWhlqaSbIg8BTeG3a7rXdEB1oDXQ', NULL, '64.225.100.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36,', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaTcyekVWMkR4eVZaZVpjT056Wm5RTHA1c0RXRHV5TEE2RzloTkwwMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767629235),
('l0U7BcjBjQ6UVEZJcymWaitg3Lu1EWxGyXOGiVqA', NULL, '43.156.156.96', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMFdCckxmTUdMejFCY1kwc01zbkZLcjVDTENVbHhPTmhWaFpZUllBcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767795922),
('L35aciy9NU8765GkW5uZRpWE7r3TDBZiWPkv2l6t', 1, '171.61.163.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiOTBmUGFxMjZBdlVmOHI5WnpOaDRyZ1hVczFsQXJyYzBYUXl3WFFLbyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9', 1768304870),
('l4mZP9eGTbPpIohWMKNTm2OstqHTzDKFkfN0bUKf', NULL, '192.178.10.101', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU2pnMjB2RzNoNGV5Z01oTjh1eHNZMkJLb1VEM3ZEcURwRnY5b1J4biI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768300075),
('L5lLOdj8Cndak6VHLuxmHvz6MlWVGNS3jNypmoRl', NULL, '101.32.208.70', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDI2UnJXZW5oRklYeGZYOVpjRUdVWlM5UlZYSDRkNDFjeVRHckFheCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767691441),
('L6L9qPOoth0xaCSDtB4SR5oDpr3XBDMw9Uj0ebYA', NULL, '74.7.243.215', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVlNWeVhlZUhNSmVPMDRkVkhLelBXVHk2Nm9xcGNNMVpDb1dwNjRrMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767514371),
('l9g5Eke44kexf2YII9WweGYqBcSjrcHcyHkzbm7u', NULL, '34.6.181.13', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidkZrczdUYTZ4M3N4OXE5UHV1cUExbjZjN1lmb09rNElvQzBtWnFzeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767891723),
('lAXPYa3mWdkHTxTKZRTm8w5924eZNDub8WIf57AM', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWnAxSHl4NlhVbldraGdaUEM0NkhDZFpoMWJkc0hUZGFvUmFHMWtpViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767761749),
('LBK9n8LHoRy6Zc38mOJnjx0nN7PBVQvPQF4y4bky', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUZxMDV5Zmp6Q3ZVUGlPWGNtSkdZMHNLVG5DUHhhTExmeE5GSmZzSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768482424),
('lBwpk3SRoJhlLrYCJleo5TaCrf6WfKxQ0XPDNTir', NULL, '54.162.90.208', 'Mozilla/5.0 (X11; CrOS x86_64 14469.59.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.94 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTHo4NDl5SGNuejBPRGlXcmFQa2JpWnFlWVpaeU1kTHhFQkE5cUdzYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768411741),
('lc5DtPxsJbzcZ4yNMnHcSVkDup1TDLtDOCKQLijd', NULL, '2a06:98c0:3600::103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjVpbGdsYWZRV0NpY2FBN0E1UXNnYjZxY0RsbHN2VXRQNnI3bkVDbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768391709),
('lCywALXjIHul5OeTxNQvJrS14vCxpN5cMscz1Yyi', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidFZqNnNJSHlJWUwyWVZ3VmNnczZubGh3aDJmajVXb3BBOUQ5RGNDWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767911322),
('lgTCu83klEZhDBgxPgM5iqULsZyRUPR3DmwNV2eM', NULL, '46.101.9.216', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic0dKRk5IUldNQ1JOM3Nid0RyRjNBVzlvOVRsd0c4d2hwV2Z0dVVJVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767994808),
('LihAAmwnP9MqxjLg39IGFdSbuDtUGydoK30Jw2UU', NULL, '217.182.64.155', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVVltNzl1U0JTQzFSc0Q3NjVxQ29hd2ZBZFYzTGZmRGhHUEgyaUpJZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767518932),
('LILxOoy1HmUogVACphyxS1Y3XbQ2bAipGwCNjlcc', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7499.169 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkl3NTk4c1picEVQZ012ZW1Hc1lNdU5NZFFhSEI4M1J1bW9YWmd0aiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768160252),
('LJa7ccvjjmPj1khrukdVkSOgviV5YGABZK1j8pOJ', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2tFNXRhY0ZRUzFOZkZWYXJXM2NMNXRtdnVRaUZuM0NsU3F5VUtzSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768463489),
('lmomJJNuc3jX4BOX3kyXwSTVWKXJieoH2Zb1Xadu', NULL, '173.252.79.113', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY0pxYWFqeHFjWWtRUUNmc1U2RWVQMVoyVHhNazRVRzNxdXNQeEcxdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567663),
('lmUNLWAV12UHmJ5gSKQ4LVtr8SDbomvCkcQqZGJW', NULL, '69.166.236.89', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTGRWOWpScW1GOGFMZXJpY0FhelNvajdOU2F4dmRnSU5tZ0YzMlRkcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768496202),
('lMxKpwcKFQqRygai60ub0xBKcuqtKijF1qd9AkI9', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSldJRmdhcWg2ekVpajR5Y2xERlNXaEtneVVTUDlyUUFSeUNibmV2VyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzY6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3Iva3ljLXN0YXR1cyI7czo1OiJyb3V0ZSI7czoyNToidmVuZG9yLnByb2ZpbGUua3ljLXN0YXR1cyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293989),
('LMZwuEGxjKGg56HbPHyesg8Gxh5KkzTYpkPrgHYL', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMzN5ZkdhdVBEcTFtWXcxZjlONVhWZVJqa0J2M0k2OXo4UjZyRUVFaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768277617),
('Ln3gsW2FF60o3oZJDkgzFuGWcTibvMSRjNhQzmA3', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTBqc0oyMEt0NFFJeHlMVTNSeUVDa0NJQk5sTHZmTndvWDNnNTdUSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768644220),
('LnmwQis4xPgiCl9xwfukLHPrgprH2LJFFqbPhGnt', NULL, '205.169.39.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibzJBQ3BKTkpMUWo1R0ZKbE5acUxtdzFzYW5hdVpNdGRKZHV4TGZTZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629311),
('Lntwq5eskwdasuGXUuITHHJpjNaQn2RiHcgh9bnB', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZUFtR3FOa1dqcktTcVM5dzJEMzNOS0JXWUJybnN0T29jVGdxTjBnZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768104437),
('Lo6A1y3dx8R3canKzL51TKq9hMyINts81kbSGhC8', NULL, '173.252.79.113', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNjZST05wbXlINk5HNjdRREVlclBJNnVZVjRTYU1UdGZjdVJmcUhaaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567663),
('lP8HG0eZpJzIfJ1XM2QuyLhBPo7vc0wQExVQGiv0', NULL, '209.85.238.65', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoialFxeUJLYm1hUWxac2pNdDZibXZmZGJXOW1VRVlhMEd1VlNDVWQwTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768386135),
('lrI21vu3xPBs5Px58ysjbyThRZkGgRDpbHOoq2RP', NULL, '207.246.126.50', 'Java/1.8.0_332', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiQmlMU3d0V3JyWXV4WFpDcmlqMDZFMGxPM2xkTnA2cFJyMjl0dWRMQiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767714497),
('LSJm952oHeDaDqkuQjzGq51Jpm5yvLbmMBhVHzpa', NULL, '93.158.91.251', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1.2 Mobile/15E148 Safari/604', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidllhM05NRGlkZHk3S3laWGY3bVU2dGJBS1Izb0xEWjluczVyQTM4eiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768176393),
('lSzNTUa04JLq6vkhx1PJXwNNLhQVvCw7UmU2NSRd', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1p5dWlIeUc0NVNMR0E3OEJMRWlHZzdWUnVZamNhNENkRUI1Y0xhbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768298303),
('LtgCZd7f9DpvO62aAsKZMhvTkDDMyDaDjtHN7rAD', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidENDcVJubDZqQnVBcFJ2V2lOMG9UN29uUUVyQ1ZLdmdkTEI3bUpRVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767572713);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('LTGLFH8OZA8hm6NtDkdpAKpFEws57wh3E1x2mVKD', NULL, '212.56.49.55', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSXBJaWhNSVJlSHM3Tm1iVzF3dThOSktyU0ZGaWtpbXhzSnpsWTdSaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767633154),
('LTyQqh38vB6caaGCkrbxmeyfCGVNST3YOXLQptN5', NULL, '209.85.238.67', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNlpXbkwyMHRrYklESDAxVm9sb1JvTUM0bUNZNzd5MVhSbWhVWkdCNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768377974),
('luERnX1Lb3zHUpxD9Knl4UQTicjHInoOc6ML9n4c', NULL, '209.85.238.67', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRTBzZ1lkZVdMeTFFN2tIemxmZmNaTnhQejZGUmhhcGc3b0YyeXZjTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768407191),
('lvlJZnWIXjMj6H5RDWAX722YMGlwI9XwwHF167HS', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDJISVVhSEttbmVOZEZCMHpUTGVqS0pyaWhWQzlCcFVMOUFvOHBYcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768103545),
('LZboJk03VF7uKn6AqrBcRO40NmawJtG6cJOHQANH', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidUVOS2RxYmVjWFhzRUpNdXc4WkRjRUxxamdidjhVd2lSRk1qM0tIbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768058709),
('LzknKvMYITlpuAAEOBI9o1gQfKBsgTf3SRdwoC4S', NULL, '43.167.236.228', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnE2QTFubjhsU1g3dWEweTBtT0Iyb01WdUNhdHlielMzR1l5VGl6VSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767669319),
('M0030uNMqlJENORSpu1ECbhKYgbUrGChNkHuEQ8y', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoienlveTNXb3B2dWdGUE9RelZrRFpaWDlOc0lMaW1vSElKMHpWSzZFQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('m1zt2CXbw5F0ZVE5r2jeYHEo2z18odai5r1H0p4p', NULL, '193.188.63.130', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiOHdObWZZTDk3YVkwNkxDZTdBUlMycEhIQlp4bEJCMGtvdDluVW01cCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768299245),
('m42gIk9G8soMmiZrwOoFbCfYLC7smHC6qWFHnyZa', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZUJ5OWFsdE9aZHZNVVJmYzdXWXdSQlppWnRreW5nWGhEQTN6cGd6eiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3JzLzExL2RldGFpbHMiO3M6NToicm91dGUiO3M6MTU6InZlbmRvcnMuZGV0YWlscyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289490),
('M6DRHFTizUathzzFetwbNu5HMmcKB30NLavshvbO', NULL, '18.116.97.22', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNXE1RnV1SFJGVWpTSm8ySzg2Ykt3cUxhbUdLbExaTk1FNHM2WlAzOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625636),
('mCI5zf0ZxvzwzINNqaTPSlRYR0y1g9EW8T4AYtVL', NULL, '205.169.39.23', 'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQVRwUHl2Q2dZeDZWOWZHalpucXV5bWxUQmk0Y3hxNFFMdkNQU3pFTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768425637),
('mdKnOVt4qS5LUeuqkX80IoP3ufDvhUIMe6iIhljV', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieUVrdzlsZnVONjJ4TUFNMkRqcXdzakdHOGxEanRLNzdnR2xrbDVDOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767761287),
('mF6hSaG2UZbCfq2RDmpE197BhkrYEKNFYoXfGebj', NULL, '52.167.144.158', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTUx5ZVVaTTRCb1NTR0M0RWU3THlqVDJoR2Z2RjVCYnlDU1lSaGVXaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768343007),
('mFSZuq1gqZoeS3JH4rURdsVPTDPpVzsbsBCK6wou', NULL, '209.85.238.4', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS3pYNW8zN0ZVZm5QZjlMU09ZdWdBMWpHQUtzWmJjV01ucG5FOTljTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768707971),
('MFwOe9084sn1v2ejOsne96Z2Y76i6yy0PUxIup8A', NULL, '188.236.204.255', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid2xjRUFPQkNZVlFScnJOMTFTeUVQVkZvcHAxS05iVlFpUU4zSlR0ZyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fX0=', 1767716334),
('mg919W85m4ZVdWA7kwXtDONyb4s8WB080Ro9cINq', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0pTZUdhTnNSeXZzVmZ4dE1vSEI5N2pzR1VQS3JxUDlqVTFNaTZ3bSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('MhIYUWC0Y4z8U4icatKJZc5WntxDpvzaHpGOl5w3', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnByRGxsNFYwVmhEZ0ZwakVkdHJOeUFGVGxvZndmWW8wWnRsMHFVQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjk6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvYWRzIjtzOjU6InJvdXRlIjtzOjE2OiJ2ZW5kb3IuYWRzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768293961),
('Mi3KlYieXq95t2l7dAjryweddih8FPHgXLytCOqW', NULL, '205.169.39.123', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ1k4MUFyRkFqN1FST0NTSHRDQ29jR0NhNWlVVmdXeHl3MHBPdlRsSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629306),
('MIgnBNj7vL1Fc8flPJTAgaAaAQLmhiAFe9vI02Gv', NULL, '192.36.109.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1BnQTNkeVJKUlVVemNwaGFHcVkydzA0a05UbU9Dc3FTYzEzQWoyaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768490267),
('Mj5zUwQGR27LdooS27RPTxxHj0zi3TFxn98tE9TA', NULL, '205.169.39.23', 'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHNMQzhjSmZPdmw3dmdINENUbU9pbjVHZVVOT1h1Y3JoRUpSWlVncyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768425637),
('Mjhc7DO8kC4nd81QbZpiIloxmpb0Zmur1QxcNlsG', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRU1yT3YwcDhIV2R5M2VuUHVaM2lJdU5lWDBQc295c1RDbUt2TmpGNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767572713),
('MJnMLEH2dgIUHlET91sVtfdcfkMOn01n3vagsdra', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZEtnZENHT092akZ6WmE1dDZuTWlKUmJ2Y3RtSFFQb3dySHpReUZrNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768016180),
('mK11NeFYGubxEkA6S4HbNlKlKb1GOrcVsOdC7uHQ', NULL, '34.221.21.250', 'Mozilla/5.0 (X11; Linux i686; rv:124.0) Gecko/20100101 Firefox/124.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTXJNanBUOGNNTDFiQmVmOWhDNVB3Y1FYeGtZZTcyaEdIcmpYRUVFdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767899405),
('Ml9LxeWkWD2lAqYTsRvNUuWlE51Mxzp40kLhz2gV', NULL, '52.167.144.169', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUTBhVWxPbnF4aGV4S0xsZWtweTZEdDlxRXN0ZWM3UWpEYzNubzc2NyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767862959),
('mmqEsWIM1FjVVsYjk6h4eWg9bd2xjMc1qHgfQnMQ', NULL, '74.7.227.129', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicTN3SVVaamp0N0FrdjlsV3EyWnQ0OHVDVElrNlA3ajFBV3JwMFBDSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767779688),
('mN1QOzbcask6GyUoHf6fvT6qW2ewlsRDe0geo1XR', NULL, '66.249.73.129', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmxhSE1kbHJuZkNFcVNlTThBMFV4R1VqN1hBSks4cnR4bjhTaGxMaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768593492),
('MnlNovIefnOYROL884tAk42gK7YgbkjPZlShtydv', NULL, '3.138.185.30', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2tVOGJUVm9ON1BuZUg4b0tDMHU1Q2UwQzgwUTBMaGpkekZzcDRRdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768194834),
('MNt8TqfsZ9SZ0dG79K8ovgF12AId3y5WZxBDdJOZ', NULL, '35.187.132.228', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiUFVFelpZbDFRU2UweklxVkhPVkx0N1VHWkFpS2ZDUmlFU3R6dENBVyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625623),
('mNToYc0RliIwu0h6ajgcJBJjtDhg75A9MkQsMAv4', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZExqeUt6Z2lZVkxUN0FnblpvamRTYUIyMVJueVJNaVBvUk5SSUFmYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768298302),
('MR12vw28Zdhj7ogF8W7l5SuKR5TxXB2JGFmszecL', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZkxIa0JRaVMwbUFQb3RZVVZNcTNEVTd2TU5heEYzSm1VOEJSSU1kNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716282),
('mS7u4soAf5GoUxq3GL48vdCSHIpPHMVdnqbvzzHw', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYnZpRkk2dlI3Z0I1Z2NESlliMENvdzF2SWJocHBWeXBLMjBpZm5MUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768580284),
('MTTZex5tzAupw65bGnVlWMZcyXaUzYjU67O1YHeC', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiblVXaUxaZER0aFNkcm5tNmdIMFd1aFZwWnlQdXNTUUljU2JHa0VqZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767860363),
('mU0T2C4JJDuZOGqK1VGm3OP16e2652vEIb3orELj', NULL, '173.252.79.7', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM08yTjFLRUVVWWJPbEN4cTM5eWhNa3RHTG5KaVY5c3hIbmpLcjFRVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567665),
('mu7VPQm0xHVWnxpXriggcyJrwcw0iOFTaPqAOzGI', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieDlCZ3dYdnp3R2l6QVEyVVpJaTZoeDVOeEVvNUhmVG9nOFJQdHk1QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcyI7czo1OiJyb3V0ZSI7czoxMToiZXhwb3MuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768283493),
('MUn83xbSSpxDY7R2mQ3jbxZ4fegvHqojzxKnc1rp', NULL, '209.85.238.66', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQjd1Y081ckhhQThLZ2lyU0JZb3pqZ1Bhd25jbXBxSEVmeG9YYW1SUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768377972),
('MvcMvSrwHdI8Pz6MvIa9285aMgt7V9OFja57D66c', NULL, '35.87.45.175', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWWtORkRwNVBLZWd5Zk05T3JtQUdkR3JrWWwzbVRFdVNMUGlscFc5SSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767690487),
('mVvfypd4HATPltslnBfbgqT0I37mtyt5ux5smadI', NULL, '2.58.56.87', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTk0wTlJITjBxaGwwb0RnOEdDZGlQUlRtd3IzZk51aTVJa1FZcDdiWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767517477),
('mWPCaDqVuZny50JSUaLYuSa9m8fgdWnVpyyAyxuB', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZWNROFhNSnV4TTNjWjE4NGNDQkIwZnEyQVFzZFUxZHVWMGl6SHZFSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767825038),
('myckUmojB9JdFTRY8bwY2JnMvFEKRzcNsCgUcjNz', NULL, '35.95.46.148', 'Mozilla/5.0 (compatible; wpbot/1.4; +https://forms.gle/ajBaxygz9jSR8p8G9)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYkU0YnhnbDdybUl6TmM3bUVTTzlvMUFmd1BCTWd6YlIybEU4aXZodCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768317811),
('MyNIkO1Im9WRy5m9yW0bPfi66zsYuCoWXxk17ucx', NULL, '37.39.210.2', 'WhatsApp/2.23.20.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMlhNZE93WFpueHJOR1EweEdmZ281YUZLYVRPd21Kc1BpQVB2TVgxQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768589872),
('mys3BWBMhyrWXIW3OUfPoL7ALPTIMfqRPPejLAE2', NULL, '54.162.90.208', 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Trident/4.0)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieFZjQTVTejg3ZkpHNmJueUltWjJUdnh0eWZPaXpEbjlwWmx6ZVJTeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768411741),
('myWGpG0iSdBxHFwzWHUBM88llXRaysFYLhnXxoaO', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVkNibGhaTmVxMFZIODZ5VFVoWGpmUnl0S0pGMDNORUNVS3BvbGFGTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767862200),
('MzbHbqkOUAq7HxyDN37s8pjCRQkVRltInkQTsTrb', NULL, '43.157.147.3', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNlBhNG1IamFkMnU1YzNibkxaWFV5cXVkcG4xOFJkaGN6NXRwaFlFYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768060614),
('N0bpVJWHlORk4uvbygbZ84AlBPuZ9bhqsBRuBM2C', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibnQ3WDhjNkVuRVBYbEU4OWM5UjlueW1DaHZPc0s5RXBIMzMyajJQZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('N4knLsnblJYhXdu2tmPBfKCvG7ohjgaNesaiVmKJ', NULL, '77.175.113.45', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicjZlTmNqWXlIUFpCSjRpV2RFakFwMDZaQXIxeVhpNGRUb0FnVGZQQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767788392),
('n5FzuRMoYX7FpQ1hC0yGoXBQXh1N4UxvB2is5fPn', NULL, '176.88.108.235', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.7.2 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM09DUWJjMjdLYk80RjM3eWpPSE5EQ3p0aW5qM25DQXJ3WkRCQTV0YiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768664578),
('N5urXJAMeOoUi6sj2e3lXS3WaNVn8URade3zPty6', NULL, '34.145.204.214', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ3YzMTFhRWticGVzWGtMeHo4YWFaWEJ0Z21yMTdHWFREZjJuRzBnbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767627723),
('N6FEytrLuCbLdqd5McdQUzvA9L1ieTXaypEQcKhg', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieDRncTFTQ05vNTgyQnNMS1RwU2NKcmhsa1ZQNENOdFFvQnhDT2xUTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767860362),
('N7CATwN4XZamh7NwbqXt0KYGwz6L1j2BW4tsCAqI', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidVhEZ2FtbkxFOUdDbU9xZWwwYzJleTV6b1MzOW9yRmVVN2RYVmdJUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768295790),
('NAqjuxXBoYlBJ17mWj7aNBnte4ruvbW1OyobZBs7', NULL, '209.85.238.66', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQVdJZ1lISWUxS1FFa0VqSDUzdFRJU1daYkRHV04waGRENUpLNkNCNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768370365),
('NB68zzzNSSYvPwP3srBhC3xizrftnUZj9OfYLidE', NULL, '104.168.28.15', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibjV3Q1psSE9pcWU2dzBMZG5kTHZ3VndoVUVrdzBGcGJpQlRhQlpNOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767607323),
('nBa4O0d88Pcc4yjzW6S3vCUHq4De9486fEWRUyPQ', NULL, '43.153.113.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVGRnR1Q5a0ozdHZsT2d4MXNGbEo1SlNKaWl0NG9xY2dQa0JNc2Z2SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767599485),
('Nc1e0XQre0v1ekaMx86ltBxsCVUP8LruHmfyqojs', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSzZFUlY0Q3JSOXk0d01pRVEweDRKTmRJcjdFN1F0cUFSRjNkdENQMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767828797),
('NCdYoqLqY1t4EXrVOma1DBfNCHzyOuaiTGwsg6E4', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieUREV0I3ZUsxeWlGTEhWYVc5WUh3eEJHS1YxcVVLbkdJYVVHdHlBVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768129449),
('nD4wI9EqSA8cZY6htehnPruiYvRJWKvkmavUlEJF', NULL, '43.159.132.207', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRE9ibUZiRXNOcUJFQ2d5Ykp5cFlsYnFza0pVS1FDNTBldVhMa0NHViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768490488),
('NDimsIpZ0Et9PZqf92G4aWSSchbIeb7ncoInYST2', NULL, '18.116.97.22', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMERKdGhOTGZ5Qld6WGxCT0x3UnJlQTh3ZGdNYjhmblQyTXhZZVdqWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625630),
('NEPJql67OlA9KEAMt8RzDicJetftQPCrdcO8zGEz', NULL, '217.182.64.155', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiREx4TVAzTjlzank4MXZ4Z0RhaVZqWXdoR3N0bGJYZ21qZ1pXaklIWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768585017),
('nfQaOPwDHjGyCjO9dZ0l74q90xZzr8RTVA9fdsZL', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjVMMnlEY0EzT1JCUmNFcVdldkZ1N0pyM0pqbHhJQnNObm0xeWpMUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767763780),
('NfVCJxNSUxShA4GgrnZxsulhul3dvDEJwuJRoR20', NULL, '34.247.84.244', 'Mozilla/5.0 (compatible; NetcraftSurveyAgent/1.0; +info@netcraft.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTFpKMlo3WjdGVUQ4SHhoZFBWdXNXTWJoS1RzN0dJdGhTRFRJYWxZNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767806606),
('Ng0GmjPnMU3dtAwPvrQ2Ibnm0MjmZfKqi8lunCDC', NULL, '173.252.95.113', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNWt4VHVLbEJNOFU4SDJ0dW9Xak5FZVR0WjhkQmNGWEk0WmxQb0pKZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567650),
('ng6Dp66PgDV1ao2DNIV5QTCAO2lHWO22aF3KuHtY', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN05mSEQ1Vk9LdVBQNEFLWGFDUmFsbkUxUUtOY0cwNEV5aXBLa3dPaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768735857),
('NgnzYjG8tnYuoOBoD8hr3MiLYDgJlJDBJJI4wsoI', NULL, '195.178.110.132', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWFlYZmtNMlFQdDkxMXV2bXdwUUFweWl6ZnpIMHNYRG1uNUpJbFN0dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767892920),
('nHGBcDJL1bNcSF7dRzSwWo4NBPA7jMSOG2xf4j8e', NULL, '209.85.238.2', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOXJYekUzYnl6aUllRFF0dkIyS3lnV0pXekhyY29CdTE4cmRmdXdvQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768795065),
('NHNyk77NVNJQNv7NP1XLM4e3jQu1pn4BTsLrEz4u', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVWhtODc0R3dMUjJGandTVEd4a1hLQnBrMjNndjI1alVqdDlhQzJCZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768140249),
('nkqTX8HXeeYYDWgc6jAbhlzY0YhLxHY6dztAwmxS', NULL, '172.253.216.49', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaUt2dzZSdFVjRVZvYk9EdlZnVU8yOTFNRDBWaUR0elZKYmoyS1p0WCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767786943),
('NlGcgYOI3Lal2vV1tkV5WlSKnja8m6nGxDiOc3MA', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUEdsRjRMbXpNTDBFOW5PdUFQUWZJWU5uVEVJVWVCaGV3U3l0Q1lsOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768018353),
('NLZQbZwDbSuXmMKcD3JtFlIqzf5rlrw0YisZP9fc', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUjJZV1o1S1U5YmdtWGdLZFkxeWh4VHdteTJkSVRLazJEVjlMcWVkWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjk6Imh0dHBzOi8vZXhwb3phLmFwcC9jYXRlZ29yaWVzIjtzOjU6InJvdXRlIjtzOjE2OiJjYXRlZ29yaWVzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768295803),
('nMs6HoDfdLEBE8vjBygzLtZZamQPj6u5co4XmjEU', NULL, '43.134.141.244', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYUUwZ2NDOXRlMTgwWG41cjl6OUk2SkhrOHB0NTd4aXoxQjBRT3JRMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768667088),
('NnzJAJcXKzmCBkkjVeXhyiMywhf96v7qHAAxIrgt', NULL, '209.85.238.65', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTjJXQnJMVmNaNEtzTnltbU5WRjdVMGdlZERTaUpEbk1udGs5QXRaNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768409119),
('nO5tnqhKMqzJN7EdANlzKXjvkHUUfqcdpA8sh9J6', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMkFBVk9zeFhVWlBTOFpGZ2UzMXJlRzdNcjVkbGtrRnE3RmZPMHB2bCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121876),
('Nqlp342wpn4M1tdn1UMYDQDNb0oKWX6pEkmVcsOE', NULL, '40.77.167.16', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMEt2S2p0R0NLV3d2OFBQM3Jsb1pMZEc4Zno2ZHFYQmRpWkNuMW9WTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768166299),
('nSGKmrOcbZT7liI1MVK8e3DRS6m3FGsQeFtXhkZ0', NULL, '91.221.70.4', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOWhMeHg3NjFjeEtSYUdpZFFSUndNNlFUU2UxSFdpRFJJMm9PMkRXRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768316207),
('nsjUHAsFfLVhfJpxnUJWnvGOUCw4l0PFxOY0Gg9H', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOVRKQWRHS1gyblhDTlZweFhTM3pwT1hYMEV1RjlSUlg0dFRYS3B2YyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768285515),
('NuFolDtCOB1PxHNfTuM53eXvB0kuC2T4rUIDwXPs', NULL, '43.166.136.24', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNDk5eVdDSzQxcGgzQlNwWVhZWnA3aWNGWlVqMFdZeVNHMFhhcGdRQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768560033),
('nwcvQqUohWgriL7Vlt9cDJo9VZje0xDtAfQWMj9d', NULL, '91.221.71.170', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicm1KbXBzeG1ualo1ZWZrU3cyNEFnTXZLRzRrRGh6WFhDUzdGOVRYYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768314198),
('NYrwT04qTwk8IBxc3lvLCEfSJtin8KXFhhOtUpWh', NULL, '5.133.192.94', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiam5mN00zdlhkTEJrOXVzRWJxUk1rNXZKWjJQTHBkSGhBYlJjOGx4ZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767740721),
('Nz6IiQHLr2nXaRRGZKu6teK6p3ML3MyNqlb6JnXt', NULL, '66.249.73.98', 'GoogleOther', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN1c3bzM1Qlh6Zm9ZdUZjVWJqYlhEZ3FmTDdHQ25hUTJuUXB4b1ZqViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625624),
('nZe4OCVBh708d9tEM2uHOKYtN6Gx2zpzPPmFYjqT', NULL, '20.191.45.212', 'DuckDuckBot/1.1; (+http://duckduckgo.com/duckduckbot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOHdqdnVVVTBDSmtKYWFydlpkakJ4V3JJVXAyTHJhdlg3ZWo3N3F5YSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767884842),
('NzGS5Ryht0BbzWHs2dHb5gbxOXpG3U5NUXLQJ99o', NULL, '205.210.31.158', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicEFzZ25OOGZKc1oxclpVSnN1WWZWMGNlRUlrcjhSbUJscU1YTmNGQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768779468),
('NzvmoiWUrmj3BePM4Ev7wl3UcNOeTOhVVS5CrISj', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSW5ST0lrQkVTYlo5SEwyT2pHWkk5U3pUTDgwM24zRE1sRGc3ZVFpMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcyI7czo1OiJyb3V0ZSI7czoxMToiZXhwb3MuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768285453),
('O4gob4PUuJBlXQ1OwhRszOCs5Em84K40GMZtRcZt', NULL, '66.23.227.62', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVZmNHdYV3M2ODVWQUlENm04aTdBanZyNFg5OXpGODMybllKckEweiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768537772),
('o6gpSlGR896B0tE9MRUWcIE9BhtA2lJpJbTNESjv', NULL, '43.154.250.181', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibVl5R0tEODZNZTVZc1hxS2FoSExpWWJWYzBncUFZcEFtSDBpaXNOZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768428844),
('oaclggTkBd6WkpzzGxH1eE0W1UGgBpdcO3uJNpzN', NULL, '192.71.12.112', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNkdPMndqSHR0SmltMkp3M1RQR0FQYTAyd0k2ZkFRQUNSbVFKUXpKbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768400422),
('OayA1aOEBKRaNSWiAWTaik5POEiCdkYTzebV7vhX', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZldlMFJiRTgxWkozZW9CdFF6a3k1WWxyTExiWFV6ekFXR2tpWDQzeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768754204),
('oBA5CUVe1zNzqrmiVSVdFPUOlkYqTSeDOedL0KSu', NULL, '43.130.34.74', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieEF4M2o0b3NlaVJFcE5Jam0xMWgxZ3ZGWENXSFlITTJnd1p2VG1NZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768138673),
('OcaT7xD4Sb7BbqzfhJx261M2oX54VyMpJglreDt8', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWEwNkMzZXlacWlib0VPSWx0NzdLaUJERnE5UThndU1ESWw2TWRrOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767519475),
('oCuoeeeuTNAHlQmEa2cLF2H4oq0PGBwd3EyQJDak', NULL, '35.187.132.227', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoicEZBOUFneE1iakpITFBNM25iSVdEZWlRcHJjRUFncGVlZGF2cVZRYyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625622),
('OdwxCEQFLrmVVbMPWyPWEuaTKom5Oqkmcnmi7Tde', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRGNINXN0Uld5cGdFdlo1Yll1Y28wNmthVWJWSEhIYTJ2WGVKWmJjdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716284),
('Og60yHjgx0jXwmLpBWTvUeELBAUykSwVmBQwvoDR', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVW1JSktYaTN6dEtlbmFJdGxobXBiSkVxakdORmdFcjB0TUtldURKcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768107708),
('OGh0Kw2jIL2QbSwz3EMbP7vdt9YwjHTzSPfMTuE3', NULL, '43.153.76.247', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNzE4bDg5Qlg4NU9sOHNiVFk2NlFtZzNxV2QwNDBUVmVIR0oxTlJFRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768579896),
('OHmoR4avyPkMjlUSNOYUdGweOps6NoosYB9VpYSh', NULL, '34.229.67.133', 'Mozilla/5.0 (Maemo; Linux armv7l; rv:2.0.1) Gecko/20100101 Firefox/4.0.1 Fennec/2.0.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWXk0a3gwc0JwWHlNN3RacmVpeGFQakgxaVFFdzd1REo4akQycVBXVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768758573),
('ohudP00n82eAxYk7SdN6XE5LV5fUP01hXLg2bYj2', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicVpzMzhuVjJBM3RTVHVmR2R0R1E4YktFWGdRRW9QaUY1cUZvUXdrdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767959253),
('OJ1faEf6tDvaSNPvDCu6FnMDhLDwFkRUjojBAwTd', NULL, '47.128.112.114', 'Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; spider-feedback@bytedance.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZEhTSDdqb1VSWTdzM01kVFJVWmhWWEYyOU9QbDRLSjBUaXUzYUE1aCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767924760),
('ojyM5pyjiFRswAGuoEAYnCUvZ7GiEugLjmC2uS6d', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSllybEJhTG1kUGpqa1ozZUlDRTRxdDVzMEhvRlRDWkpHZ2x5N3dqRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767862306),
('OmbYyEwNCYtPEbs3b3vrc7zTrZiTnKNjmv60Bw6g', NULL, '145.239.84.133', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmZwdnpnandObTVnanFVOERucDJhZzA1cGpCSWNsUE1MUnIyeG5zdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767988375),
('ONccNDQFshZmEI1YTIXf2cVpBdLoNWyRQFGylabe', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZFR0VkN3ckxlZVM2YWFiZzEybjJGQkRkbkJobG9rTVR2R2JhM1hUQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767540830),
('OojwKjtJyzcdx1K94iP9tPfF3maJNqOjyntjLWuB', NULL, '173.252.79.114', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYjduTlQxaGNoamhzaVJUM3FObEcxUlBLYzk0ZjN5cjBpMHU1aEJiZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567662),
('opJWemy5GzNsBuUAhUACxEZRFZsJUbu3nau1pmN9', NULL, '43.157.156.190', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaWNDT2hqMnFJWFIyWFNMUjB0WFBKTllzUVhyR0Z5bDU5UnRzYlIxaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768365620),
('opN2k7QZLYKecZ6ynyHCZvYd1gj4nY7docWMbz7L', NULL, '43.159.135.203', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmZvdmpXZzJ3eG5nSGRvbE50Y1lSTzl3eDJOWGphT3dSeUJ4aEppdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768181709),
('oQ89LlgS76bcc7vDZjxXmiTREVye7r1ToHc8DgsM', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidGl0VWxDcHIzWDVXVUkzVEhNS1hkakFkZGphYTNFelE3MDMwRm43USI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768145445),
('oRH0dPCArMs2n5bq6Id82yrwISdMOETMM85CxwJA', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibnA4WGlObDJFUlJyNXRWQUFSNjhqUnVuMEJXTlBwOFo5ZDRxZnpVUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768295799),
('Os0p2xchgvCDRSLg2wQBb903JLjAn2tdzy6CMHRL', NULL, '54.91.83.49', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36 Edg/84.0.522.52', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY25aQ1JkTHhXUmNmTGpSblVoV3o2MEhvWWxmWVlUVTdoNjMyVE95VCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768245516),
('oSkoX4gB4u1nNPvkCE3JW7Tf3cmkj8SeJQ3nvtHr', NULL, '93.158.90.161', 'Mozilla/5.0 (Linux; U; Android 13; sk-sk; Xiaomi 11T Pro Build/TKQ1.220829.002) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/112.0.5615.136 Mobile Safari/537.36 XiaoMi/MiuiBrowser/14.4.0-g', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0RTVURhbFJWY213d1NjQ0Qzd3AxZjNmWnkwQUdSUURoRG11S0NxQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767975942),
('OtnUCEGmceu7XCT5H19XQGFLrFXtWRFrEKXSi01y', NULL, '66.249.73.100', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR1RVUUV2Z3NZS2JkV0hSdk14S1ZFbzJlaDlGWW5MY3pwRXRubU04WSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767532828),
('oWX6VgtiUhLnszDrv6UNipUIENSQNm2rDi0wGeOj', NULL, '66.249.73.98', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7499.169 Mobile Safari/537.36 (compatible; GoogleOther)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidjJyemxZQUtwVmZFRFpvVXNORXVLT0F5czF0RkJtZ1U5RTVIbDlOWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767840966),
('oxBK8eHKTOBO0VCt9vDVXPtmxwxTsWJDxCF4fy2R', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicjRobDdxTkRCVXlaS3h1YzlHVUF6OTNDOHU0Yjd4eUVGalNCeG5CdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('OYHbP4CXbn4d4Q0VmaJlL58lvVMiHBbIZYk8MLC7', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicm9XU1hxVG1QT0I3Ym9Rek5oenZoRW1BNDZCUkR0N215QjJhZ1IwWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768521262);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('OZ8EzgUkNF6P7I7I5ZOeWyNp7Cv7bOwMXqdTjpmF', NULL, '109.172.93.45', 'Mozilla/5.0 (X11; Linux x86_64) Chrome/19.0.1084.9 Safari/536.5', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS1Y1b3dIcFlsY08xNWxXU3R1U2txdFpmd2lnQzliNGtheHE2aTFqNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768560656),
('p1MzZK5XuO6emj30SZ4nmC4VpBhOycoPSyN4Ib78', NULL, '31.13.115.13', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMGttU0tzTDFOeFFUSnRNcnZ3NExyVjNLRmxFd2d5S2Q0WWhPbDBqOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768514276),
('P3K1GcsqcLQHYn0PwpmVb1ofCattFG6DSoW6eKIF', NULL, '4.194.99.179', 'Mozilla/5.0 (Linux; Android 11; CPH2251) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTEIxMG1VRWhkZW9seFA4WldyV1FoZm5MRkNoeFc3ODlGRFBuYXhvMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768185138),
('p3Q81AzkVsg455TcOqrXsZpQYGoBJYkHxQ9krJp1', NULL, '182.42.110.255', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGdEcGlLdVNjNWlzdnl4cXpZMUR0THoySVlneFBTWnVVSjFQMG1XRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767826024),
('p89KeRlHzuZoQCFCVtdhTxekomJwAK4mKE3SlyAZ', NULL, '170.106.179.68', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicTVBbUFUY1NZQjV0RjNwREp0b0dwellJUklNeDU5QXlER2IyRUVJTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768323615),
('p9vBOBIZAUFw5KrfOTe1GxVgY9vo41vezdbZeWgG', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWU0MzFJZkZmOEs2ZnhvOUtiMzZ3bHdLejBUSUhvZGlTTHR2Qnp0TCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767981548),
('pai8a2t0aAK3zeVYUIszZ0uuOYOUuQrfNgsLALxx', NULL, '43.153.96.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGxuT1BiT1pTcXJyeDZBa1BaZjFYb1RNSE5ZN2d0QWFHZERpY1kzVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768786768),
('PBL6BNjCFBoUwlzfNr2AIMjUGKZD5EFSNJNkNCsv', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZVNPTk9va0lGQndZbE5yb0hrZmRkWFR2amFzVUNhTzBISVdRRHZTNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716281),
('PCxPdp3Asjjv4P4lJKsiGxSIOC1J07WnPpObdUmS', NULL, '173.252.79.5', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUGxOUG5IaURPSHEzd0RmMnV0VkNYa2VtRzR5bjFFNUZ0NUdXRHN0diI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567669),
('pesKBprZZyzCYVK2Xm90Pq5HOrsJ3mYc4pkhhLof', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTNCM1B2bElBcVdDVjg1dnU4Tnp6MVVPYlFYNWxCMURsV1UzN25zaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768233994),
('PG3UVOXgojSo8vImgMsM5DidJIyP2MVJ7a8ho3Yo', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMnJWeUx2VDNuQUZHdUVadWRBQ0V6OVJHR2J2Mm5TQVM5WVZoV0ZuTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('pGkVt8PnwZiZ1WjEtG2afMw00sJzvUlpp7u9Cgx1', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGRya0FNZG1KWjZFY2tMZzBzVnU1ZXpyZHI4RkJRcWNSZU44ZmRQeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768795102),
('Pgp3i53ZMaubrNcNrFV4sjdk0oTRZfwYHAlEj4gx', NULL, '46.101.9.216', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHRQa3FGNWwxdzlnVnFLZGY5RFI4QnRFbURCbUxmODBMc2tjZHRWUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767994807),
('PhPphBBUrlHuBPlSbK7JGGXEo6m41fxjJrCudPLK', NULL, '43.135.115.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTHpzNlhYY0F0cE1YSnFWUjA1Nm9pcTlxcHpWbW5saHRZNGRVOU11bCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768385748),
('phVCSGyeE5i5m2kuqXUH5NgiWsvG8NNSfDIX1MtK', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic05FTm5LZGNEanpOV3FEdEg2QlhaRTJLN3ZoWWtkT0pVUXBFNlhCZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC91c2VycyI7czo1OiJyb3V0ZSI7czoxMToidXNlcnMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768283492),
('pJQNputJ4Am44KNmZ6lal0zqgLr8CMO8WPkwedM8', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGt5RGtRUUpwclVNS2VLVHVNQ2g5SFozcW1yT2ZKeXFQYjhxR25hZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767782926),
('pnCRixlBwZad7YIjULeNPea0HWmD2GqZWqW9xRFw', NULL, '192.36.109.214', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUnJrM1A0UnFKVnJwOWd2QXFSb2VyWGpWMXdqUk80SnNFYTFESFprSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767647602),
('pndltLKTCfKdFtZO89IFDqTlBS5FYwaZBB5zqKIJ', NULL, '209.85.238.3', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3h2WHRBWVBCeFZ3QW91VEl0WDQyVG9VUHdnS1I0Y1ZNM1FsdENYeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768536187),
('pNqQhuhIrtl7cObJ3jON1HwQeNd1fGNHwfC8Vjoy', NULL, '43.159.132.207', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN2k4OG5QeGN2MnZHMDlpMWZvVWVOQnQ4dm5OM1pEVG5CNEo3dktQRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768490486),
('PNR1heC5V3CSsrCxOiwYSjU1K7UOwHVIjj6jIpco', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQmt0N3JZR1Rwb3pMMm1lOWswNUFnVmtmU1Zsd2dYMXNPNjRPVWxXTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768729527),
('pNVEw9z4FIpHVYeUPk3JdWUJYPPmMxotf1nYVclb', NULL, '173.239.217.46', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ09xSm1UdFd5enBYVFVzUjQxSFd2d2J4MzFFSDZRV3JCMGlYTmxEUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767511392),
('POAzA2mYdOYlWJ9KfDVVIqCzP6BWCf7iDDf1scEj', NULL, '93.158.90.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Viewer/99.9.8853.8', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS3N2NGhWVFVmWm9kdmtsYTBpaGU0VmpyRzNodFh4VXRzMXFqZkgwayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768729018),
('PoKxB6LIF4lG1RwTk244oYyPwm7FvbdpWsTINWSf', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN0JJc2dOWlNQalpyaVlrUk42alc2S0E0TjZadkl0dXlRZGdnR0hxSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121873),
('PPlMZBOdvvvXGiuuS7FBp3F5kNsxbDg3noUjCury', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid1AyYWhOUklwZHMzdDBUa3pUV2JseTgxN2dpa0ZXVkRWTElNenY1ZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767625435),
('pQ4E6iPS45eJWVR6HBvpvX5sNzcUeK6KYsmyVJu2', NULL, '104.168.28.15', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTV4OFBXeFBvV2RkME5URGtST3RBb01meEg5WlU4TXk4OXlpOEdpOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767607323),
('pSPM3ZVkF79OEIiPeh3eEVTPfKokatvmnM8NNqnq', NULL, '43.165.189.206', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOEZGWERDeVJjeDhUYVRPZ056b0c4WkdPTUZ1N2o4VUtoblp3NHYwayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767754448),
('PTeqhu1zJyfNVYqPqNHTgyhzT9SceFBxwhKo6Dur', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiako2dzNXMVVuWmdTWWs5eWFSU1Z2T3RmcTV6RVp0b3JZWHY4bjZzMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768317901),
('pTk3PV8XRRYf3fydIpDbBgRkp9AhEsj88ba3jR3G', NULL, '135.148.195.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/114.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYTRBaU1Hanhnb3pDVEY5aEFIaGx1UGNqMWxkcWcyc0hwVEFRQzRocSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768037389),
('PxeochHn0tV98kXG9NYOYe2H50xAkm2bvz6J32L1', NULL, '66.249.65.161', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2N3S3JpR1IyRlV0NHQ1dmR4bWhTblBZVjdhcXZNOHNiWUtQdHFXWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768401909),
('PXJMXGIwBbEom12ycpk3mts5C8CyPGTx84ogzP35', NULL, '49.51.52.250', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMUNwOXZURlVicVBIT25qTEdEa3dZU3E3QmptVUJFdWVoZmlXNVhnMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768089396),
('PxQATCQqIWw0ws7NRboY3cASysjkjK8vy21kAlJy', NULL, '111.172.249.49', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTW41NlFCRm5oSDhTc1dBcG05ZFN5UUladmlpbmF0WDhvSnBJRU43SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768012257),
('Q7BleQAuiqnyawmU8Lv0I8eEwzU0eMi3I3FbzOrp', NULL, '18.185.96.60', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmkzTEhGYTBrZmNVUzFaVk95bWNpeEhpQVMycDZUM1lTak5xZk1icSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768433281),
('Q7tM5NpsIGs49t8rIuwUPE9Zl724my6rYNfaWPbk', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN0pCU3R0NG5hYVZKZVI1RVJwZWUyTnRFOVBTQlltVG5yQjFFUGZ0VyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767714632),
('qcEnSE2wXF2SUhJmVcu739xW9Itpjp9yuv38j5iP', NULL, '100.31.89.111', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.13+ (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibERLRWhsdlRORENxbkx6UjZhbGJKTmJYWDhXRGMxcUdxTmdvSTlzWCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768586897),
('qCMr8mYDANQ5AK5lAFuosUsvzmSKkgsb2qb6PaJ5', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY2p3cjhEUHZ6dVNIdzlibHFQUnJSZDRYMVFSc3lsZktscVRGQjV2TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716280),
('qdfcTk2FPxV17dRASxX7KtnBDHNy5JjzG8BxzwiF', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaGl4TDFSaXdhSUdmUVNueElnQlozaTNBdGxaa3k3ZlVCd0NlRmQyYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768239639),
('qG9C60teSPvgOng29LIAgJyTagAMjwqTqL9bp0q5', NULL, '151.80.144.77', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMDdOTVZvcjFoV3IzYndlNTNlNk5OMWE4dU53SkxGQ3F5VW85VnNjdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767692134),
('QGaqVaTVThVTIyZG4ehzrbs81FIszSaPnMrUbCFr', NULL, '173.252.79.7', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWmRCRjlpek5JdmFtVWRmQVBVZzQxRHIxUWgwb1JSbTdGNnhDOVBNcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768567671),
('qItNrpMvI4i13uVxWmPTN1hkJhFh6EhbboIlNoCB', NULL, '45.94.31.42', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVzdMWVRaMFdoVGFkZm5Ic0pWa0xxV3BzRzFCNjhIYmNVYlNSa3R3RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767523480),
('qm79rxVkahERydi54OJL7zB96ytAcMfSOSXD0otw', NULL, '98.81.205.141', 'Mozilla/5.0 (compatible; Exabot/3.0;  http://www.exabot.com/go/robot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUlpxNWw4R2E3TVlodFdQd1VmcWZ2d0tPNXREY09IYkZTazBiUFZSMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768056376),
('qMXcArd0KyL1cKnsuuiEg51Jst6TnUOUrD9l4Ioe', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWhTb0p0eDAweHI4TW1KM0lHVGdzaTF5UmZQcVJOS1JBUVZKZ1p2RCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767605119),
('qNITHxp8aeLpQmX4neQzpxuTcLcsPFKy5CZwJ0ss', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVByYzdpOGFjVGtQald0b0hwejhuVEtYeDZUSEJudmRUZlQ2RFF3byI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768317903),
('qQeE5ENSCgbVLPEzARmvv0UmCfztdJWiG8QKTaYG', NULL, '185.213.154.220', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR2dzZjJLbnZ2ak91SUc0UlBJTUZYMlRROGhpM3puQkN0ZXhwVVFieCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767795597),
('qRJoUuhfcvVFblTTP53MHWyeouwyFAyYCJ4aSPYA', NULL, '66.228.45.123', 'Mozilla/5.0 (compatible; SaaSBrowserBot/1.0; +https://saasbrowser.com/bot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQWtFTGlCMFk2UTlnejhKRmQxTUZFcXYwYW41NmR0bk9IT3NlQnJuVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768629750),
('QrZqFZPjWcnAYGUiWeMuyHjWeiqxzwVClPkaczHZ', NULL, '34.239.119.53', 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.5; en-US; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHRDaFhzWkcyR3ZEa0JqaG1ja3dSV25WSUNPdklqeE9HRFpxZmxhdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767717677),
('Qs0yPg67ouq7hVUC7MIjZDGSSEQ10AaNQDHy1Jmr', NULL, '172.253.216.60', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVBGa2tQeG9YVXNzQzV5VGg2T1FIZ1UxdTdWM3hqNFhkRjVLUmlXSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768466397),
('qsbzXhXd3aReZfEnmXqgKru6wlhCiYaRzJ1ODkZ0', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVWJoYWMwSG9KU0kyTkJ0TTk0SXdpSHZvRzZFSzV1cllna1V1U0owaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768043345),
('qSrkib9CjpiuXaKQ6FmLndbBV1hqnHJOHDru0qhL', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWGlDZFZZTW9rWEt6RWphR0prZHJTN2VJVzdFR2g5QmN4blJMYlE2cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768306832),
('qTobEzoMyzy40icoYgPF9PiwTCbUBBd3o53YmuFg', NULL, '123.187.240.242', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY2tPakc1QmcxS2M2ZXIyM0pZbVhuNmhUNWk2RnFtMGo3bzFFVUtGMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768058581),
('QtqNEOvivjzqL0DiIPn53nnG88GyA7oMULPAA70E', NULL, '66.249.73.131', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQjMzMWhXdXJXT3JkY0NtMFh2V3VhMXRSbUlhcUhsNDl0NjNBSzRyVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768593491),
('qUDxeHE87vsQE3NhSIcbEZngNHdv2lXlKmFpkDFa', NULL, '54.173.22.58', 'Mozilla/5.0 (compatible; archive.org_bot; Wayback Machine Live Record; +http://archive.org/details/archive.org_bot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaDhwZVNQOEpWYlhyUkhDcUxxd3M3TEpQZFFtdm5YeDdCYXhZWjIzSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767891402),
('QvaNbDbRmEOuHuGtTtNOPq5lnXxxRSLcA4B55wed', NULL, '101.33.81.73', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWw0NVIyTzY4VWlQRFZ6MWpkeDZSdFp1U0RPSVZxeU9ucnV1ZVJ5eiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767532628),
('qvSUpXW4e5StD0z6YVgZMSgY5vRKcO0MVkMQomba', NULL, '54.196.169.29', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/138.0.7204.23 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMUk1MmVGSHVQR3VPWG5FaU5RYVNGTzFUTmZNRVhYZzd0UWJXQUNxaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768735997),
('QwytwfSMJeuxwJhxg6iytCpJvIbEhNBIlX949bTC', NULL, '198.235.24.54', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNWhoY1VCeXhHbWtjb0gxeWpsMFI1Tmx3MHBJNW9mdVNRNHpGWFZzciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768804062),
('qxGZ1Nn6siGKaGa8SvQsgWUijrPONdo23iXXibU1', NULL, '2.58.56.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicXhnZE5JOVhMUEhBWXRDMEl2SDZsMUxnOHZXU0I5Z3lZOTl4RlRyaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768092127),
('Qxqq26EnPNV1BywG3kl3JyVc5vM71b1tjSUF8mw2', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQm9ISkhKVXFwZnZHM2E2b1QwSXlUMVZTU0hSMlk2OEtiWWFBM1IyUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768018396),
('qXXGjCUmIhhEOMwaEXjL7Vps8BRkDSJnZjO85NIb', NULL, '47.82.11.94', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUHFDekx5RXU0RnhSWEtNZlVFbWVJQjhFb0Y4UlVxUVlrd0l2em5wRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768751796),
('QzBDpGTITD6m3TzRhwpPTROocns3NXVvCvb5bxXd', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ1Y0OTBsM3I3eVpvbVVDVUNJMFV6S1VxUjJOdVRFWW9Td1lXZzRWeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzI6Imh0dHBzOi8vZXhwb3phLmFwcC9zdWJzY3JpcHRpb25zIjtzOjU6InJvdXRlIjtzOjE5OiJzdWJzY3JpcHRpb25zLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768287599),
('r4jduRDtRCtQCmyQNkR6dtlQVZMsFevBhHhKgLUl', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRFc2Zk9SR1BZMjVQb3g0OERITkJoSDlWY0MwNmNIeHZLc2F4MXl6cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767517779),
('r5c3VviiyfIxEn0aRCf8zJzzf3MsVrcpsnJUVhHr', NULL, '35.239.132.228', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaTJNcUlRWnRjQlpPS0xGaHlyVmRDREpnNE1LTTZCemxwMTFPTEp0SSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767604088),
('RahHdvOnapSCgJrfD430mqNpwDnW7sz2OdHzW7cI', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidGF5dGY2U1JKbFVhS0ZBNENSM1hZVURTS0pLa0J2UHM3b2tYVGFacyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767951924),
('RAr9vQt4ri5jCgaStpXjDW36OYdI10S1jgmYwQVu', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM0g4OXAyRFBTSmRBR2RMdDFnT1VUcHpMb0tYbzlGeGRoT1FIU2ZHOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768285452),
('RaUDdgHbChppMGHASkaPrC5RV6s19edniubazXwY', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibm5uYUhCQ3dFdlVSY1ZpYjVhZEVyS2dEOFczTzRnNDFEcWI4a29LSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767523947),
('rddd9XSBob4NRZjc1yd4TwRK9ghn1rgkbxX2c4ZW', NULL, '43.166.244.251', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTnQyNVhNMnJranp3bTZFdjdDZnFueU1rQVM4eE9NcVJ6UDBqdHpveCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767952690),
('rEwG7BmxX0d6ibNJ91HZYKWWktAJxtbief5jrF4t', NULL, '199.244.88.229', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicjdjSUUwdVZLalN1V0dSbFByUVpIVFZRcDFka1Z2bm1EUzlyeXpadiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767865282),
('RFA4uUqJrVH4kzaoq8BGRIkzrwM5g0tWZP8ItEPN', NULL, '43.153.102.138', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2w4UThiZzJyMDB3Q1NqRzQ5SDFSZGhLanA0Zm5yS1YxNkd4MVpXSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768405888),
('RFQ2SKTKMJ39ZhBXqnltdY14vCBJvetR31CpLUFu', NULL, '170.106.180.153', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiblpETU9iQmR0UHBTZmF0bGVRVm0xbFYzczVGcEduSElJTDNNT094WiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767862999),
('RGAHxWZorKQqCjOkgrdtSOyIwa8vpuo94UbTI0yt', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidkh3M3YwV0htYzFBeVY4TkhoUTFPeU1yUHJWenMxdFJvaWxOYlBHaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768558344),
('rk9TTPEoXJR3zTuwHl5odfUXdCrObOgCItVBzhMz', NULL, '195.24.236.147', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicElaVFI4NFdEbUpVdTZKaXpKZWg1NzBkcjdzVEltZXBGUWRLUnBLSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767639164),
('RlLwS1TfD1hUkhC8Rw0d8JYI6A2siMiArlhRSMq3', NULL, '3.129.57.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmVqU1NhOWZWekp4R2dZa0NQTEVNdmdFUW52clV0N00zS0lGWFdldSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625630),
('RlZGgbTbxXbemcyGrXazOzOx8V38nleyM5iAlrxO', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib25aWDZ0T1E0azJZOU9YMWt4RklpcERhTlNRYmhGVkdQWDBIRTBadiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjk6Imh0dHBzOi8vZXhwb3phLmFwcC9jYXRlZ29yaWVzIjtzOjU6InJvdXRlIjtzOjE2OiJjYXRlZ29yaWVzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768285520),
('RMRcb9j8XUSrcNDBT2VGX8LXxsfOXIa2IcwPiiY0', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZkQzQWl5WE5yODVKUXZyTjJnS1VwQjVEbGxWRUxSZ2FhaVZNYTF3NCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768557287),
('RNzl7m37fxw36mnVfSK4B1E3Du91PScVS0fHblgx', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVW11Ym5oN21wdVpUeXVXNk5rNW8zNHRHSE5uMXJiVUpXbThiVXI4YyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767974818),
('RPLsjjI0rkGTP2FBCsC9RtfsxsQEvNHLjV9wKTOh', NULL, '43.153.113.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid0JvbkxQM0J1cXBYRlFhVWkyNHJwWFE5YnJhQlBXc1prZktMVkp4RCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625951),
('rPntz2Xx757hbBxC9zHMEz5LQ2V4EMevFWyCR0Pk', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTDQ4bnBiUzNGWUxTcTg2Z0lKemVHWFZYdkNrWUZSNW9kcGgyYUt1aiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716280),
('rtm5MkEPUZ4b85oqRrWLKhQ8BrG62gZ6TfhjGe9f', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVmJQdXB4NVRIak5RNTI5NWVxY282aEc2UEFnSnp0T2JmaENRVEluNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768286915),
('rTN4esHMt8JOC0iLy1zOMjqhRQ6dQ39rB55rI12S', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibk1TcTlVdDNUN1ZGSmg0Z0tuSDJtRlZDaXZRdFo5Vmt5RWNSQVdiUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767759554),
('RU1zAOgKszbhsN3pp70IxhzqSn9IdN3RQPGhUT9n', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiamY0eWlaS3lWQWlhRzBNSjhaWjRuR2MycngwZzNCazNUelNmWVhaYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768756453),
('rW2i4O02LUwH8YQNpGsPTsgpdCituEc7AbVSou4Q', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHBJSTJ0bklLUWxMNlpDeVFMa0RVdW9aeHdXRHZLbXBVVllhMWNEZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767824437),
('rYrMK0FQ2EGVkGGVU0y0qcYctwCZWZmY3UkXcCCt', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOElvZk4xd1Y1c2k4bkRvS1dGWXRscms0YTBTbzVNdWdwc1RkUzdpNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('RZ5wvByvVmOoyBh34bOApvY5rMXjkjHf3Cms9aTp', NULL, '136.117.102.41', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4240.193 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibHFoZzBGUlNRN0htNzlqYzRFdzZuNGM2Q08zbzR1VjU1VkJNeDVPRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767631063),
('rzTiRkl5tPN6WqKtuaNiIekuic2o3EWUvEV47jcg', NULL, '66.249.73.130', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ2pJeWdiUVdwMFpKcEdwU2tqT2hFTTZDMnE1bHVQcmtINTJ4VDI4dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768472788),
('S11ByR1TYfy5MlWIYWUdhu6WNXll7n3yY0sgEUW3', NULL, '35.226.219.149', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4240.193 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieGpjWmJzc2VyNVdacWxwd1czY0ViQkhFRE5IWGdYQnh3UkRHQWo5biI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768379364),
('s4ovbODjqqizVmSSffTMozBYMUNeMoIAjODDd6Sw', NULL, '18.97.9.99', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; PerplexityBot/1.0; +https://perplexity.ai/perplexitybot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibThvdDNKSlFwU0xhOU1pbDZWYWhnc1RCRWdGcmdFWDQ0UURjQnRYbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768517356),
('s6Rj57wG99nWjVXNGCPa3d596nk6A5WsoKviC3Xo', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMDlXR2ZOZGhlNG53bVdyaFVvTjlYZmtocmJqMmZtR3JVRG81SWYzOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768189942),
('s6WFwhR3CcwmEez4Lc4RLodmkMkD8a4fbXxx5xs2', NULL, '43.166.253.94', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSU42Y3dab2Q3WnJjTU5oSEp0QzZhN3NpWmZDZ0ExMWVVQUFvaVBVTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767819192),
('S9X5IPYe3qIErKh9mdzxsSMHYkDhBSJUOVQf8EwV', NULL, '34.6.181.13', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1ZJc0tXSWJLTWtheVRpRVk1UVRuY2M1OXhzZlFXZjFrbWVna252QyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767891722),
('sABIVnvArljq3yGnDO4dAiGcfFb89BRqcfMBM7Hy', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0RGZmp2NlREc1JaT1VrQlBZT1pWc05iY0FBbll5VVhMSTBjTzVLYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcmVnaXN0ZXIiO3M6NToicm91dGUiO3M6MTU6InZlbmRvci5yZWdpc3RlciI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121890),
('SchsnJrNRQnvMUtaxJZlirjpatUvKRxCKHL88Ixp', NULL, '93.158.91.251', 'Mozilla/5.0 (X11; CrOS x86_64 14541.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibE9PY2FqcW52OHRuU1phWldqMnR1dnppeURQTTJ3Wk5peFdqTHJ4TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767732023),
('SeBfR7rbu8pMXsmZXRi0CAvk6e1NcuBFG3Ks8fFQ', NULL, '119.249.100.52', 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiemw1Nk1qRUdRc01mQlNTVm9qVDV0eHZBYTdzUTZNcVV5eUlrNktlUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768244659),
('SEM8Y2Tbd1l28rRLWmYDj21jPYhJ1JRQCrBDnJQT', NULL, '34.23.140.116', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRlozdzhHSGRmaE1zOXBvVlJ6MUtBWjkxMUJZVE5GbVZONHhBalJ3TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767633803),
('sErnIGwwmME8Ut05WaKzSjj1rjhGux7Mf8fONjil', NULL, '43.153.76.247', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoielZSZzhUTEQyMWFXejQ5Y3gxR2FNRzZvNjR3UXBJWUNad2JZalowRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768579894),
('SEuFJycHRPInCOj6khUtbq7Fl2wwyYboXpt2B1ER', NULL, '43.159.128.247', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVBzS0U2cEFWM0tnV0hvcVd1TGlWUGhPMEc0ak9wOXJ6OGNrNUFGeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo4TUFNSFlxWDUzN1FnbXQ5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768470894),
('sGs1UwfccPoYmrkjc6Z6LPJD9XRx9aimBQsKtpyi', NULL, '104.252.191.31', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWFuOWZrb3VoTlNhcm5DZVlaS2hFcDRuQUV0SjhPM0RjdUdEZVl5SSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767511375),
('sHfy8kSsQIpPy3BQMAjOEdzFujWpxhZ0uSAgCG5y', NULL, '157.173.122.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1ZnTUZvZlZYZldIbTAwUGp2TUxSb1FXNjhpZm1zR29XTTV1YXFUYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767791148),
('SKbDX5NznAw7uQXBLdJhw0trquwXxgocsOynaegv', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibWZZSWtWN3ZtWW9YcmJ0OFpTZjZ5SkdlNUVVc3pqeldHaU1oQnFmTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768475378),
('smLGGzRUigDBjzWHLRLKRRjhkPGpduqHncMsVByl', NULL, '66.249.73.130', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUERxaEVKRUJ0b09rUXdsY2g1N2pwdEx0WFAxQWxZaDBYbVJKRFlWYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768780633),
('SnSszhI1Wowv0iHhu5DxshkgkUsTJID4jWYHMvmn', NULL, '49.234.10.105', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4021.2 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVlFZOVJkZ2pPOW1MQ1UxU0RjeVFxYVJ6RGJGbUwzVTVFVlA5eTYxRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768272742),
('soHjcsEgazF5cCeepi6VZywFcCOAa9QmfegDFl0o', NULL, '66.228.45.123', 'Mozilla/5.0 (compatible; SaaSBrowserBot/1.0; +https://saasbrowser.com/bot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmtXcjhxR3ZuUUN1TWZrTElSYzYwVGZhUmNMTExFekZtQmVsUTRZNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768629749),
('sPIji3MDT2vBDveYDkLkhb2ALkBPMRGYibKLSU1p', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUHVxaHFETTliTnRhcTFGSUIxNkxscnl0bWNLek83WXBKdk9sRlJ4TyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768638186),
('Sr9DI5L1xoZbrNMMqhDOG90mBrrGPCWVWexWJQhd', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiclJ3SHc2OGE5WW41bTA4blhDdXFvODZ6Q0cyNndMWVVCeHBuc2haYiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283307),
('SrzQASX50E275LcGOFBEjJ5qzCynjmOw4Sy5kca3', NULL, '209.85.238.3', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV0hLMGplUEhaT3JQbFNSR01CamY2OE5kbkFTN0J1S2JrbzZ1NGhBNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768754294),
('sTW8aG0Vm87JFYSP9rUX6cjkIlkL3Pain8Bi9Bdh', NULL, '36.111.67.189', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSGJMMVlXYk5KdkZSUXd4UEJ0cGZIMTdWaEZFblgxRkkzMHZqS1R6ZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768150417),
('sUayAuTgdCWqBzs9tOmHYk5E5oSpOax9maC6BQW2', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSkt2TE9rMldrR3dhYnlxcnNJRE53RW9PTE9BOEd5VGhmTVVDNDR3MSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767981543),
('sV8NW3K7l7yigb9CntLBKIXEXsgfC4xJv9EGVtN8', NULL, '182.42.111.213', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOEFvNllZVDNINUxSUG5TNGtaZ0hodm8yWHdhcUd5UEJJd2o1R1FUWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767639438),
('sVGgLNdR2JEWxN7azuVPeyuC3YiKrn50f0qhc5m1', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoielpiZzNkMkFJdFl6eXpEVkdRVUpFRmM5Y2k0S3dyNkR2SVl2MmxvRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjg6Imh0dHBzOi8vZXhwb3phLmFwcC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768471414),
('SvM1LDyFoGfeTfyJbz8609PxyKRkrWIOvxqCMgiT', NULL, '43.159.135.203', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVmplZ0dSU1VOc1U4TkdnaGZvOVY5bnowV3NxcUtOUUJTSHd1QmM4bSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768181708);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('SVmYljZnQsdwrxnYf3lUlYhYvTpUlCRbhyjvNnYn', NULL, '43.155.140.157', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSXhrZUhISGJpUmZZWmlGZmExeDUxemhsb1RSRHE4NERIUjk3cFRDMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767554976),
('Swx57pXamHWA8Xej238YQ84FqXzJce9ShnwfN36S', NULL, '43.157.179.227', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMlBQb2t1QU1Kejg2N0VuVFBtaGg1OFNFWEVIOHpMbk1LdENJcWhTUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768159836),
('SxzzapsaVSRKnIuCWv2gJv9fjJcl8D6czhqU4qjV', NULL, '100.31.89.111', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1 Camino/2.2.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV0tmWllWYUZNSk8zM281VU9GcDhPc3d4bGF1ejhoRndkNk9pWHlGNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768586897),
('syrNwMcjUc76uwMuLhPAkFhGU6XUpmvpfguD9fcv', NULL, '173.252.95.20', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQk5KUWxSVnZBTmsxYW1iaWZLZXRDeTNtY25GcXRod3lBWHpIOXJ1YSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567653),
('Sz7ylBmpVEI0fFfdyqCCIrAgRgneeAfdpZ8hPDYh', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY0EzS2pmbEJLSEg0SWd3Wk40YjdUa2YwUEFFeUdKdU5TWGhaOG80RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767995798),
('sZIkcwKGUYla1ZoPTaraW9rtWoB6CTN3jfWSXon2', NULL, '66.249.73.99', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibzNwRDNza3ppRFVoOFpEazJOMGlvVUl4QUNteGxINXEzS1hJMWhhRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767581128),
('sZZqtno7y6Afcwomi7ZkZsEo2PmTTXiT4PErIBHs', NULL, '162.142.125.121', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYnF3QTFybUJjMHpPdDh1dUNhTnRYaVJuRjBWUUNPdklRU3RDMHdJSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767743768),
('T11JK0okhpxipqKeet0DYXJnk1XzZc1oW5SOpHQS', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSDZ6TlVaSTdvUFlHYnRxWHh4a2paMVpqd3Nhempra1ZvZlhkNzhwMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767517780),
('t7j0Pa6tCPzp13xF0Zop72Gpsym3FGJ66lTNmZd5', NULL, '54.173.22.58', 'Mozilla/5.0 (Linux; Android 12; SM-F926B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibFhrVmxudWNQbkxXU0NUY2t4N254TU40TzRkd1IwbWszRlpKZkYxZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767891401),
('taAU28hop3mlBX8kweahQoyZLdpPMK4p0AE3Yvra', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYWozNTBMcjZlelhRSnQyaXNjNGxzZDJudTVOTkhXZzBXRVBiY0o1SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('TAI20kITP9LRFYLwlFigEiAI7L9TmCn8mlN0ctn4', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicHA4c1hoazVvYW5OMll3TTZIWFhLVmFRNHh2MEU4eEEzdVZMcVlFbiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('tbfTxQI5T8SHJIemxLnDmmuLAK1ICqjA76rGqanB', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1B2VG5aZVZCczlUVjRRVWR0U3U5eG1tSTdCR2NHbHhHV2xINTdtZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768287729),
('TEe7Z3zZTdJ0VoAbPoM7DFzEEuKD8TGypQrqGNqj', NULL, '43.135.134.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzJ1aHFVVDRUR2lyQ0tHSkRKS2w5ZlNheFNQV2F3dXhBUUMzTEFGYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768621069),
('teGfS4w4OVfpyrCtTKTgv1Zw28F7Um0mb6GIu5cB', NULL, '182.42.105.85', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMkhXcVdzbmdvaWtDblBBN2FTQnY5N1hkaDFpWk9mZnhJeDlxclFsdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768378594),
('tFFYwmYVkZoPa62bIJl9ZD1kRRhWnNANydXAVvNS', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU083WnJwT0hzMEM4SlYxRFI5TDEzT2FmY1ZXZ25pWnpreVByRUVSMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767976467),
('TgedGWbw2ByawBxRXIe3O2uZA5aKoGNyJ4FCyCMd', NULL, '3.140.182.19', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidFI3cnk3SDBuV2JiZjcxSWdTWWdZVWNSaDhqV1Q4aks0dVZRMk0zUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767626384),
('TgEVm4cFXF5iR2Bab8LOOoyHj5Gyhme8VaMBMPtx', NULL, '93.158.91.244', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1.2 Mobile/15E148 Safari/604', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZTRvZ2lSeWpET25Bd25jVEVwVjRJVGVtSWxMN0ZQMWY4TE1QVXpodyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768176392),
('TIbpLgoRKEjEl46nIObz0Rv4KtkAwjJaWgEfPGTd', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicWtLdDBheEJBR3Y1WTRtdHNmTHFGSjV0VEU0Z0ttZmY3YzVOMW1NMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716280),
('Tj9FrZfv8G3QEqmNLRoZfm0Bdp4siVrfb8jpbAg3', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlFQVnB2MUhIemRXWTNSREc0WHVCUFBhNXpYS3dEd2xEem1uMmlzciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767586784),
('tNBUDud9aTA5vjqwNiYZiZxl0zzsmOP92ut9LhSn', NULL, '100.24.208.151', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYmM3eWJwajQwZnFDblNIUVE1aDZaN1hZTzdualRtMHZqek1lUGVrNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768168583),
('TozsHfcdtJxEGbbymS7uyExtqjcj9YvM6WVQzp7x', NULL, '43.153.113.127', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMjkxQlBzQVVFRlZ2UGlIeVdNejVTM0g1Yk1YYTZ2Q25GSlJScGlYNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625950),
('tpIN0BAUEFs0nduEEzIuZLg6nTk4OpnqXWJ9R6xz', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWTdnazlxSVFtRGtGa09oUURaM0tORXdzS3RQTjd6Sm5keW1STlRSTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768145444),
('TPj4eTknHZISiaDTi5SgjelIBQHAEtGVDkdZHij2', NULL, '173.252.79.114', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib3hEMVdJY0pZOFJRQmFMUERCZ21jSHIyOWpSY2tMUTNWWjZjV3g2NSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567662),
('TqxSdLWhiYBvNiObeXa0aQk3IUbccx4nJBtpEo6H', NULL, '43.166.244.192', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZlVsbWppbUxxeXNEV09XdHdDWGozOXBiTnlXeEIyZkZGTlBleHlVcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768202243),
('Tr1PIPZRt7jGRpLY4sXRh81Z7ma4R0Lpu3m2zYXB', NULL, '209.85.238.66', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzRRQm1hQ1BkRzRPYzNFcFRNTklkY2h2d0FWNmFuR3BYdDNmaUhUeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768368139),
('Ts0pob7t720nEOyvaCDxeqSIx0LMSU6A4sK6TZxK', NULL, '209.85.238.2', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1RRSFpUdFdYU0NCQ1ZwSmlseFZPeUk5bEVZQUFlZXU0SzlROWRvWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768623743),
('tsNikjoi8hSAWY7HVdMzsT6ZMQvSfjpWVEq0L5CU', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSEE1NU5vaTI5dG5QbXhobHk4ckNnWVZaQ2hCQ2ZScGtLMFZpbjhsdSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767604523),
('ttOqpVUjgOd0zNvCJ0p35kyVb1LEmeE9NDOHPaYO', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTDdmN0NXU2VDOWtDVWtlRGMzVHoyU0s2TDNGdmJqVDc5enJMNkl5RiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768285681),
('TucejWcPwQD737LGrrYWAMQkjXF1o2MegdiNqmDR', NULL, '66.249.73.99', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibXIxZXU2WUhaNGpJY2xwS2xGRGN2eTRxck5uajNXVnZ1NUlYZHFPVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768058393),
('TVAvUpJKuQJ1jXGAecFz5MUMX82GwVHIKNTQNwjA', 41, '37.39.238.167', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6.1 Safari/605.1.15', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiNTAzZWN4aHhUQ0N2SW1OZnpSREFRdnhSMEZlVm41bGpuV1A0UHNiUyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjQxO30=', 1768725848),
('tWJZMFQsKMrjchDXwl8lT7DTYsBYOTJG0t3f3dpH', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYUZWZ3B4bmRvWGU3aHRUdWRGaFhIS3hxRGUzc0JrZVE3SmZKaGhxZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcyI7czo1OiJyb3V0ZSI7czoxMToiZXhwb3MuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768285453),
('TXmxTEd8I0WsmL7NyDdyBOXZCuVIjRWtz8Fjz77W', NULL, '182.44.12.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSERvMThwVEhKZUdwTnNTdVFkMThUZnlWdFNnMzMydThYNU5Wc3h2ZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767966807),
('tyG1LqZ6hgxBTFmkfdAJFiQLIxg3ZLu3NFZWHkCh', NULL, '43.166.224.244', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVJtSkp6QkFKOUFmcm9jcU9BUVJJc05tTkFNWk94RFFUWjhnNzZoSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767905178),
('u10keBqMUIwgbejTcgLsyHUgvttKZQXfNoIrLC0p', NULL, '123.108.201.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib3JUT1ZLNmF2c2FaZzdvaENCaTlxclFPN0ZlRUxWSUFZbFIxdXpzbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcmVnaXN0ZXIiO3M6NToicm91dGUiO3M6MTU6InZlbmRvci5yZWdpc3RlciI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767776280),
('u2hkEYXnr79fk1ZTTXRiFQiCYS12ikiZ5GFdCJMh', NULL, '192.71.2.9', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHVkZzBSSHFFVXlTa2VFTVYwS05RWVg4NUtsOElDNE0wSXZZOU5oQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768400423),
('U2nDSRCIQ0r1ZRBQpxaZ5jSOIJrF6kVZOIG6nJLy', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWWZXcXE0dlpoQ0FOUkpRZTJ3Tk53NVc4NjFUc3RZT2VJNVpoVkE5eCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767825358),
('U4nLDb8bbT46hQbb9zBTXyh0aE3LUsg5RyHvgI5S', NULL, '43.130.47.33', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMFBQSldITXNNc2x3ZVE2SFRBVTd2VWdpbjhHOVZnRjl1cVh0OHpMViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768696914),
('U6fgFE5hdvTuFAg7KHXEIHHNpzdXu0PiVEMEdQLn', NULL, '3.138.185.30', 'cypex.ai/scanning Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR0F1REhlSm5ES2tQcjBPeW9YcEZNczNJWUxwSHpwR0ZQUmhkckFtOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767864112),
('U8NRzJqEpFtocXfa5XKdjKt1Prw281WSC3X3gylE', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieTJ1TnVQa3RiR0tRSGgxOEdkalR0Q1p1clNTSVBndTBOTUExU05WciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('UbA6sNbdEd1M3ZmKVisE8MdQVrUmk3l9cktYmdel', NULL, '141.138.208.43', 'Mozilla/5.0 (Linux; Android 14; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.280 Mobile Safari/537.36 OPR/80.4.4244.7786', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibUZmMGNhMk04UGkyMXA1SmM5Mklzb3dOVHBYdWZ0QUlyWTJldkpjUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767933554),
('UBjFx4ivEKY7wkaBcVQo38QeN8e2Tr2JhlVTJGFR', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOTRDS2FmV2VTWmlrOHV0TXA2bHZ2WVFZcnI3eDVySWwxN3lEOFVMNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768228753),
('UC6GJQTE4tNoiuTuoTkFfGOMpKBObG5AtdZBEIne', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUHV3a0FCYVJJeXVQSmRna3IyV1NrV0UzMGk0VnM5NW14OG55d3JGYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy8zL2VkaXQiO3M6NToicm91dGUiO3M6MTA6ImV4cG9zLmVkaXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768283672),
('UcQnmKtP6Uii3bZVyNl6z7qgzHiexmMd4gwzIOjp', NULL, '182.42.111.213', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHZkR0FRNTM2djdqUzkwQ1UwTGlpNTZXZlVEejNCNkpWNTdOY0FOdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768654077),
('udgB2h1GdW10PMXA9qAggJ7u3JP0ZZLwBvcBLtYh', NULL, '66.249.90.36', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUGlucVhSOEhUNW1VelY2a0hXTTZIVk9DbHpqdHNrUXI5Nkp5TWV1RSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768364207),
('uDj5QPv9ZhYznU6m8cknHdbaHv51yjIKYF1VJWkx', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUWczM0xwQVJoYndzSE1rRDltTldjM3JyMUN5VnRZYjUyaWt2bkY3QiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716280),
('UDSYdwT0gEQAHCFY2XYDgK3jgG4RG4Q7sAd0iGWX', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSnZmYm5Zam1HUFdIQVVHUXVqdDROT3Vjd3F3dWR2VzJHSllLelNNbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768058708),
('uEbCWvGmeMvxHuR9eVlqbcYuDGOwjhephqAQq3mm', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYkdwTGNSY2lWUDhXSng0U3VPSzllNTdkV3NoRWQ2eDY3a2gyakpwYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768026445),
('uGA2kGGDlFfhCNije8eRpbSt67GvR25T8DGaTwPg', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicWp2WUxnRmY1amp0bjdqQjdxc0lQaEpmWXNrY244bm1QQklCNHF1aCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471400),
('UgioFcdSkYSYYIMzNSKroLJDhg8de6WMjVFWVQGG', NULL, '209.85.238.3', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTkY2WU42T25ucnRLclV2elh1VjltYlN3QjlxSmRjcU03YkZtb3BXUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768450248),
('UgJghBUNTTWSYZ8acmTlZX9vj6mzLoMRkqO8NO3A', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.197 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR1RXeWQ5MkFzM1l1SHU1V1V5alI4TU5kZmM0RkU2MWRYN05Eak1EcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121874),
('uhv1Ah453zbUqUwdOa61UEnorzQp6uRS3xbSJKEA', NULL, '35.187.132.228', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiNnZIbGlXamdaVTd1bmd5bGs2N0JpZVV3VjZ2bmNJZFUxM1htcUp3biI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625645),
('UhW7SsES1JOqYM2YWvK7SUohqASFyDjyMaPEiRZG', NULL, '40.77.167.27', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSWVYeGxQZXNOdUhwTU1QakxEQjZRd0dCOWpzOUNxUk1SSjV3eGtBNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768738089),
('UJSSV0VPUradqGGGJ2Ckd4Y4q0eNYf5laArbmORX', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYlNVOWo2bnVwaU1kbnJuVDVrS3lERThiQnJmcEpyMWFGUm5EaXozaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768747596),
('uk83ArIkL1glbf6J6P7wflFaPl4Bj18c0YYGn7yS', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia1YyWmpjVG1MWEpPT0hoUnRuYVJEVzhyYVBUa2ZieGxoYjVHN1pobiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvcGF5b3V0cyI7czo1OiJyb3V0ZSI7czoyMjoidmVuZG9yLmZpbmFuY2UucGF5b3V0cyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768293960),
('UkhzGzdMthO2Mz3UsHkWKfyN7JYKBag6bOlpAOSz', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTFFPSTFxc3FsUFc4bFBEcGlPd05CQ3c0dlJtR0hZczdXT21vdDYzQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767671606),
('uMOs76x5fdRO65V5eTgvfEiWXQbAFAAAFAwI326d', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQXJ6WmNRck1XdzB0c1JGbE5vNFRWemx5YnVvZkVUQVZnVzQ3OFFmTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768189947),
('UMPKIEQpMKXKgmWiiEpk1BbQpY6ahaPItNFn7x2U', NULL, '43.128.67.187', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM1VMdFF5R2hKWHBzNmJSSnBCTzRtaFppWldkemhmQklub1J6OTh2eCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768222318),
('uN8zDYsm0TicBPNB9LuQeGyFM0tqtg6OQAAPmXxr', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUTI0eDJHRVhzUDkxY2pKMzBwVVluaTFnak5HVWo2YzNad2FCM1gwVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767914565),
('UnHOnRZlAd54iXBd35CEgl86ShVDyTFx12LOv2m7', NULL, '74.7.227.130', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQTM5UlFPY2xidzgyT010N1hpQkwzNzBzNUllSjZoUEdvcWVUUVVjViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767963489),
('unpzWV4qUBpJ3IxLJ2pr9VITl8wsdVqHLgiiBEfF', NULL, '87.236.176.141', 'Mozilla/5.0 (compatible; InternetMeasurement/1.0; +https://internet-measurement.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMkt4VFB5NnlHY0N1Vmhyc1BUem8wbmNpelQyR0Y1Zmt0ZDFYU0tBOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768642105),
('UOlVAiWkuVG8gdiiZHb1aS8d8f5JFZnX8H9hTxNd', NULL, '66.249.73.99', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTW1aSE5wcTEzUGZJZ2ZKeFV4Vk1DQ1hUWkFrd2VGUW5CbVF2NkxMSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767523829),
('UQVQ1mMODqQlLK9h3BkYSCBKVmLqcEOWapbnXfkL', NULL, '205.169.39.191', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS25CSUkySk16YmhFeWxwUVl2Q2ZWc29CUjJ0MGhlRFJaNWNITjkwMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629336),
('UsfU9rJ48Kx6cG2jiqikxr6RB9MVTgvHxHRocEcu', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM0tRbVJZSUZrVm1ua3g0YlJHVGpFOHdGcWtzNXVUMFpTWUhjWGlvOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767673349),
('uT6pc4QXEpB3riLILfPE3WpuN5azV4N5LzlMyAlm', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVFJtSjVZSHFWenljRmZqUWoyZWdaYWhidjFmZ3ViZ3JFWklSOThxbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjI6Imh0dHBzOi8vZXhwb3phLmFwcC9hZHMiO3M6NToicm91dGUiO3M6OToiYWRzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768295788),
('UTTdj7ul1B8OuK7oqkHRGeq2VPf469uSgnWnDHWi', NULL, '93.158.91.239', 'Mozilla/5.0 (X11; CrOS x86_64 14541.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMnVRc1JxTG00Q0QwWmNQRUZDdzQ1b2MzWkhGUnpKMFV2aHpSNGJuNyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767732022),
('uTUMHmEiEYzgfawfHGGE74pVNntPpbvhwfTiUdJl', NULL, '141.138.208.43', 'Mozilla/5.0 (Linux; Android 14; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.280 Mobile Safari/537.36 OPR/80.4.4244.7786', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOHphMGZ2bWU2ejhoVUY1dEYzajhRTVloM2JhQWtESUwzTkJubmhKOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767933553),
('UtVXAQZDBQiMporsPmwr7GfVC9XTv0px9SfXLbpq', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2xvMmxSdXZGNXdCbnluS0lRRTg5VTNlcUtGQ21qMktoVFlJN2xOaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767951925),
('UUYrYtJN0Re9tFZGF1MgSQ8cQMj8lg8iGWRCjQEL', NULL, '47.129.200.189', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNlprb2dLZUVrbU96V3FQNFJ2TVJHSWprbnRNNW1ZSzlzdWV0WE95aCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767864713),
('UyDEnZAH6FaPX2D0ylKiVCEGxl16jszFzjmotzhF', NULL, '122.51.236.174', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRjBoTmxmYWZtT1FlQXNDUzMwdzQwTjBJaExVbW1YSnZJVTFMUFNTWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768333837),
('UyHmNldyd7EXnV6wYTaUhiOyYIXkxV8zezq1dFG3', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ2xFc2Mwd2ZvZjdHU3FKQnc1MEYzWng1cVVHTHdUSGw1eVRyMHBiRCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768729525),
('uytAk5Rl3OMvedmCWW3KY0vafyT0O5pHrOOcI89I', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYm11MzRNOWMyVnJ3ckxISHVtanJjQVdQcVJXQk5PZ3JWdVFLZ0RkTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767886576),
('uzH5xDQKPFSnH6VV7OVBLabEoy17uTAs4V5wsEBT', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoianRaRlloWmVRdmVpTG9hZjM4T2NZOXJrZHJGeHdMV1BjMTFIOGEzdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767690263),
('V2gemdnZfP1zHC1P6jpeIuBvLhqvi3OBygaYmAVR', NULL, '43.154.250.181', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN1FLWWg4cGVaTWh3cGVUMGo1NnRka1B3aVFuczFhT1owTmo4RWNOcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768428845),
('v5alfT1iwn70xlKHCnwM8xFipdFNtxsygbrXhJOD', NULL, '205.169.39.57', 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib0YxbU1IcW5wckgxdXdYZmFKZVNqeVhxVFNLbXlhOW1LSkpxS2g5cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629293),
('v6DEvhcPnPyByd9ehVbqD6zy5O1OZBMcdsiE37Rm', NULL, '43.157.174.69', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNFQyS01RVWp3S242WWpTMEh5enJEdDNjb09QSU1xeldwUTlCSWUyayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767973469),
('v6PDf0Q4dJchtTO7HAxb7koQzIB27261H9vORaCF', NULL, '93.158.91.19', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmdZZlJKNjN5UWhjU2V5RGlocU1sVUJkRDRHRGpRNW5OS3llMGJNciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768638898),
('V8avSloc2cDeKF1x3833bV2kZ805PFaFmQ7TTXOc', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRm9LQXBKU0Q3QUp6WE9kNUgxQjlnVWc1ZGdQRVdRY3lyckVwS0N2NiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768464833),
('V8iYJEBcl8hX4jOaQuS57UhpJQ6G3K0OYGt6w7h0', NULL, '54.175.86.167', 'Wget/1.9.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaVB1UTBiejVjaGNzYWVNc2E3c0hMQlU2VEhFYzVsMlVweXhvUzdCSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767548574),
('v8K2AA9yqkKbQOHDyNMxMamj9cSA1Zwqd3iEhdGq', NULL, '93.158.90.33', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieVUzQkhjejhpN0taTkpOZ3RSMmUxM1pCZWI1WVRZSFhybzFNQmFlZCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768679177),
('v9gclCGVKusSpzRrv2EdW65oKSK0L9udAsEmIMHl', NULL, '66.249.65.162', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSTQ5RHFTQTV3cjVzdDlvajIxZmt1dFlKd3Z5ZW9xQXg2MzFVSGVUaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768403542),
('vA9o5KEK6VlBqCv6W6bCkiXnw1n58dCFPLpP31hY', NULL, '64.225.100.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36,', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZUdVRUsydUhsOE5LajdWRFYwUW43c3Rkbk80aDlLeWw3RDNmOVY0SyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629236),
('vBNfZQCbTPZb8df6gpxoCV2640qmz4D3MPL1o6NX', NULL, '77.67.167.143', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.7.2 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM0JTS041RjlSbTM4TnAweURhNXQyRUZRTm90Skd5QTRRVWNCYTllUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768589882),
('vEdccw37zV0zTdtwNo1rlYj9VilU2MclltiM4DWU', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieHN2U3QwUDNVVXFEYUJETnphYXRMZHRSS21LY2RwZzhlTlRSZW9uayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767632221),
('vh0p0qJBEdHqNNZDkqDCKmqz22H4GQaxZNE08sym', NULL, '40.88.21.235', 'DuckDuckBot/1.1; (+http://duckduckgo.com/duckduckbot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU2hBRW1ESXhwSWpqTWZQdUpNaGhyOHBLM21XRm0xSXJXRlo0T0h4aCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767805182),
('vhCxQwiNRqO1OLhlj8TaNUJ4j9JW96TzAiTTfKav', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid3F0NDNrU2lZVmdUc3RXSUJUdURjeVI1cWZRNHV3S29iWVBWdWFrUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9zdGF0ZSI7czo1OiJyb3V0ZSI7czoxMToic3RhdGUuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768287598),
('vij0XZcd8kxDrjnBvxbcrwjM484dRIsygcNcKkZ0', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaDNKT0pNOXc5Z2s5QnZnc0pvVnhGR0d0MXVXSlFpdHNIYUpDUDBVZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9zdWJzY3JpcHRpb25zLzQiO3M6NToicm91dGUiO3M6MTg6InN1YnNjcmlwdGlvbnMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768288689),
('viLmNygzbEMvgLryAw7fsMcZhpLCXhToQBhB4kEj', NULL, '2a06:98c0:3600::103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSGRsOGlRTVdkSWxZVHJMaEpPT01JWVkyajZZZ292T1V5d2lyNUhPaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768391709),
('vIQFPuUL1kzHiX64RfZLZQRbbdkthzI7OdJdVkIx', NULL, '43.164.197.177', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ3pHWFppSjMyOEZIRkpGRGx3cGZhRnM0YlFTT1JQM3JVb212WU9ySyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767882126),
('viSVjf3wTjbA3W5V57ljtLZeQ6K8cfmWoGp6A327', NULL, '146.190.133.177', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidVF3b2FLY1ZqSkI2QmhQaXZtdXc5UXduaVE4NzV4UzVBbmd2OFBYayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768206291),
('VJOkdfKKL951I22bLh9cdRUoHgtJvD5M2AI6gBBs', NULL, '170.106.82.209', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidmNtS2pQWWxHdWxYS3FQVDZJZkJPdWp6RTd4QjBuVVdyRTFZbW9YViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767711057),
('VNaIKcKkpod8TinVuLg7MYiApaqLmnth81p2BYc8', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiclFCNURFUHhrSDNEOGthZ1BJTFBmOTFKdGpqU0lGZzI4Q0hOY3RHYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768557288),
('vp43OE2K8kZnNDJhbxrushbGJmOZjszZNRbG7YDC', NULL, '35.187.132.227', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiNld6Q0VNUDRMdnJBVnRQYlpORklCaTlCN2s0UllWVzhpb1cwN1ZHaCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767625632),
('vReeCt5BemxLPpuDNT7koyC7KBnAaeKTAYCLLnFV', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWXBEem1VcW9Tc2JlTENyYWs3aG96eHlCdkN3dElvQWppN2FvQzR5MSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767677498),
('vRzgF4OPz5SBa6UjAd6Dpa0tWd6hEcB82sjPd5JD', NULL, '66.23.227.62', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQVRmMmgyRVJCRlB4ZUhvdVBKRmFmZm1OcVQ4bjVnMjJmMkRNNTlEUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768537772),
('vvaS7j1AX3CMwzHA2RPvXAjYHiDnbCgokUochh3B', NULL, '43.134.141.244', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUQ4bkowMWt6S1hSM1VaSTZ3eUVjS01ZRlE5czMzWEplRHNpYkJMNSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768667086),
('VvxadRO2W0W0XRirTJmj1dlY9ncgv1kBTp9sbecU', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUXRsaG41NzB2aGNBTkdHQzNpaExLWVpkT3ozakQ0Wmp6QldmNzBJTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768125682),
('vXjfKRRBy7IZxeTt25EcQVC1QQ2wTicMQSJlMdZh', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZVRkMFFGU2JVUFJUQVNPU1lVVFpVcTI4ME5NV3FoUGR1ZUdpN3NuOCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767868134),
('vxY4wGmjewZ4woyaRe19d4B9B1Gi3yepKXmoi0js', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYmVzTFl6eklQVnV5RmdZTUFpcE8xNkNFOUtJTm9VMGtueFpsUTRvaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289331),
('VYyhXiYic5PTsO0CqybtFonfAjIgJmzwa6Uy3l7m', NULL, '209.85.238.3', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzRvMUVrSm1BOUV6UEhsWW9VWDVXTVhVVHFaOHV6REtUOUltRHRkcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768449017),
('vzhz90WZI2kkclIwTpy7sEaxCrGI3dQ81sJ2h0TK', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT3h3c3pRS1dXaEUyV2NCUmN5cjZOb3VYcUtYOWtlYzRqcUh2b3RiUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768279051),
('w20wXx7NdOgOxMKh5UIrYVBa6DNIdKPBsgXPZhln', NULL, '173.252.95.9', 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOHYzeE96UndjM2VPUE9oc3FBMUhGVng0RUM2OFFjMDd2WWliaVN1VCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768567655),
('w5Y9LLxQqJB7gPw7b4TYiAkzWCA8YKbuhf6cudRP', NULL, '51.20.98.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS29EMEI0cUVvbVZvdnVxYTBaVzlGOTh0WWl3b0U0VkRoWE8yTFZvViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768424233),
('w7xwJU3r0YOwZ6eesZj7zDxDzBvPxWAwL5UHMFhd', NULL, '170.106.165.76', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV3J3OEpWWFRqOTVkbDg1bjJRT2NqYks2aFc1T09zSXZXWjNWeG8zciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768744063),
('W8f88iroKPH0bUMCFad0KWbaoderqffgzStcBtjP', NULL, '209.85.238.2', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMU9xUlI5eTV3SXFBdUZ0dkZQbmZ2SGExeTYxRVg3TnliTlBpRkRGUCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768620970),
('w8IdvI7Koew4SDwIO0TULGgVu2XNLwa1AIemis5I', NULL, '138.68.144.227', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT040MjY3S1JvaDZpeW9JVG1jaUxkVUduUXNJN2R4ZkZsa203Tk52QiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767511384);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('WaNf5CEWy18wAbpnzTDLxdjIvMSlLzDf9GubvJZ1', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWm9kMUU4SUpKTnJsc2hpMUpIdmI0WG94MDdnUWlHNVVIVjV3Skd1ZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471405),
('wAxduY2xciDt1rIBFH18MG1EHfre7HI8yUtAxaA2', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUzdSNXAyMmVEckt6OEpPYVo5ZFJ4OTVuSHBsVnE1RzM0TVZDaVB1diI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471405),
('WBJGnbwBufdAkYDJOCDTEXkKrpwlkBIsd83moWd4', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYkx6b0E3cWFCb1pTWWM1SlpYVHRuRE1kWlkxTzRsVmFDU2NBSjBJVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHBzOi8vZXhwb3phLmFwcC9hZG1pbi9zZXR0aW5ncyI7czo1OiJyb3V0ZSI7czoxNDoic2V0dGluZ3MuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768287604),
('weQA5hLNZwRojTOOQRT4PYZYWHkFxvFMphuPbyDE', NULL, '107.172.58.36', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibkRLaWlGeHU0R3FkVXdIQlJjZ2R1ZFN3cDRscnBGRjF5QzNyMThvYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767628807),
('WeQVB5yJaZQcnBQWRaUAomdNdXz3TMwgQKzgxcbg', NULL, '217.160.202.182', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGxOQWo5YlV5bUtkNDUwWU1jU3A4cWtoelZmU1BnVlZCOGlncUxNTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768668177),
('WHHrVvckyqgLTRPNox3ak1cHsOVqYGcakQ5tLMRK', NULL, '182.44.12.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSFdaNmFMbjRMVFY0UlJXMVRNRjBGbGcyNjd4dU9SUzZLR3hURXMySiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767778139),
('whnlgVHekoJpnYTrTYKbf0VEdy5XuDPUgqekTGg4', NULL, '54.196.169.29', 'okhttp/5.3.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiczlWWENXZnlsVHpQcVA3WXNoTklLQklzeG1DSENkVDBmSFBNSm84SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768735955),
('WhWEQfVixaNnJDpGfHr00w2I51zWJoXGqEDhbYEq', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWUxYWmlZOUd6cldhRUs3SVVuTEttZGdKRnFhM2FHSm9rTm9Dem9TdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768287605),
('WJfHi9DAceJvebgXKBpEe89iKKLJm9i6L1yjschF', NULL, '34.105.219.249', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiREVCUExCR2lqY0FxNlpKVkMxMXB5ZmxBeWxEZ2tsVnZBZk1YMk1XcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzY6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3Iva3ljLXN0YXR1cyI7czo1OiJyb3V0ZSI7czoyNToidmVuZG9yLnByb2ZpbGUua3ljLXN0YXR1cyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768289424),
('wLa6CLa9EHlf2kN8OvIHJERYkgUQijHRY7netee2', NULL, '87.98.230.248', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMDFCd0ZmU05aVFZJakU0c0R3ckpwUTFmakd3Tkg1anhrd04yMXl6NSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767631342),
('wLwZBviNX7KCPi4OtZ2EL8EaLi67J9Dq25yJdlAG', NULL, '4.197.176.207', 'Mozilla/5.0 (Linux; Android 10; LM-Q720) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkJQSER2M0xqN1lLSDRyaGJ2VXV4SDFKdVd3RWx5SFpQQ0xPbElxUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767706415),
('WQ0UzTVjkdl5ztehVBGrbjweB4Ie0Xq5obWQwuK7', NULL, '209.85.238.3', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2FMZTJZVGdmbHNoT05CRVFyQkFqcjVUcEI5NFU3Nks0RXFsc3NQMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768711579),
('wqvsTXu14VqKrSfuMt963U3dS8v5LHoDS2fSCQZf', NULL, '35.205.159.124', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDB4a3dzYnN1YXZ4UzBieHBQWXJPYVN5bURGU3hTM1RlWHNvYUdkSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy9jcmVhdGUiO3M6NToicm91dGUiO3M6MTI6ImV4cG9zLmNyZWF0ZSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283501),
('wRLHJTwojmNS0D1m6ASbp5g7YNjMeUHrDv4Zp7aw', NULL, '64.233.172.101', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibEx5WVhaN1N5bG9FWlp0Y01qRUhrbWpBSW1XOFhnNVRqUzFWcVBPUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767862609),
('wtFNJCrtvn0HW8pcow1rKHfNnxcV9RVEgNCAUI1a', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3ZpQ3BmRUl4emZidkE5bk9Kb2FXa2Y2QWZrMlZLMHNUVUU5SGJhSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767954071),
('wuliYTkdAs4iq7rJT2HnCjWmPRN81WGypDWJyGRB', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibkF4QVBLM1dxTkdFdGVuZEpEVHBlSXE2Z1FmczNIYXZEUXM0RDFlYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767697092),
('WVJ1qx8oLlkrbq88k8LAYNusuTPCktbUtNgm5goX', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYWlNcWZ1Y0d4cDVVdDgwWkpHMmFOYjIxeVdMaVZGQmpQOGdFRVpYbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768054886),
('WX07jTADkeuhzo9BZEm5hHVPu1YfW6JnA9ANK3Z3', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieFVEREVLSzQzc1ZEVk5id1V5aWFHRHY4ZWJadnFmZXVnQTh5NlNKZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768475379),
('wyhPDP1daGLIwksklYBlEDlRRjPMHYQNokG46P2w', NULL, '217.160.202.182', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYWY5YVZZM1M3aHJpTkN4RnVnWGJLMG9tQnNiWU1GNEpySFYyUko0SiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768668177),
('wYjrYIMu8Ek6zdtQ2m9zPGA0GDl78I1AOqL8woHv', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWGJwdFNhQmpHcERGbkxrM1hKd1pBQmZiNEN0dG5qaVpLSzBCREU0MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768638185),
('WYzbSFf8wU3ZXDjcY7mNUwbXzDZrImyOKpd4cvoq', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOG5HVVVrWmVRVE5LWlZ4TXFLOUY3eG8yaHdBR1BkbmM5NTBkTTFHdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768328612),
('WZrdW0AnJ7oR1HZRchuDh1hc8SXSL0xOAQ6fJAuK', NULL, '170.106.180.153', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3BDTU9NQXQ0bHRWbnQ3MDdyZWJFdGQyQWNzbmp5NW5Sa3NuZWprUiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767862998),
('x1IxagY7b2RBhrRNwRthfuR6H0C1AG1Ky3Ca16ue', NULL, '66.249.90.36', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2lodXM4RFZyWTRBekhTaXdBQ25KMTNQSWtJaHRQWW51Y1RXekJndiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767818080),
('x2FDl0rQO79UnemFa8TLbXkMF6zt7P5S2rMVTM63', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiczIxNmdIU0t6RlNpMGFFQWpUVTJxMGlQTmRwazVIMklHSmFDMmtVMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('x4F9H3A5Yb5y0zinKfpzwrbOToflE2slLhwiUKFD', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic09DTmliOWdCeHVzdDg1amowdjhGeVd2bG5KQ1VDdFlpZTN6WjZHMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768105364),
('xAGdiikbWoJiYz6ibPWBMNoUn1WJFBUWpifTCmd3', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVWUxMWpJSllYUzZnWUV3bFBVNnJ6MmlxZ25xRmlXS1lyMjJJc2xUSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768295486),
('XeZkEbwnfMY8RqHQ2LwDE3Tk7NtP1WBMRmZaCIJG', NULL, '66.249.73.99', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; GoogleOther)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT1FkZHVqMmpyMmg1OEprUG94Z1ZTdjhnUWprWldVZWVVbUxaSW50MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767710728),
('xfgD2FfCppD23b3YCsDS9VVtdhnxJJoLO2nyWYUX', NULL, '100.31.89.111', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1 Camino/2.2.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWTM2WGVuMW5vWEZDYmMzeWFsQ3FiM2V1YUxhUndZSHhmMjBLUkN5YSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768586897),
('Xfj3UT4flVmXfXeady1PTBfof5bTPEMW0GSJapw3', NULL, '43.157.148.38', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMW9DRnExS29jUmdwTjNtTXVtaUxCZmpTUldMbVd4TElTNTFWTG5saiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768039381),
('Xh6fIkdi7tHwPtehCU0biDW7OOGYJXCz1hW9Slqd', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlVYdVRLQTBrU21ROGdJc1VtajlINHRCUkFwY2tReGNjeUViOVpMMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767540011),
('XhBSW2iD7XvGDwiGRn1er4hBGVxZ2gZ9k2fHID2s', NULL, '54.162.90.208', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:14.0) Gecko/20100101 Firefox/14.0.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZGtlQVZjdldHQ0hQRHRTWEtETGtEZTMwZ0F4R2t0VnRFWGx6MTFMMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768411741),
('XJGmILqLSWvk2eewQLPm99YhWIN0uvvORslEAPK4', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZTNaVnBRQjg2QjJuSGxkclVpYVM0UW5QdUJmVXMwME5ZYnNMNjRNZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768294411),
('xmjKk5pXQTByRTeEZBlGiyZds2oQaAn5y5617oTi', NULL, '205.210.31.56', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNEpQT3VLT0VBb1FDQUxnck5hTUxHMGtoNWxzTldBYThiT2RXaHZKSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768084807),
('XnMMJ1p7g9jk6pYxij8j1c8BORhWseFaT7TYUcI9', NULL, '157.173.122.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOHA3bFZHVkR0VFV1bDVHM1B1MW5RS0p0anhNNTQ2VDhyYWRScmJHSyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767791148),
('XoEH5FJ50nrHUt1yaXRnoLGWeVxkd5GaucH1sKHY', NULL, '34.91.129.93', 'Scrapy/2.13.4 (+https://scrapy.org)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWldha2lGdkN3aWlKOVV4TkY3dWNFWmtJcm5DOXJWc3VpQUpMaGZTWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768345079),
('Xp8PByAy1XcSmmkfTNofRMm2idGGi1K3gprMFYRx', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT2hpaVQzWUtpVFVFeWlBSUpOZzJxU1pxSnZUcTlheDkxZ29hUlViZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHBzOi8vZXhwb3phLmFwcC9vcmRlcnMiO3M6NToicm91dGUiO3M6MTI6Im9yZGVycy5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283492),
('xPghTVZ7vuPP0nFj9W9SaurvMR1MDGTddsruOssv', 41, '176.88.108.235', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.7.2 Mobile/15E148 Safari/604.1', 'YTo2OntzOjY6Il90b2tlbiI7czo0MDoieFdiaGVvdGxxZzluWVhiemd0NTRWdGJXZnhxTkNrNW1xOGozd1p2OSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6MTk6InZlbmRvcl9yZWdpc3RyYXRpb24iO2E6Nzp7czo5OiJmdWxsX25hbWUiO3M6MTQ6Ik5hZGEgQWxtYXJhZ2hpIjtzOjU6ImVtYWlsIjtzOjE5OiJEYWx5YTAxQGhvdG1haWwuY29tIjtzOjU6InBob25lIjtzOjg6Ijk3OTA4MDY4IjtzOjg6InBhc3N3b3JkIjtzOjEwOiJHb29kbWFuMjAkIjtzOjIxOiJwYXNzd29yZF9jb25maXJtYXRpb24iO3M6MTA6Ikdvb2RtYW4yMCQiO3M6MTI6ImFjY2VwdF90ZXJtcyI7YjoxO3M6MTk6InVzZV9hcm1hZGFfZGVsaXZlcnkiO2I6MTt9czoxMDoidmVuZG9yX290cCI7aTo5NDk4MDk7czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6NDE7fQ==', 1768726125),
('xpZdM004S8mmlV9t5ua2hONMvHsVs4GBJLBQZjeg', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR3h4NjBkT1BYRmMyUUw5cTRrQlkzb25yRkpLaEFyQTN4ZkUzSjA0ZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767584351),
('Xrh2P5AsRxMs0YcOjygODndjocPV5CvSrkFL603W', NULL, '137.184.232.239', 'Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZnRXN0Q5bjlsWlQ2azZJQlRTZGhZVFV0S0VSQkY3M0p5QmdYdmpUaSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768027608),
('xsFK5Cn7BI7aeymgFGiQz5B21yieZmEmelhlcqE2', NULL, '49.234.10.105', 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN3dnNG5GZlEzQWhwdFpOb2xiOUM0Wk0xbW9EaW1ObzJGWkI1OVAxSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768272746),
('XsLnidpDNJWdrGfEw4WxNPfnzWOh8eaGqdhvXZTU', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSnUzWFc5QUVWcHpqMkE5OVJLVXBuNjlmVTJaQ2xNc0MxZmQ1dkZiaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzI6Imh0dHBzOi8vZXhwb3phLmFwcC9zdWJzY3JpcHRpb25zIjtzOjU6InJvdXRlIjtzOjE5OiJzdWJzY3JpcHRpb25zLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768295798),
('xT1JotZSfzMpQg0e2otkhkzXBP3vs8jsHq85CArj', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiczNSYlZabFJrMW1HeTVoR25SYU9uQzZTN0MxcnVEQzU1VERRdUZVZiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767608634),
('xTkDTRP4q99pjMIq5p0VeQlKkSF0Oe0oFjYZIPsn', NULL, '66.249.73.129', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUkV3M2pncXB5TElia2IxeVFLUXVwVktjS0ZXWGk1QVozcmVNbjZ2NCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768520559),
('xVfMsRzJ6EvnI7H6nyHPljuUVUUZIw3HboGNZKeB', NULL, '43.157.156.190', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSk1paTdnSnphbXMzdVFKWnNnM05OR3hqRHNwS3Roc2ZFa1ZVYWhMUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768365618),
('XvTTM8oYT7Cxy807lhufluVkpe3KsbcWAJnKyVwt', NULL, '174.129.106.157', 'okhttp/5.3.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSnBTVkU1UU9lN2NhTTA3RDlXTmwwM0FIdXZvemRva1ZyR3pTMWNDVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767745424),
('xvVSmlPqWQQWmT2HR5m0SfWKA5PdbKcqeMnsFTIM', NULL, '66.249.73.130', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibnJtMDE4QkpJYVU5cVo5UlZiMlp0MlVIcWM1UXNxc0FhMUh0UGlKeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768784103),
('XXTj3GJTp6N2Y8j6OMJrg54XRJCeXiXNqBqkP9NB', NULL, '193.188.62.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiWUhEWjgyV0QzM0N3eTZDM3pxV1JYN1V4dmRGZjJtVlBxQW1CcFZtbCI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768472331),
('xy7qu5AYYlT4UpeQb0eyr0Jl8PsHXRpcwRFG2kVE', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSDEwOXZvTURLMUdzQXQ4blNnbGxGQXA0NEE4bzE2YlVJTTdGejhUdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767889672),
('xYu8Tdhu2ZnxRXJte9mh5mADNE6T50XApufC4K9e', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibEg2Q01sSlIwN3I4c05IWW9hWTd5YlpPVFptbVhmQ0FGaXlwV0R4QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767825019),
('XZuacCqKOIRe4EglYQrGPuLHu6FJbnezup2DrWPD', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOXVzZE9wMWREOEczWERZMWhHbzRRbTJpeEpRelpYem1SaDJPVWFJYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767822235),
('Y2d0uOmwyf0VQQDc5WS9GTU8UIZd5xzzw1pEZWTi', NULL, '165.154.27.20', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieThyZmVCTFcxWTZBS1JFV202QUpBcmVwMU5ib282MGxnaGxMQnVDaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjY6Imh0dHBzOi8vZXhwb3phLmFwcC9zdXBwb3J0IjtzOjU6InJvdXRlIjtzOjc6InN1cHBvcnQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767716278),
('Y2JuJfzLAlliCy2qN4nvhT67vslL9nPIa8HEA6CN', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVkZMS1pTdVhtZXpIYkptZlNsZG1UeG5lS1ZmTldzNlVOOXlBZFlGRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767851758),
('y2mVmn6mTFKSoPW0pd7dFEiYPSJb6HJ0PYfKmm9P', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieWhmNXF6SFBXUjlYd2xuM1ZKQ2xBTjU2YXVQdFVNUTIyZmJJb0FWNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768747596),
('Y6EgF37QqPRqs8eacvRmX6hA03rqaxiHODd54ZM4', NULL, '118.194.228.7', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaUVmYTRJV3V3Y2VhR003QnNNUzBqOVpDYW9LdFhydDIwak9UQ1VWMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767676886),
('y6rtb0vC9uWnjMUXYwSmp0MOkY2U05DjrNcRKPHo', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQnB2UXBaYllWbUpjRGhvd0V6YVI3eTVBTUloeDF1WldLTjVrWnZYbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768306831),
('y7qnJxzvPXIFwDpDd6P0rFR58sZZvODpzDBytCnt', NULL, '43.166.253.94', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiODN1NUp4WU1vRXJ2d2pDTmdFblIxWWkyUmprdnhuTkxaUzI4SDl1cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767819194),
('y7zOsHJlV2hdIsNwgklEOUpmurDJYq1l3n6kZXgG', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOGRjWHRHUFNYaXhhYjNXQ3ZwMUZiVzhwdnJsdkVnTVc1YmZqZjR4QiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768283309),
('Y8nBPYP1So4ZK7IJOzpZLMjKCRwV4bIzftI2EfpL', NULL, '54.175.86.167', 'Wget/1.9.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSnZuTHVsaDhpcGRQZWFDcnlQSFFEbm1ydTBZR1oyam1icUNNa3I3RyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767548574),
('y8xMlhlAR5oqPyvk1Uihk26gSLsJNFIHqXx9EweE', NULL, '13.200.251.60', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSjl1VW1NdWJhV1BKTEN0ZGNMTWhKbWRYQVYzU0R4cXpYQ1NkZjBzSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767850835),
('Y9ypknoqiHGoLam8vDWSZv7dDolGY84viNbzXHco', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQU41UGVjWmNZVnNGVHdlTkZsbXFjVXhDTnhTTzAzY2pRdGRkdVRhcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768121875),
('YaeGaptMNN3xs2BimrBWi81pwizq6hOlrVumUdV7', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidDZwN2lVeUpBWEwxQVJJOVROaTAxZ0ZMc0ZGRkxWQzRLQ1h3Z3NlNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767995785),
('yBDERGjwx0qfIizaDa3wqQUWIIGJAmdMiKWd0bdl', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSTFIOEdsblZYZ0Z4eHVJMHFNVjl5aFNuYkxBa2hFR0FZZElCd01vSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC91c2VycyI7czo1OiJyb3V0ZSI7czoxMToidXNlcnMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768285520),
('yBKHzQkjBvyRuzvv5ifb3ZxAxD4gujB2jYD8AC9K', NULL, '66.249.73.131', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicnBWRnQ3M0hOdFZPbVl3bjFHNFROSk9VNXJCV21vWkZSS0t4WmhUVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768642719),
('YbucVaeAD8SS5Wt0HvQxDii35GpAx349RUmPqnzT', NULL, '43.130.34.74', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidmNUZnF1Z2tNbXo5bjZkUGFMQ2RHc0RaampOMllzWmd2aWFiR0ZzaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpOQkV1NVAxVWRNekFwSXAyIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768538462),
('yEK1YHQxuNcQRGCPt2NjMeAB4MpklxneSk6rm7Xd', NULL, '170.106.73.216', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMWlreXZhOEFnbHk5SXZrZGxQMjNqdUlnMjRlZHR4MzVmMzFpdWh0dyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767647158),
('yHHiMnC65iIU5D0OxCBlGJoGbZZbl816OSAP5VrJ', NULL, '66.249.90.34', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaWNleEVJYWVkd2tNUHVTd0JKOHM0cVo4Q3hEd3VmdVB1VTBJS0R5MCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767598449),
('yibrKP5yc56ZSzxuNSkG5bQkDfYoYFmOcTQ5sRIX', NULL, '205.169.39.191', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidXJLMkRDbDdFODVuY2Z3enBTbHF6Tk5BUXdVS2ZkRzRDMmlEbHRnaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629331),
('YiPQZ95C0NzxRwU1HHFAKxUD39TRxtMAyqRKAohj', NULL, '34.72.176.129', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWTlMOVhDYllrU0RWUXdkWUNZS21xbzFnNmFpd2c4Wkk5Q2hPbGhyRSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767629302),
('YIVar1NSGPnjQYD19bJPHQmiGctqzsb84NqoVG3D', NULL, '170.106.165.76', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTkVIRGxaeWptRTdDV2JjOEJtejRwNTVpS2h6cWJERkdtbTN1UGRKVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768744061),
('YkBcxzNKLQWGjJf2pRSTIAM7LzlfY7b1Vb92SJfV', NULL, '66.249.73.130', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicVJyS3ppd3JiM09VbUJob2JQQ0Y4RXk2allpVWFVQ2ZQczQyeld3eSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768645790),
('Yl1dEjMw6KwdyynfGuzqasw3JUbNcP51eNbzW1oc', NULL, '66.249.90.35', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS1JxcjFwbGZ4VE9LSXBRZ3FVaEJkWlRIOVRkNmoxTTFjaEdQVGRZRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767978333),
('YNXHHpR5OGu6YoISXf2SDFwemkoHOwSyL0NwRa96', NULL, '35.187.132.228', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/112.0 Firefox/112.0 AppEngine-Google; (+http://code.google.com/appengine; appid: s~virustotalcloud)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTlZFRFpCNUtXdjMxM3Bja2h2T2F5MXAwRklBTjNqSEsxd0hLWFNreiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625632),
('YPiWPMjI6eelZ7r6vxKjMIWIg3bC3A70EkPq5yxq', NULL, '192.36.217.48', 'Mozilla/5.0 (Linux; Android 14; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.280 Mobile Safari/537.36 OPR/80.4.4244.7786', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYnVPc1FUUTJqSHQzMWsycHJ1V09zbjM2VTdwNXppYnBNUnNSVU5GaCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768211724),
('yq83X1mOM1gN7z1ZlfbLtqEy5nXl6LUFZda5BCdc', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ0NRN240U0ZBOVJMVDFucDBrcmJ2d1N5Y3pDTXFnUm10cTVYb0t5RSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767779066),
('yqxjurK8Uq5GjMiuHbzSlgMHaLVpyf9Vf61GmNuH', NULL, '92.222.108.122', 'Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiY0k3dDVxc3JmNG9zZkRzcnQwc1kwNEc5eEpXZFhBSU85NXgwT3ZBRyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768428734),
('Yripe5xnqExpGnrX0ncUcaRoMjYNEqDQbRmNsaEr', NULL, '66.249.90.34', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2l0ZlBCVGhMQXJWSWo3bWZQQjJ5dDRpT1JiQ1lvV2pXSDh2clVCaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768140249),
('YS3PuQxUwvxUZLEUrfryNiwy9I6qbMPlkVlkTw52', NULL, '43.130.67.33', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTGR6Nkx1dHZldGpwbEE4SGRkdThjY1g4UURYWkFjZTdCQVZLR3ZHQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768262723),
('Ys3tjm4Fv2GAV1mxWUaALpyfI9y5bmcFzoUjuKnl', NULL, '66.249.90.35', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZld6WVRXZHpzcUlPNm1NS3BteE10Q2pzVXZDWjdHeEpsV3RhQXNNNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768034168),
('YsZby9ZvAWXnnRlcnLcEiBJxPqeTQ5bkWG9w7Ljz', NULL, '195.86.24.111', 'Mozilla/5.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiT1lyNlVuOEtvVUZyMzdKRGZOQlJNbkhOSUxEeGpYVE1jRm9JenFITCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768393535),
('ywuWIRfwMQWvcFTCYntqlhdbNirG8qspZfRJ5h0u', NULL, '66.249.73.100', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYTJscXFPUXp2MnFGS0p6b3lDUU5tRFdvblVGSzJzYzVVeXQ4NFRJSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767520977),
('YwUY67A9I2bbKtAW4rznuEV0bZpNwy7hG5bBFjcZ', NULL, '49.7.227.204', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ1B3d3BJbE44dGNqR2xpQ0FwUHdtOERUYkdvc1JqSG92OHBZTzdNViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo4TUFNSFlxWDUzN1FnbXQ5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768468593),
('YXqEkxpxu878xNnGpZSMuFeDyWGYLiNko8tpr8Gw', NULL, '198.235.24.12', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibkNuMlhxQ2hMd0p4YlhvUWNqYUhNWnNqdjBLMFpnN2trZUF4bHJWcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768121148),
('yy72401FyyJemk0OiEi93itzAxyjMaiWF69Ub6NZ', NULL, '66.249.73.98', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidk9KbTFVaEIxWnNieDhZVUhXTTFqYXdoMzRzV2RkTEpRWnJuVXBiTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767875007),
('z0fY1MLDlg67T6pZAMJo4WtEiEjF8vK3uMtIGQbm', NULL, '66.249.90.35', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYVo1MHZ1anFiNThHN3JUcVJBWVN2eWlrUkY1VnkwTlpyWWpZS1hNYyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767904387),
('Z3zS4AbNeNfTmNPpij8MYZcQQGrCirEu871dHhwn', NULL, '43.157.95.239', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVZmSFZBcFlIbWV6ZUVhTlMzWnJxcWtuQmNhTXFQQW9oNndLbTIwOSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768304046),
('z4B8RdoqEOxdzDFn0sWpeZTjgpmoMAxIlPyWOOwn', NULL, '173.239.203.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWElqU3JEYUdrSUZKRjJ5RnQzMFVJb0FRbXB2emxFeVlBQUwweEZDeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767633175),
('z4i7Sgf6CkdbXpA37hgjni4bbZU7OBPk2W0jF1rh', NULL, '43.130.102.223', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3paSzNHMXg3amdXRmRCSlc1SEZVNFljaU9VMVplVFVDV0dYeDAxbCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768344673),
('Z85F5bmp9RopCrd6lFyfQgBeN46q2JqHal9Uc7aC', NULL, '129.226.213.145', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaU1VZXJrN2kyd1lBU3Bicm43UEtZVnhFekVzb25HVmtHSmVhMXg1cSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767930875),
('Zbfy9xLiFatZB0voRuo4nn8Xc5RZxunU2b7v4F0S', NULL, '88.198.208.16', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTFlGUkttMzdSdmdySGR3bVBIR2pPcXpwUWJrMUxjdjdlQmJWU0FkdCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768736271),
('zdWneDTAszc96CIrqjHaaFzofpClG1mAyNbyEkId', NULL, '43.157.148.38', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRXJLbHdxMzR5elQ5N2ZwNzJ1Uk1td2NnbEE5eUpuSnlrWVhtRURpZSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768039384),
('ZeCOPpoDpZxCs4qUwvnviHvbFvwYirSeKUwaNBoi', NULL, '43.133.69.37', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieXhyZEZoYWpCa3Z2WHZZSUxYNm5jZVBpY1ZhQm8ybzd6c3c3Tm0wSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768722360),
('zF4EXtFvUhBXPEIAxYrNSXyoHiDXjfVTTPsbUkdm', NULL, '43.166.136.24', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzE0ZHlBb08xVHU3b2FjM05DTTdtbUNrZTA4MHY2cGF4NG0zTExXTiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768560031),
('ZGCeMLRwiVVO2aFwRxWG1slnPNoAWvM2FVJxTjnC', NULL, '74.125.212.163', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRWY0cGR2VUFlbWF0bkZnSzE3UnZaME1zTllVT0VqblpsbnZkSTFKYSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768278421),
('zgUAsjfghWAF4QEVI9FPgYWRRgCDnsfT5t3Simzl', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieE5qVE5kdG9YSE1odjlMTXNxaUhSbWxnSDZCOTFTR2hrZjRDOWRObyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768471402),
('Zh17qYXRiEn7VPiyXbjbtX4lPdXQ9R72XLYsxA8l', NULL, '54.70.53.60', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2Y0NEhNQ2x1Yk1QMERXaEJtVWRmSDloWUhvSEtwUXNlTmdRalNKTyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625713),
('ZIcQm8rh6JtX9NAw5ulvz3UYagJG72yP5x84c2y6', NULL, '209.85.238.2', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiejdoUFNvOVg0ZWxXbmxpWFRoMDk0V0hIY2JtNHh5Q3NianljUFlYQyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768658855),
('zJZEjqpa9y3iGclZSPq9UJYNUjNEeWb0ZoChDee4', NULL, '43.166.136.202', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWGR5Rklad0c5ZG5rNjl0ZUVoTFNvSGpwdUlNUzRDS243R1YxcUhkSSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjo0dFBYQlhYNDFiWVlTQnBPIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768765215),
('zJZXTAgGvze44XMCAjxbVnFwtkqclL7K4a6vpIG7', NULL, '209.85.238.4', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidnFHOXdYeDhJYkRUbFMzcTlhZ0s0OFZraERrWkZRaDJiYXNYcnVlVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768644221),
('zkKgJaeF6GQc6Ff8pC8FY4toD70111sna8u1M6Id', NULL, '3.129.57.232', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.51', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibWQ2bm1iNXZFeHZubU11RWE2V2RNSVdoaEZCamhFQmljcGdoSE95UyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767625636),
('ZLjHGi2jy4c54r8LJHgYjYFpdD8K1EypT3SEuDR2', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRFNyZ1h0QVYxMjQyUGg1VFhyVHRhMlJTTzNycWRFN3ZvbnFsNG05bCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767831033),
('ZLueDU0bpoLCVCEB6nkyxEFQ1pHTf970aaR3N0t1', NULL, '4.194.91.73', 'Mozilla/5.0 (iPad; CPU OS 16_7_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWjl0Z3o3djI2SVdQNzlZV0JBck50M0FaNXoxWFJnNENYUFN5NzBrNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHBzOi8vZXhwb3phLmFwcC9pbmRleC5waHAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767531693),
('zmGFcQIqjsf6OEFbEEcrYxEjBvFucUlfMagj0O5B', NULL, '209.85.238.3', 'Mozilla/5.0 (X11; Linux i686; rv:93.0) Gecko/20100101 Firefox/93.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWktWZlRROHRmOWI0NUpUakFDTXc2WE5FYmRKTU1tbVNrcGVLa3hBMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768620878),
('zN0Zj5IQBlKjqWHQgmSwAaOVXIjoGvNHsuom4Ppt', NULL, '170.106.82.209', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR29lZThpZGhTYWNlSDNNWjBEZTFJYXNzT0VKbng5Q0QxMWFQMTVveiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767711059),
('zOx8HHd6PenNckOnLHuZrwJDYqopUBA5IwXp9Grg', NULL, '54.162.90.208', 'Mozilla/5.0 (X11; CrOS x86_64 14469.59.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.94 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic21haTlTUk9CY0hXekRFQWt3QzBHaEl5MlVVbWcwUXJEdklGcGNWQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768411741),
('zQs5lv6P7V60np4kHu5cBT34vv3STBVaZlxYgthB', NULL, '209.85.238.3', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiN1BudEs4R1ZPYnVSVlNWM3dpVWNGMjFvRXcyRzFtVmdqYklVN05ZayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768735858),
('ZQXSiIUdcqzz6x04mJsOQrhPyAgHUdin2jvwSRtd', NULL, '43.159.128.247', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid2V6b2ZURVBCc2Voc1RiaVlENGIydnRjMUlLQ2huZHI0SjNTazhvTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768470896);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('zRPDygaP1mJOteGBkVm2vTyEgXIfcUxXFt2Kv45L', NULL, '66.249.90.36', 'PlayStore-Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSEZETkVxcUY0U3JzdVlWZEt3NnZzamxHZnVOa2lsdXdlOTFSQkdCVSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768276682),
('ZS2isIhSyz1BDFZLbay6LldLS7tUSUhhzqpzzoCK', NULL, '34.229.67.133', 'Mozilla/5.0 (Linux; Android 5.1.1; Coolpad 3622A Build/LMY47V) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWduRlZybDNvWFBvODJJdTU5OXRUR3BQNGp2RUQ2OGhUbnRFWmhodiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768758573),
('zsFMuNyt2igdXwGUzJ8f0EaUkmh1cBbN0RsiAyW9', NULL, '93.158.90.70', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Viewer/99.9.8853.8', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVndRWnh1RGFqSFZtQ05kbEFOWjhDcXU5QzlhSXpYb1NoRHlDQnBkNiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpGQTlvRzc5ejVKRWhGMUwxIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768447049),
('Zt2PybG1zOFQHyDAqfFJv8zwP3Tima9XOgQ1yyFt', NULL, '195.24.236.199', '', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRWZqNkFhYlJ3UVJ0eGJiVWU4SGJqQ3dhVXZzbENnZTdkU1pEUUg0TCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768089263),
('ZTgXRM18cxnm420xonirCRcwkdhvJtuJEDQPny7S', NULL, '66.249.90.34', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieTNKcXJBNVRCV2lnNHpRUllCMmJTVTU2bTE0S1Q3N3JOZ2ZqWFE0RSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767891870),
('ZTwwW62MxWCvpHdn77rfZsu6Kxt8W7tQxz3Jz4E1', NULL, '170.106.82.209', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYlRZTmVkT3lsZE9vODR0RTEyZ3VsODlpRlhzRG5vUkRFdEFjVEN3VSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpwUTFtSkg4dmNTN3BCTmpMIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1768116108),
('zvBrIGsIj0UaJYq8uUWTw4TqwmiCvxsvlwJlYZZJ', NULL, '74.7.227.129', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.3; +https://openai.com/gptbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZXZTZExIWnlRMjgwOFdhWWN4TFQ1U1pVbkR5NUtwM0IzMnlKMjVkcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1767755881),
('ZwbK2uky556aCRfBlvCp9DkvK870rqCo94UPiqb7', NULL, '34.79.154.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM25VZjhEUlBvRGg1cU9DdVJ6ekd5d2RXQXlEUnpyTkJhRWRZTUVjeCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC9leHBvcy82L2VkaXQiO3M6NToicm91dGUiO3M6MTA6ImV4cG9zLmVkaXQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1768286335),
('zWbXe3ZVtyBdB960fY5gOvlBlilsdPofEgxebiBp', NULL, '66.249.73.99', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiQTlya3RsYjVYdjhqODlxeU1sVUZhRU1nbjNWRjFmM1JNTE81MVhTViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZXhwb3phLmFwcC9jbXMvcHJpdmFjeS1wb2xpY3kiO3M6NToicm91dGUiO3M6ODoiY21zLnNob3ciO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1767519315),
('zxSbNaP1FEFAKpmxM4bBDZtXYFzhHMoVwevmFfDY', NULL, '171.61.165.16', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaEptZVBMeFVCRTNTUzVidHNlV1poUlBXUE1naTlpOW8zdkVFUjdUUyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJuZXciO2E6MDp7fXM6Mzoib2xkIjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHBzOi8vZXhwb3phLmFwcC92ZW5kb3IvbG9naW4iO3M6NToicm91dGUiO3M6MTI6InZlbmRvci5sb2dpbiI7fX0=', 1768537967),
('zxyf8sRxRN8soRd3E0L4bIgKX1WPojMUpnmLki8x', NULL, '84.233.212.21', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRHI2dGNkYWxna1JIU0RxQ1d0NGRBbkt6ZGgwVVdmVWZ1YUcyZWpjUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768649851),
('Zy14BGdF3JgnUaIfnfvmILBICoGWsI96TDzuGmcf', NULL, '43.166.237.57', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVFyWVNqeU5OckMwNHpOSVVRWnF3dFNIOTNUWHBHYnIyV3phY3hJMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHBzOi8vZXhwb3phLmFwcC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1768646393),
('ZZkdCRkQN4QPI5df0ojv5CU7LgU8JlXQ7ZvIMLpK', NULL, '182.42.111.213', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUDJ5OW9jZ29TM3VLSGtwZFVtRnRNbmxKSGR6c0lURkRNYjI3cThqUSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTg6Imh0dHBzOi8vZXhwb3phLmFwcCI7czo1OiJyb3V0ZSI7czoyNzoiZ2VuZXJhdGVkOjpvOWlxeFpjTU5HZ3pJRjd5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1767639436);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` bigint UNSIGNED NOT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `key`, `value`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'payout_frequency', '15_days', '2025-12-18 18:15:39', '2025-12-18 18:15:39', NULL),
(2, 'custom_payout_date', NULL, '2025-12-18 18:15:39', '2025-12-18 18:15:39', NULL),
(3, 'vendor_commission', '5', '2025-12-18 18:15:39', '2026-01-13 12:30:47', NULL),
(4, 'gateway_fees', '2', '2025-12-18 18:15:39', '2026-01-17 01:33:07', NULL),
(5, 'admin_notifications', '0', '2025-12-18 18:15:39', '2025-12-18 18:15:39', NULL),
(6, 'delivery_fee_per_km', NULL, '2025-12-18 18:15:39', '2025-12-18 18:15:39', NULL),
(7, 'base_delivery_fee', '2', '2025-12-18 18:15:39', '2025-12-18 18:15:39', NULL),
(8, 'free_delivery_threshold', '0', '2025-12-18 18:15:39', '2025-12-28 18:26:40', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `slot_bookings`
--

CREATE TABLE `slot_bookings` (
  `id` bigint UNSIGNED NOT NULL,
  `expo_id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `vendor_expo_id` bigint UNSIGNED DEFAULT NULL,
  `slot_number` int DEFAULT NULL,
  `booked_slots` json NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `states`
--

CREATE TABLE `states` (
  `id` bigint UNSIGNED NOT NULL,
  `country_id` bigint UNSIGNED NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `states`
--

INSERT INTO `states` (`id`, `country_id`, `name_en`, `name_ar`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Al Asimah', 'العاصمة', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(2, 1, 'Hawalli', 'حولي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(3, 1, 'Farwaniya', 'الفروانية', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(4, 1, 'Ahmadi', 'الأحمدي', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(5, 1, 'Mubarak Al-Kabeer', 'مبارك الكبير', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(6, 1, 'Jahra', 'الجهراء', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(7, 1, 'Sabah Al Ahmad', 'صباح الأحمد', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(8, 1, 'Wafra', 'الوفرة', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(9, 1, 'Fintas', 'الفنطاس', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL),
(10, 1, 'Salwa', 'سلوى', 'active', '2025-12-18 17:18:28', '2025-12-18 17:18:28', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `id` bigint UNSIGNED NOT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `price` decimal(10,2) NOT NULL,
  `duration` enum('monthly','yearly') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','suspended','deleted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `sort_order` int NOT NULL DEFAULT '0',
  `ad_limit` int NOT NULL DEFAULT '0',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscriptions`
--

INSERT INTO `subscriptions` (`id`, `title_en`, `title_ar`, `description_en`, `description_ar`, `features`, `price`, `duration`, `status`, `sort_order`, `ad_limit`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, 'Expoza Dashboard Entry', 'دخول بوابة اكسبوزا', '<p>Access to Expo participation and booth booking with limited support for one month.</p>', '<p>حجز بوث بمعرض مع دعم محدود لمدة شهر واحد.</p>', '[\"One Expo Participation\",\"One Booth Booking\",\"Basic Support\"]', 0.00, 'monthly', 'active', 1, 0, NULL, '2025-12-18 17:18:27', '2026-01-06 19:11:15'),
(2, 'Standard Plan', 'الخطة القياسية', 'More features and better support.', 'مزيد من الميزات ودعم أفضل.', '[\"5 ads\",\"Standard support\",\"Access to analytics\"]', 24.99, 'monthly', 'suspended', 2, 5, NULL, '2025-12-18 17:18:27', '2025-12-21 16:23:15'),
(3, 'VIP STORE', 'اشتراك ال VIP', '<p>One banner advertisement with Expoza team full support.</p>', '<p>.اضافة اعلان واحد مع دعم كامل من فريق اكسبوزا</p>', '[\"One Banner Advertisement\",\"Full Team Support\"]', 100.00, 'monthly', 'active', 2, 1, NULL, '2025-12-18 17:18:27', '2026-01-13 12:50:46'),
(4, 'EXPOZA Plan (Yearly)', 'اشتراك اكسبوزا (سنوي)', '<p>Yearly access to basic features with limited support.</p>', '<p>حجز بمعرض مع دعم محدود .</p>', '[\"Basic support\",\"No premium features\"]', 0.00, 'yearly', 'active', 1, 0, NULL, '2025-12-18 17:18:27', '2026-01-13 12:48:29'),
(5, 'Standard Plan (Yearly)', 'الخطة القياسية (سنوي)', 'Yearly plan with more features and better support.', 'خطة سنوية مع مزيد من الميزات ودعم أفضل.', '[\"60 ads\",\"Standard support\",\"Access to analytics\"]', 249.99, 'yearly', 'suspended', 5, 60, NULL, '2025-12-18 17:18:27', '2025-12-21 16:16:02'),
(6, 'Premium Plan (Yearly)', 'الخطة المميزة (سنوي)', 'All features unlocked with priority support for a year.', 'جميع الميزات مفعلة مع دعم أولوية لمدة سنة.', '[\"Unlimited ads\",\"Priority support\",\"Featured listings\"]', 499.99, 'yearly', 'active', 6, 999, '2025-12-21 16:15:49', '2025-12-18 17:18:27', '2025-12-21 16:15:49'),
(7, 'VIP Team Support', 'دعم VIP', '<p>Full team support and adding products to your booth</p>', '<p> دعم كامل واضافة المنتجات في البوث</p>', '[\"Full Team Support\",\"Add Products\"]', 50.00, 'monthly', 'active', 0, 0, NULL, '2026-01-13 12:58:28', '2026-01-13 12:58:28');

-- --------------------------------------------------------

--
-- Table structure for table `support_requests`
--

CREATE TABLE `support_requests` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_info` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('contact','feedback','query','pending','resolved','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `google_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `apple_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','vendor','user') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `language` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'en',
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `mobile_verified_at` timestamp NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password_reset_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_reset_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `google_id`, `apple_id`, `full_name`, `mobile`, `phone`, `email`, `password`, `role`, `language`, `image`, `status`, `mobile_verified_at`, `email_verified_at`, `password_reset_token`, `password_reset_at`, `remember_token`, `last_login_at`, `deleted_at`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, 'Admin User', NULL, NULL, 'admin@example.com', '$2y$12$F5e9bz.rTP01lxt0KELRHOv9D.XhqilhFYA7Vr1q9rOnWmgnq7Uee', 'admin', 'en', NULL, 'active', NULL, '2025-12-18 17:18:27', NULL, NULL, 'iB9HSjpkPfFGK3R3mWrry2PjAYuIi8ASlJVzbuAI48wG03haZESsE9m8KkoR', '2026-01-19 13:34:39', NULL, '2025-12-18 17:18:27', '2026-01-19 13:34:39'),
(3, NULL, NULL, 'Ms. Beth Schultz', NULL, NULL, 'adrianna98@example.com', '$2y$12$O.8pAQAKeuzMfSutHLRpUOisaQd9BSR0clIiChfqrL86.UrwJI/xK', 'user', 'en', NULL, 'active', NULL, '2025-12-18 17:18:28', NULL, NULL, 'jWnoteI21t', NULL, NULL, '2025-12-18 17:18:28', '2025-12-18 17:18:28'),
(14, 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ5NmQwMDhlOGM3YmUxY2FlNDIwOWUwZDVjMjFiMDUwYTYxZTk2MGYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMjA1MzQ0MDYxNjAtdDlyN3NjY3VhMTRyYWZkazA0aGk5NTFhMGlwYjg4b2ouYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIxMjA1MzQ0MDYxNjAtbjJjcTg4NjhlZW9tMnY4bGZoN2szZDUza2dobWZ0bGkuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDAzMTc5MTQ4MTA5Mzg3MzAxOTIiLCJlbWFpbCI6ImFycGl0Lm1pcmFjbGVAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJBcnBpdCBLaHVudCIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NKaTd5QjdMTVVfYnZTMWluTlRqYjFWcEVBaGNJV3g3SXY2UERiVC0wQ3hYRE1lWnc9czk2LWMiLCJnaXZlbl9uYW1lIjoiQXJwaXQiLCJmYW1pbHlfbmFtZSI6IktodW50IiwiaWF0IjoxNzY3MDEwNzk0LCJleHAiOjE3NjcwMTQzOTR9.NUvYDeKn4K2EnhfM3gmhEcnOW1pzlXrOOQItA1D6bZ7GEK0Wo8l41BXzM-BHwwyXboGNFFwfdr_dyNAchBBJA-na78CH8Zu8LX4_3F8BDFEar0x70fqmqzfnsZpTPEH9a0r9Uvx4x82TezNgGh6UawTBVcVdDHlxmphSHx1gjc0-FY9A9pEHaVcuA1yMJ8nMCkHA2TX4Q1ianLmpmssVKQvCnmDFXChywXBbTtVQrk3V5efRageOHY924RaZMCe6fXFpTnmxq20UgkmXzposwXzM0eifJXN5EtKgqmE-3xA-K4u6U36Dgvtb9ZzNKZ-mLO3u847OERLipM0e-4Tsxw', NULL, 'Arpit Khunt', NULL, NULL, 'arpit.miracle@gmail.com', NULL, 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-29 17:53:15', '2025-12-29 17:53:15'),
(15, 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ5NmQwMDhlOGM3YmUxY2FlNDIwOWUwZDVjMjFiMDUwYTYxZTk2MGYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMjA1MzQ0MDYxNjAtdDlyN3NjY3VhMTRyYWZkazA0aGk5NTFhMGlwYjg4b2ouYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIxMjA1MzQ0MDYxNjAtbjJjcTg4NjhlZW9tMnY4bGZoN2szZDUza2dobWZ0bGkuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDgzNTkyMTg1MTc0MjE2NjY5NDciLCJlbWFpbCI6Im5hc2hlYS5rd0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6Ik5hc2hlYSBLdyIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NLYTNwU2g5RFVfZTV6VFdELUZGNHJZNFZ0Q1FaelZuNTlKWGp3Ym42NkpNdE9yY2c9czk2LWMiLCJnaXZlbl9uYW1lIjoiTmFzaGVhIiwiZmFtaWx5X25hbWUiOiJLdyIsImlhdCI6MTc2NzAxMjA1MiwiZXhwIjoxNzY3MDE1NjUyfQ.Ny8YTmQZ0dpskt7eVMDLVPW0ZsRYzKxlKWbdxWk_IJhzzb7Fh2EDvm0mV-nPz5cNFGjqReHXeWSUwtx88TtsB0qt_xfipAUdCwqCvfIdie4vfZAcSQkCl4ihpmdxlA9qsgz8ZOtuPQcrhqcju_KJ1abXljZwPfxxQuB3Qfc2Mrt9MMzBAZvmgWwjGWvNkPPSfYyNCZRendm9lQdLeP2lK3JOpagvq-kjck5TvBjptxtXKcEEAP15R4fLIRHpHVdo5D0WdCfqyh7OIAqdLF74oMmdVH3zltO97Ngi43Z1WOb8PKwpFY_W8L-m4vBtfXE3R1o-E4uItONz3d0X6pwY4Q', NULL, 'Nashea Kw', NULL, NULL, 'nashea.kw@gmail.com', NULL, 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-29 18:10:54', '2025-12-29 18:10:54'),
(22, NULL, 'eyJraWQiOiJZUXJxZE1ENGJxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnZnYS5leHBvemEiLCJleHAiOjE3Njc5NTMxMDIsImlhdCI6MTc2Nzg2NjcwMiwic3ViIjoiMDAxMTIzLmVkMDZiOWNhYjUwMDQzNmFiM2M5YTI4YmE3NDA5MjlmLjEwMDUiLCJjX2hhc2giOiJZQ1VoVEx5RTFFQ0hLSDVBVTBtQXdRIiwiZW1haWwiOiJvdGhtYW4uMTk5NTVAaG90bWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXV0aF90aW1lIjoxNzY3ODY2NzAyLCJub25jZV9zdXBwb3J0ZWQiOnRydWUsInJlYWxfdXNlcl9zdGF0dXMiOjJ9.Qaa67k1kDB38KIY3UKfSfPgTwP2upjZP9CenY8Zh9l0bf4NzeEVQAWShwYQXgx99v2L_bWFbyQs4DdqsF_Ene5CnV7oc3tlPsxhZBqnsmcAIYjO1mRVwxpxNZ1TzJYr0cvKbBxzjWLJb_orua2VdjzPmouX1mM-qA-1bdtSfDY2hdgQHXnhazbdhHxNr7h8WO-i8H1zhVWqkGq4M27d12hamlKl-p8YevMnGACtPyM8gnlaxIGJKrPigGpWvewXFkvHAHcXzmZKj3CQJAquWV2vZ29Cdp1OkUZLXdAj8aXw4tTYa_PcxZMpUE0BU2Ms3oDzbxE5L8gzCT_ycYYqAdQ', 'Othman', NULL, NULL, 'othman.19955@hotmail.com', NULL, 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, 'c17d7e2b74a6e436c8de463c451c30587.0.rrrst.RYSd2nvctE1n6FhXfxSXPw', NULL, NULL, '2026-01-08 15:35:06', '2026-01-08 15:36:10'),
(25, 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjRiYTZlZmVmNWUxNzIxNDk5NzFhMmQzYWJiNWYzMzJlMGY3ODcxNjUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMjA1MzQ0MDYxNjAtaXJuOWIwcTZmbWxnY2E1YmVuN3JkZWN1Nm5odmdsZ28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIxMjA1MzQ0MDYxNjAtaXJuOWIwcTZmbWxnY2E1YmVuN3JkZWN1Nm5odmdsZ28uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDU2MzMyNzIxNDkzMTM5MTYyMzkiLCJlbWFpbCI6Im1hbG1vaGFpbnlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJsaXhrWjh6N3MzUUZVai1LUUVFdi13Iiwibm9uY2UiOiJzV2VCRGRvTUhlYzc0WTBlU3k2V3ZEM3J4MmUyQ204Tll6MS1aMW56N2prIiwibmFtZSI6Ik0gQWxNIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0s3WEx0X0Ewd1lBOVZFNnJ2UXlhcG1PQklfRTFsZ09UWF95SUNxRlpjc1cwekI1Zz1zOTYtYyIsImdpdmVuX25hbWUiOiJNIiwiZmFtaWx5X25hbWUiOiJBbE0iLCJpYXQiOjE3NjgxMTAyMzIsImV4cCI6MTc2ODExMzgzMn0.Zp1eP-7t8FygJjNqRoDGA2IxcEY4bDltjAw3TXypbhAHr020cU9m-SjUq7if8CSQKJB6mR9VlCiaXajk8nzPy1It1A7xkwZfWw6QiBnlNbJx0y4s-6Hu6jis0PbLO8EO0GKh7IEXALaa1Is5340M7q5F1tXlydqre3S30KV2N0cyxWfOyZ7kTqtSevaj8iQecnarZFp2govRl8qvA47R6yKg4rDxCVCTvOJE7iZaNTLkeFcIWgXayx8GZssWwAowyBPmY8jSxZJ5h13Z3Qu8Eoi_WTvRwldj6cf6x8jJoLCvzxmkH9Ggh1vfcdRtvulxFEIGT8TlEtwkbUy6PD7Zww', NULL, 'M AlM', NULL, NULL, 'malmohainy@gmail.com', NULL, 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-11 11:14:01', '2026-01-11 11:14:01'),
(28, NULL, 'eyJraWQiOiJiRnd6bGVSOHRmIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnZnYS5leHBvemEiLCJleHAiOjE3NjgzNjkyMDMsImlhdCI6MTc2ODI4MjgwMywic3ViIjoiMDAwNTIyLmE1MmJlYTRjMzUyYzQ2MWZhYWNiMGMzOWQyNGRmMDg0LjA1NDAiLCJjX2hhc2giOiJ2d0JjYUViZGNsOG5BVjB6TnBFWlhBIiwiZW1haWwiOiJhLmFsbmFrYXNAaG90bWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXV0aF90aW1lIjoxNzY4MjgyODAzLCJub25jZV9zdXBwb3J0ZWQiOnRydWUsInJlYWxfdXNlcl9zdGF0dXMiOjJ9.fNFfA5VUT2uEouu4lF04us4Y12LSgPvOCOvMmU-ZxwsJSYJlAPize2CkI16G3sxtHoFf53YZXvYAAr5q-oQoL3bn4ynE_W1iS5ml8umpIRfKvxGiojWesp6kT1cyqlEy3bcBSxoMVyCIISC5eZiwlnb1r43Cv0FYNHw0EWk8US6aGPSjzYjD0D-7sz8mHO-md2ZSNgif40EmcDy-7dJICZToZ8mLJjyXwXeHxGY_QOIm0ejBp5lFdX3mO6JdwzYX6UMoK3J__ctuv-2WVdVI0axVxJopsSRK1IhdM3jM33fxCHO6ghYeZIIdjrZOZ5HZj-m_6mL_uRsnyzzBHsmm3g', 'User', NULL, NULL, 'a.alnakas@hotmail.com', NULL, 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, 'cdd39c330532945f6b852ed304dfc763c.0.mvss.PlpJ_Qvl2PMAS0L_BVTb8Q', NULL, NULL, '2026-01-13 11:10:07', '2026-01-13 11:10:07'),
(32, NULL, NULL, 'Ahmad Abu Ayshah', '55556968', NULL, 'a.abuayshah@gmail.com', '$2y$12$.UAlW5gxAJKvYfH3W8Ik6eQ6hkLYB3AN8eoBPpcw9SqSRYfIjAfZu', 'user', 'en', NULL, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-13 16:03:12', '2026-01-13 16:03:21'),
(41, NULL, NULL, 'Craft N Company', '97908068', '97908068', 'dalya01@hotmail.com', '$2y$12$rbSbum0XYAuYGwXP71ki9.sVthmru1jl4i/9c4EpjSbtlvGCbavCm', 'vendor', 'en', NULL, 'active', NULL, '2026-01-18 14:13:23', NULL, NULL, 'nyxJ9p1oteQ5IJnkXB2YycC3DkOpSIOVAO4yFXLSgseQDayNjEUdTLjmcuLc', NULL, NULL, '2026-01-18 14:13:23', '2026-01-18 14:13:23');

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE `vendors` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `category_id` bigint UNSIGNED DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand_name_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand_name_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `logo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `commission` decimal(5,2) NOT NULL DEFAULT '10.00',
  `kyc_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `kyc_rejection_reason_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `kyc_rejection_reason_ar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `kyc_documents` text COLLATE utf8mb4_unicode_ci,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `use_armada_delivery` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vendors`
--

INSERT INTO `vendors` (`id`, `user_id`, `category_id`, `name`, `brand_name_en`, `brand_name_ar`, `description_en`, `description_ar`, `logo`, `mobile`, `email`, `status`, `commission`, `kyc_status`, `kyc_rejection_reason_en`, `kyc_rejection_reason_ar`, `kyc_documents`, `is_verified`, `use_armada_delivery`, `created_at`, `updated_at`, `deleted_at`) VALUES
(14, 41, NULL, 'Craft N Company', 'Craft N Company', 'Craft N Company', NULL, NULL, NULL, '97908068', 'dalya01@hotmail.com', 'active', 5.00, 'pending', NULL, NULL, NULL, 0, 0, '2026-01-18 14:13:23', '2026-01-18 14:13:23', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vendor_payouts`
--

CREATE TABLE `vendor_payouts` (
  `id` bigint UNSIGNED NOT NULL,
  `payout_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `status` enum('pending','approved','completed','rejected','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_details` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` text COLLATE utf8mb4_unicode_ci,
  `scheduled_date` date NOT NULL,
  `processed_date` date DEFAULT NULL,
  `transaction_reference_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendor_subscriptions`
--

CREATE TABLE `vendor_subscriptions` (
  `id` bigint UNSIGNED NOT NULL,
  `vendor_id` bigint UNSIGNED NOT NULL,
  `subscription_id` bigint UNSIGNED NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_status` enum('pending','processing','paid','failed','refunded','partially_refunded','chargeback') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `waiting_lists`
--

CREATE TABLE `waiting_lists` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_notified` tinyint(1) NOT NULL DEFAULT '0',
  `notified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wishlists`
--

INSERT INTO `wishlists` (`id`, `user_id`, `product_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 10, 2, '2025-12-24 18:58:19', '2025-12-24 18:58:19', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addresses_user_id_foreign` (`user_id`),
  ADD KEY `addresses_city_id_foreign` (`city_id`);

--
-- Indexes for table `ads`
--
ALTER TABLE `ads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ads_vendor_id_foreign` (`vendor_id`),
  ADD KEY `ads_status_priority_index` (`status`,`priority`),
  ADD KEY `ads_start_date_end_date_index` (`start_date`,`end_date`);

--
-- Indexes for table `attributes`
--
ALTER TABLE `attributes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `audit_logs_admin_id_foreign` (`admin_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `carts_user_id_foreign` (`user_id`),
  ADD KEY `carts_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_items_cart_id_foreign` (`cart_id`),
  ADD KEY `cart_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cities_country_id_foreign` (`country_id`),
  ADD KEY `cities_state_id_foreign` (`state_id`);

--
-- Indexes for table `cms_pages`
--
ALTER TABLE `cms_pages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cms_pages_slug_unique` (`slug`);

--
-- Indexes for table `contact_queries`
--
ALTER TABLE `contact_queries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contact_queries_user_id_foreign` (`user_id`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coupon_usages`
--
ALTER TABLE `coupon_usages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `coupon_usages_order_id_foreign` (`order_id`),
  ADD KEY `coupon_usages_user_id_foreign` (`user_id`);

--
-- Indexes for table `expos`
--
ALTER TABLE `expos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `expo_category`
--
ALTER TABLE `expo_category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `expo_category_expo_id_foreign` (`expo_id`),
  ADD KEY `expo_category_category_id_foreign` (`category_id`);

--
-- Indexes for table `expo_products`
--
ALTER TABLE `expo_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `expo_products_expo_id_foreign` (`expo_id`),
  ADD KEY `expo_products_product_id_foreign` (`product_id`),
  ADD KEY `expo_products_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `expo_product_coupons`
--
ALTER TABLE `expo_product_coupons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expo_product_coupons_code_unique` (`code`);

--
-- Indexes for table `expo_sections`
--
ALTER TABLE `expo_sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expo_vendor_section_slot_unique` (`expo_id`,`vendor_id`,`section_id`,`slot_id`),
  ADD KEY `expo_sections_vendor_id_foreign` (`vendor_id`),
  ADD KEY `expo_sections_section_id_foreign` (`section_id`);

--
-- Indexes for table `expo_slots`
--
ALTER TABLE `expo_slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `expo_slots_expo_id_foreign` (`expo_id`),
  ADD KEY `expo_slots_product_id_foreign` (`product_id`);

--
-- Indexes for table `expo_vendor`
--
ALTER TABLE `expo_vendor`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expo_vendor_expo_id_vendor_id_unique` (`expo_id`,`vendor_id`),
  ADD KEY `expo_vendor_vendor_id_foreign` (`vendor_id`),
  ADD KEY `expo_vendor_address_id_foreign` (`address_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `finance_transactions_transaction_id_unique` (`transaction_id`),
  ADD KEY `finance_transactions_user_id_foreign` (`user_id`),
  ADD KEY `finance_transactions_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `fulfillments`
--
ALTER TABLE `fulfillments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fulfillments_order_id_foreign` (`order_id`);

--
-- Indexes for table `fulfillment_items`
--
ALTER TABLE `fulfillment_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fulfillment_items_fullfilment_id_foreign` (`fullfilment_id`),
  ADD KEY `fulfillment_items_item_id_foreign` (`item_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  ADD KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indexes for table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  ADD KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`);

--
-- Indexes for table `notification_views`
--
ALTER TABLE `notification_views`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notification_views_notification_id_foreign` (`notification_id`),
  ADD KEY `notification_views_user_id_foreign` (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `otps`
--
ALTER TABLE `otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `otps_user_id_foreign` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_category_id_foreign` (`category_id`),
  ADD KEY `products_vendor_id_foreign` (`vendor_id`),
  ADD KEY `products_parent_id_foreign` (`parent_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviews_user_id_foreign` (`user_id`),
  ADD KEY `reviews_product_id_foreign` (`product_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`);

--
-- Indexes for table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `role_has_permissions_role_id_foreign` (`role_id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sections_category_id_foreign` (`category_id`),
  ADD KEY `sections_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `section_products`
--
ALTER TABLE `section_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `section_products_section_id_foreign` (`section_id`),
  ADD KEY `section_products_product_id_foreign` (`product_id`),
  ADD KEY `section_products_vendor_id_foreign` (`vendor_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `settings_key_unique` (`key`);

--
-- Indexes for table `slot_bookings`
--
ALTER TABLE `slot_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `slot_bookings_expo_id_foreign` (`expo_id`),
  ADD KEY `slot_bookings_vendor_id_foreign` (`vendor_id`),
  ADD KEY `slot_bookings_slot_number_index` (`slot_number`),
  ADD KEY `slot_bookings_vendor_expo_id_foreign` (`vendor_expo_id`);

--
-- Indexes for table `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`id`),
  ADD KEY `states_country_id_foreign` (`country_id`);

--
-- Indexes for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `support_requests`
--
ALTER TABLE `support_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `support_requests_user_id_foreign` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vendors_user_id_unique` (`user_id`),
  ADD KEY `vendors_category_id_foreign` (`category_id`);

--
-- Indexes for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vendor_payouts_payout_id_unique` (`payout_id`),
  ADD KEY `vendor_payouts_vendor_id_foreign` (`vendor_id`),
  ADD KEY `vendor_payouts_approved_by_foreign` (`approved_by`);

--
-- Indexes for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vendor_subscriptions_vendor_id_foreign` (`vendor_id`),
  ADD KEY `vendor_subscriptions_subscription_id_foreign` (`subscription_id`);

--
-- Indexes for table `waiting_lists`
--
ALTER TABLE `waiting_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `waiting_lists_user_id_foreign` (`user_id`),
  ADD KEY `waiting_lists_product_id_foreign` (`product_id`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wishlists_user_id_product_id_unique` (`user_id`,`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ads`
--
ALTER TABLE `ads`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `attributes`
--
ALTER TABLE `attributes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `cms_pages`
--
ALTER TABLE `cms_pages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `contact_queries`
--
ALTER TABLE `contact_queries`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `coupon_usages`
--
ALTER TABLE `coupon_usages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expos`
--
ALTER TABLE `expos`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `expo_category`
--
ALTER TABLE `expo_category`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expo_products`
--
ALTER TABLE `expo_products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `expo_product_coupons`
--
ALTER TABLE `expo_product_coupons`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expo_sections`
--
ALTER TABLE `expo_sections`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expo_slots`
--
ALTER TABLE `expo_slots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expo_vendor`
--
ALTER TABLE `expo_vendor`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faqs`
--
ALTER TABLE `faqs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `fulfillments`
--
ALTER TABLE `fulfillments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fulfillment_items`
--
ALTER TABLE `fulfillment_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `notification_views`
--
ALTER TABLE `notification_views`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `otps`
--
ALTER TABLE `otps`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `section_products`
--
ALTER TABLE `section_products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `slot_bookings`
--
ALTER TABLE `slot_bookings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `states`
--
ALTER TABLE `states`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `support_requests`
--
ALTER TABLE `support_requests`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `waiting_lists`
--
ALTER TABLE `waiting_lists`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_city_id_foreign` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `ads`
--
ALTER TABLE `ads`
  ADD CONSTRAINT `ads_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carts_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cities`
--
ALTER TABLE `cities`
  ADD CONSTRAINT `cities_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cities_state_id_foreign` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `contact_queries`
--
ALTER TABLE `contact_queries`
  ADD CONSTRAINT `contact_queries_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `coupon_usages`
--
ALTER TABLE `coupon_usages`
  ADD CONSTRAINT `coupon_usages_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `coupon_usages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expo_category`
--
ALTER TABLE `expo_category`
  ADD CONSTRAINT `expo_category_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_category_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expo_products`
--
ALTER TABLE `expo_products`
  ADD CONSTRAINT `expo_products_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_products_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expo_sections`
--
ALTER TABLE `expo_sections`
  ADD CONSTRAINT `expo_sections_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_sections_section_id_foreign` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_sections_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expo_slots`
--
ALTER TABLE `expo_slots`
  ADD CONSTRAINT `expo_slots_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_slots_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expo_vendor`
--
ALTER TABLE `expo_vendor`
  ADD CONSTRAINT `expo_vendor_address_id_foreign` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expo_vendor_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expo_vendor_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  ADD CONSTRAINT `finance_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `finance_transactions_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `fulfillments`
--
ALTER TABLE `fulfillments`
  ADD CONSTRAINT `fulfillments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fulfillment_items`
--
ALTER TABLE `fulfillment_items`
  ADD CONSTRAINT `fulfillment_items_fullfilment_id_foreign` FOREIGN KEY (`fullfilment_id`) REFERENCES `fulfillments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fulfillment_items_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notification_views`
--
ALTER TABLE `notification_views`
  ADD CONSTRAINT `notification_views_notification_id_foreign` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notification_views_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `otps`
--
ALTER TABLE `otps`
  ADD CONSTRAINT `otps_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `products_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sections`
--
ALTER TABLE `sections`
  ADD CONSTRAINT `sections_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sections_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `section_products`
--
ALTER TABLE `section_products`
  ADD CONSTRAINT `section_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `section_products_section_id_foreign` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `section_products_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `slot_bookings`
--
ALTER TABLE `slot_bookings`
  ADD CONSTRAINT `slot_bookings_expo_id_foreign` FOREIGN KEY (`expo_id`) REFERENCES `expos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `slot_bookings_vendor_expo_id_foreign` FOREIGN KEY (`vendor_expo_id`) REFERENCES `expo_vendor` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `slot_bookings_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `states`
--
ALTER TABLE `states`
  ADD CONSTRAINT `states_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `support_requests`
--
ALTER TABLE `support_requests`
  ADD CONSTRAINT `support_requests_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `vendors`
--
ALTER TABLE `vendors`
  ADD CONSTRAINT `vendors_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vendors_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_payouts`
--
ALTER TABLE `vendor_payouts`
  ADD CONSTRAINT `vendor_payouts_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vendor_payouts_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vendor_subscriptions`
--
ALTER TABLE `vendor_subscriptions`
  ADD CONSTRAINT `vendor_subscriptions_subscription_id_foreign` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `vendor_subscriptions_vendor_id_foreign` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `waiting_lists`
--
ALTER TABLE `waiting_lists`
  ADD CONSTRAINT `waiting_lists_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `waiting_lists_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

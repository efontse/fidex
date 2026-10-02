-- ========================================================
-- FIDEX: Digital Agricultural Networking Platform
-- Database Setup Script for XAMPP / MySQL / phpMyAdmin
-- Database: fidex_db
-- ========================================================

CREATE DATABASE IF NOT EXISTS `fidex_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `fidex_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Users Table
DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `fullName` VARCHAR(255) NOT NULL,
  `phoneNumber` VARCHAR(50) NOT NULL UNIQUE,
  `role` ENUM('visitor', 'farmer', 'consumer', 'logistician', 'admin') NOT NULL DEFAULT 'visitor',
  `isActive` TINYINT(1) NOT NULL DEFAULT 1,
  `address` VARCHAR(255) NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Sessions Table (Auth & OTP Management)
DROP TABLE IF EXISTS `Sessions`;
CREATE TABLE `Sessions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `otpCode` VARCHAR(10) NULL,
  `deviceId` VARCHAR(255) NULL,
  `failedAttempts` INT NOT NULL DEFAULT 0,
  `expiresAt` DATETIME NULL,
  `isActive` TINYINT(1) NOT NULL DEFAULT 1,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `Users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Products Table (Agricultural Goods)
DROP TABLE IF EXISTS `Products`;
CREATE TABLE `Products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `category` VARCHAR(100) NOT NULL DEFAULT 'Other',
  `harvestDate` DATE NULL,
  `unit` VARCHAR(50) NOT NULL DEFAULT 'kg',
  `farmerId` INT NOT NULL,
  `imageUrl` VARCHAR(500) NULL,
  `isApproved` TINYINT(1) NOT NULL DEFAULT 1,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`farmerId`) REFERENCES `Users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Value Chain Events Table (Farm-to-Fork Traceability)
DROP TABLE IF EXISTS `ValueChainEvents`;
CREATE TABLE `ValueChainEvents` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `farmerId` INT NOT NULL,
  `productId` INT NULL,
  `status` VARCHAR(100) NOT NULL,
  `notes` TEXT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`farmerId`) REFERENCES `Users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`productId`) REFERENCES `Products`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Baskets Table
DROP TABLE IF EXISTS `Baskets`;
CREATE TABLE `Baskets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `consumerId` INT NOT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`consumerId`) REFERENCES `Users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Basket Items Table
DROP TABLE IF EXISTS `BasketItems`;
CREATE TABLE `BasketItems` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `basketId` INT NOT NULL,
  `productId` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`basketId`) REFERENCES `Baskets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`productId`) REFERENCES `Products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Orders Table
DROP TABLE IF EXISTS `Orders`;
CREATE TABLE `Orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `consumerId` INT NOT NULL,
  `orderDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `totalAmount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `status` ENUM('pending', 'paid', 'processing', 'in_transit', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  `deliveryAddress` VARCHAR(255) NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`consumerId`) REFERENCES `Users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Order Items Table
DROP TABLE IF EXISTS `OrderItems`;
CREATE TABLE `OrderItems` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderId` INT NOT NULL,
  `productId` INT NOT NULL,
  `qty` INT NOT NULL DEFAULT 1,
  `subtotal` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`orderId`) REFERENCES `Orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`productId`) REFERENCES `Products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Payments Table
DROP TABLE IF EXISTS `Payments`;
CREATE TABLE `Payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderId` INT NOT NULL UNIQUE,
  `amount` DECIMAL(10, 2) NOT NULL,
  `status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  `method` VARCHAR(50) NOT NULL DEFAULT 'card',
  `providerReference` VARCHAR(255) NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`orderId`) REFERENCES `Orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Deliveries Table (Logistics Coordination)
DROP TABLE IF EXISTS `Deliveries`;
CREATE TABLE `Deliveries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderId` INT NOT NULL UNIQUE,
  `logisticianId` INT NULL,
  `pickupPoint` VARCHAR(255) NOT NULL,
  `dropoffPoint` VARCHAR(255) NOT NULL,
  `pickupCoordinates` VARCHAR(100) NULL,
  `dropoffCoordinates` VARCHAR(100) NULL,
  `estimatedDistanceKm` DECIMAL(6, 2) NULL,
  `status` ENUM('pending', 'assigned', 'in_transit', 'delivered', 'failed') NOT NULL DEFAULT 'pending',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`orderId`) REFERENCES `Orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`logisticianId`) REFERENCES `Users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================================
-- INITIAL SEED DATA (Demo Accounts & Products)
-- ========================================================

-- Users
INSERT INTO `Users` (`id`, `fullName`, `phoneNumber`, `role`, `isActive`) VALUES
(1, 'Amadou Diallo (Producer)', '+2348011111111', 'farmer', 1),
(2, 'Grace Adewale (Producer)', '+2348022222222', 'farmer', 1),
(3, 'Sarah Johnson (Buyer)', '+2348033333333', 'consumer', 1),
(4, 'Michael Chen (Buyer)', '+2348044444444', 'consumer', 1),
(5, 'David Okonkwo (Fleet Lead)', '+2348055555555', 'logistician', 1),
(6, 'Amina Bello (Platform Admin)', '+2348099999999', 'admin', 1),
(7, 'Guest Explorer', '+2348077777777', 'visitor', 1);

-- Sessions with master demo OTP '123456'
INSERT INTO `Sessions` (`userId`, `otpCode`, `deviceId`, `failedAttempts`, `expiresAt`, `isActive`) VALUES
(1, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(2, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(3, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(4, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(5, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(6, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1),
(7, '123456', 'demo-suite', 0, DATE_ADD(NOW(), INTERVAL 30 DAY), 1);

-- Products
INSERT INTO `Products` (`id`, `name`, `description`, `price`, `quantity`, `category`, `harvestDate`, `unit`, `farmerId`, `isApproved`) VALUES
(1, 'Fresh Organic Cassava Roots', 'High starch content, harvested from fertile volcanic soil. Ideal for fufu, gari, and flour processing.', 45.00, 1500, 'Tubers', '2026-09-01', 'kg', 1, 1),
(2, 'Yellow Maize Grain (Grade A)', 'Clean, moisture-controlled grain suitable for milling, feed formulation, and food manufacturing.', 32.50, 3000, 'Grains', '2026-08-25', 'kg', 1, 1),
(3, 'Vine-Ripened Roma Tomatoes', 'Juicy, rich red tomatoes naturally ripened in greenhouse enclosures with minimal pesticide exposure.', 28.00, 850, 'Vegetables', '2026-09-10', 'kg', 2, 1),
(4, 'Premium Fermented Cocoa Beans', 'Export-grade dried cocoa beans with rich chocolate notes and standardized fermentation.', 95.00, 600, 'Cash Crops', '2026-08-15', 'kg', 2, 1),
(5, 'Export Quality White Yams', 'Firm, mature tubers harvested at peak starch maturity. Excellent shelf-life.', 55.00, 900, 'Tubers', '2026-08-28', 'tuber', 1, 1),
(6, 'Organic Sweet Bell Peppers', 'Crisp tricolor bell peppers cultivated under drip irrigation.', 40.00, 500, 'Vegetables', '2026-09-15', 'kg', 2, 1);

-- Value Chain Events
INSERT INTO `ValueChainEvents` (`farmerId`, `productId`, `status`, `notes`, `timestamp`) VALUES
(1, 1, 'Harvested', 'Hand-harvested at Green Valley Farm Plot B.', '2026-09-01 08:30:00'),
(1, 1, 'Washed & Graded', 'Cleaned of dirt and classified into export grade A.', '2026-09-01 14:00:00'),
(1, 1, 'Cold Storage Depot', 'Stored at 12°C in Regional Farm Hub awaiting pickup.', '2026-09-02 10:00:00'),
(2, 4, 'Fermentation Complete', 'Banana leaf tiered fermentation completed over 6 days.', '2026-08-21 09:00:00'),
(2, 4, 'Sun Dried & Moisture Verified', 'Moisture measured at 6.8%. Ready for packaging.', '2026-08-28 16:00:00');

-- Demo Order
INSERT INTO `Orders` (`id`, `consumerId`, `orderDate`, `totalAmount`, `status`, `deliveryAddress`) VALUES
(101, 3, NOW(), 228.00, 'in_transit', '42 Marina Street, Central Lagos');

INSERT INTO `OrderItems` (`orderId`, `productId`, `qty`, `subtotal`) VALUES
(101, 1, 2, 90.00),
(101, 5, 2, 110.00),
(101, 3, 1, 28.00);

INSERT INTO `Payments` (`orderId`, `amount`, `status`, `method`, `providerReference`) VALUES
(101, 228.00, 'completed', 'card', 'fidex_txn_demo_ref_123');

INSERT INTO `Deliveries` (`orderId`, `logisticianId`, `pickupPoint`, `dropoffPoint`, `pickupCoordinates`, `dropoffCoordinates`, `estimatedDistanceKm`, `status`) VALUES
(101, 5, 'Regional Farm Hub, Plot B', '42 Marina Street, Central Lagos', '7.1500,3.8200', '6.5244,3.3792', 12.80, 'in_transit');

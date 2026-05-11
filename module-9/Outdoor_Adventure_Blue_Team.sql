-- ============================================================
-- OUTDOOR ADVENTURE DATABASE
-- Blue Team: Sheridan Dela Cruz, Megan Mosier,
--            Garvin Stewart, Garrett Woods
-- Module 9.1  |  May 2026
-- ============================================================

CREATE DATABASE IF NOT EXISTS Outdoor_Adventure;
USE Outdoor_Adventure;

-- Drop tables in reverse dependency order to avoid FK conflicts
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS EquipmentSale;
DROP TABLE IF EXISTS EquipmentRental;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS TripSupply;
DROP TABLE IF EXISTS Supply;
DROP TABLE IF EXISTS Supplier;
DROP TABLE IF EXISTS TripGuide;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Role;

-- ============================================================
-- ROLE
-- Stores employee role classifications.
-- 3NF: RoleName is fully functionally dependent on RoleID only.
-- ============================================================
CREATE TABLE Role (
    RoleID   INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(100) NOT NULL
);

-- ============================================================
-- EMPLOYEE
-- Stores staff linked to exactly one role.
-- 3NF: No transitive dependencies; RoleID is FK only.
-- ============================================================
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName  VARCHAR(100) NOT NULL,
    LastName   VARCHAR(100) NOT NULL,
    RoleID     INT          NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

-- ============================================================
-- LOCATION
-- Stores region + destination pairs for trips.
-- 3NF: Both attributes depend on LocationID only.
-- ============================================================
CREATE TABLE Location (
    LocationID  INT AUTO_INCREMENT PRIMARY KEY,
    RegionName  VARCHAR(100) NOT NULL,
    Destination VARCHAR(100) NOT NULL
);

-- ============================================================
-- TRIP
-- Stores trip schedule details linked to a location.
-- TripName added for readability; all attributes depend on
-- TripID with no transitive dependencies -> 3NF.
-- ============================================================
CREATE TABLE Trip (
    TripID          INT AUTO_INCREMENT PRIMARY KEY,
    LocationID      INT          NOT NULL,
    TripName        VARCHAR(150) NOT NULL,
    StartDate       DATE         NOT NULL,
    EndDate         DATE         NOT NULL,
    MaxParticipants INT          NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- ============================================================
-- TRIPGUIDE (Bridge: Trip <-> Employee)
-- Many-to-many; composite PK enforces uniqueness.
-- 3NF: no non-key attributes; bridge is inherently normalized.
-- ============================================================
CREATE TABLE TripGuide (
    TripID     INT NOT NULL,
    EmployeeID INT NOT NULL,
    PRIMARY KEY (TripID, EmployeeID),
    FOREIGN KEY (TripID)     REFERENCES Trip(TripID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- ============================================================
-- SUPPLIER
-- Stores vendor information.
-- 3NF: ContactInfo depends on SupplierID, not on SupplierName.
-- ============================================================
CREATE TABLE Supplier (
    SupplierID   INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactInfo  VARCHAR(255) NOT NULL
);

-- ============================================================
-- SUPPLY
-- Tracks supply purchases from a specific supplier.
-- 3NF: SupplierName removed (was transitive via SupplierID).
-- ============================================================
CREATE TABLE Supply (
    SupplyID     INT AUTO_INCREMENT PRIMARY KEY,
    SupplierID   INT          NOT NULL,
    Category     VARCHAR(100) NOT NULL,
    PurchaseDate DATE         NOT NULL,
    Quantity     INT          NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);

-- ============================================================
-- TRIPSUPPLY (Bridge: Trip <-> Supply)
-- Many-to-many with QuantityUsed attribute.
-- 3NF: QuantityUsed depends on the full composite key.
-- ============================================================
CREATE TABLE TripSupply (
    TripID       INT NOT NULL,
    SupplyID     INT NOT NULL,
    QuantityUsed INT NOT NULL,
    PRIMARY KEY (TripID, SupplyID),
    FOREIGN KEY (TripID)   REFERENCES Trip(TripID),
    FOREIGN KEY (SupplyID) REFERENCES Supply(SupplyID)
);

-- ============================================================
-- CUSTOMER
-- Stores guest contact information and running balance.
-- 3NF: RunningBalance is a stored operational attribute;
--      no transitive dependencies present.
-- ============================================================
CREATE TABLE Customer (
    CustomerID     INT AUTO_INCREMENT PRIMARY KEY,
    Name           VARCHAR(150) NOT NULL,
    ContactInfo    VARCHAR(255) NOT NULL,
    RunningBalance DECIMAL(10,2) DEFAULT 0.00
);

-- ============================================================
-- BOOKING
-- Links customers to trips with a booking date.
-- 3NF: BookingDate depends on BookingID only; trip and
--      customer data live in their own tables.
-- ============================================================
CREATE TABLE Booking (
    BookingID   INT AUTO_INCREMENT PRIMARY KEY,
    TripID      INT  NOT NULL,
    CustomerID  INT  NOT NULL,
    BookingDate DATE NOT NULL,
    FOREIGN KEY (TripID)     REFERENCES Trip(TripID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- ============================================================
-- EQUIPMENT
-- Tracks rentable/sellable inventory items.
-- 3NF: All attributes depend solely on EquipmentID.
-- ============================================================
CREATE TABLE Equipment (
    EquipmentID       INT AUTO_INCREMENT PRIMARY KEY,
    EquipmentType     VARCHAR(100) NOT NULL,
    PurchaseDate      DATE         NOT NULL,
    ConditionStatus   VARCHAR(100) NOT NULL,
    QuantityAvailable INT          NOT NULL
);

-- ============================================================
-- EQUIPMENTRENTAL
-- Tracks equipment rented by customers.
-- 3NF: All attributes depend on RentalID only.
-- ============================================================
CREATE TABLE EquipmentRental (
    RentalID          INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID        INT          NOT NULL,
    EquipmentID       INT          NOT NULL,
    RentalStartDate   DATE         NOT NULL,
    RentalEndDate     DATE         NOT NULL,
    ConditionOnReturn VARCHAR(100),
    FOREIGN KEY (CustomerID)  REFERENCES Customer(CustomerID),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID)
);

-- ============================================================
-- EQUIPMENTSALE
-- Tracks equipment sold to customers.
-- 3NF: SalePrice depends on SaleID; no transitive deps.
-- ============================================================
CREATE TABLE EquipmentSale (
    SaleID      INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT           NOT NULL,
    EquipmentID INT           NOT NULL,
    SaleDate    DATE          NOT NULL,
    SalePrice   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID)  REFERENCES Customer(CustomerID),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID)
);

-- ============================================================
-- BILLING
-- Tracks per-customer billing events.
-- 3NF: BillingMethod/Amount depend on BillingID only.
-- ============================================================
CREATE TABLE Billing (
    BillingID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID    INT           NOT NULL,
    BillingPeriod VARCHAR(100)  NOT NULL,
    BillingMethod VARCHAR(100)  NOT NULL,
    AmountCharged DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);


-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- ROLE (6 records)
INSERT INTO Role (RoleName) VALUES
('Guide'),
('Marketing'),
('Inventory & Supplies'),
('Ecommerce'),
('Owners/Administration'),
('Customer Support');

-- EMPLOYEE (7 records — all roles covered)
INSERT INTO Employee (FirstName, LastName, RoleID) VALUES
('John',      'MacNell',       1),
('D.B.',      'Marland',       1),
('Anita',     'Gallegos',      2),
('Dimitrios', 'Stravopolous',  3),
('Mei',       'Wong',          4),
('Blythe',    'Timmerson',     5),
('Jim',       'Ford',          6);

-- LOCATION (6 records)
INSERT INTO Location (RegionName, Destination) VALUES
('Africa',          'Cairo, Egypt'),
('Asia',            'Beijing, China'),
('Southern Europe', 'Venice, Italy'),
('Africa',          'Dodoma, Tanzania'),
('Asia',            'Tokyo, Japan'),
('Southern Europe', 'Madrid, Spain');

-- TRIP (6 records)
INSERT INTO Trip (LocationID, TripName, StartDate, EndDate, MaxParticipants) VALUES
(1, 'Pyramids & Nile Explorer',   '2025-03-01', '2025-03-15', 12),
(2, 'Great Wall & Beijing Stroll','2025-04-10', '2025-04-24', 10),
(3, 'Venetian Canals Journey',    '2025-05-20', '2025-06-03', 14),
(4, 'Serengeti Safari',           '2025-07-01', '2025-07-14', 8),
(5, 'Tokyo Cultural Immersion',   '2025-09-05', '2025-09-19', 15),
(6, 'Iberian Adventure',          '2025-10-10', '2025-10-24', 12);

-- TRIPGUIDE (6 records — guides assigned to trips)
INSERT INTO TripGuide (TripID, EmployeeID) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 1),
(6, 2);

-- SUPPLIER (6 records)
INSERT INTO Supplier (SupplierName, ContactInfo) VALUES
('Dicks Sporting Goods', 'supplies@dicks.com'),
('Cabelas',              'vendor@cabelas.com'),
('Bass Pro Shop',        'supplies@bps.com'),
('Target',               'care@target.com'),
('REI Co-op',            'wholesale@rei.com'),
('Shoe Carnival',        'bulk@shoecarnival.com');

-- SUPPLY (6 records)
INSERT INTO Supply (SupplierID, Category, PurchaseDate, Quantity) VALUES
(1, 'Tents',           '2025-01-10', 20),
(2, 'Sleeping Bags',   '2025-01-15', 30),
(3, 'Fishing Gear',    '2025-02-01', 15),
(4, 'First Aid Kits',  '2025-02-10', 25),
(5, 'Backpacks',       '2025-02-20', 18),
(6, 'Hiking Boots',    '2025-03-01', 22);

-- TRIPSUPPLY (6 records)
INSERT INTO TripSupply (TripID, SupplyID, QuantityUsed) VALUES
(1, 1, 6),
(1, 4, 3),
(2, 2, 8),
(3, 5, 7),
(4, 1, 4),
(5, 3, 5);

-- CUSTOMER (6 records)
INSERT INTO Customer (Name, ContactInfo, RunningBalance) VALUES
('Alice Tran',     'atran@email.com',    250.00),
('Marcus Webb',    'mwebb@email.com',    500.00),
('Sandra Okafor',  'sokafor@email.com',  175.00),
('Derek Lim',      'dlim@email.com',     320.00),
('Priya Kapoor',   'pkapoor@email.com',    0.00),
('Ben Nakamura',   'bnakamura@email.com',100.00);

-- BOOKING (6 records)
INSERT INTO Booking (TripID, CustomerID, BookingDate) VALUES
(1, 1, '2024-11-01'),
(2, 2, '2024-11-15'),
(3, 3, '2024-12-01'),
(4, 4, '2024-12-10'),
(5, 5, '2025-01-05'),
(6, 6, '2025-01-20');

-- EQUIPMENT (6 records)
INSERT INTO Equipment (EquipmentType, PurchaseDate, ConditionStatus, QuantityAvailable) VALUES
('Kayak',         '2023-03-15', 'Good',      8),
('Mountain Bike', '2023-05-20', 'Excellent', 10),
('Climbing Harness','2022-08-10','Fair',      15),
('Canoe',         '2023-01-25', 'Good',      6),
('Snowshoes',     '2022-11-30', 'Excellent', 12),
('Tent (4-person)','2024-01-10','Excellent', 20);

-- EQUIPMENTRENTAL (6 records)
INSERT INTO EquipmentRental (CustomerID, EquipmentID, RentalStartDate, RentalEndDate, ConditionOnReturn) VALUES
(1, 1, '2025-03-01', '2025-03-15', 'Good'),
(2, 2, '2025-04-10', '2025-04-24', 'Excellent'),
(3, 3, '2025-05-20', '2025-06-03', 'Fair'),
(4, 4, '2025-07-01', '2025-07-14', 'Good'),
(5, 5, '2025-09-05', '2025-09-19', NULL),
(6, 6, '2025-10-10', '2025-10-24', NULL);

-- EQUIPMENTSALE (6 records)
INSERT INTO EquipmentSale (CustomerID, EquipmentID, SaleDate, SalePrice) VALUES
(1, 3, '2025-03-16', 89.99),
(2, 5, '2025-04-25', 45.00),
(3, 2, '2025-06-04', 320.00),
(4, 1, '2025-07-15', 650.00),
(5, 6, '2025-09-20', 199.99),
(6, 4, '2025-10-25', 480.00);

-- BILLING (6 records)
INSERT INTO Billing (CustomerID, BillingPeriod, BillingMethod, AmountCharged) VALUES
(1, 'March 2025',   'Credit Card', 1200.00),
(2, 'April 2025',   'Credit Card', 1500.00),
(3, 'May 2025',     'Bank Transfer', 950.00),
(4, 'July 2025',    'Credit Card', 1100.00),
(5, 'September 2025','Check',      1350.00),
(6, 'October 2025', 'Credit Card', 1250.00);

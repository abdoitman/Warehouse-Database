-- CREATE DATABASE IF NOT EXISTS WAREHOUSE_DATA;
use warehouse_data;

CREATE TABLE IF NOT EXISTS Customers (
CustomerID VARCHAR(10),
Email VARCHAR(50),
Password VARCHAR(20), -- does passwords have a length constraint in the front end?
FullName VARCHAR(100),
Gender ENUM('Male', 'Female'),

CONSTRAINT pk_Customers PRIMARY KEY (CustomerID)
);

CREATE TABLE IF NOT EXISTS Products (
ProductID VARCHAR(10),
ProductName VARCHAR(100),
Price FLOAT CHECK (Price > 0),
Description TINYTEXT, -- 255 bytes
ItemsInStock INT CHECK (ItemsInStock >= 0),
Image_1  VARCHAR(100),
Image_2  VARCHAR(100),
Image_3  VARCHAR(100),

CONSTRAINT pk_Products PRIMARY KEY (ProductID)
);

CREATE TABLE IF NOT EXISTS Shelves (
ShelfID VARCHAR(10),
Location_X INT, -- constraints should be assigned according to the warehouse coordinates
Location_Y INT,
ProductID VARCHAR(10),
isHavingOrder BOOL,

CONSTRAINT pk_Shelves PRIMARY KEY (ShelfID),
CONSTRAINT fk_products_in_shelves FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

CREATE TABLE IF NOT EXISTS Robots (
RobotID VARCHAR(10),
Speed FLOAT CHECK (Speed >= 0),
BatteryPercentage FLOAT CHECK (BatteryPercentage >= 0 AND BatteryPercentage <= 100),
CurrentLocation_X INT CHECK (CurrentLocation_X >= 0 AND CurrentLocation_X <= 20), -- upper bound needs revision
CurrentLocation_Y INT CHECK (CurrentLocation_Y >= 0 AND CurrentLocation_Y <= 20), -- same
NextLocation_X INT CHECK (NextLocation_X >= 0 AND NextLocation_X <= 20), -- still same
NextLocation_Y INT CHECK (NextLocation_Y >= 0 AND NextLocation_Y <= 20), -- wallah same
isCharging BOOL,
ShelfID VARCHAR(10),

CONSTRAINT pk_Robots PRIMARY KEY (RobotID),
CONSTRAINT fk_shelves_in_robots FOREIGN KEY (ShelfID) REFERENCES Shelves (ShelfID)
);

CREATE TABLE IF NOT EXISTS Orders (
OrderID VARCHAR(10),
CustomerID VARCHAR(10),
TotalCost FLOAT CHECK(TotalCost > 0),
Orderdate TIMESTAMP,
PhoneNumber CHAR(11),
Address VARCHAR(150) NOT NULL,
PaymentStatus ENUM('Paid', 'Not yet'),
PaymentMethod ENUM('Cash', 'Online'),
OrderStatus ENUM('1' , '2' , '3'),  -- add constraints

CONSTRAINT pk_Orders PRIMARY KEY (OrderID),
CONSTRAINT fk_customers_in_orders FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

CREATE TABLE IF NOT EXISTS Orders_Details (
OrderID VARCHAR(10),
ProductID VARCHAR(10),
Quantity INT CHECK (Quantity > 0),

CONSTRAINT pk_Order_Details PRIMARY KEY (OrderID, ProductID),
CONSTRAINT fk_Orders_products_details FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
CONSTRAINT fk_products_orders_details FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

CREATE TABLE IF NOT EXISTS Customer_Services (
MessageID VARCHAR(10),
CustomerID VARCHAR(10),
PhoneNumber CHAR(11),
Message MEDIUMTEXT NOT NULL,

CONSTRAINT pk_Customer_Services PRIMARY KEY (MessageID),
CONSTRAINT fk_Customers_in_customer_services FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

CREATE TABLE IF NOT EXISTS Notification (
NotificationID VARCHAR(10),
Notification TEXT,
NotificationDateTime TIMESTAMP,

CONSTRAINT pk_Notification PRIMARY KEY (NotificationID)
);
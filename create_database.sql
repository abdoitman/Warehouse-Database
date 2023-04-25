CREATE DATABASE IF NOT EXISTS WAREHOUSE_DATA;
use warehouse_data;

CREATE TABLE IF NOT EXISTS Customers (
CustomerID VARCHAR(10),
Email VARCHAR(50) UNIQUE,
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

CREATE TABLE IF NOT EXISTS Shelves ( -- Erg3
ShelfID VARCHAR(10),
Location_X INT CHECK (Location_X BETWEEN 0 AND 20), 
Location_Y INT CHECK (Location_Y BETWEEN 0 AND 20),
ProductID VARCHAR(10),
NumberOfOrders INT CHECK (NumberOfOrders >= 0) DEFAULT 0,

CONSTRAINT pk_Shelves PRIMARY KEY (ShelfID),
CONSTRAINT fk_products_in_shelves FOREIGN KEY (ProductID) REFERENCES Products (ProductID),
CONSTRAINT unique_location UNIQUE KEY (Location_X, Location_Y)
);

CREATE TABLE IF NOT EXISTS Robots (
RobotID VARCHAR(10),
Speed DECIMAL(3,2) CHECK (Speed >= 0),
BatteryPercentage DECIMAL(3,2) CHECK (BatteryPercentage BETWEEN 0 AND 100),
CurrentLocation_X INT CHECK (CurrentLocation_X BETWEEN 0 AND 20), -- upper bound needs revision
CurrentLocation_Y INT CHECK (CurrentLocation_Y BETWEEN 0 AND 20), -- same
isCharging BOOL,
ShelfID VARCHAR(10) UNIQUE,

CONSTRAINT pk_Robots PRIMARY KEY (RobotID),
CONSTRAINT fk_shelves_in_robots FOREIGN KEY (ShelfID) REFERENCES Shelves (ShelfID),
CONSTRAINT UCurrent_robot_location UNIQUE KEY (CurrentLocation_X, CurrentLocation_Y)
);

CREATE TABLE IF NOT EXISTS Orders (
OrderID VARCHAR(10),
ProductID VARCHAR(10),
Quantity INT CHECK (Quantity > 0),

CONSTRAINT pk_Orders PRIMARY KEY (OrderID, ProductID),
CONSTRAINT fk_products_orders_details FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

CREATE TABLE IF NOT EXISTS Orders_details (
OrderID VARCHAR(10),
CustomerID VARCHAR(10),
TotalCost FLOAT CHECK(TotalCost > 0),
Orderdate TIMESTAMP DEFAULT now(),
PhoneNumber VARCHAR(13),
Address VARCHAR(150) NOT NULL,
PaymentMethod ENUM('Cash On-Delivery', 'Credit Card', 'Paypal'),
OrderStatus ENUM('New', 'In Progress', 'Completed'),  -- add constraints

CONSTRAINT pk_Orders_Details PRIMARY KEY (OrderID),
CONSTRAINT fk_Orders_products_details FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
CONSTRAINT fk_customers_in_orders FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

CREATE TABLE IF NOT EXISTS Wishlist (
CustomerID VARCHAR(10),
ProductID VARCHAR(10),

CONSTRAINT pk_Wishlist PRIMARY KEY (CustomerID, ProductID),
CONSTRAINT fk_customers_in_wishlist FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
CONSTRAINT fk_products_in_wishlist FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

CREATE TABLE IF NOT EXISTS Customer_Services (
MessageID VARCHAR(10),
CustomerID VARCHAR(10),
PhoneNumber CHAR(13),
Message TEXT NOT NULL,

CONSTRAINT pk_Customer_Services PRIMARY KEY (MessageID),
CONSTRAINT fk_Customers_in_customer_services FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

CREATE TABLE IF NOT EXISTS Notifications (
NotificationID INT AUTO_INCREMENT,
Notification TINYTEXT,
NotificationDateTime TIMESTAMP DEFAULT now(),

CONSTRAINT pk_Notification PRIMARY KEY (NotificationID)
);

# Warehouse Database
## About The Project
The project aims to create a database for a warehouse that stores information about the customers, shelves & products, orders, and robots serving the warehouse. The database is designed to efficiently manage all the data related to the warehouse operations, including the inventory of products and the movement of goods from the time an order is placed until they are moved to the administrator booth.<br>

The database stores information about the customers, including their names, addresses, and contact details. The database also stores information about the shelves in the warehouse, including their location and the products that are stored on them. This information is used by the robots that serve the warehouse to locate products and transport them from the appropriate shelves to the administrator booth.

<hr> 

## Designing The Database
After the normalization of data, the current database design is as follows:
![Database ER](https://github.com/abdoitman/warehouse-database/assets/77892920/5a9a61f3-ce9f-465a-8848-cfe67e892b60)

<hr> 

## Project files
The project consists of 2 main SQL scripts, that were made using MySQL:
  * [create_database.sql](https://github.com/abdoitman/warehouse-database/blob/main/create_database.sql)

    This script is responsible for __the creation of the tables inside the database and the relations between the primary keys of each table.__ Also, the constraints and the limits of each atribute (column) in the tables.
  * [database_logic.sql](https://github.com/abdoitman/warehouse-database/blob/main/database_logic.sql)

    This script is responsible for __the creation of the triggers of each table.__

### Triggers
The database contains __4 triggers__:

  __1) After inserting any new order__
  
```sql
  CREATE TRIGGER orders_after_insert AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE Shelves
    SET Shelves.NumberOfOrders = Shelves.NumberOfOrders + 1
    WHERE Shelves.ProductID = NEW.ProductID;
    
	UPDATE Products
	SET Products.ItemsInStock = Products.ItemsInStock - NEW.Quantity
	WHERE Products.ProductID = NEW.ProductID;
END
```
After inserting any order, the database should **automatically increament the number of orders** on the shelves containing any products from those shelves. Also, it will **subtract the quantity of the products in this order from the stock**.

  __2) After updating Products tables__
 
```sql
 CREATE TRIGGER Products_after_update AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
	IF NEW.ItemsInStock BETWEEN 1 AND 10
    THEN
		INSERT INTO Notifications(Notification) VALUES
		( CONCAT('Product ' , NEW.ProductName , ' (' , NEW.ProductID , ') is low in stock. [' , NEW.ItemsInStock , ' items left.]') );
	END IF;
    
	IF NEW.ItemsInStock = 0
    THEN
		INSERT INTO Notifications(Notification) VALUES
		( CONCAT('Product ' , NEW.ProductName , ' (' , NEW.ProductID , ') ' , 'is out of stock.') );
	END IF;
END
```
 When an item gets *low in stock (less than 10)* or *out of stock*, send a **notification in the notifications table**.
 
  __3) After inserting the order details__
  
```sql
CREATE TRIGGER orders_details_after_insert AFTER INSERT ON Orders_Details
FOR EACH ROW
BEGIN
    INSERT INTO Notifications(Notification) VALUES (
    (SELECT concat(OrderID , ' is placed with ' , (
    SELECT group_concat( concat(o.quantity, ' items from ', o.productid, ' in shelf ', s.shelfid) SEPARATOR ' & ')
    FROM Orders o JOIN Shelves s ON o.productid = s.productid
	WHERE OrderID = NEW.OrderID
    ))
    FROM Orders_Details
	WHERE OrderID = NEW.OrderID)
    );
END
```
Atfer the user places any order, a **notification should be sent with the order details**.

  __4) After completing any order__
  
```sql
CREATE TRIGGER orders_details_after_update AFTER UPDATE ON Orders_Details
FOR EACH ROW
BEGIN
	IF NEW.OrderStatus = 'Completed' THEN
		UPDATE Shelves
		SET NumberOfOrders = NumberOfOrders - 1
		WHERE ShelfID IN (
		SELECT S.ShelfID
		FROM Orders o
		JOIN Orders_Details od
		ON o.OrderID = od.OrderID
		JOIN Shelves s
		ON o.ProductID = s.ProductID
		WHERE o.OrderID = NEW.OrderID);
	END IF;
END
```
After completing any order, decrement the number of orders of each shelf that was increment in the placement of the order. 
This way if multiple orders containing products from the same shelf were placed, they will be all fulfiled.

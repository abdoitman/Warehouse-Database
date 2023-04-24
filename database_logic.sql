-- Create triggers for the database
USE warehouse_data;

DROP TRIGGER IF EXISTS orders_before_insert;
DROP TRIGGER IF EXISTS orders_detalis_after_insert;
DROP TRIGGER IF EXISTS notification_is_recieved;
DROP TRIGGER IF EXISTS Products_after_update;
DROP TRIGGER IF EXISTS orders_after_insert;

-- before an order is placed, make the orderdate = time of insertion 
DELIMITER //

-- after an order is placed:
-- 1) set the corrosponding shelf isHavingOrder to True
-- 2) decrement ItemsInStock for each product in the order
CREATE TRIGGER orders_detalis_after_insert AFTER INSERT ON orders_details
FOR EACH ROW
BEGIN
    UPDATE Shelves
    SET Shelves.isHavingOrder = True
    WHERE Shelves.ProductID = NEW.ProductID;
    
	UPDATE Products
	SET Products.ItemsInStock = Products.ItemsInStock - NEW.Quantity
	WHERE Products.ProductID = NEW.ProductID;
    
END//

-- when an item gets low in stock (less than 10), send a notification in the notifications table
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
END//

CREATE TRIGGER orders_after_insert AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO Notifications(Notification) VALUES (
    (SELECT concat(orderid , ' is placed with ' , group_concat(
	concat(quantity, ' items from ', productid) SEPARATOR ' & '))
    FROM orders_details
	WHERE orderid = 'O3')
    );
END//

DELIMITER ;
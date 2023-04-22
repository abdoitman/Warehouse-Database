-- Create triggers for the database
USE warehouse_data;

DROP TRIGGER IF EXISTS orders_before_insert;
DROP TRIGGER IF EXISTS orders_detalis_after_insert;
DROP TRIGGER IF EXISTS notification_is_recieved;
DROP TRIGGER IF EXISTS Products_after_update;

-- before an order is placed, make the orderdate = time of insertion 
DELIMITER //
CREATE TRIGGER orders_before_insert BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
	SET NEW.OrderDate = now();
END//

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

-- when  a notificaiton is recieved, make the notificationDateTime = time of insertion 
CREATE TRIGGER notification_is_recieved BEFORE INSERT ON Notifications
FOR EACH ROW
BEGIN
	set NEW.NotificationDateTime = now();
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

DELIMITER ;
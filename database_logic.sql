-- Create triggers for the database

DROP TRIGGER IF EXISTS orders_before_insert;
DROP TRIGGER IF EXISTS orders_detalis_after_insert;
DROP TRIGGER IF EXISTS notification_is_recieved;

USE warehouse_data;

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

DELIMITER ;
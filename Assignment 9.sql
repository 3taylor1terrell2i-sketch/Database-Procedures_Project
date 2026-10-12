-- *************************************************************
-- Assignment: 9
-- Written by: Terrell Taylor
-- Date      : 11/30/25
-- *************************************************************

USE my_guitar_shop;

-- *******************************************
-- Part 1 Exercise 1
-- *******************************************
 
DROP PROCEDURE IF EXISTS test;

DELIMITER //

CREATE PROCEDURE test()
BEGIN 
	DECLARE sql_error BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		SET sql_error = TRUE;
	
    START TRANSACTION;
    
    DELETE FROM addresses
		WHERE customer_id = 8;
    
    DELETE FROM customers
		WHERE customer_id = 8;
	
    IF sql_error = FALSE THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END//

-- *******************************************
-- Part 1 Exercise 2
-- *******************************************

DROP PROCEDURE IF EXISTS test;

DELIMITER //

CREATE PROCEDURE test()
BEGIN 
	DECLARE sql_error BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		SET sql_error = TRUE;

	START TRANSACTION;
    
    INSERT INTO orders VALUES
		(DEFAULT, 3, NOW(), '10.00', '0.00', NULL, 4, 'American Express', '378282246310005', '04/2023', 4);
	
    SELECT LAST_INSERT_ID() INTO order_id;
    
    INSERT INTO order_items VALUES
		(DEFAULT, order_id, 6, '415.00', '161.85', 1);
	
    INSERT INTO order_items VALUES
		(DEFAULT, order_id, 1, '699.00', '209.70', 1);

    IF sql_error = FALSE THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END//

-- *******************************************
-- Part 1 Exercise 3
-- *******************************************

DROP PROCEDURE IF EXISTS test;

DELIMITER //

CREATE PROCEDURE test()
BEGIN 
	DECLARE sql_error BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		SET sql_error = TRUE;
	
    START TRANSACTION;
    
	SELECT * FROM customers
		WHERE customer_id = 6;
	
    UPDATE orders
		SET customer_id = 3;
	
    UPDATE addresses
		SET customer_id = 3;
	
    DELETE FROM customers
		WHERE customer_id = 6;
	
    IF sql_error = FALSE THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
END//


-- *******************************************
-- Part 2 Exercise 1
-- *******************************************

DROP TRIGGER IF EXISTS products_before_update;

DELIMITER //

CREATE TRIGGER products_before_update
	BEFORE UPDATE ON products
    FOR EACH ROW
BEGIN
	DECLARE sum_discount_percent DECIMAL(10, 2);
    
	IF NEW.discount_percent > 0 AND NEW.discount_percent < 100 THEN
		SELECT SUM(NEW.discount_percent * 100)
        INTO sum_discount_percent
        FROM products
        WHERE NEW.discount_percent = sum_discount_percent;
	ELSE
		SIGNAL SQLSTATE 'HY000'
			SET MESSAGE_TEXT = 
				'Discount percent must be between 0 and 100.';
	END IF;
END//

UPDATE products
	SET discount_percent = 40
    WHERE list_price != 0;

-- *******************************************
-- Part 2 Exercise 2
-- *******************************************

DROP TRIGGER IF EXISTS products_before_insert;

DELIMITER //

CREATE TRIGGER products_before_insert
	BEFORE INSERT ON products
	FOR EACH ROW
BEGIN
    IF NEW.date_added = NULL THEN
		UPDATE products
        SET NEW.date_added = CURRENT_DATE();
	END IF;
END//
	
    INSERT INTO products VALUES
    (NULL, 4, 'test', 'product_test', 'desc_test', 0, 0, NULL);

-- *******************************************
-- Part 2 Exercise 3
-- *******************************************

DROP TABLE IF EXISTS products_audit;

CREATE TABLE products_audit
(
	audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    product_code VARCHAR(10) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    discount_percent DECIMAL(10, 2) NOT NULL,
    date_updated DATETIME
)

DELIMITER //

DROP TRIGGER IF EXISTS products_after_update;

CREATE TRIGGER products_after_update
	AFTER UPDATE ON products
    FOR EACH ROW
BEGIN
	INSERT INTO products_audit (product_id, category_id, product_code, product_name, list_price, discount_percent, date_updated) VALUES
		(NEW.product_id, NEW.category_id, NEW.product_code, NEW.product_name, NEW.list_price, NEW.discount_percent, NEW.date_added);
        
	END//

UPDATE products
SET discount_percent = discount_percent;
SELECT * FROM products_audit;


-- *******************************************
-- Part 2 Exercise 4
-- *******************************************

SHOW VARIABLES LIKE 'event_scheduler'

DELIMITER //

CREATE EVENT delete_rows_from_products_audit
ON SCHEDULE EVERY 1 DAY
DO BEGIN
	DELETE FROM products_audit
    WHERE date_updated < NOW() - INTERVAL 1 WEEK;
END//

SHOW EVENTS;
DROP EVENT delete_rows_from_products_audit;
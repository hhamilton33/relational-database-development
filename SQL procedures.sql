/*
CS4400: Introduction to Database Systems
Summer 2020
Phase III Template

Team 24
John Taylor (jtaylor362)
Alexandre Andrade (aandrade32)
Alexis Rugg (arugg3)
Hanna Hamilton (hhamilton33)

Directions:
Please follow all instructions from the Phase III assignment PDF.
This file must run without error for credit.
*/

/************** UTIL **************/
/* Feel free to add any utilty procedures you may need here */

-- Number:
-- Author: kachtani3@
-- Name: create_zero_inventory
-- Tested By: kachtani3@
DROP PROCEDURE IF EXISTS create_zero_inventory;
DELIMITER //
CREATE PROCEDURE create_zero_inventory(
    IN i_businessName VARCHAR(100),
    IN i_productId CHAR(5)
)
BEGIN
-- Type solution below
    IF (i_productId NOT IN (
        SELECT product_id FROM InventoryHasProduct WHERE inventory_business = i_businessName))
    THEN INSERT INTO InventoryHasProduct (inventory_business, product_id, count)
        VALUES (i_businessName, i_productId, 0);
    END IF;

-- End of solution
END //
DELIMITER ;


/************** INSERTS **************/

-- Number: I1
-- Author: hhamilton33
-- Name: add_usage_log
DROP PROCEDURE IF EXISTS add_usage_log;
DELIMITER //
CREATE PROCEDURE add_usage_log(
    IN i_usage_log_id CHAR(5),
    IN i_doctor_username VARCHAR(100),
    IN i_timestamp TIMESTAMP
)
BEGIN
-- Type solution below
INSERT INTO UsageLog(id, doctor, timestamp) VALUES (i_usage_log_id, i_doctor_username, i_timestamp);
-- End of solution
END //
DELIMITER ;

-- Number: I2
-- Author: aandrade32
-- Name: add_usage_log_entry
DROP PROCEDURE IF EXISTS add_usage_log_entry;
DELIMITER //
CREATE PROCEDURE add_usage_log_entry(
    IN i_usage_log_id CHAR(5),
    IN i_product_id CHAR(5),
    IN i_count INT
)
sp_main: BEGIN
-- Type solution below
SET @hospital_i2 = (select hospital from doctor where username = (select doctor from usagelog where id = i_usage_log_id));

    -- Check if hospital has enough inventory
    if (select count from inventoryhasproduct where inventory_business = @hospital_i2 and product_id = i_product_id) < i_count
        then leave sp_main; end if;
    
    -- Insert into usage log
    INSERT INTO usagelogentry VALUES (i_usage_log_id, i_product_id, i_count);
    
    -- Deduction of hospital inventory
    UPDATE inventoryhasproduct SET count = count - i_count WHERE inventory_business = @hospital_i2 and product_id = i_product_id;
-- End of solution
END //
DELIMITER ;


-- Number: I3
-- Author: arugg3
-- Name: add_business
DROP PROCEDURE IF EXISTS add_business;
DELIMITER //
CREATE PROCEDURE add_business(
    IN i_name VARCHAR(100),
    IN i_BusinessStreet VARCHAR(100),
    IN i_BusinessCity VARCHAR(100),
    IN i_BusinessState VARCHAR(30),
    IN i_BusinessZip CHAR(5),
    IN i_businessType ENUM('Hospital', 'Manufacturer'),
    IN i_maxDoctors INT,
    IN i_budget FLOAT(2),
    IN i_catalog_capacity INT,
    IN i_InventoryStreet VARCHAR(100),
    IN i_InventoryCity VARCHAR(100),
    IN i_InventoryState VARCHAR(30),
    IN i_InventoryZip CHAR(5)
)
Sp_main: BEGIN
-- Type solution below

DECLARE `should_rollback` BOOL DEFAULT FALSE;

DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `should_rollback` = TRUE;

START TRANSACTION;
   
IF i_maxDoctors < 0 or i_budget< 0 or i_catalog_capacity <0 then leave sp_main; end if;
    
INSERT INTO business VALUES(i_name, i_BusinessStreet, i_BusinessCity, i_BusinessState, i_BusinessZip);

IF i_businessType= "Hospital" THEN INSERT INTO hospital VALUES(i_name, i_maxDoctors, i_budget); END IF;

IF i_businessType="Manufacturer" THEN INSERT INTO manufacturer 
   VALUES(i_name,i_catalog_capacity ); end if;
INSERT INTO inventory VALUES(i_name, i_InventoryStreet, i_InventoryCity, i_InventoryState, i_InventoryZip );

IF `should_rollback` THEN ROLLBACK; END IF;

COMMIT;

-- End of solution
END //
DELIMITER ;

-- Number: I4
-- Author: kachtani3@
-- Name: add_transaction
DROP PROCEDURE IF EXISTS add_transaction;
DELIMITER //
CREATE PROCEDURE add_transaction(
    IN i_transaction_id CHAR(4),
    IN i_hospital VARCHAR(100),
    IN i_date DATE
)
BEGIN
-- Type solution below

INSERT INTO Transaction(id, hospital, date) VALUES (i_transaction_id, i_hospital, i_date);

-- End of solution
END //
DELIMITER ;

-- Number: I5
-- Author: jtaylor362
-- Name: add_transaction_item
DROP PROCEDURE IF EXISTS add_transaction_item;
DELIMITER //
CREATE PROCEDURE add_transaction_item(
    IN i_transactionId CHAR(4),
    IN i_productId CHAR(5),
    IN i_manufacturerName VARCHAR(100),
    IN i_purchaseCount INT)
sp_main: BEGIN
-- Type solution below

SET @hospital_i5 = (select hospital from transaction where id = i_transactionId);
SET @total_cost_i5 = round((select price from catalogitem where product_id = i_productId and manufacturer = i_manufacturerName), 2) * (i_purchaseCount);

-- Check if hospital can afford
    if (select budget from hospital where name = @hospital_i5) < @total_cost_i5
        then leave sp_main; end if;
-- Check if manufacturer warehouse has inventory listing
    if (select count(*) from inventoryhasproduct where inventory_business = i_manufacturerName and product_id = i_productId) = 0
        then leave sp_main; end if;
-- Check if manufacturer warehouse has enough inventory
    if (select count from inventoryhasproduct where inventory_business = i_manufacturerName and product_id = i_productId) < i_purchaseCount
        then leave sp_main; end if;

-- Add transaction item
    INSERT INTO transactionitem(transaction_id, manufacturer, product_id, count) VALUES (i_transactionId, i_manufacturerName, i_productId, i_purchaseCount);
-- Add to hospital inventory if it does not exist
    if (select count(*) from inventoryhasproduct where inventory_business = @hospital_i5 and product_id = i_productId) = 0
        then INSERT INTO inventoryhasproduct VALUES (@hospital_i5, i_productId, 0); end if;
-- Adjust hospital budget, hospital inventory, and manufacturer inventory
    UPDATE hospital SET budget = budget - @total_cost_i5 WHERE name = @hospital_i5;
    UPDATE inventoryhasproduct SET count = count + i_purchaseCount WHERE inventory_business = @hospital_i5 and product_id = i_productId;
    UPDATE inventoryhasproduct SET count = count - i_purchaseCount WHERE inventory_business = i_manufacturerName and product_id = i_productId;
    
    call delete_zero_inventory();
    
-- End of solution
END //
DELIMITER ;


-- Number: I6
-- Author: hhamilton33
-- Name: add_user
DROP PROCEDURE IF EXISTS add_user;
DELIMITER //
CREATE PROCEDURE add_user(
    IN i_username VARCHAR(100),
    IN i_email VARCHAR(100),
    IN i_password VARCHAR(100),
    IN i_fname VARCHAR(50),
    IN i_lname VARCHAR(50),
    IN i_userType ENUM('Doctor', 'Admin', 'Doctor-Admin'),
    IN i_managingBusiness VARCHAR(100),
    IN i_workingHospital VARCHAR(100)
)
BEGIN
-- Type solution below
INSERT INTO User(username, email, password, fname, lname) VALUES (i_username, i_email, SHA(i_password), i_fname, i_lname);
IF i_userType = 'Doctor'
    THEN
        INSERT INTO Doctor(username, hospital) VALUES (i_username, i_workingHospital);
    END IF;
IF i_userType = 'Admin'
    THEN
        INSERT INTO Administrator(username, business) VALUES (i_username, i_managingBusiness);
    END IF;
IF i_userType = 'Doctor-Admin'
    THEN
        INSERT INTO Doctor(username, hospital) VALUES (i_username, i_workingHospital);
        INSERT INTO Administrator(username, business) VALUES (i_username, i_managingBusiness);
    END IF;

-- End of solution
END //
DELIMITER ;

-- Number: I7
-- Author: aandrade32
-- Name: add_catalog_item
DROP PROCEDURE IF EXISTS add_catalog_item;
DELIMITER //
CREATE PROCEDURE add_catalog_item(
    IN i_manufacturerName VARCHAR(100),
    IN i_product_id CHAR(5),
    IN i_price FLOAT(2)
)
BEGIN
-- Type solution below
insert into catalogitem (manufacturer, product_id, price)
values (i_manufacturerName, i_product_id, i_price);
-- End of solution
END //
DELIMITER ;


-- Number: I8
-- Author: arugg3
-- Name: add_product
DROP PROCEDURE IF EXISTS add_product;
DELIMITER //
CREATE PROCEDURE add_product(
    IN i_prod_id CHAR(5),
    IN i_color VARCHAR(30),
    IN i_name VARCHAR(30)
)
BEGIN
-- Type solution below

insert into product values (i_prod_id, i_color, i_name);

-- End of solution
END //
DELIMITER ;


/************** DELETES **************/
-- NOTE: Do not circumvent referential ON DELETE triggers by manually deleting parent rows


-- Number: D1
-- Author: jtaylor362
-- Name: delete_product
DROP PROCEDURE IF EXISTS delete_product;
DELIMITER //
CREATE PROCEDURE delete_product(
    IN i_product_id CHAR(5)
)
BEGIN
-- Type solution below
    DELETE FROM product where id = i_product_id;
-- End of solution
END //
DELIMITER ;

-- Number: D2
-- Author: hhamilton33
-- Name: delete_zero_inventory
DROP PROCEDURE IF EXISTS delete_zero_inventory;
DELIMITER //
CREATE PROCEDURE delete_zero_inventory()
BEGIN
-- Type solution below
DELETE FROM InventoryHasProduct WHERE count = 0;
-- End of solution
END //
DELIMITER ;


-- Number: D3
-- Author: ftsang3@
-- Name: delete_business
DROP PROCEDURE IF EXISTS delete_business;
DELIMITER //
CREATE PROCEDURE delete_business(
    IN i_businessName VARCHAR(100)
)
BEGIN
-- Type solution below
    DELETE FROM Business where name = i_businessName;
-- End of solution
END //
DELIMITER ;

-- Number: D4
-- Author: aandrade32
-- Name: delete_user
DROP PROCEDURE IF EXISTS delete_user;
DELIMITER //
CREATE PROCEDURE delete_user(
    IN i_username VARCHAR(100)
)
BEGIN
-- Type solution below
delete from ga_ppe.user 
where username = i_username;
-- End of solution
END //
DELIMITER ;


-- Number: D5
-- Author: arugg3
-- Name: delete_catalog_item
DROP PROCEDURE IF EXISTS delete_catalog_item;
DELIMITER //
CREATE PROCEDURE delete_catalog_item(
    IN i_manufacturer_name VARCHAR(100),
    IN i_product_id CHAR(5)
)
BEGIN
-- Type solution below

DELETE FROM CatalogItem WHERE product_id = i_product_id and manufacturer = i_manufacturer_name;

-- End of solution
END //
DELIMITER ;


/************** UPDATES **************/

-- Number: U1
-- Author: jtaylor362
-- Name: add_subtract_inventory
DROP PROCEDURE IF EXISTS add_subtract_inventory;
DELIMITER //
CREATE PROCEDURE add_subtract_inventory(
    IN i_prod_id CHAR(5),
    IN i_businessName VARCHAR(100),
    IN i_delta INT
)
sp_main: BEGIN
-- Type solution below

--  Check if stock will be negative
    if (select count from inventoryhasproduct where inventory_business = i_businessName and product_id = i_prod_id) + i_delta < 0
        then leave sp_main; end if;

-- Check if inv listing exists
    if (select count(*) from inventoryhasproduct where inventory_business = i_businessName and product_id = i_prod_id) = 0
        then INSERT INTO inventoryhasproduct VALUES (i_businessName, i_prod_id, 0); end if;
        
    UPDATE inventoryhasproduct SET count = count + i_delta WHERE inventory_business = i_businessName and product_id = i_prod_id;
    
    call delete_zero_inventory();
-- End of solution
END //
DELIMITER ;


-- Number: U2
-- Author: hhamilton33
-- Name: move_inventory
DROP PROCEDURE IF EXISTS move_inventory;
DELIMITER //
CREATE PROCEDURE move_inventory(
    IN i_supplierName VARCHAR(100),
    IN i_consumerName VARCHAR(100),
    IN i_productId CHAR(5),
    IN i_count INT)
BEGIN
-- Type solution below
#If the inventory_business/product_id combination is new, add a row and initialize count to 0.
    IF (i_consumerName, i_productId) NOT IN (SELECT inventory_business, product_id FROM InventoryHasProduct)
        THEN 
        INSERT INTO InventoryHasProduct (inventory_business, product_id, count) VALUES (i_consumerName, i_productId, 0);
    END IF;
    IF (i_supplierName, i_productId) NOT IN (SELECT inventory_business, product_id FROM InventoryHasProduct)
        THEN 
        INSERT INTO InventoryHasProduct (inventory_business, product_id, count) VALUES (i_supplierName, i_productId, 0);
    END IF;
        
# The action should only succeed if supplier has enough of the product to fulfill the move.
    IF (SELECT count FROM InventoryHasProduct WHERE inventory_business = i_supplierName AND product_id = i_productId) >= i_count
        THEN
        UPDATE InventoryHasProduct SET count = count + i_count WHERE inventory_business = i_consumerName AND product_id = i_productId;
        UPDATE InventoryHasProduct SET count = count - i_count WHERE inventory_business = i_supplierName AND product_id = i_productId;
    END IF;
    
# Never leave an inventory line with a count of 0. Just delete the row to keep the table clean.
    DELETE FROM InventoryHasProduct WHERE count = 0;
-- End of solution
END //
DELIMITER ;


-- Number: U3
-- Author: aandrade32
-- Name: rename_product_id
DROP PROCEDURE IF EXISTS rename_product_id;
DELIMITER //
CREATE PROCEDURE rename_product_id(
    IN i_product_id CHAR(5),
    IN i_new_product_id CHAR(5)
)
BEGIN
-- Type solution below
update product set id = i_new_product_id
where id = i_product_id;
-- End of solution
END //
DELIMITER ;


-- Number: U4
-- Author: arugg3
-- Name: update_business_address
DROP PROCEDURE IF EXISTS update_business_address;
DELIMITER //
CREATE PROCEDURE update_business_address(
    IN i_name VARCHAR(100),
    IN i_address_street VARCHAR(100),
    IN i_address_city VARCHAR(100),
    IN i_address_state VARCHAR(30),
    IN i_address_zip CHAR(5)
)
BEGIN
-- Type solution below

    UPDATE business SET address_street=i_address_street, address_city=i_address_city, address_state=i_address_state, address_zip=i_address_zip WHERE name=i_name;

   

    UPDATE inventory SET address_street=i_address_street, address_city=i_address_city,address_state=i_address_state, address_zip=i_address_zip WHERE owner=i_name;


-- End of solution
END //
DELIMITER ;

-- Number: U5
-- Author: jtaylor362
-- Name: charge_hospital
DROP PROCEDURE IF EXISTS charge_hospital;
DELIMITER //
CREATE PROCEDURE charge_hospital(
    IN i_hospital_name VARCHAR(100),
    IN i_amount FLOAT(2))
BEGIN
-- Type solution below

    if (select budget from hospital where name = i_hospital_name) >= i_amount
        then UPDATE hospital SET budget = budget - i_amount WHERE name = i_hospital_name;
    end if;
-- End of solution
END //
DELIMITER ;

-- Number: U6
-- Author: hhamilton33
-- Name: update_business_admin
DROP PROCEDURE IF EXISTS update_business_admin;
DELIMITER //
CREATE PROCEDURE update_business_admin(
    IN i_admin_username VARCHAR(100),
    IN i_business_name VARCHAR(100)
)
sp_main: BEGIN
-- Type solution below
    # Check if business will have at least one admin after switch
    IF (SELECT COUNT(*) FROM administrator WHERE business = (SELECT business FROM administrator WHERE username = i_admin_username) GROUP BY business) < 2
        THEN LEAVE sp_main; END IF;
    # Check if admin will have somewhere to work
    IF i_business_name not in (SELECT name from business)
        THEN LEAVE sp_main; END IF;
    UPDATE Administrator SET business = i_business_name WHERE username = i_admin_username;
-- End of solution
END //
DELIMITER ;

-- Number: U7
-- Author: ftsang3@
-- Name: update_doctor_manager
DROP PROCEDURE IF EXISTS update_doctor_manager;
DELIMITER //
CREATE PROCEDURE update_doctor_manager(
    IN i_doctor_username VARCHAR(100),
    IN i_manager_username VARCHAR(100)
)
BEGIN
-- Type solution below
IF i_doctor_username <> i_manager_username
    THEN
        UPDATE Doctor SET manager = i_manager_username WHERE username = i_doctor_username;
    END IF;
-- End of solution
END //
DELIMITER ;

-- Number: U8
-- Author: aandrade32
-- Name: update_user_password
DROP PROCEDURE IF EXISTS update_user_password;
DELIMITER //
CREATE PROCEDURE update_user_password(
    IN i_username VARCHAR(100),
    IN i_new_password VARCHAR(100)
)
BEGIN
-- Type solution below
update user set password = sha(i_new_password)
where username = i_username;
-- End of solution
END //
DELIMITER ;


-- Number: U9
-- Author: arugg3
-- Name: batch_update_catalog_item
DROP PROCEDURE IF EXISTS batch_update_catalog_item;
DELIMITER //
CREATE PROCEDURE batch_update_catalog_item(
    IN i_manufacturer_name VARCHAR(100),
    IN i_factor FLOAT(2))
BEGIN
-- Type solution below

UPDATE catalogitem SET price=price*i_factor where manufacturer=i_manufacturer_name;

-- End of solution
END //
DELIMITER ;

/************** SELECTS **************/
-- NOTE: "SELECT * FROM USER" is just a dummy query
-- to get the script to run. You will need to replace that line
-- with your solution.

-- Number: S1
-- Author: jtaylor362
-- Name: hospital_transactions_report
DROP PROCEDURE IF EXISTS hospital_transactions_report;
DELIMITER //
CREATE PROCEDURE hospital_transactions_report(
    IN i_hospital VARCHAR(100),
    IN i_sortBy ENUM('', 'id', 'date'),
    IN i_sortDirection ENUM('', 'DESC', 'ASC')
)
BEGIN
    DROP TABLE IF EXISTS hospital_transactions_report_result;
    CREATE TABLE hospital_transactions_report_result(
        id CHAR(4),
        manufacturer VARCHAR(100),
        hospital VARCHAR(100),
        total_price FLOAT,
        date DATE);

    INSERT INTO hospital_transactions_report_result
-- Type solution below

    SELECT transaction_id, ti.manufacturer, hospital, SUM(ROUND(price,2) * count) as total_price, date
    FROM transactionitem as ti INNER JOIN catalogitem as c on ti.manufacturer = c.manufacturer and ti.product_id = c.product_id
    INNER JOIN transaction as t on transaction_id = id
    WHERE hospital = i_hospital
    GROUP BY transaction_id
    
    ORDER BY
        CASE WHEN i_sortDirection = 'ASC' or i_sortDirection = '' THEN
            CASE 
                WHEN i_sortBy = 'id' THEN id
                WHEN i_sortBy = 'date' THEN date 
            END
        END ASC
        , CASE WHEN i_sortDirection = 'DESC' THEN
            CASE 
                WHEN i_sortBy = 'id' THEN id
                WHEN i_sortBy = 'date' THEN date 
        END
    END DESC;
-- End of solution
END //
DELIMITER ;
-- Number: S2
-- Author: ty.zhang@
-- Name: num_of_admin_list
DROP PROCEDURE IF EXISTS num_of_admin_list;
DELIMITER //
CREATE PROCEDURE num_of_admin_list()
BEGIN
    DROP TABLE IF EXISTS num_of_admin_list_result;
    CREATE TABLE num_of_admin_list_result(
        businessName VARCHAR(100),
        businessType VARCHAR(100),
        numOfAdmin INT);

    INSERT INTO num_of_admin_list_result
-- Type solution below
    SELECT H.name, 'Hospital', count(*)
    FROM Hospital AS H, Administrator AS A
    WHERE name = business
    GROUP BY H.name
    UNION
    SELECT M.name, 'Manufacturer', count(*)
    FROM Manufacturer AS M, Administrator AS A
    WHERE name = business
    GROUP BY M.name;
-- End of solution
END //
DELIMITER ;

-- Number: S3
-- Author: hhamilton33
-- Name: product_usage_list
DROP PROCEDURE IF EXISTS product_usage_list;
DELIMITER //
CREATE PROCEDURE product_usage_list()

BEGIN
    DROP TABLE IF EXISTS product_usage_list_result;
    CREATE TABLE product_usage_list_result(
        product_id CHAR(5),
        product_color VARCHAR(30),
        product_type VARCHAR(30),
        num INT);

    INSERT INTO product_usage_list_result
-- Type solution below
SELECT id, name_color, name_type, SUM(COALESCE(count,0))
FROM UsageLogEntry RIGHT JOIN Product ON UsageLogEntry.product_id = Product.id
GROUP BY id
ORDER BY SUM(count) DESC;
-- End of solution
END //
DELIMITER ;

-- Number: S4
-- Author: aandrade32
-- Name: hospital_total_expenditure
DROP PROCEDURE IF EXISTS hospital_total_expenditure;
DELIMITER //
CREATE PROCEDURE hospital_total_expenditure()

BEGIN
    DROP TABLE IF EXISTS hospital_total_expenditure_result;
    CREATE TABLE hospital_total_expenditure_result(
        hospitalName VARCHAR(100),
        totalExpenditure FLOAT,
        transaction_count INT,
        avg_cost FLOAT);

    INSERT INTO hospital_total_expenditure_result
-- Type solution below
select name as hospitalName, COALESCE(tE,0) as totalExpediture, COALESCE(tC,0) AS transaction_count, COALESCE(ac,0) as avg_cost from
hospital left outer join
(select hospital as hosp, round(sum(count*price),2) as tE , count(distinct id) as tC,
round(sum(count*price)/count( distinct id),2) as ac from 
(select * from transaction join transactionitem on id=transaction_id) as table_A 
join catalogitem on table_A.manufacturer=catalogitem.manufacturer and table_A.product_id=catalogitem.product_id
group by hospital) as table_C
on hospital.name = table_C.hosp;
-- End of solution
END //
DELIMITER ;


-- Number: S5
-- Author: arugg3
-- Name: manufacturer_catalog_report
DROP PROCEDURE IF EXISTS manufacturer_catalog_report;
DELIMITER //
CREATE PROCEDURE manufacturer_catalog_report(
    IN i_manufacturer VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS manufacturer_catalog_report_result;
    CREATE TABLE manufacturer_catalog_report_result(
        name_color VARCHAR(30),
        name_type VARCHAR(30),
        price FLOAT(2),
        num_sold INT,
        revenue FLOAT(2));

    INSERT INTO manufacturer_catalog_report_result
-- Type solution below

SELECT name_color, name_type, price, COALESCE(count,0) AS num_sold, COALESce(revenue,0) as revenue FROM 

(SELECT product_id, price, name_color, name_type FROM catalogitem JOIN product ON product_id=id WHERE catalogitem.manufacturer="Marietta Mask Production Company") AS table_A

LEFT OUTER JOIN (SELECT transactionitem.manufacturer, round(price*count) AS revenue, transactionitem.product_id, count  FROM transactionitem JOIN catalogitem ON transactionitem.product_id=catalogitem.product_id WHERE 
transactionitem.manufacturer="Marietta Mask Production Company" and
catalogitem.manufacturer="Marietta Mask Production Company" ) AS table_B ON table_A.product_id=table_B.product_id ORDER BY revenue DESC;


-- End of solution
END //
DELIMITER ;

-- Number: S6
-- Author: jtaylor362
-- Name: doctor_subordinate_usage_log_report
DROP PROCEDURE IF EXISTS doctor_subordinate_usage_log_report;
DELIMITER //
CREATE PROCEDURE doctor_subordinate_usage_log_report(
    IN i_drUsername VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS doctor_subordinate_usage_log_report_result;
    CREATE TABLE doctor_subordinate_usage_log_report_result(
        id CHAR(5),
        doctor VARCHAR(100),
        timestamp TIMESTAMP,
        product_id CHAR(5),
        count INT);

    INSERT INTO doctor_subordinate_usage_log_report_result
-- Type solution below
    SELECT id, doctor, timestamp, product_id, count from usagelog join usagelogentry on id = usage_log_id where doctor in
    (select username from doctor where manager = i_drUsername) or doctor = i_drUsername;
-- End of solution
END //
DELIMITER ;

-- Number: S7
-- Author: jtaylor362
-- Name: explore_product
DROP PROCEDURE IF EXISTS explore_product;
DELIMITER //
CREATE PROCEDURE explore_product(
    IN i_product_id CHAR(5))
BEGIN
    DROP TABLE IF EXISTS explore_product_result;
    CREATE TABLE explore_product_result(
        manufacturer VARCHAR(100),
        count INT,
        price FLOAT(2));

    INSERT INTO explore_product_result
-- Type solution below
    select c.manufacturer, count, price from catalogitem as c inner join inventoryhasproduct as i on c.product_id = i.product_id and inventory_business = manufacturer where i.product_id = i_product_id;
-- End of solution
END //
DELIMITER ;

-- Number: S8
-- Author: aandrade32
-- Name: show_product_usage
DROP PROCEDURE IF EXISTS show_product_usage;
DELIMITER //
CREATE PROCEDURE show_product_usage()
BEGIN
  DROP TABLE IF EXISTS show_product_usage_result;
    CREATE TABLE show_product_usage_result(
        product_id CHAR(5),
        num_used INT,
        num_available INT,
        ratio FLOAT);
    INSERT INTO show_product_usage_result
-- Type solution below
SELECT AVL.id as product_id, coalesce(USD.uses,0) as num_used, AVL.has as num_available, round(COALESCE((USD.uses/AVL.has),0),2) as ratio FROM
(select product_id, sum(count) as uses from usagelogentry join usagelog on id = usage_log_id
group by product_id) as USD
right outer join
(select id, COALESCE(IHP.AVAIL,0) as has from product 
left outer join (select product_id, inventory_business, sum(count) as AVAIL
 from inventoryhasproduct where inventory_business 
 in ( select name from manufacturer)
 group by product_id) as IHP
 on product_id = id group by id) as AVL 
 on AVL.id = USD.product_id;

-- End of solution
END //
DELIMITER ;


-- Number: S9
-- Author: arugg3
-- Name: show_hospital_aggregate_usage
DROP PROCEDURE IF EXISTS show_hospital_aggregate_usage;
DELIMITER //
CREATE PROCEDURE show_hospital_aggregate_usage()
BEGIN
    DROP TABLE IF EXISTS show_hospital_aggregate_usage_result;
    CREATE TABLE show_hospital_aggregate_usage_result(
        hospital VARCHAR(100),
        items_used INT);

    INSERT INTO show_hospital_aggregate_usage_result
-- Type solution below
    
select hospital, COALESCE(sum(count),0) as product_count from (select * from usagelogentry join usagelog on usage_log_id=id) as table_A right join doctor on doctor=username group by hospital;

-- End of solution
END //
DELIMITER ;

-- Number: S10
-- Author: jtaylor362
-- Name: business_search
DROP PROCEDURE IF EXISTS business_search;
DELIMITER //
CREATE PROCEDURE business_search (
    IN i_search_parameter ENUM("name","street", "city", "state", "zip"),
    IN i_search_value VARCHAR(100))
BEGIN
    DROP TABLE IF EXISTS business_search_result;
    CREATE TABLE business_search_result(
        name VARCHAR(100),
        address_street VARCHAR(100),
        address_city VARCHAR(100),
        address_state VARCHAR(30),
        address_zip CHAR(5));

    INSERT INTO business_search_result
-- Type solution below
    SELECT * FROM business WHERE
    CASE 
        WHEN i_search_parameter = "name" THEN (name like concat('%',i_search_value,'%'))
        WHEN i_search_parameter = "street" THEN (address_street like concat('%',i_search_value,'%'))
        WHEN i_search_parameter = "city" THEN (address_city like concat('%',i_search_value,'%'))
        WHEN i_search_parameter = "state" THEN (address_state like concat('%',i_search_value,'%'))
        WHEN i_search_parameter = "zip" THEN (address_zip like concat('%',i_search_value,'%'))
    END;
-- End of solution
END //
DELIMITER ;

-- Number: S11
-- Author: arugg3
-- Name: manufacturer_transaction_report
DROP PROCEDURE IF EXISTS manufacturer_transaction_report;
DELIMITER //
CREATE PROCEDURE manufacturer_transaction_report(
    IN i_manufacturer VARCHAR(100))

BEGIN
    DROP TABLE IF EXISTS manufacturer_transaction_report_result;
    CREATE TABLE manufacturer_transaction_report_result(
        id CHAR(4),
        hospital VARCHAR(100),
        `date` DATE,
        cost FLOAT(2),
        total_count INT);

    INSERT INTO manufacturer_transaction_report_result
-- Type solution below

SELECT id, hospital, date,  round(sum(count*price)) AS cost, sum(count) AS total_count FROM (SELECT * FROM transactionitem INNER JOIN transaction ON transaction_id=id WHERE manufacturer=i_manufacturer) AS table_A INNER JOIN (SELECT * FROM catalogitem WHERE manufacturer=i_manufacturer) AS table_B ON  table_A.product_id=table_B.product_id GROUP BY hospital;


-- End of solution
END //
DELIMITER ;

-- Number: S12
-- Author: jtaylor362
-- Name: get_user_types
-- Tested By: yxie@
DROP PROCEDURE IF EXISTS get_user_types;
DELIMITER //
CREATE PROCEDURE get_user_types()
BEGIN
DROP TABLE IF EXISTS get_user_types_result;
    CREATE TABLE get_user_types_result(
        username VARCHAR(100),
        UserType VARCHAR(50));
    INSERT INTO get_user_types_result
-- Type solution below
    SELECT username,
        (CASE WHEN username in (select username from doctor) THEN concat('Doctor',
            concat(CASE WHEN username in (select username from administrator) THEN '-Admin' ELSE '' END,
            CASE WHEN username in (select manager from doctor) THEN '-Manager' ELSE '' END))
        ELSE 'Admin' END) AS UserType
    FROM user;
-- End of solution
END //
DELIMITER ;


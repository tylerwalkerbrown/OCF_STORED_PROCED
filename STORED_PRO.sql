/* THIS IS FOR THE MASTER TABLE */
/* The procedure must be applied to the base table */

CREATE DEFINER=`root`@`localhost` PROCEDURE `master_clean`()
BEGIN
ALTER TABLE `old_cobblers_farm`.`transactions` 
CHANGE COLUMN `Transaction type` `Transaction_type` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Order ID` `Order_ID` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Product Details` `Product_Details` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Total product charges` `Total_product_charges` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Total promotional rebates` `Total_promotional_rebates` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Amazon fees` `Amazon_fees` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Total (USD)` `Total` DOUBLE NULL DEFAULT NULL ,
DROP COLUMN `MyUnknownColumn`;
END
/*This creates the master_trans table that all the data will go into
The main table will go from transactions to master_trans   */

CREATE DEFINER=`root`@`localhost` PROCEDURE `master_table_creation`()
BEGIN
create table old_cobblers_farm.master_trans as(
with split as (  
  Select *,(Substring(Date, -2)) as Year,
  Substring(Date, 3, 2) as Day,
  Substring(Date, 1,2) as M
from old_cobblers_farm.transactions)
,trim as (
select *, trim("/"from M) as Month
from split)
,master_1 as (
select cast(concat(20,Year,'/', Month, '/', Day) as datetime) as Date,
`Transaction_type`, `Order_ID` , `Product_Details`, 
`Total_product_charges` , `Total_promotional_rebates` , 
`Amazon_fees` , Other, `Total`,  CASE
  WHEN Total_product_charges = 0 THEN NULL
  When Amazon_fees = 0 THEN NULL
  ELSE Amazon_fees / Total_product_charges end as amazon_fee_percent
from trim)
select * from master_1);

END







/* 	NEW DATA  */
/* 	NEW DATA  */
/* 	NEW DATA  */
/* 	NEW DATA  */
/* 	NEW DATA  */
/* 	NEW DATA  */




/* The first procedure that is created will be applied to the "order_refresh" table that we imported. 
What this does is cleans the column names so it can be properly passed through the next query and inserted
into the all transactions table */

CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_refresh`()
BEGIN
ALTER TABLE `old_cobblers_farm`.`order_refresh` 
CHANGE COLUMN `Transaction type` `Transaction_type` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Order ID` `Order_ID` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Product Details` `Product_Details` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Total product charges` `Total_product_charges` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Total promotional rebates` `Total_promotional_rebates` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Amazon fees` `Amazon_fees` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Total (USD)` `Total` DOUBLE NULL DEFAULT NULL ,
DROP COLUMN `MyUnknownColumn`;

END
/*  */
/* Next we have to call the procedure so it applies the edits to the table */

call clean_refresh ()

/* Next we have to create a stored procedure that cleans the refreshed data to fit the format of the 
history of the transactions */

CREATE DEFINER=`root`@`localhost` PROCEDURE `inserting_data`()
BEGIN

INSERT INTO old_cobblers_farm.master_trans(Date, Transaction_type, Order_ID, Product_Details, Total_product_charges, Total_promotional_rebates, Amazon_fees, Other, Total, amazon_fee_percent)
with split as (  
  Select *,(Substring(Date, -2)) as Year,
  Substring(Date, 3, 2) as Day,
  Substring(Date, 1,2) as M
from old_cobblers_farm.order_refresh)
,trim as (
select *, trim("/"from M) as Month
from split)
select cast(concat(20,Year,'/', Month, '/', Day) as datetime) as Date,
`Transaction_type`, `Order_ID` , `Product_Details`, 
`Total_product_charges` , `Total_promotional_rebates` , 
`Amazon_fees` , Other, `Total`,  CASE
  WHEN Total_product_charges = 0 THEN NULL
  When Amazon_fees = 0 THEN NULL
  ELSE Amazon_fees / Total_product_charges end as amazon_fee_percent
from trim;

END

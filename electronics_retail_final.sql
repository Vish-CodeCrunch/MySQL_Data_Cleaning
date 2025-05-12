# Data Cleaning In MySQL

# Drop database MySQL_Projects if exists.
drop database if exists MySQL_Projects;

# Creating Database 
create database MySQL_Projects;

# Using Database
use mysql_projects;

# Creating "Electronics_Retail" Table
-- order_date,unit_price column in varchar because we will import data from where order_date column has error so we are using varchar after cleaning will change datatype of that column. At the end we will ensure all columns datatype to be correct.

create table electronics_retail (
    product_id varchar(50),
    product_name varchar(100),
    category varchar(50),
    stock_quantity int,
    unit_price varchar(50),
    sales_quantity int,
    order_date varchar(50),
    customer_id varchar(50),
    store_location varchar(50),
    discount float,
    warehouse_id varchar(50),
    supplier_name varchar(100),
    order_status varchar(50),
    customer_email varchar(100),
    restock_date varchar(50)
);

# Verify table exist in table or not
show tables;

# Data Import
-- Used python script for importing data in mysql_projects.electronics_retail.
-- python file and csv file must be in same folder
/*
import pandas as pd
import mysql.connector

# Database connection
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",
    database="mysql_projects"
)
cursor = conn.cursor()

# Read CSV
df = pd.read_csv('electronics_retail_unclean_5000_extended.csv')

# Insert data
sql = """
INSERT INTO electronics_retail (
    product_id, product_name, category, stock_quantity, unit_price,
    sales_quantity, order_date, customer_id, store_location, discount,
    warehouse_id, supplier_name, order_status, customer_email, restock_date
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""
for _, row in df.iterrows():
    # Handle NaN values
    values = [None if pd.isna(x) else x for x in row]
    cursor.execute(sql, values)

# Commit and close
conn.commit()
cursor.close()
conn.close()
print("Data imported successfully!")
*/

# View Dataset
select * from electronics_retail;

# Removing Duplicates

-- Check for exact duplicates (all columns)
select product_id, product_name, category, stock_quantity, unit_price, sales_quantity,
       order_date, customer_id, store_location, discount, warehouse_id, supplier_name,
       order_status, customer_email, restock_date, COUNT(*) as count
from electronics_retail
group by product_id, product_name, category, stock_quantity, unit_price, 
		sales_quantity,order_date, customer_id, store_location, discount,
        warehouse_id,supplier_name,order_status, customer_email, restock_date
having count > 1;

-- Add Temporary unique id column temp_id
alter table electronics_retail 
add column temp_id int auto_increment primary key first;

-- Creating a Temporary table for detecting first occurence of each duplicates
create temporary table temp_electronics_retail as 
select temp_id
from (
select temp_id,
	row_number() over(partition by product_id, product_name, category, stock_quantity,unit_price, sales_quantity,order_date, customer_id, store_location, discount, warehouse_id, supplier_name,order_status, customer_email, restock_date 
			order by temp_id) as rn
from electronics_retail ) t
where rn = 1;

-- View temporary table
select * from temp_electronics_retail;

-- Deleting Duplicate Data
delete from electronics_retail
where temp_id not in (select temp_id from temp_electronics_retail);

-- Drop Temporary Table 
drop temporary table temp_electronics_retail;

-- Drop the Temporary temp_id column
alter table electronics_retail
drop column temp_id;

-- View dataset without Duplicates
select * from electronics_retail;

-- Confirm no duplicates (if any any records appear means there is duplicate)
select product_id, product_name, category, stock_quantity, unit_price, sales_quantity,
       order_date, customer_id, store_location, discount, warehouse_id, supplier_name,
       order_status, customer_email, restock_date, COUNT(*) as count
from electronics_retail
group by product_id, product_name, category, stock_quantity, unit_price, sales_quantity,
         order_date, customer_id, store_location, discount, warehouse_id, supplier_name,
         order_status, customer_email, restock_date
having count > 1;

-- View Datatypes of columns of electronics_retail Table
describe electronics_retail;

# Correcting unit_price Column

-- Changing datatype of unit_price and removing "$" , "USD" from that column for treating that column as number

-- creating new unit price column
alter table electronics_retail
add column new_unit_price decimal(10,2) after unit_price;

-- updating unit price for behaving as number
update electronics_retail
set unit_price = 
(select cast(trim(replace(replace(unit_price,"$","")," USD","")) as decimal(10,2)));

-- Update new_unit_price with unit_price
update electronics_retail
set new_unit_price = (select unit_price);

-- Deleting unit_price column of datatype varchar
alter table electronics_retail
drop column unit_price;

-- Rename new_unit_price column to unit_price
alter table electronics_retail
rename column new_unit_price to unit_price;

-- Confirm unit_price column datatype
desc electronics_retail;


# Standardize store_location values

-- View unique values of store_location
select distinct store_location,count(*)
from electronics_retail
group by store_location;

-- Update store_location
update electronics_retail
set store_location = case
						when lower(store_location) in ("ny","new york") then "New York"
						when lower(store_location) in ("la") then "Los Angeles"
						when lower(store_location) in ("sf","san francisco") then "San Francisco"
						when lower(store_location) in ("chicago") then "Chicago"
						else store_location
                      end;
 
# Standardize order_status values

-- View unique values of order_status
select distinct order_status,count(*)
from electronics_retail
group by order_status;

-- Update order_status
update electronics_retail
set order_status = lower(order_status),
    order_status = case
        when order_status = 'delivrd' then 'delivered'
        when order_status = 'pendng' then 'pending'
        else order_status
    end;
 
# Checking Missing values

-- Checking Columns with null values
select 
	sum(case 
		when product_id = "" or product_id is null then 1 else 0 end) as missing_product_id,
	sum(case
		when product_name = "" or product_name is null then 1 else 0 end) as missing_product_name,
	sum(case
		when category = "" or category is null then 1 else 0 end) as missing_category,
	sum(case
		when stock_quantity is null then 1 else 0 end) as missing_stock_quantity,
	sum(case
		when unit_price is null then 1 else 0 end) as missing_unit_price,
	sum(case
		when sales_quantity is null then 1 else 0 end) as missing_sales_quantity,
	sum(case
		when order_date = "" or order_date is null then 1 else 0 end) as missing_order_date,
	sum(case
		when customer_id = "" or customer_id is null then 1 else 0 end) as missing_customer_id,
	sum(case
		when store_location = "" or store_location is null then 1 else 0 end) as missing_store_location,
	sum(case
		when discount is null then 1 else 0 end) as missing_discount,
	sum(case
		when warehouse_id = "" or warehouse_id is null then 1 else 0 end) as missing_warehouse_id,
	sum(case
		when supplier_name = "" or supplier_name is null then 1 else 0 end) as missing_supplier_name,
	sum(case
		when order_status = "" or order_status is null then 1 else 0 end) as missing_order_status,
	sum(case
		when customer_email = "" or customer_email is null then 1 else 0 end) as missing_customer_email,
	sum(case
		when restock_date = "" or restock_date is null then 1 else 0 end) as missing_restock_date
from electronics_retail;

-- column has null values
/*
missing_stock_quantity
missing_customer_id	
missing_discount
missing_warehouse_id	
missing_supplier_name
missing_customer_email
missing_restock_date
*/

# Impute missing values

-- set varible @median_stock to calculate median of stock_quantity
set @median_stock := (
	select stock_quantity
    from (select stock_quantity,
		  row_number() over (order by stock_quantity) as row_num,
          count(*) over() as total_count
          from electronics_retail
          where stock_quantity is not null
	) t 
    where row_num in ((floor(total_count + 1)/2),ceil((total_count + 1)/2))
    limit 1);
    
-- View variable value
select @median_stock;

-- Impute stock_quantity
update electronics_retail
set stock_quantity = (select @median_stock)
where stock_quantity is null;

-- Impute customer id 
update electronics_retail
set customer_id = "UNKNOWN"
where customer_id is null;

-- Impute Discount
update electronics_retail
set discount = 0
where discount is null;

-- Impute Warehouse_id
update electronics_retail
set warehouse_id = "UNKNOWN"
where warehouse_id is null;

-- Impute Supplier_name
update electronics_retail
set supplier_name = "UNKNOWN"
where supplier_name is null;

-- Impute Customer_email
update electronics_retail
set customer_email = "UNKNOWN"
where customer_email = "" or customer_email is null;

-- Formatting some email like "cust8@" to "cust8@email.com"
update electronics_retail
set customer_email = case
    when customer_email regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' then customer_email
    when customer_email regexp '^[a-zA-Z0-9._%+-]+@$' then CONCAT(customer_email, 'email.com')
    else customer_email
END;

-- update "cust8@email.com" to "customer8@email.com"
update electronics_retail
set customer_email = case
	when customer_email regexp "^[A-Za-z]{4}[0-9]{1,}+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" then concat("customer",mid(customer_email,instr(customer_email,"t")+1,instr(customer_email,"@")-1-instr(customer_email,"t")),"@email.com")
    else customer_email
    end;

# Correcting order_date set varchar to date 

-- Adding order_date_column as date
alter table electronics_retail
add column order_date_correction date after order_date;

-- Update order_date_correction with corrected order_date format
update electronics_retail
set order_date_correction =
(select
	case
		when order_date regexp "^[A-Za-z]{3} [0-9]{4}$" then cast(str_to_date(concat(order_date, ' 01'), "%b %Y %d") as date)
        when order_date regexp "^[0-9]{2}/[0-9]{2}/[0-9]{4}$" then cast(str_to_date(order_date,"%m/%d/%Y") as date)
        when order_date regexp "^[0-9]{4}/[0-9]{2}/[0-9]{2}$" then cast(str_to_date(order_date,"%Y/%m/%d") as date)
        when order_date regexp "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" then cast(str_to_date(order_date,"%Y-%m-%d") as date)
        end as order_date_correction);

-- Drop order_date column (datatype - varchar)
alter table electronics_retail
drop column order_date;

-- Rename order_date_correction to order_date
alter table electronics_retail
rename column order_date_correction to order_date;

# Correcting restock_date set varchar to date (set any default an average restock_date)

-- Check the current values to confirm formats
select restock_date, COUNT(*) AS record_count
from electronics_retail
group by restock_date
order by record_count desc
limit 200;

-- checking missing values
select count(*) as null_count
from electronics_retail
where restock_date is null or restock_date = '';

-- Adding a new date column
alter table electronics_retail
add restock_date_clean date after restock_date;

-- Update restock_date_clean
update electronics_retail
set restock_date_clean = case
		-- MM/DD/YYYY Format
		when restock_date regexp "^[0-9]{2}/[0-9]{2}/[0-9]{4}$" then cast(str_to_date(restock_date,"%m/%d/%Y") as date)
        -- YYYY-MM-DD Format
        when restock_date regexp "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" and (right(left(restock_date,7),2)<=12) then cast(str_to_date(restock_date,"%Y-%m-%d") as date)
        -- YYYY-DD-MM Format
        when restock_date regexp "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" and (right(left(restock_date,7),2)>12) then cast(str_to_date(restock_date,"%Y-%d-%m") as date)
        -- MMM YYYY Format
        when restock_date regexp "^[A-Za-z]{3} [0-9]{4}$" then cast(str_to_date(concat(restock_date, ' 01'), "%b %Y %d") as date)
        when restock_date is null then null
        end;
        
-- Seleting Average date for setting as default
set @avg_restock_date := (
select date(from_unixtime(avg(unix_timestamp(restock_date))))
    from electronics_retail
    where restock_date is not null
	);
    
-- View @avg_restock value
select @avg_restock_date;
    
-- Checking null values
select count(*)
from electronics_retail
where restock_date_clean is null;

-- Update restock_date_clean null values with @avg_restock_date
update electronics_retail
set restock_date_clean = @avg_restock_date
where restock_date_clean is null;

-- Drop restock_date column (datatype - varchar)
alter table electronics_retail
drop column restock_date;

-- Rename restock_date_clean to restock_date
alter table electronics_retail
rename column restock_date_clean to restock_date;

# Standardize Product_id

/* Formats : P001,2,11,141,PROD-003 */

update electronics_retail
set product_id = case
	when length(product_id) = 1 then concat("P00",product_id)
    when length(product_id) = 2 then concat("P0",product_id)
    when length(product_id) = 3 then concat("P",product_id)
    when product_id regexp "^[A-Z]{4}-[0-9]{3}$" then concat("P",right(product_id,3))
    else product_id
    end;

# Standardize Warehouse_id

/*Formats : 001,WH001,WH-003 */

update electronics_retail
set warehouse_id = case 
	when length(warehouse_id) = 3 then concat("WH",warehouse_id)
    when warehouse_id regexp "^[A-Z]{2}-[0-9]{3}$" then concat("WH",right(warehouse_id,3))
    else warehouse_id
    end;
    
# Final check datatypes of columns
desc electronics_retail;
    
# View Cleaned Dateset
select * from electronics_retail

/* Dataset Cleaning Done */
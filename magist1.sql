use magist;

# how many order are in the database

describe orders;

select * 
from orders;

select count(distinct order_id) 
from orders;	#99441

# Orders delivered or not

select * 
from orders;

select distinct order_status
from orders;

select order_status, count(order_status) as numbers
from orders
group by order_status
;
#96478 orders delivered

select order_status, count(order_status) as numbers, round(count(order_status)*100.0/sum(count(order_id)) over (),2) as percentage
from orders
group by order_status
order by numbers desc
;
# 97% of the orders delivered

#magist user growth

describe orders;

select * from orders;

select month(order_purchase_timestamp) as Month_of_Purchase, year(order_purchase_timestamp) as Year_of_Purchase, count(customer_id) as Number_of_Customers
from orders
group by month(order_purchase_timestamp), year(order_purchase_timestamp)
order by year(order_purchase_timestamp), month(order_purchase_timestamp);
# table with Purchases per month from 2016-2018


#how many products are in the product table? Which categories?

describe products;

select * from products;

select count(distinct product_id) 
from products;		
#32951 products with unique product id's

select pr.product_category_name, pcnt.product_category_name_english, count(distinct product_id) as Number_of_Products
from products pr
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name 
group by product_category_name
order by 3 desc; 
#table with categories and available products in every category

#How many products are really being sold on this marketplace?

describe order_items;


select oi.product_id, pr.product_category_name, pcnt.product_category_name_english, count(oi.product_id)
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by oi.product_id
order by 4 desc;
#single products sold and margin of it. 

select pr.product_category_name, pcnt.product_category_name_english, count(oi.product_id) as numbers, round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by pr.product_category_name
order by 3 desc;

#testing of I get all sold products 
select count(product_id) from order_items;
#112650

select count(oi.product_id)
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by pr.product_category_name
order by 1 desc;

create table test_table 
select count(oi.product_id) as numbers
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by pr.product_category_name
order by 1 desc;

drop table test_table;

select * from test_table;

select sum(numbers) from test_table;
#112650 same number of sold items. worked. end of test

create table test_table2
select order_id, order_item_id, seller_id, price, freight_value
from products
left join order_items on products.product_id = order_items.product_id
order by order_item_id;
#where order_item_id is null;

select * from test_table2;

select count(price) from test_table2;

select count(distinct product_id) from products;

create table items_sold
select order_id, order_item_id, seller_id, price, freight_value, products.product_id
from products
left join order_items on products.product_id = order_items.product_id
where order_item_id is not null
order by order_item_id
;



#every item was sold at least once

#looking at prices for the products

select oi.product_id, pr.product_category_name, price from order_items oi
join products pr on oi.product_id = pr.product_id
order by price desc;

create table max_price_table
select pr.product_category_name, pcnt.product_category_name_english, max(price)
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by 2
order by 3 desc
;

drop table max_price_table;

select * from max_price_table;

select oi.product_id, pr.product_category_name, price from order_items oi
join products pr on oi.product_id = pr.product_id
order by price;

create table min_price_table
select pr.product_category_name, pcnt.product_category_name_english, min(price)
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by 2
order by 3 desc
;

select * from min_price_table;

select  avg(price) from order_items;

create table avg_price_table
select pr.product_category_name, pcnt.product_category_name_english, round(avg(price),2)
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by 2
order by 3 desc
;

select * from avg_price_table;


SELECT products.product_id, products.product_category_name, order_items.product_id, order_items.product_id,
product_category_name_translation.product_category_name,product_category_name_translation.product_category_name_english
FROM products
INNER JOIN order_items ON order_items.product_id = products.product_id
INNER JOIN product_category_name_translation on product_category_name_translation.product_category_name =products.product_category_name
order by product_category_name_english;

create table sold_items_table
select pcnt.product_category_name_english as categories, count(oi.product_id) as sold_items,
	round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage_of_sold_volume, round(sum(price),2) as revenue, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue
from order_items oi
join products pr on oi.product_id = pr.product_id
join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
group by 1
order by 2 desc
;

drop table sold_items_table;
select * from sold_items_table;
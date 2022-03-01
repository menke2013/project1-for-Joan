use magist;

select * from product_category_name_translation;
# tech related products: audio, books_technical, cds_dvds_musicals, computers, computers_accessories, consoles_games, dvd_blue_ray, elecetronics, 
#pc_gamer, others, telephony, toys,watches_gifts, tablets_printing_image, small_appliances

#-------------------------------
#creating a table a table for just the tech-categories
create table second_set_tech_table
select * 
from products pr
join product_category_name_translation pcnt using (product_category_name);

describe orders;

create table third_set_tech_categories
select * from second_set_tech_table
where product_category_name_english in ('audio', 'books_technical', 'cds_dvds_musicals', 'computers', 'computers_accessories', 'consoles_games', 'dvds_blu_ray', 'electronics',
'pc_gamer', 'others', 'telephony', 'toys', 'watches_gifts', 'tablets_printing_image', 'small_appliances');

#-------------------------------------

#products per category
select  product_category_name_english as categories ,count(distinct product_id) as number_of_unique_products from third_set_tech_categories
group by product_category_name_english
order by count(*) desc;


select product_category_name_english as names, count(product_id) as sold_items, round(avg(price),2) as average_price, round(sum(price),2) as revenue, 
	round(count(product_id)*100.0/sum(count(product_id)) over (),2) as percentage_of_sold_volume, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue
from third_set_tech_categories 
inner join order_items using (product_id)
group by product_category_name_english
order by 2 desc
;



#-------------------
# testing something
select product_category_name_english, count(product_id), avg(price) from third_set_tech_categories join order_items using (product_id)
where product_category_name_english = 'cds_dvds_musicals'
group by product_category_name_english
order by avg(price) desc
;

select product_id, price from third_set_tech_categories join order_items using (product_id)
where product_category_name_english = 'cds_dvds_musicals';

#end of test
#-------------------------------

select * from order_reviews;
select count(order_id) from order_reviews; #98371
select count(distinct order_id) from order_reviews; # 98371

create table all_categories_summery
select pcnt.product_category_name_english as categories, count(oi.product_id) as sold_items,
	round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage_of_sold_volume, 
    round(sum(price),2) as revenue_in_Euros, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue,
    avg(review_score) as average_review_score
from order_items oi
inner join products pr on oi.product_id = pr.product_id
inner join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
inner join order_reviews ore on oi.order_id = ore.order_id
group by 1
order by 2 desc
;

create table tech_categories_summery
select pcnt.product_category_name_english as categories, count(oi.product_id) as sold_items,
	round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage_of_sold_volume, 
    round(sum(price),2) as revenue_in_Euros, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue,
    avg(review_score) as average_review_score
from order_items oi
inner join products pr on oi.product_id = pr.product_id
inner join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
inner join order_reviews ore on oi.order_id = ore.order_id
group by 1
order by 2 desc
;
select * from all_categories_summery;

create table bla5
select pcnt.product_category_name_english as categories, count(oi.product_id) as sold_items,
	round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage_of_sold_volume, 
    round(sum(price),2) as revenue_in_Euros, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue,
    avg(review_score) as average_review_score
from order_items oi
inner join products pr on oi.product_id = pr.product_id
inner join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
inner join order_reviews ore on oi.order_id = ore.order_id
where price > 100 
group by 1
order by 2 desc;

create table bla6
select pcnt.product_category_name_english as categories, count(oi.product_id) as sold_items,
	round(count(oi.product_id)*100.0/sum(count(oi.product_id)) over (),2) as percentage_of_sold_volume, 
    round(sum(price),2) as revenue_in_Euros, round(sum(price)*100.0/sum(sum(price)) over (),2) as percentage_of_revenue,
    avg(review_score) as average_review_score
from order_items oi
inner join products pr on oi.product_id = pr.product_id
inner join product_category_name_translation pcnt on pr.product_category_name = pcnt.product_category_name
inner join order_reviews ore on oi.order_id = ore.order_id
where price > 200 
group by 1
order by 2 desc;

select * from bla5;

select * from all_categories_summery;

create table bla4
select * from all_categories_summery
where categories in ( 'computers', 'computers_accessories', 'electronics', 'telephony', 'watches_gifts', 'tablets_printing_image');

select * from bla4;

drop table bla4;

create table review_scores_tech_categories
select categories, acs.average_review_score as all_item_review_score, bla5.average_review_score as 100_Euro_or_more_review_score, bla6.average_review_score as 200_Euro_or_more_review_score
from all_categories_summery acs
inner join bla5 using (categories)
inner join bla6 using (categories)
where categories in ( 'computers', 'computers_accessories', 'electronics', 'telephony', 'watches_gifts', 'tablets_printing_image');

create table review_scores_all_categories
select categories, acs.average_review_score as all_item_review_score, bla5.average_review_score as 100_Euro_or_more_review_score, bla6.average_review_score as 200_Euro_or_more_review_score
from all_categories_summery acs
inner join bla5 using (categories)
inner join bla6 using (categories)
;

select * from review_scores_all_categories;

#---------------------
#delivery time

describe orders;

create table delivery_times
select 
	order_id, customer_id,
    timestampdiff(hour, order_purchase_timestamp, order_delivered_customer_date ) as delivery_time,
    timestampdiff(hour, order_estimated_delivery_date, order_delivered_customer_date) as diff_to_estimated_delivery_time,
    timestampdiff(hour, order_purchase_timestamp, order_delivered_carrier_date) as purchase_to_carrier_time,
    timestampdiff(hour, order_delivered_carrier_date, order_delivered_customer_date ) as carrier_delivery_time
       
from orders;

create table delivery_times_days
select 
	order_id, customer_id,
    timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date ) as delivery_time,
    timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) as diff_to_estimated_delivery_time,
    timestampdiff(day, order_purchase_timestamp, order_delivered_carrier_date) as purchase_to_carrier_time,
    timestampdiff(day, order_delivered_carrier_date, order_delivered_customer_date ) as carrier_delivery_time
       
from orders;

drop table delivery_times;

select * from delivery_times;

select * from delivery_times_days;

select order_id, delivery_time, diff_to_estimated_delivery_time 
from delivery_times_days
where diff_to_estimated_delivery_time > 10;


select count(*) from delivery_times_days;

select 	count(order_id)
from delivery_times_days
where diff_to_estimated_delivery_time > 0 ;

create table another_time_table
select *,
	case
		when diff_to_estimated_delivery_time > 0 then 'not on time'
         else 'on time'
	end as delay
  
from delivery_times_days
;

drop table another_time_table;

select * from another_time_table;


select round(sum(
	case
		when delay = 'not on time' then 1
        else 0
	end)*100/count(order_id),2) as percentage_not_delivered_on_time
from another_time_table; #6.57 percent not on expected time delivered

create table delayed_orders    
select *
from another_time_table
where delay = 'not on time';

drop table delayed_orders;

select * from delayed_orders;

select count(*) from delayed_orders
where purchase_to_carrier_time > 3;

select count(*) from delayed_orders
where purchase_to_carrier_time > carrier_delivery_time; #820 orders

select * 
from delayed_orders
inner join customers using (customer_id)
inner join geo on customers.customer_zip_code_prefix = geo.zip_code_prefix;

select city, state, avg(delivery_time), avg(diff_to_estimated_delivery_time), count(*) 
from delayed_orders
inner join customers using (customer_id)
inner join geo on customers.customer_zip_code_prefix = geo.zip_code_prefix
group by city
order by count(*) desc;

describe geo;

describe order_items;

select * from order_items;

describe delayed_orders;

create table delayed_orders_2
select order_id, customer_id,delivery_time, diff_to_estimated_delivery_time, purchase_to_carrier_time, carrier_delivery_time, delay, seller_id
from delayed_orders
inner join order_items using (order_id)
;

select * from delayed_orders_2;

select seller_id, avg(delivery_time), count(*)
from delayed_orders_2
group by seller_id
order by avg(delivery_time) desc;

create table seller_delayed
select seller_id, avg(delivery_time) as average_delivery_time_delayed, count(*) as number_of_delayed_orders
from delayed_orders_2
group by seller_id
order by count(*) desc;

#drop table seller_delayed;

select *  from seller_delayed;



create table seller_customer_time_table
select order_id, customer_id,delivery_time, diff_to_estimated_delivery_time, purchase_to_carrier_time, carrier_delivery_time, delay, seller_id, count(*) as number_of_orders
from another_time_table
inner join order_items using (order_id)
group by seller_id
;

create table seller_customers_orders_time_table
select order_id, customer_id,delivery_time, diff_to_estimated_delivery_time, purchase_to_carrier_time, carrier_delivery_time, delay, seller_id
from another_time_table
inner join order_items using (order_id);

select * from seller_customers_orders_time_table;

create table lighter_version
select order_id, customer_id, seller_id, delay
from seller_customers_orders_time_table;

select * from lighter_version;



drop table seller_customer_time_table;

select * from seller_customer_time_table;

create table bla_1
select seller_id, average_delivery_time_delayed, number_of_delayed_orders, seller_customer_time_table.number_of_orders, number_of_delayed_orders/ seller_customer_time_table.number_of_orders as percentage
from seller_delayed
inner join seller_customer_time_table using (seller_id)
where number_of_orders >= 10 and number_of_delayed_orders/ seller_customer_time_table.number_of_orders >= 0.1
order by percentage desc;

select * from bla_1
order by average_delivery_time_delayed;

select count(*) from sellers; #3095 sellers

select count(distinct seller_id) from seller_delayed; #1274

select count(distinct seller_id) from bla_1; #296

create table bla_2
select seller_id, average_delivery_time_delayed, number_of_delayed_orders, seller_customer_time_table.number_of_orders, number_of_delayed_orders/ seller_customer_time_table.number_of_orders as percentage
from seller_delayed
inner join seller_customer_time_table using (seller_id)
where number_of_orders and number_of_delayed_orders/ seller_customer_time_table.number_of_orders >= 0.1
order by percentage desc;

select count(distinct seller_id) from bla_2; #565

select * from bla_2
order by average_delivery_time_delayed;

select *
from avg_price_table
inner join max_price_table using (product_category_name_english)
where product_category_name_english in ( 'computers', 'computers_accessories', 'electronics', 'telephony', 'watches_gifts', 'tablets_printing_image');

select * from max_price_table;

create table competition
select product_category_name_english as categories, count(distinct seller_id) as amount_of_sellers
from products
inner join order_items using (product_id)
inner join product_category_name_translation using (product_category_name)
where product_category_name_english in ( 'computers', 'computers_accessories', 'electronics', 'telephony', 'watches_gifts', 'tablets_printing_image')
group by product_category_name_english;

select * from competition;
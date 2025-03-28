use olist_project;
SELECT *FROM olist_customers_dataset;
SELECT *FROM olist_geolocation_dataset;
SELECT *FROM olist_order_items_dataset;
SELECT *FROM olist_order_payments_dataset;
SELECT *FROM olist_order_reviews_dataset;
SELECT *FROM olist_orders_dataset;
SELECT *FROM olist_products_dataset;
SELECT *FROM olist_sellers_dataset;
SELECT *FROM product_category_name_translation;

##1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT CASE WHEN DAYOFWEEK(STR_TO_DATE(o.order_purchase_timestamp, '%d-%m-%Y')) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS day_type,
concat(ROUND(SUM(p.payment_value) / (SELECT SUM(p.payment_value) FROM olist_order_payments_dataset p) * 100,2),"%") AS percentage_of_total
FROM olist_orders_dataset o JOIN Olist_order_payments_dataset p on o.order_id = p.order_id
GROUP BY day_type;

#2.Number of Orders with review score 5 and payment type as credit card.
SELECT COUNT(p.order_id) AS Total_Orders FROM olist_order_payments_dataset p JOIN olist_order_reviews_dataset r ON p.order_id = r.order_id
WHERE r.Review_Score=5 AND p.Payment_type = 'credit_card';

#3.Average number of days taken for order_delivered_customer_date for pet_shop
SELECT ROUND(AVG(DATEDIFF(STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y'),STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y'))),0) AS AVG_DAYS
FROM olist_orders_dataset AS o JOIN olist_order_items_dataset AS oi ON o.order_id=oi.order_id 
JOIN olist_products_dataset AS op ON op.product_id=oi.product_id WHERE op.product_category_name='pet_shop';

#4.Average price and payment values from customers of sao paulo city
WITH orderitemavg AS (select round(avg(item.price)) as avg_order_item_price from olist_order_items_dataset item
join olist_orders_dataset ord on item.order_id = ord.order_id join olist_customers_dataset cust on ord.customer_id = cust. customer_id
where cust.customer_city = "sao paulo")
select (select avg_order_item_price from orderitemavg) as avg_order_item_price, round(avg(pmt.payment_value)) as avg_payment_value
from olist_order_payments_dataset pmt join olist_orders_dataset ord on pmt.order_id = ord.order_id
join olist_customers_dataset cust on ord.customer_id = cust.customer_id where cust.customer_city = "sao paulo";

#5.Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT review_score,ROUND(AVG(DATEDIFF(STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y'), STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y'))),0) 
AS Shipping_Days FROM olist_orders_dataset AS o JOIN olist_order_reviews_dataset AS ore ON o.order_id=ore.order_id 
GROUP BY review_score ORDER BY review_score;



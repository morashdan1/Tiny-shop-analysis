use tiny_shop ;

 --Which product has the highest price? Only return a single row

 select top  1 *
 from products
 order by price desc ;


 --Which customer has made the most orders?
 select c.customer_id , c.first_name , c.last_name ,
 count (order_id) as total_order
 from customers c 
 join orders s 
 on c.customer_id = s.customer_id 
 group by c.customer_id , c.first_name , c.last_name
 order by total_order desc;

--What’s the total revenue per product?
select  p.product_id,p.product_name , sum (price * quantity) as total
from products p
join order_items o
on p.product_id = o.product_id 
group by p.product_id , p.product_name 
order by total desc ;



--Find the day with the highest revenue
select  order_date ,sum (price * quantity) as total
from products p
join order_items o
on p.product_id = o.product_id 
join orders s
on s.order_id = o.order_id 
group by  order_date
order by total desc ;

--Find the first order (by date) for each customer
select  s.customer_id , min (order_date ) as frist_order
from customers s
join orders d 
on d.customer_id = s.customer_id
group by s.customer_id;

--Find the top 3 customers who have ordered the most distinct products
select top 3 c.customer_id , c.first_name , c.last_name ,
count (distinct(t.product_id)) as distinct_products
from products p join  order_items  t
on p.product_id = t.product_id
join orders s
on s.order_id = t.order_id 
join customers c 
on c.customer_id = s.customer_id
group by c.customer_id ,c.first_name , c.last_name
order by distinct_products desc , c.customer_id
;

--Which product has been bought the least in terms of quantity?
select product_name , sum (quantity) as total
from products p 
join order_items t
on p.product_id = t.product_id 
group by product_name 
order by total asc ;

--What is the median order total? 
with t_order as (
select order_id , sum (price * quantity) as total , 
ROW_NUMBER() over (order by  sum(price * quantity) asc ) as asc_rank ,
ROW_NUMBER() over (order by sum(price * quantity) desc ) as desc_rank
from order_items d join products p
on d.product_id = p.product_id
group by order_id
)
select avg(total) as median_total
from t_order
where asc_rank in (desc_rank ,desc_rank -1 ,desc_rank +1 ) ;

--For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
select s.order_id ,
case 
when  sum(price*quantity) > 300 then   'Expensive'
when  sum(price * quantity) > 100 then  'Affordable'
else 'cheap'
end as stutes 
from orders s 
join order_items t 
on s.order_id = t.order_id 
join products p
on p.product_id = t.product_id
group by s.order_id ;


--Find customers who have ordered the product with the highest price.
with cte as 
(
select c.customer_id , c.first_name,c.last_name, price ,
dense_rank () over(order by price desc) as ra_k
from customers c
join orders s 
on c.customer_id = s.customer_id
join order_items t 
on t.order_id = s.order_id
join products p 
on p.product_id = t.product_id
 )
 select * from cte 
 where ra_k =1 ;
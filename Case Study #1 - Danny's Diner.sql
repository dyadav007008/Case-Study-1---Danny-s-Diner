
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

 select * from sales



-------------------------------------------------------
--Case Study Questions
--Each of the following case study questions can be answered using a single SQL statement:

--Q1.What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(price)
from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id;

--Q2.How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) from sales
group by customer_id;

--Q3. What was the first item from the menu purchased by each customer?

select a.customer_id, m.product_name from (
select distinct(customer_id),order_date,
row_number() over (partition by customer_id order by order_date) as rn ,product_id from sales) a 
join menu m
on a.product_id = m.product_id
where a.rn = 1;


--Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.Product_name,count(s.product_id)
from sales s
join menu m
on s.product_id=m.product_id
group by m.Product_name,s.product_id
order by 2 desc
limit 1;

--Q5. Which item was the most popular for each customer?

select a.customer_id,m.product_name from (
select customer_id,product_id,count(*),
rank() over (partition by customer_id order by count(product_id) desc) as rn from sales
group by 1,2
order by 1) a
join menu m
on a.product_id = m.product_id
where rn = 1;


--Q6. Which item was purchased first by the customer after they became a member?

with a as (
select *,dense_rank() over (partition by customer_id order by order_date) as rn from sales
join members
using(customer_id)
join menu
using(product_id)
where order_date > join_date
order by customer_id )
select customer_id,product_name from a
where rn = 1;


-- Q7. Which item was purchased just before the customer became a member?

with a as (
select *,dense_rank() over (partition by customer_id order by order_date desc) as rn from sales
join members
using(customer_id)
join menu
using(product_id)
where order_date < join_date
order by customer_id )
select customer_id,product_name from a
where rn = 1;

--Q8.What is the total items and amount spent for each member before they became a member?

with a as (
select *,dense_rank() over (partition by customer_id order by order_date desc) as rn from sales
join members
using(customer_id)
join menu
using(product_id)
where order_date < join_date
order by customer_id )
select customer_id, order_date,count(product_name), sum(price) from a
group by 1,2
order by customer_id;



-- Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
select *, case
			when m.product_name = 'sushi' then price * 20
			else price * 10
			end as points		
from sales s
join menu m
using(product_id)
)
select customer_id , sum(points)
from cte
group by 1;



--Q10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


with a as (
SELECT *,
    CASE
        WHEN s.order_date between m.join_date and  m.join_date +  INTERVAL '7 days'  THEN price * 10 * 2
        WHEN menu.product_name = 'sushi' THEN price * 10 * 2
        ELSE price * 10
    END AS points
FROM 
    members m
JOIN 
    sales s USING (customer_id)
JOIN 
    menu ON s.product_id = menu.product_id
WHERE s.order_date < '2021-02-01'
)
select customer_id, sum(points)
from a
group by customer_id;


/*Bonus Questions
Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

customer_id	order_date	product_name	price	member
A	2021-01-01	curry	15	N
A	2021-01-01	sushi	10	N
A	2021-01-07	curry	15	Y
A	2021-01-10	ramen	12	Y
A	2021-01-11	ramen	12	Y
A	2021-01-11	ramen	12	Y
B	2021-01-01	curry	15	N
B	2021-01-02	curry	15	N
B	2021-01-04	sushi	10	N
B	2021-01-11	sushi	10	Y
B	2021-01-16	ramen	12	Y
B	2021-02-01	ramen	12	Y
C	2021-01-01	ramen	12	N
C	2021-01-01	ramen	12	N
C	2021-01-07	ramen	12	N
*/


select s.customer_id,s.order_date,m.product_name,m.price,
case
				when order_date >= join_date then 'Y'
				else 'N'
				end as member from sales s
join menu m
using(product_id)
full join members ms
using(customer_id)
order by 1,2;


/*Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

customer_id	order_date	product_name	price	member	ranking
A	2021-01-01	curry	15	N	null
A	2021-01-01	sushi	10	N	null
A	2021-01-07	curry	15	Y	1
A	2021-01-10	ramen	12	Y	2
A	2021-01-11	ramen	12	Y	3
A	2021-01-11	ramen	12	Y	3
B	2021-01-01	curry	15	N	null
B	2021-01-02	curry	15	N	null
B	2021-01-04	sushi	10	N	null
B	2021-01-11	sushi	10	Y	1
B	2021-01-16	ramen	12	Y	2
B	2021-02-01	ramen	12	Y	3
C	2021-01-01	ramen	12	N	null
C	2021-01-01	ramen	12	N	null
C	2021-01-07	ramen	12	N	null
*/

with cte as (
select *,
case
				when order_date >= join_date then 'Y'
				else 'N'
				end as member_status from sales s
join menu m
using(product_id)
full join members ms
using(customer_id)
order by 1,2
)
select customer_id,order_date,product_name,price,
			case
				when member_status = 'Y' then rank() over (partition by customer_id,member_status order by order_date)
				else NUll
				end as ranking from cte
order by 1,2


# Case Study #1 - Danny's Diner

![image](https://github.com/user-attachments/assets/a2c60f35-2e02-42ca-881c-d2af5dfaeafa)


Case Study Link: https://8weeksqlchallenge.com/case-study-1/
## Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen. Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.
Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:
- sales
- menu
- members

You can inspect the entity relationship diagram and example data below.
  ![image](https://github.com/user-attachments/assets/ef44892d-f398-4481-9bf0-752265724a08)

### Example Datasets

All datasets exist within the dannys_diner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

#### Table 1: sales
The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

### Table 2: menu
The menu table maps the product_id to the actual product_name and price of each menu item.

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |


### Table 3: members
The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |


## Schema

```sql
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
```


## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
```sql
select s.customer_id,sum(price)
from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id;
```
2. How many days has each customer visited the restaurant?

```sql
select customer_id, count(distinct(order_date)) from sales
group by customer_id;
```
3. What was the first item from the menu purchased by each customer?

```sql
select a.customer_id, m.product_name from (
select distinct(customer_id),order_date,
row_number() over (partition by customer_id order by order_date) as rn ,product_id from sales) a 
join menu m
on a.product_id = m.product_id
where a.rn = 1;
```

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
select m.Product_name,count(s.product_id)
from sales s
join menu m
on s.product_id=m.product_id
group by m.Product_name,s.product_id
order by 2 desc
limit 1;
```

5. Which item was the most popular for each customer?
```sql
select a.customer_id,m.product_name from (
select customer_id,product_id,count(*),
rank() over (partition by customer_id order by count(product_id) desc) as rn from sales
group by 1,2
order by 1) a
join menu m
on a.product_id = m.product_id
where rn = 1;
```

6. Which item was purchased first by the customer after they became a member?
```sql
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
```
7. Which item was purchased just before the customer became a member?
```sql
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
```
8. What is the total items and amount spent for each member before they became a member?
```sql
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
```
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
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
```
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
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
```

11. Bonus Question:

Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

```sql
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
```

12. Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | curry        | 15    | N      | null    |
| A           | 2021-01-01 | sushi        | 10    | N      | null    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | null    |
| B           | 2021-01-02 | curry        | 15    | N      | null    |
| B           | 2021-01-04 | sushi        | 10    | N      | null    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-07 | ramen        | 12    | N      | null    |

```sql
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
```


## Conclusion:

In this case study, Danny's Diner has leveraged customer purchase data to gain valuable insights into customer behavior, spending patterns, and the effectiveness of its loyalty program. The analysis of individual customer spending, visit frequency, and item preferences reveals key trends that can help improve customer engagement and retention.

- **Customer Spending and Frequency:**  By tracking the total amount spent and the number of visits, Danny’s Diner can identify high-value customers and target them for special promotions or loyalty rewards.
- **Menu Preferences:** The analysis of most popular and first items purchased provides a clear understanding of customer tastes, helping the diner optimize its menu and marketing strategies.
- **Loyalty Program Impact:**  The loyalty program’s influence is evident in the increase in points and purchases after customers join. By offering double points in the first week and special rewards for certain items (e.g., sushi), Danny's Diner can encourage faster adoption and increased spending from members.
- **Pre-membership Spending:**  Understanding what customers spent before joining the loyalty program gives insights into how much value the diner was offering even to non-members, and how much their loyalty program can boost future earnings.
- **Operational Efficiency:** The use of joined tables enables the diner to quickly access customer-specific data, such as total spend, item preferences, and loyalty status, without needing complex SQL queries. This improves operational efficiency and customer service.
In conclusion, Danny’s Diner can use these insights to fine-tune its marketing efforts, optimize its menu, and enhance the overall customer experience, ultimately driving increased loyalty and profitability.




#### SQL Topics Used in this case study:
- Common Table Expressions
- Group By Aggregates
- Window Functions for ranking
- Table Joins


Thank You.

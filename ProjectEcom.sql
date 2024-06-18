Use ecom;

/* Q1.
You can analyze all the tables by describing their contents.
Task: Describe the Tables:
Customers
Products
Orders
OrderDetails
*/

Desc Customers;
Desc Products;
Desc  Orders;
Desc OrderDetails;

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
/* Q2
Problem statement
Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

Hint:
Use the “Customers” Table.
Return the result table limited to top 3 locations in descending order

Note: NUM in the output format denotes a numerical value */

-- I dentify top 3 cities with highest num of cutomers using Customer table.

Select Location, Count(Customer_ID) Number_of_customers
from Customers
Group by Location
Order by Number_of_customers Desc
Limit 3;

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
/* Q3
Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.
Hint:
Use the “Orders” table.
Return the result table which helps you to segment customers on the basis of the number of orders in ascending order.
Consider the following:

Note: NUM in the output format denotes a numerical value */

-- Detemine the Cutomer segment based on the number of orders placed to detemine the onetim shoppers and regular customers 
-- Use Order table.
 /* Line 14-17 Finds the number of orders made by a single customer EG- Customer 2 order 1 and order 2*/
 /* Line 8 CO is the number of Orders placed by customer*/
 -- CTE Represnts the number of Customer, so basically the terms used, are getting used for different customer, it can be used to calculate total number of customers in that criteria.
 
 -- Select Count(Distinct Customer_ID) from Orders;
WITH Find AS (
    SELECT 
        S.CO AS N,
        CASE
            WHEN S.CO = 1 THEN 'One-time buyer'
            WHEN S.CO BETWEEN 2 AND 4 THEN 'Occasional shopper'
            WHEN S.CO > 4 THEN 'Regular Customer'
        END AS Terms
    FROM (
        SELECT 
            Customer_ID, 
            COUNT(Order_id) AS CO
        FROM 
            Orders
        GROUP BY 
            Customer_ID
    ) S)


 Select
          N AS NumberOfOrders,
          Count(Terms) As CustomerCount
          From 
          Find
          Group by N
          Order by N;
          
          
-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/* Q4
Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

Use “OrderDetails”.
Return the result table which includes average quantity and the total revenue in descending order.

Note: NUM in the output format denotes a numerical value.*/

-- Suggest the premium product, Find the a high revenue product with Avg puchased quantity equals to 2.
-- use Orderdetails
-- find the average Rev, every Revenue more than avg is high ticket product.


SELECT 
    Product_ID,
    AVG(Quantity) AS AvgQuantity,
    SUM(Quantity * Price_Per_Unit) AS TotalRevenue
FROM 
    OrderDetails
GROUP BY 
    Product_ID
HAVING 
    AVGQuantity = 2
ORDER BY 
    TotalRevenue DESC;
 -- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   
  
  /* Q5
  For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.


Hint:

Use the “Products”, “OrderDetails” and “Orders” table.
Return the result table which will help you count the unique number of customers in descending order.

Output format:
Italian Trulli
Note: NUM in the output format denotes a numerical value.*/

-- for Product category, caculate a unique number of customers, to understand the popular products.
--Use Products, Orderdetails and Orders
-- Returning table with unique number of customers in desc.
-- OrderDetails(order_id	product_id	quantity	price_per_unit)
-- Product(product_id	name	category	price)
-- Orders(order_id	order_date	customer_id	total_amount)
-- Customers for a product category(Product and Orders)
-- But OD Joins product using(Product_ID) and OD Joins Orders Using(Order_ID)

SELECT
    P.category,
    Count(Distinct O.customer_id) AS Unique_Customers
FROM
    Products P
JOIN
    OrderDetails OD ON P.product_id = OD.product_id
JOIN
    Orders O ON OD.order_id = O.order_id
    Group by 
    P.category
    Order by 
    Unique_Customers Desc;
    
    -- xxxxxxxxxxxxxxxxxxxxxxxxxx
    
    /* Q6
    Analyze the month-on-month percentage change in total sales to identify growth trends.

Hint:

Use the “Orders” table.
Return the result table which will help you get the month (YYYY-MM), Total Sales and Percent Change of the total amount (Present month value- Previous month value/ Previous month value)*100.
The resulting change in percentage should be rounded to 2 decimal places.


Note: NUM in the output format denotes a numerical value and DECI NUM denotes a numerical value with decimal.*/

-- Analyse the month on month change in total Sales to indentify growth.
-- Find the total Sales of the month, find the percentage change
-- Desc Orders; -Order_date is in Text
-- select * from Orders;- date format is Y-m-d

SELECT 
    S.Month,
    S.TotalSales,
    CASE
        WHEN LAG(S.TotalSales) OVER (ORDER BY S.Month) is NULL  then Null
        ELSE ROUND(((S.TotalSales - LAG(S.TotalSales) OVER (ORDER BY S.Month)) * 100.0 / 
                   LAG(S.TotalSales) OVER (ORDER BY S.Month)), 2)
    END AS PercentChange
FROM
(
    SELECT 
        DATE_FORMAT(STR_TO_DATE(Order_date, '%Y-%m-%d'), '%Y-%m') AS Month, 
        SUM(OD.Quantity * OD.Price_per_unit) AS TotalSales
    FROM Orders O
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    GROUP BY Month
    ORDER BY Month
) S;

/* Q7
Problem statement
Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.



Hint:

Use the “Orders” Table.
Return the result table which will help you get the month (YYYY-MM), Average order value and Change in the average order value (Present month value- Previous month value).
The resulting change in average order value should be rounded to 2 decimal places and should be ordered in descending order.


Output format:

Italian Trulli

Note: DECI NUM in the output format denotes a numerical value with decimal.*/

-- M-O-M change in the Values of avg order.
-- find the Avg Order values
-- by using lag funtion, find the difference.

SELECT 
    S.Month,
    S.AvgOrderValue,
    Round(CASE
        WHEN LAG(S.AvgOrderValue) OVER (ORDER BY S.Month) IS NULL THEN NULL
        ELSE (S.AvgOrderValue - LAG(S.AvgOrderValue) OVER (ORDER BY S.Month))
    END,2) AS ChangeInValue
FROM
(
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Month, 
        AVG(Total_Amount) AS AvgOrderValue
    FROM Orders 
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
 ) S

ORDER BY ChangeInValue DESC;

-- xxxxxxxxxxxxxxxxxxxx
/* Problem statement
Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
Hint:

Use the “OrderDetails” table.
Return the result table limited to top 5 product according to the total sales in descending order.

Note: NUM in the output format denotes a numerical value.
*/
-- find the frequence od a product been sold.
-- show the top 5 in descending order

Select 
         Product_id, 
        Count(order_id) SalesFrequency
From OrderDetails
Group by Product_id
Order by SalesFrequency desc
limit 5;
-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

/*
Problem statement
List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
Hint:

Use the “Product”, “Orders”, “OrderDetails” and “Customers” table.
Return the result table which will help you get the product names along with the count of unique customers who belong to the lower 40% of the customer pool.
Note: NUM in the output format denotes a numerical value and Product name denote name of the product.*/

-- List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
-- Use all 4 tables.
-- Return the result table which will help you get the product names along with the count of unique customers who belong to the lower 40% of the customer pool.
-- Count (Total customer_ID ) *40/100


SELECT 
    P.Product_ID,
    P.Name,
    COUNT(DISTINCT C.Customer_ID) AS UniqueCustomerCount
FROM 
    Customers C
JOIN 
    Orders O ON C.Customer_ID = O.Customer_ID
JOIN 
    OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN 
    Products P ON OD.Product_ID = P.Product_ID
GROUP BY 
    P.Product_ID, P.Name
HAVING 
    UniqueCustomerCount < (SELECT COUNT(DISTINCT Customer_ID) * 0.4 FROM Customers);
    
    -- xxxxxxxxxxxxxxxxxxxxxxxxxxx
    /*Problem statement
Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
Hint:

Use the “Orders” table.
Return the result table which will help you get the count of the number of customers who made the first purchase on monthly basis.
The resulting table should be ascendingly ordered according to the month.

Note: NUM in the output format denotes a numerical value.*/

-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
-- Return the result table which will help you get the count of the number of customers who made the first purchase on monthly basis.
-- from the order_date find the first purchase date, cound the no of customers who purchased during that time.


SELECT 
    DATE_FORMAT(STR_TO_DATE(S.OD, '%Y-%m-%d'), '%Y-%m') AS FirstPurchaseMonth,
    COUNT(S.C) AS TotalNewCustomers
FROM
    (SELECT 
         Customer_ID AS C, 
         Order_date AS OD, 
         Order_Id AS ID, 
         ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS rn
     FROM Orders) S
WHERE S.rn = 1
GROUP BY FirstPurchaseMonth
Order by FirstPurchaseMonth;

/* Problem statement
Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

Hint:

Use the “Orders” table.
Return the result table which will help you get the month (YYYY-MM) and the Total sales made by the company limiting to top 3 months.
The resulting table should be in descending order suggesting the highest sales month.

Note: NUM in the output format denotes a numerical value.*/

-- identify the highestsales vol month
-- find total sales, group it by month
--Return the result table which will help you get the month (YYYY-MM) and the Total sales made by the company limiting to top 3 months.
-- The resulting table should be in descending order suggesting the highest sales month.


SELECT 
    DATE_FORMAT(STR_TO_DATE(A.Order_Date, '%Y-%m-%d'), '%Y-%m') AS Month,
    SUM(B.Quantity * B.Price_per_unit) AS TotalSales
FROM 
    Orders A
JOIN 
    OrderDetails B USING (Order_ID)
GROUP BY 
    DATE_FORMAT(STR_TO_DATE(A.Order_Date, '%Y-%m-%d'), '%Y-%m')
ORDER BY 
    TotalSales DESC
LIMIT 3;

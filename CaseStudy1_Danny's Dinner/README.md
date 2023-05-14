[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/jiaqiyu1)
[![View Repositories](https://img.shields.io/badge/View-My_Portfolio-red?logo=GitHub)](https://github.com/jiaqiyu1/Portfolio_Guide)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/jiaqiyu1?tab=repositories)


# 🍜 Case Study #1 - Danny's Dinner
<p align="center">
<img width="289" alt="Screen Shot 2023-05-12 at 3 36 58 PM" src="https://8weeksqlchallenge.com/images/case-study-designs/1.png">
</p>

## 📕 Table Of Contents
* 🛠️ [Problem Statement](#-problem-statement)
* 📂 [Dataset](#-dataset)
* 🚀 [Questions and Solutions](#-questions-and-solutions)
---

## 🛠️ Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

 <br /> 

---

## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

### **```sales```**

<details>
<summary>
View table
</summary>

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 </details>

### **```menu```**

<details>
<summary>
View table
</summary>

The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

</details>

### **```members```**

<details>
<summary>
View table
</summary>

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 </details>



## 🔰 Entity Relationship Diagram
![q](https://github.com/jiaqiyu1/SQL_CaseStudy_DannyMa/assets/84236678/506062bd-b594-44ff-94db-3a8487f41423)

Powered by [dbdiagram.io](https://dbdiagram.io/d/608d07e4b29a09603d12edbd/?utm_source=dbdiagram_embed&utm_medium=bottom_open)



## 🚀 Questions and Solutions
Please [click here](https://github.com/jiaqiyu1/SQL_CaseStudy_DannyMa/blob/main/CaseStudy1_Danny's%20Dinner/Solution_Sql.sql) to see the questions and my solutions ! 




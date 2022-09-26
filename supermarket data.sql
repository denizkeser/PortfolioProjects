select * from sales
--1) first step i should check the null values
select * from sales where InvoiceID is null
select * from sales where Branch is null
select * from sales where City is null
select * from sales where Customertype is null
select * from sales where Gender is null
select * from sales where Productline is null
select * from sales where Unitprice is null
select * from sales where Quantity is null
select * from sales where 'Tax5%' is null
select * from sales where Total is null
select * from sales where Date is null
select * from sales where Time is null
select * from sales where Payment is null
select * from sales where cogs is null
select * from sales where grossmarginpercentage is null
select * from sales where grossincome is null
select * from sales where Rating is null
--null value does not exıst
--2) we should check data types
PRAGMA table_info(sales);
SELECT REPLACE(InvoiceID, '-', '') FROM sales
update sales set InvoiceID=REPLACE(InvoiceID,'-','')
--ALTER TABLE sales ALTER COLUMN InvoiceID INTEGER; However i use sqlite, so changed it without function
--We reduce the decimal parts to make the numbers more regular.
SELECT round("Tax5%",2) from sales
update sales set "Tax5%"=round("Tax5%",2)
update sales set "Total"=round("Total",2)
update sales set cogs=round(cogs,2)
update sales set grossmarginpercentage=round(grossmarginpercentage,2)
update sales set grossincome=round(grossincome,2)


update sales set "Date"=replace("Date",'-','/')
select substr("Date",1,1) from sales
alter table sales add column "Month" INTEGER;
update sales set Month=substr("Date",1,1)
select Month from sales
alter table sales add column "Day" INTEGER;
select substr("Date",3,2) from sales
update sales set Day=substr("Date",3,2)
update sales set Day=replace(Day,'/','')
select Day from sales
alter table sales add column "Year" INTEGER;
select substr("Date",-4,4) from sales
update sales set Year=substr("Date",-4,4)
select * from sales 
alter table sales drop column "Date"

--now we can explore the data 

select Branch,City from sales group by 1,2 -- as you can see we have 1 branch for every city
-- i will use the branch instead of the City
select Branch, sum(grossincome) from sales 
group by 1-- in total no big differences. 

select Month,Branch, sum(grossincome) from sales 
group by 1,2
order by 3 desc -- no big differences about monthly grossincome

SELECT * from sales

select Customertype,round(sum(grossincome),2) as 'total gross income' from sales
group by 1-- total gross income is not affected by the customertype.no meaningful difference

select Month,Customertype,round(sum(grossincome),2) as 'total gross income' from sales
group by 1,2 -- when we check values for the months, there is no big difference as well

select Gender, round(sum(grossincome),2) as 'total gross income' from sales
group by 1-- the result shows us that the female customers spent more than males 

-- what about the results for the moths seperately

select Month,Gender, round(sum(grossincome),2) as 'total gross income' from sales
group by 1,2-- male customers spent too less on second month.

--little bit more deep dive
select Month,Branch, round(sum(grossincome),2) as 'total gross income' from sales
where Gender='Male'
group by 1,2-- we can see all three branches have the worst amount of the gross income on the second month

select Month,Branch, round(avg(Rating),2) as "average rating" from sales
where Gender='Male'
group by 1,2-- male customers average rating scores for the 3 branches are not too low on the second month

select Month,Branch, round(sum(grossincome),2) as 'total gross income', count(DISTINCT InvoiceID) from sales
where Gender='Male'
group by 1,2-- males did less shop on february

select Month, round(sum(grossincome),2) as 'total gross income', count(DISTINCT InvoiceID) from sales
where Gender='Male'--males did less shop on february
group by 1

select Month, round(sum(grossincome),2) as 'total gross income', count(DISTINCT InvoiceID) from sales
where Gender='Female'
group by 1-- no big difference

select Month,Branch, round(avg(Rating),2) as "average rating" from sales
group by 1,2-- average customer satisfaction rating for each month and each branch 

select Month,Day,Branch, round(avg(Rating),2) as "average rating" from sales
group by 1,2,3-- daily changes

select Month,Day,Branch, round(avg(Rating),2) as "average rating" from sales
group by 1,2,3
having "average rating"<5
order by "average rating"--The days with the least customer satisfaction with a score of less than 5

--Payment
select Payment,round(sum(grossincome),2) as 'total gross income' from sales
group by 1-- for all VALUES

select Productline,round(sum(grossincome),2) as 'total gross income' from sales
group by 1--similar income level from the different productlines

select Productline,Customertype,round(sum(grossincome),2) as 'total gross income' from sales
group by 1,2


--we can analyze the data from different perspectives 
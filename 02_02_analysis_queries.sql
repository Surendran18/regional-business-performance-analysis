-- REGIONAL BUSINESS ANALYSIS

-- Query 1: Category Product Coverage
with category_coverage as
(select c.category_id,c.category_name,'has products' as product_status from categories c inner join products p
 on c.category_id=p.category_id
union all
select c.category_id,c.category_name,'no products' as product_status from categories c 
where not exists (select 1 from products p where c.category_id=p.category_id ))
select * from category_coverage;
-- Query 2: Products by Category
select c.category_name,p.product_name from categories c inner join products p 
on c.category_id=p.category_id order by c.category_id,p.product_id;
-- Query 3: Orders Without Associated Products
select o.order_id from orders o where not exists(select 1 from products p inner join order_items oi 
 where p.product_id=oi.product_id and oi.order_id=o.order_id);
 -- Query 4: Categories and Their Departments
 select c.category_id,c.category_name,d.department_id ,d.department_name from categories c left join departments d
 on c.department_id=d.department_id order by c.category_id,d.department_id;
 -- Query 5: Realized Sales by Region
with order_gross_sales as
(select  oi.order_id,sum(oi.order_quantity * oi.price_at_sale) as gross_sales from order_items oi inner join orders o 
on o.order_id=oi.order_id
where order_status = 'completed' group by order_id)
select r.region_id,r.region_name,sum(ogs.gross_sales -o.discount_amount) as realized_sales from regions r inner join orders o 
on r.region_id=o.region_id inner join order_gross_sales ogs on o.order_id=ogs.order_id 
group by r.region_id,r.region_name order by r.region_id;
-- Query 6: Completed Orders by Region
select r.region_id,r.region_name,count(o.order_id) as completed_orders from regions r inner join orders o 
on r.region_id=o.region_id where order_status='completed'
group by r.region_id,r.region_name order by completed_orders desc;
-- Query 7: Average Order Value by Region
with order_gross_sales as
(select o.order_id,o.region_id,sum(oi.order_quantity * oi.price_at_sale) as gross_sales from order_items oi inner join orders o 
on o.order_id=oi.order_id where order_status = 'completed' group by oi.order_id),
order_net_sales as
(select o.region_id,ogs.gross_sales - discount_amount as net_order_value from order_gross_sales ogs inner join orders o 
on ogs.order_id=o.order_id)
select r.region_id,r.region_name,avg(ons.net_order_value) as average_order_value from regions r inner join order_net_sales ons 
on r.region_id=ons.region_id group by r.region_id,r.region_name order by average_order_value desc;
-- Query 8: Regional Sales Contribution
with order_net_sales as
(select o.order_id,o.region_id,sum(oi.order_quantity*oi.price_at_sale) -o.discount_amount as realized_sales 
from orders o inner join order_items oi on o.order_id=oi.order_id where order_status = 'completed'
group by o.order_id,o.region_id,o.discount_amount),
region_sales as
(select region_id,sum(realized_sales) as realized_sales from order_net_sales group by region_id)
select r.region_id,r.region_name,rs.realized_sales,rs.realized_sales/sum(rs.realized_sales) over() * 100 as sales_percentage
from regions r inner join region_sales rs on r.region_id=rs.region_id order by sales_percentage desc;
-- Query 9: Customer Count by Region
select r.region_id,r.region_name,count(distinct o.customer_id) as number_of_customers from regions r inner join orders o
on r.region_id=o.region_id where o.order_status = 'completed' group by r.region_id,r.region_name
order by  number_of_customers desc;
-- Query 10: Average Customer Spending by Region
with realized_net_sales as
(select o.order_id,o.customer_id,o.region_id,sum(oi.order_quantity*oi.price_at_sale) - o.discount_amount as realized_value
from orders o inner join order_items oi on o.order_id=oi.order_id where o.order_status = 'completed' group by o.order_id,
o.customer_id,o.region_id,o.discount_amount),
customer_region_spending as
(select customer_id,region_id,sum(realized_value) as customer_spending from realized_net_sales group by customer_id,region_id)
select r.region_id,r.region_name,avg(crs.customer_spending) as average_customer_spending from regions r 
inner join customer_region_spending crs on r.region_id=crs.region_id group by r.region_id,r.region_name
order by average_customer_spending desc;
-- Query 11: Highest-Spending Customer in Each Region
with finding_total_spending as
(select o.customer_id,o.region_id,sum(oi.order_quantity*oi.price_at_sale)-o.discount_amount as total_spending from order_items oi inner join orders o
on oi.order_id=o.order_id where o.order_status = 'completed' group by o.order_id,o.region_id),
finding_region_wise as
(select region_id,max(total_spending) as max_total_spend from finding_total_spending group by region_id)
select fts.region_id,c.customer_id,c.customer_first_name,fts.total_spending from finding_total_spending fts inner join
finding_region_wise frw on fts.region_id=frw.region_id and fts.total_spending=frw.max_total_spend inner join customers c 
on c.customer_id=fts.customer_id order by fts.region_id;
-- Query 12: Regional Customers and Realized Sales
with finding_customers as
(select region_id,count(distinct customer_id) as customer_count from orders where order_status = 'completed' group by region_id),
finding_total as
(select o.order_id,o.region_id,sum(oi.order_quantity*oi.price_at_sale)-o.discount_amount as realized_sales from order_items oi inner join orders o
on o.order_id=oi.order_id where order_status='completed' group by o.order_id,o.region_id)
select fc.region_id,r.region_name,fc.customer_count,sum(ft.realized_sales) as realized_sales from finding_customers fc inner join finding_total ft
on fc.region_id=ft.region_id inner join regions r on r.region_id=fc.region_id
group by fc.region_id,fc.customer_count order by realized_sales desc;
-- Query 13: Total Units Sold by Region
with region_units_sold as
(select o.region_id,sum(oi.order_quantity) as units_sold from order_items oi inner join orders o 
on o.order_id=oi.order_id where order_status = 'completed' group by o.region_id)
select r.region_id,r.region_name,rus.units_sold  from regions r inner join region_units_sold rus 
on r.region_id=rus.region_id group by r.region_id,r.region_name order by units_sold desc;
-- Query 14: Category Realized Sales by Region
with category_gross_sales as
(select o.order_id,r.region_id,r.region_name,c.category_id,c.category_name,sum(oi.order_quantity*oi.price_at_sale) as category_gross_sale
from regions r inner join orders o on r.region_id=o.region_id 
inner join order_items oi on o.order_id=oi.order_id inner join products p on
oi.product_id=p.product_id inner join categories c on c.category_id=p.category_id where o.order_status='completed'
group by o.order_id,r.region_id,r.region_name,c.category_id,c.category_name,o.discount_amount),
order_gross_sales as
(select oi.order_id,sum(oi.order_quantity*oi.price_at_sale) as order_wise from order_items oi inner join orders o
on oi.order_id=o.order_id where o.order_status = 'completed' group by order_id),
finding_category_share as
(select ogs.order_id,cgs.category_id,cgs.category_gross_sale/ogs.order_wise as category_share from category_gross_sales cgs inner join order_gross_sales ogs
on ogs.order_id=cgs.order_id),
finding_category_discount as
(select fcs.order_id,fcs.category_id,fcs.category_share * o.discount_amount as category_discount from finding_category_share fcs inner join orders o
on o.order_id=fcs.order_id)
select cgs.region_id,cgs.region_name,cgs.category_id,cgs.category_name,sum(cgs.category_gross_sale - fcd.category_discount )
as category_realized_sales from category_gross_sales cgs inner join finding_category_discount fcd on cgs.order_id=fcd.order_id and cgs.category_id=fcd.category_id
group by cgs.region_id,cgs.region_name,cgs.category_id,cgs.category_name;
-- Query 15: Highest-Realized-Sales Category in Each Region
with category_gross_sales as
(select o.order_id,r.region_id,r.region_name,c.category_id,c.category_name,sum(oi.order_quantity *oi.price_at_sale) as category_gross_sale from regions r inner join orders o on o.region_id=r.region_id inner join order_items oi
on oi.order_id=o.order_id inner join products p on oi.product_id=p.product_id inner join categories c on c.category_id=p.category_id 
where o.order_status = 'completed' group by  o.order_id,r.region_id,r.region_name,c.category_id,c.category_name),
order_gross_sales as
(select o.order_id,sum(oi.order_quantity*price_at_sale) as order_gross_sale from orders o inner join order_items oi
on o.order_id=oi.order_id group by o.order_id),
category_discount_share as
(select cgs.order_id,cgs.category_id,cgs.category_gross_sale/ogs.order_gross_sale as category_share from  category_gross_sales cgs 
inner join order_gross_sales ogs on cgs.order_id=ogs.order_id),
individual_category_discount as
(select cds.order_id,cds.category_id,cds.category_share * o.discount_amount as category_discount from category_discount_share cds inner join orders o
on cds.order_id=o.order_id),
realized_sales as
(select cgs.region_id,cgs.region_name,cgs.category_id,cgs.category_name,sum(cgs.category_gross_sale - icd.category_discount) as realized_sale
from category_gross_sales cgs inner join individual_category_discount icd on cgs.order_id=icd.order_id and cgs.category_id=icd.category_id
group by cgs.region_id,cgs.region_name,cgs.category_id,cgs.category_name),
max_realized_sales as
(select region_id,max(realized_sale) as max_realized_sale from realized_sales group by region_id)
select rs.region_id,rs.region_name,rs.category_id,rs.category_name,rs.realized_sale from realized_sales rs inner join max_realized_sales mrs 
on rs.region_id=mrs.region_id and rs.realized_sale=mrs.max_realized_sale;
-- Query 16: Highest-Volume Product in Each Region
with product_region_volume as
(select r.region_id,r.region_name,p.product_id,p.product_name,sum(oi.order_quantity) as total_units_sold from regions r inner join orders o on o.region_id=r.region_id 
inner join order_items oi on oi.order_id=o.order_id inner join products p on oi.product_id=p.product_id 
where o.order_status = 'completed' group by r.region_id,r.region_name,p.product_id,p.product_name),
max_region_volume as
(select region_id,max(total_units_sold) as max_units_sold from product_region_volume group by region_id)
select prv.region_id,prv.region_name,prv.product_id,prv.product_name,mrv.max_units_sold from product_region_volume prv 
inner join max_region_volume mrv  on prv.region_id=mrv.region_id and prv.total_units_sold=mrv.max_units_sold;
-- Query 17: Category Sales Mix by Region
with category_gross_sales as
(select o.order_id,c.category_id,sum(oi.order_quantity * oi.price_at_sale) as category_gross from orders o inner join order_items oi on oi.order_id=o.order_id inner join products p on p.product_id=oi.product_id 
inner join categories c on c.category_id=p.category_id where o.order_status='completed' group by o.order_id,c.category_id),
order_gross_sales as
(select o.order_id,sum(oi.order_quantity*oi.price_at_sale) as order_gross from orders o inner join order_items oi on oi.order_id=o.order_id
where o.order_status = 'completed' group by o.order_id),
discount_share as
(select cgs.order_id,cgs.category_id,cgs.category_gross / ogs.order_gross * 100 as category_share_percentage from category_gross_sales cgs inner join order_gross_sales ogs
on cgs.order_id=ogs.order_id),
category_discounts as
(select o.order_id,ds.category_id,o.discount_amount * ds.category_share_percentage /100 as category_discount from orders o
 inner join discount_share ds on o.order_id=ds.order_id),
 category_realized_sales as
 (select cgs.order_id,cgs.category_id,cgs.category_gross-cd.category_discount as realized_sales from category_gross_sales cgs inner join category_discounts cd
 on cgs.order_id=cd.order_id and cgs.category_id=cd.category_id)
 select o.region_id,crs.category_id,sum(crs.realized_sales) as category_realized_sales,sum(crs.realized_sales) / sum(sum(crs.realized_sales))
 over(partition by o.region_id)*100 as category_mix_percentage from orders o inner join category_realized_sales crs 
on crs.order_id=o.order_id group by o.region_id,crs.category_id;
-- Query 18: Order Status Distribution by Region
with region_order_count as
(select region_id,count(order_id) as region_order_count  from orders group by region_id),
region_status_count as
(select region_id,order_status,count(order_id) as region_status_count from orders group by region_id,order_status)
select rsc.region_id,rsc.order_status,rsc.region_status_count / roc.region_order_count * 100 as shared_percentage from region_order_count roc
inner join region_status_count rsc on roc.region_id=rsc.region_id;
-- Query 19: Average Items per Order by Region
with order_item_totals as
(select o.order_id,sum(oi.order_quantity) as total_items from orders o inner join order_items oi
on oi.order_id=o.order_id where o.order_status = 'completed' group by o.order_id)
select r.region_id,r.region_name,avg(oit.total_items) as average_item_per_order from regions r inner join orders o on o.region_id=r.region_id 
inner join order_item_totals oit on o.order_id=oit.order_id group by r.region_id,r.region_name order by r.region_id;
-- Query 20: Total Discount Amount by Region
select r.region_id,r.region_name,sum(o.discount_amount) as total_discount_amount from orders o inner join regions r on o.region_id=r.region_id
where o.order_status = 'completed' group by r.region_id;
-- Query 21: Average Discount Amount by Region
with discount_total as
(select region_id,order_id,sum(discount_amount) as total_discount_amount from orders group by region_id,order_id)
select r.region_id,r.region_name,avg(dt.total_discount_amount) as average_disount_amount from regions r inner join discount_total dt
on dt.region_id=r.region_id group by r.region_id,r.region_name;
-- Query 22: Total Shipping Cost by Region
select region_id,sum(shipping_cost) as total_shipping_cost from orders group by region_id;
-- Query 23: Regional Performance KPI Summary
with order_gross_sales as
(select o.order_id,sum(oi.order_quantity * oi.price_at_sale) as order_gross_sale from order_items oi inner join orders o on oi.order_id=o.order_id
where o.order_status = 'completed' group by o.order_id),
category_gross_sales as
(select o.order_id,p.category_id,sum(oi.order_quantity * oi.price_at_sale) as category_gross_sale from orders o inner join order_items oi
 on oi.order_id=o.order_id inner join products p on p.product_id=oi.product_id where o.order_status='completed' group by o.order_id,p.category_id),
discount_percentages as
(select cg.order_id,cg.category_id, cg.category_gross_sale / order_gross_sale * 100 as discount_percentage from category_gross_sales cg
 inner join order_gross_sales og on cg.order_id=og.order_id),
category_discount_shares as
(select dp.order_id,dp.category_id,o.discount_amount * dp.discount_percentage / 100 as category_discount_amount from orders o 
inner join discount_percentages dp on dp.order_id=o.order_id),
category_realized_sales as
(select cg.order_id,cg.category_id,cg.category_gross_sale - ds.category_discount_amount as realized_sales from category_gross_sales cg 
inner join category_discount_shares ds on ds.order_id=cg.order_id and cg.category_id=ds.category_id),
order_items_total as
(select oi.order_id,sum(oi.order_quantity) as order_items_total from order_items oi inner join orders o
on o.order_id=oi.order_id where o.order_status='completed' group by order_id),
average_items_per_order as
(select region_id,avg(oit.order_items_total) as average_items_per_order from order_items_total oit inner join orders o
on o.order_id=oit.order_id group by o.region_id),
completed_order_metrics as
(select o.region_id,count(distinct o.order_id) as completed_orders,count(distinct o.customer_id) as customer_count,
sum(oi.order_quantity) as total_units_sold 
from orders o inner join order_items oi on o.order_id=oi.order_id where order_status='completed' group by region_id),
region_costs as
(select region_id,sum(shipping_cost) as total_shipping_cost,sum(discount_amount) as total_discount_amount from orders 
where order_status = 'completed' group by region_id)
select r.region_id,r.region_name,
round(sum(crs.realized_sales),2) as realized_sales,
com.completed_orders,round(sum(crs.realized_sales) / com.completed_orders,2) as average_order_value,
com.customer_count,com.total_units_sold,aipo.average_items_per_order,rc.total_discount_amount,rc.total_shipping_cost
from regions r inner join orders o on o.region_id=r.region_id
inner join category_realized_sales crs on crs.order_id=o.order_id 
inner join average_items_per_order aipo on aipo.region_id=r.region_id
inner join completed_order_metrics com on com.region_id=r.region_id
inner join region_costs rc on rc.region_id=r.region_id
GROUP BY r.region_id,r.region_name,com.completed_orders,com.customer_count,com.total_units_sold,aipo.average_items_per_order,
rc.total_discount_amount,rc.total_shipping_cost;
-- Query 24: Top-Sales Month and Product Performance by Region
with order_gross_sales as
(select o.order_id,sum(oi.order_quantity*oi.price_at_sale) as order_gross_sales from orders o inner join order_items oi
on o.order_id=oi.order_id where o.order_status='completed' group by o.order_id),
category_gross_sales as
(select o.order_id,p.category_id,sum(oi.order_quantity*oi.price_at_sale) as category_gross_sales from orders o inner join order_items oi
on o.order_id=oi.order_id inner join products p on p.product_id=oi.product_id where o.order_status = 'completed'
group by o.order_id,p.category_id),
category_sales_share as
(select cgs.order_id,cgs.category_id,cgs.category_gross_sales / ogs.order_gross_sales * 100 as category_sales_share from category_gross_sales cgs
inner join order_gross_sales ogs on ogs.order_id=cgs.order_id),
category_discount as
(select css.order_id,css.category_id,discount_amount * css.category_sales_share / 100 as category_discount from category_sales_share css
inner join orders o on o.order_id=css.order_id),
category_realized_sales as
(select cd.order_id,cd.category_id,cgs.category_gross_sales - cd.category_discount as realized_sales from category_discount cd
inner join category_gross_sales cgs on cgs.order_id=cd.order_id and cgs.category_id=cd.category_id),
monthly_region_sales as
(select o.region_id,date_format(o.order_date,'%y-%m') as sales_month,round(sum(crs.realized_sales),2) as realized_sales
from orders o inner join category_realized_Sales crs on o.order_id=crs.order_id
group by o.region_id,date_format(o.order_date,'%y-%m')),
max_realized_sales as
(select region_id,max(realized_sales) as max_realized_sales from monthly_region_sales group by region_id),
total_units_sold as
(select o.region_id,date_format(o.order_date,'%y-%m') as sales_month,
sum(oi.order_quantity) as quantity_sold
from orders o inner join order_items oi on o.order_id=oi.order_id
where o.order_status = 'completed' group by o.region_id,date_format(o.order_date,'%y-%m')),
product_metrics as
(select o.order_id,o.region_id,p.product_id,p.product_name,p.category_id,sum(oi.order_quantity) as products_sold_units,date_format(o.order_date,'%y-%m') 
as sales_month,sum(oi.order_quantity * oi.price_at_sale) as product_gross_sales,
round(cd.category_discount * sum(oi.order_quantity * oi.price_at_sale) / cgs.category_gross_sales * 100 / 100,2) as product_discount_amount,
round(sum(oi.order_quantity * oi.price_at_sale) - cd.category_discount * (sum(oi.order_quantity * oi.price_at_sale) / cgs.category_gross_sales * 100 )/ 100,2) as
product_realized_sales
from products p  inner join order_items oi on oi.product_id=p.product_id inner join orders o on o.order_id=oi.order_id
inner join category_gross_sales cgs on cgs.order_id=o.order_id and cgs.category_id=p.category_id
inner join category_discount cd on cd.order_id=o.order_id and cd.category_id=p.category_id
where o.order_status='completed'
group by p.product_id,p.product_name,o.region_id,o.order_id,date_format(o.order_date,'%y-%m'))
select r.region_id,r.region_name,pm.product_id,pm.product_name,om.sales_month,sum(products_sold_units) as product_sold_units,
sum(pm.product_gross_sales) as product_gross_sales,
sum(pm.product_discount_amount) as product_discount_amount,
sum(pm.product_realized_sales) as product_realized_sales,
round(sum(pm.product_gross_sales) / sum(pm.products_sold_units),2) as average_price_at_sales,
tus.quantity_sold,om.realized_sales as realized_sales
from regions r inner join monthly_region_sales om on om.region_id=r.region_id 
inner join max_realized_sales mrs on om.region_id=mrs.region_id and om.realized_sales=mrs.max_realized_sales
inner join total_units_sold tus on tus.region_id=r.region_id and tus.sales_month=om.sales_month
inner join product_metrics pm on pm.region_id=r.region_id and pm.sales_month=om.sales_month
group by r.region_id,r.region_name,pm.product_id,pm.product_name,om.sales_month;
-- Query 25: Final Regional Business Analytical Dataset
with order_summary as
(select o.region_id,o.order_id,date_format(o.order_date,'%Y-%m') as order_date,o.customer_id,
concat(c.customer_first_name,' ',c.customer_last_name) as customer_name,
o.order_status,sum(oi.order_quantity*oi.price_at_sale) as order_gross,o.discount_amount as order_discount_amount,
count(distinct o.customer_id) as customer_count,count(distinct o.order_id) as total_orders,sum(oi.order_quantity) as total_units_sold,
sum(oi.order_quantity*oi.price_at_sale) - o.discount_amount as order_realized_sales,
(sum(oi.order_quantity*oi.price_at_sale) - o.discount_amount) / count(distinct o.order_id) as average_order_value,
o.shipping_cost as order_shipping_cost
from orders o inner join order_items oi on o.order_id=oi.order_id 
inner join customers c on c.customer_id=o.customer_id
group by o.order_id,o.order_date,o.discount_amount,o.order_status),
category_summary as
(select o.order_id,c.category_id,c.category_name,sum(oi.order_quantity * oi.price_at_sale) as category_gross,
round(sum(oi.order_quantity * oi.price_at_sale) / os.order_gross,2) as category_share,
round(sum(oi.order_quantity * oi.price_at_sale) / os.order_gross * o.shipping_cost,2) as category_shipping_cost,
round(sum(oi.order_quantity * oi.price_at_sale) / os.order_gross * o.discount_amount,2) as category_discount_amount,
sum(oi.order_quantity*oi.price_at_sale) - round(sum(oi.order_quantity * oi.price_at_sale) / os.order_gross * o.discount_amount,2) as category_realized
from orders o inner join order_items oi on o.order_id=oi.order_id
inner join products p on p.product_id=oi.product_id
inner join categories c on c.category_id=p.category_id 
inner join order_summary os on os.order_id=o.order_id
group by o.order_id,c.category_id,c.category_name),
product_summary as
(select cs.order_id,cs.category_id,cs.category_name,p.product_id,p.product_name,sum(oi.order_quantity) as product_units_sold,
round(sum(oi.order_quantity*oi.price_at_sale),2) as product_gross,
round(sum(oi.order_quantity*oi.price_at_sale) / cs.category_gross,2) as product_share,
round(sum(oi.order_quantity*oi.price_at_sale) / cs.category_gross * cs.category_discount_amount,2) as product_discount_amount,
round(sum(oi.order_quantity*oi.price_at_sale) - sum(oi.order_quantity*oi.price_at_sale) / cs.category_gross * cs.category_discount_amount,2) as product_realized_sales,
round(sum(oi.order_quantity*oi.price_at_sale) / cs.category_gross * cs.category_shipping_cost,2) as product_shipping_cost
from category_summary cs inner join order_items oi on oi.order_id=cs.order_id
inner join products p on oi.product_id=p.product_id and p.category_id=cs.category_id
inner join orders o on o.order_id=cs.order_id
group by cs.order_id,cs.category_id,cs.category_name,p.product_id,p.product_name),
region_order_metrics as
(select o.region_id,count(distinct o.order_id) as total_orders,sum(os.order_gross) as region_gross_sales,sum(o.discount_amount) as region_discount_amount,
sum(os.order_gross) - sum(o.discount_amount) as region_realized_Sales,
round(sum(os.order_realized_sales) / count(distinct o.order_id),2) as regional_average_order_value,
sum(os.total_units_sold) / count(distinct o.order_id) as average_items_per_order,
count(distinct o.customer_id) as region_customer_count,sum(os.total_units_sold) as region_total_units
from orders o inner join order_summary os on o.order_id=os.order_id and o.region_id=os.region_id
group by o.region_id)
select os.order_id,os.customer_id,os.customer_name,os.order_date,os.order_status,r.region_id,r.region_name,
cs.category_id,cs.category_name,ps.product_id,ps.product_name,ps.product_units_sold,rom.region_gross_sales,rom.region_discount_amount,rom.region_realized_sales
,os.order_gross,os.order_discount_amount,os.order_realized_sales,cs.category_gross,cs.category_discount_amount,cs.category_realized,ps.product_gross,ps.product_discount_amount,
ps.product_realized_sales,rom.region_customer_count,os.customer_count,rom.region_total_units,os.total_units_sold,rom.regional_average_order_value,os.average_order_value,rom.average_items_per_order,
os.order_shipping_cost,cs.category_shipping_cost,ps.product_shipping_cost
from order_summary os inner join regions r on os.region_id=r.region_id
inner join category_summary cs on os.order_id=cs.order_id
inner join product_summary ps on ps.order_id=cs.order_id and ps.category_id=cs.category_id
inner join region_order_metrics rom on rom.region_id=r.region_id 
order by cast(substring(os.order_id,2) as unsigned);
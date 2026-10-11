# Regional Business Performance Analysis

## About the Project

This project focuses on analyzing overall sales across different regions and evaluating regional business performance based on completed orders. Using SQL and Excel, the analysis examines regional sales, order volume, customer activity, product and category performance, discounts, and other business metrics to identify the key factors contributing to revenue generation and differences in regional performance.

## Tools Used

- MySQL
- MySQL Workbench
- SQL
- Microsoft Excel

## Analysis

The project covers the following areas of regional business analysis:

- Overall sales performance across regions
- Regional performance based on completed orders
- Total units sold and distinct customer and order counts
- Regional discount amounts and shipping costs
- Monthly sales trends
- Product and category performance across regions
- Average Order Value (AOV) and customer spending
- Order status distribution
- Regional contribution to overall sales
- Top-performing categories by realized sales in each region
- Peak sales periods and product performance
- Combined regional KPI analysis

## Approach

I first explored the database using SQL queries to understand the data and the relationships between different tables. I then created queries to analyze regional sales, completed orders, customer activity, product and category performance, and other business metrics.

After completing the SQL analysis, I brought the final analytical dataset into Excel for further analysis. I used Power Query to prepare the data and merge the required order quantity information into the final analytical dataset.

I then used Excel features to calculate and compare regional performance metrics, analyze sales trends, and identify the factors contributing to the differences between regions. Finally, I combined the findings from SQL and Excel to understand the overall business performance and identify possible areas for improvement.

## Project Files

- `02_01_database_setup.sql` - Database and table creation with sample data.
- `02_02_analysis_queries.sql` - Contains 25 SQL queries used for data exploration and regional business analysis.
- `Regional_Business_Performance_Analysis.xlsm` - Excel workbook containing the final analytical dataset, regional analysis, and VBA automation.
- `Conclusion & Recommendations.txt` - Contains the overall conclusions and recommendations based on the analysis.
- `Region Central.txt` - Contains the detailed analysis of the Central region.
- `Region East.txt` - Contains the detailed analysis of the East region.
- `Region North.txt` - Contains the detailed analysis of the North region.
- `Region Northeast.txt` - Contains the detailed analysis of the Northeast region.
- `Region South.txt` - Contains the detailed analysis of the South region.
- `Region West.txt` - Contains the detailed analysis of the West region.
- `README.md` - Provides the project overview, tools used, analysis areas, key insights, and concepts applied.
## Key Insights

- The South region performed better than the other regions across most of the major business metrics.
- The North region recorded the highest Average Order Value (AOV).
- The East region recorded the highest Average Items per Order.
- The Laptop category contributed significantly to completed sales across multiple regions.
- Regional sales performance differed based on order volume, customer activity, product mix, and average order value.
- Differences in discounts and shipping costs provided additional information for comparing regional performance.
- The analysis of cancelled, pending, and returned orders showed differences between regions that require further investigation.
- Comparing multiple business metrics together provided a better understanding of regional performance beyond sales alone.

## SQL Concepts Used

- SELECT and filtering
- INNER JOIN and LEFT JOIN
- GROUP BY and aggregate functions
- Common Table Expressions (CTEs)
- Subqueries
- NOT EXISTS
- UNION ALL
- Window functions
- Date-based analysis
- Percentage calculations
- Identifying top-performing products and categories
## Excel Concepts Used

- Power Query for data preparation and transformation
- Merging data from different sources
- Data Model
- DAX calculations
- PivotTables for summarizing business metrics
- Regional and monthly sales analysis
- KPI comparison
- Slicers and interactive filtering
- VBA automation

## Project Status

Completed as a SQL and Excel regional business performance analysis project.

The project includes database preparation, 25 SQL analysis queries, a final analytical dataset, Excel-based business analysis, and VBA automation.

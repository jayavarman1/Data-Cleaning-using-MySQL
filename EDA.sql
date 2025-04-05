-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

--Basic Queries
--Select All Records
SELECT * 
FROM world_layoffs.layoffs_staging2;
---This query selects all columns and rows from the layoffs_staging2 table in the world_layoffs schema.

---Find Maximum total_laid_off
SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;
---This query returns the maximum value of the total_laid_off column from the layoffs_staging2 table.

---Find Maximum and Minimum percentage_laid_off
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;
---This query returns the maximum and minimum values of the percentage_laid_off column, excluding null values.

---Find Companies with 100% Layoffs
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;
---This query selects all records where the percentage_laid_off is 100%.

---Order Companies with 100% Layoffs by funds_raised_millions
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
---This query selects all records where the percentage_laid_off is 100% and orders them by funds_raised_millions in descending order.

--Group By Queries
--Companies with the Biggest Single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;
---This query selects the top 5 companies with the highest single layoff event.

----Companies with the Most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;
---This query selects the top 10 companies with the highest total layoffs by summing total_laid_off and grouping by company.

---Layoffs by Location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;
---This query selects the top 10 locations with the highest total layoffs.

---Layoffs by Country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;
---This query selects the total layoffs by country.

---Layoffs by Year
SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY YEAR(date) ASC;
---This query selects the total layoffs by year.

--Layoffs by Industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;
--This query selects the total layoffs by industry.

---Layoffs by Stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;
---This query selects the total layoffs by the stage of the company.

---Advanced Queries
----Companies with the Most Layoffs Per Year
WITH Company_Year AS (
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;
---This query uses Common Table Expressions (CTEs) to find the top 3 companies with the most layoffs per year.

---Rolling Total of Layoffs Per Month
WITH DATE_CTE AS (
  SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
  FROM world_layoffs.layoffs_staging2
  GROUP BY dates
  ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
---This query calculates the rolling total of layoffs per month using a CTE to first aggregate the monthly totals.


---viewing the dataset
select*from layoffs;

---creating a duplicate dataset called layoffs_staging like layoffs,
---We want a table with the raw data in case something happens
create table layoffs_staging
like layoffs; ---now empty table skeleton will be created like layoffs

---viewling the empty table
select * from layoffs_staging;

---now inserting the values from the layoffs table into duplicate table layoffs_staging
insert into layoffs_staging
select * from layoffs

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates
-- First let's check for duplicates
---THIS A METHOD TO FIND THE DUPLICATES
---Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
---CREATING A TABLE CALLED LAYOFFFS_STAGING2 INCLUDING A ROW_NUM COLUMN
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

---NOW INSERTING THE VALUES FROM LAYOFFS_STAGING AND ADDING ROW NUMBER
insert into layoffs_staging2
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

select* from layoffs_staging2
where row_num > 1;
---NOW DELETING THE ROWNUM GREATER THAN 1
DELETE
from layoffs_staging2
where row_num > 1;



---2.STANDERDIZING DATA
---company columns are having unwanted spaces , therefore we use this statement to view the difference
select company, trim(company)
from layoffs_staging2
---now we are updating that in our table and viewing it
update layoffs_staging2
set company = trim(company);

select *  from layoffs_staging2

---now we are slecting industry for any cleaning is need to be done
select distinct industry
from layoffs_staging2;
---where crypto is the same industry name differently as crypto and cryptocurrency
select distinct industry
from layoffs_staging2
where industry like 'crypto%';
---now we are updating all crypto industry in the name crypto
update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

---now we are  looking into location where everything is fine 
select distinct location
from layoffs_staging2
order by 1;

---now we are looking into country 
select distinct country
from layoffs_staging2;
---where we can find that united states country trailing with a '.'
select distinct country
from layoffs_staging2
where country like 'united states%';
---now we are triming it and checking
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
where country like 'united states%';
---checking is all good so we are updating it in the table
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%';


---now  we see the date column 
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;
---where its not in proper format therefore we are using str_to_date to format it
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');---previously its in mm/dd/yyyy format we are changing into standard sql format that is yyyy/mm/dd
---viewing table
select*from layoffs_staging2;
---but still its in text data type now we are changing it into date
alter table layoffs_staging2
modify column `date` DATE;


-- 3. LOOKING INTO NULL VALUES 
---we are checking for null in industry column
select *
from layoffs_staging2
where industry is null
or industry ='' ;
---few companys have null now we are takinga company to see does they have information in other rows inordr to fill this null area
select *
from layoffs_staging2
where company ='Airbnb'; 
---we are setting all blank area wih null value 
update layoffs_staging2
set industry = null
where industry ='';
---we are joining the table to fill the values
select t1.industry, t2.industry
from layoffs_staging2 t1
	join layoffs_staging2 t2
    on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;
--- now updating in the table
update layoffs_staging2 t1
	join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
---also they dont have any relatable columns so thatwe cant fill the null values
-- so there isn't anything I want to change with the null values


---4.DELETING UNWANTED ROWS AND COLUMNS
---Here we are checking wether both total_laid_off and percentage_laid_off are null 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
---if it is null then it is of no use so we are deleting the rows
-- Delete Useless data we can't really use
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;
---the row_number column we created before is also not needed so wwe are dropping that column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
SELECT * 
FROM .layoffs_staging2;

-- DATA CLEANING



select * 
from layoffs;

-- 1.REMOVE DUPLICATES
-- 2.STANDARIZE THE TABLE 
-- 3.NULL VAULES OR BLANK VAULES 
-- 4.REMOVE ANY COLUMNS

-- CREATE STAGING

create table layoffs_staging
LIKE layoffs;

select * 
from layoffs_staging;

insert layoffs_staging
select*
from layoffs;

-- REMOVE DUPLICATES

SELECT*,
row_number () OVER (
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging;

with duplicate_cte as
(
SELECT*,
row_number () OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date` ,
stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
select* 
from duplicate_cte
where row_num > 1;

select*
from layoffs_staging
WHERE company = 'Casper';

with duplicate_cte as
(
SELECT*,
row_number () OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date` ,
stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
DELETE
from duplicate_cte
where row_num > 1;


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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select*
from layoffs_staging2;

INSERT INTO  layoffs_staging2
SELECT*,
row_number () OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, `date` ,
stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

select*
from layoffs_staging2
where row_num > 1 ;

DELETE
from layoffs_staging2
where row_num > 1;

SELECT*
FROM layoffs_staging2;

-- Standardizing data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select*
from layoffs_staging2
where industry like 'Crypto%' ;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country , trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country =  trim(trailing '.' from country)
where country like 'United_States%';

select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

SELECT * 
FROM layoffs_staging2;

-- WORKING WITH NULL AND BLANK VAULES

SELECT*
FROM layoffs_staging2
WHERE total_laid_off is null
and percentage_laid_off is null;


update layoffs_staging2
set industry = NULL
WHERE industry = '';

select*
from layoffs_staging2
where industry is null
or industry = '';

select*
from layoffs_staging2
where company = 'Airbnb';

select t1.industry , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry 
where t1.industry is null
and t2.industry is not null;

select*
from layoffs_staging2;

-- REMOVE COLUMNS AND ROWS

SELECT*
FROM layoffs_staging2
WHERE total_laid_off is null
and percentage_laid_off is null;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is null
and percentage_laid_off is null ;

SELECT*
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP column row_num;

/*
  PROJECT: Global Tech Layoffs – Data Cleaning
  DESCRIPTION:
    This script cleans and prepares raw layoff data for analysis. Key cleaning steps include:
    - Removing duplicates using ROW_NUMBER()
    - Trimming whitespace and standardizing capitalization
    - Converting string dates to DATE format
    - Filling missing industry values using company/location mapping
    - Removing rows with no valid layoff data

    Final output is staged in `layoffs_staging2` for downstream analysis.
*/

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns / rows - only really useful for massive data sets to reduce time spent querying, unless there are completely useless columns/rows

-- Create staging table for raw data import
CREATE TABLE layoffs_staging -- Create staging so as not to work on the real 'raw' data incase something goes wrong
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- 1. Identify dupes - use row numbers

-- Remove exact duplicate records using window function
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY
	company, industry, total_laid_off, percentage_laid_off, `date`
) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY
		company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
	) AS row_num
	FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- SELECT *
-- FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY
	company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- 2. Standardising data

SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Clean whitespace and standardize text casing
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country like 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


-- 3. Nulls & Blanks

-- Replace empty strings with NULLs for consistency
UPDATE layoffs_staging2 -- First update any blank spaces to NULL so that we can manipulate data properly later on, if left blank it messes with the UPDATE/SET further down
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NOT NULL;

-- Fill missing industry values using known company/location pairs
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


-- 4. Remove Columns & Rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows with no valid layoff data (edge cleanup)
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;











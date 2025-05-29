/*
  PROJECT: Global Tech Layoffs – Exploratory Data Analysis
  DESCRIPTION:
    This script analyzes layoff trends using cleaned data from the `layoffs_staging2` table.
    Key insights include:
    - Layoffs by company, country, and year
    - Funding stage and industry impact
    - Rolling monthly and annual layoffs using window functions
    - Top locations and companies per year using DENSE_RANK()

    Output from this file would support dashboard visuals and reporting.
*/

-- Spot check: single company with highest layoffs
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000;

-- Explore numeric extremes in the dataset
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company/country
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- SELECT *
-- FROM layoffs_staging2;

SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR (`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Monthly layoff trends
SELECT SUBSTRING(`date`, 1, 7) `Month`,
SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

SELECT SUBSTRING(`date`, 1, 4) `Year`,
SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 4) IS NOT NULL
GROUP BY `Year`
ORDER BY 1 ASC;

-- Rolling monthly and yearly totals using window functions
WITH Rolling_Total_Month AS (
	SELECT SUBSTRING(`date`, 1, 7) AS `Month`,
    SUM(total_laid_off) AS total_laid_off_sum
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `Month`
	ORDER BY 1 ASC
)
SELECT `Month`,
total_laid_off_sum,
SUM(total_laid_off_sum) OVER (
	ORDER BY `Month`
) AS rolling_laid_off_total,
SUM(total_laid_off_sum) OVER (
	PARTITION BY SUBSTRING(`Month`, 1, 4)
	ORDER BY `Month`
) AS Rolling_yearly_total
FROM Rolling_Total_Month;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Top 5 companies by year using DENSE_RANK()
WITH Company_Year (company, years, total_laid_off) AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
	ORDER BY 3 DESC
),
Company_Year_Rank AS (
	SELECT *, DENSE_RANK() OVER (
		PARTITION BY years
		ORDER BY total_laid_off DESC
	) AS Ranking
	FROM Company_Year
	WHERE years IS NOT NULL
	AND total_laid_off IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- Top 10 locations by year using DENSE_RANK()
WITH Location_Year (country, location, years, total_laid_off) AS (
	SELECT country,
    location,
    YEAR(`date`),
    SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY country, location, YEAR(`date`)
	ORDER BY 3 ASC
),
Location_Year_Rank AS (
	SELECT *, DENSE_RANK() OVER (
		PARTITION BY years
		ORDER BY total_laid_off DESC
	) AS Ranking
	FROM Location_Year
	WHERE years IS NOT NULL
	AND total_laid_off IS NOT NULL
)
SELECT *
FROM Location_Year_Rank
WHERE Ranking <= 10;









-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
;

SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR (`date`)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;



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
WHERE Ranking <= 5
;



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
WHERE Ranking <= 10
;









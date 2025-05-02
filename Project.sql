SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- REMOVE DUPLICATES

CREATE TABLE layoffs_staging2
SELECT *, ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS Row_Num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE Row_Num >1
;

SET sql_safe_updates=0;
DELETE
FROM layoffs_staging2
WHERE Row_Num>1;

SELECT *
FROM layoffs_staging2
;


-- STANDARDIZING DATA

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company= TRIM(company);

SELECT DISTINCT INDUSTRY
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry= 'Crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country= TRIM(TRAILING '.' FROM country)
;

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date`= str_to_date(`date`, '%m/%d/%Y')
;

SELECT *
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;  #changing data type

-- FILL NULL VALUES

UPDATE layoffs_staging2
SET industry = NULL
where industry ='' ;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

SELECT l.company, l.industry, ll.company, ll.industry
FROM layoffs_staging2 l
JOIN layoffs_staging2 ll
	 ON l.company = ll.company
     AND l.location=ll.location
WHERE l.industry IS NULL 
AND ll.industry IS NOT NULL;


UPDATE layoffs_staging2 l
JOIN layoffs_staging2 ll
	 ON l.company = ll.company
     AND l.location=ll.location
SET l.industry=ll.industry
WHERE l.industry IS NULL 
AND ll.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL;


-- DELETE UNWANTED ROWS OR COLUMNS

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN Row_Num;

/*
    PROJECT : Indian Startup Funding Analysis
    PERIOD  : 2020-2024 (2025 partial, separate)

    OBJECTIVE

    Analyse startup funding patterns in India between 
    2020 and 2024 to understand:
    - How did total funding evolve across the boom and funding winter?
    - Which sectors attracted the most capital?
    - How concentrated is funding across deals and startups?
    - Which cities dominated which sectors?
    - How unequal is capital distribution? (Gini analysis)

    DATA SCOPE

    Trend analysis     : 2020-2024 complete years only
    Aggregate analysis : 2020-2024 dataset
    Investor/startup   : 2020-2025 full dataset
    Concentration check: 2020-2025 full dataset
    Partial year       : 2025 analysed separately 

    KNOWN LIMITATIONS

    Sample data, not representative of full Indian market.
    Multi-investor deals recorded as single investor string.
    City names assumed consistent, no normalisation applied.
    2025 figures not comparable to full year results.
*/

/*
    DATA QUALITY ASSESSMENT
    To score dataset completeness before analysis begins
*/
SELECT
    ROUND(COUNT(Startup) * 100.0
        / COUNT(*), 1)                  AS startup_complete_pct,
    ROUND(COUNT(Industry) * 100.0
        / COUNT(*), 1)                  AS industry_complete_pct,
    ROUND(COUNT(City) * 100.0
        / COUNT(*), 1)                  AS city_complete_pct,
    ROUND(COUNT(Investors) * 100.0
        / COUNT(*), 1)                  AS investors_complete_pct,
    ROUND(COUNT(InvestmentType) * 100.0
        / COUNT(*), 1)                  AS type_complete_pct,
    ROUND(COUNT(InvestmentAmount_USD) * 100.0
        / COUNT(*), 1)                  AS amount_complete_pct,
    ROUND(COUNT(Date) * 100.0
        / COUNT(*), 1)                  AS date_complete_pct,
    ROUND((
        COUNT(Startup) + COUNT(Industry) +
        COUNT(City) + COUNT(Investors) +
        COUNT(InvestmentType) +
        COUNT(InvestmentAmount_USD) + COUNT(Date)
    ) * 100.0 / (COUNT(*) * 7), 1)     AS overall_complete_pct
FROM investor_funding;

/* Result : Dataset has no missing values */

-- Duplicate record analysis

SELECT
    Startup,
    Date,
    InvestmentAmount_USD,
    COUNT(*) AS duplicate_count

FROM investor_funding

GROUP BY
    Startup,
    Date,
    InvestmentAmount_USD

HAVING COUNT(*) > 1;

/* Result : No duplicates found */

-- To identify dataset date range and detect partial-year data

SELECT
    MIN(Date) AS earliest_date,
    MAX(Date) AS latest_date
FROM investor_funding;

/* Result : Dataset spans 2020-2025, with 2025 ending in June, treated as partial year */

-- Total scale of the funding

SELECT 
    COUNT(*)            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD),2)     AS total_funding,
    ROUND(AVG(InvestmentAmount_USD),2)     AS avg_deal_size,
    MIN(YEAR(Date))     AS first_year,
    MAX(YEAR(Date))     AS last_year
FROM investor_funding
WHERE InvestmentAmount_USD IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024;

/* Result : 1,016 deals totalling $25.27bn across 2020-2024 */

-- Checking for outliers and distribution

SELECT
    ROUND(MIN(InvestmentAmount_USD), 2)                       AS smallest_deal,
    ROUND(MAX(InvestmentAmount_USD), 2)                       AS largest_deal,
    ROUND(AVG(InvestmentAmount_USD), 2)                       AS mean_deal,
    ROUND(STDEV(InvestmentAmount_USD), 2)                     AS std_deviation,
    COUNT(CASE WHEN InvestmentAmount_USD > 100000000 
          THEN 1 END)                               AS Deals_100M
FROM investor_funding
WHERE InvestmentAmount_USD IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024;

/* Result : Standard deviation 3x the mean, average deal size is unreliable, use median */

/*  
   Power law check
   What % of total funding do the top deals over 100M represent?
*/

SELECT
    ROUND(SUM(CASE WHEN InvestmentAmount_USD > 100000000 
          THEN InvestmentAmount_USD END) * 100.0 
          / SUM(InvestmentAmount_USD), 2)                AS large_deal_percentage,
    ROUND(SUM(CASE WHEN InvestmentAmount_USD <= 100000000 
          THEN InvestmentAmount_USD END) * 100.0 
          / SUM(InvestmentAmount_USD), 2)                AS small_deal_percentage
FROM investor_funding
WHERE InvestmentAmount_USD IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024;

/* Result : Deals over $100M are small in numbers but dominate total funding */

/*
   Concentration check
   What % of all funding went to just the top 10 startups?
*/
WITH startup_totals AS (
    SELECT
        Startup,
        SUM(InvestmentAmount_USD)                       AS startup_total
    FROM investor_funding
    WHERE Startup IS NOT NULL
    GROUP BY Startup
),
ranked AS (
    SELECT
        Startup,
        startup_total,
        ROW_NUMBER() OVER (ORDER BY startup_total DESC) AS rnk,
        SUM(startup_total) OVER ()                      AS grand_total
    FROM startup_totals
)
SELECT
    SUM(CASE WHEN rnk <= 10 
        THEN startup_total END) * 100.0 
        / MAX(grand_total)                              AS Top10_Percentage,
    SUM(CASE WHEN rnk > 10  
        THEN startup_total END) * 100.0 
        / MAX(grand_total)                              AS Rest_Percentage
FROM ranked;

/* Result : Top 10 startups absorbed a disproportionate share */

/*
   Typical deal size
   To find the true middle value unaffected by mega deals*/

SELECT DISTINCT
    ROUND(PERCENTILE_CONT(0.5) 
    WITHIN GROUP (ORDER BY InvestmentAmount_USD)
    OVER (), 2)                     AS median_deal_usd
FROM investor_funding
WHERE InvestmentAmount_USD IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024;

/* Result : Median $1.1M vs mean $24.88M, half of all startups raised under $1.1M */

/*
   Gini coefficient 
   To Measure how unequally funding is distributed
*/

WITH ranked AS (
    SELECT
        InvestmentAmount_USD,
        ROW_NUMBER() OVER (ORDER BY InvestmentAmount_USD)  AS rn,
        COUNT(*) OVER ()                                   AS n
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
    AND YEAR(Date) BETWEEN 2020 AND 2024
),
gini_calc AS (
    SELECT
        n,
        SUM(InvestmentAmount_USD)                          AS total,
        SUM((2.0 * rn - n - 1) * InvestmentAmount_USD)    AS weighted_sum
    FROM ranked
    GROUP BY n
)
SELECT
    ROUND(weighted_sum / (n * total), 4)                   AS gini_coefficient
FROM gini_calc;

/* Result : 0.87, funding is very unequal. */

/*
    SENSITIVITY ANALYSIS
    To check if conclusions change when 2025 is included
    To find if our key metrics are robust to this scope decision?
    Median used instead of mean, more robust to outliers
*/

-- 2020-2024 Only
SELECT
    '2020-2024 Only'                                        AS scope,
    COUNT(*)                                                AS total_deals,
    ROUND(AVG(InvestmentAmount_USD)/1000000, 2)             AS mean_millions,
    ROUND(SUM(InvestmentAmount_USD)/1000000000, 2)          AS total_billions,
    ROUND(MIN(median_val)/1000000, 4)                       AS median_millions
FROM (
    SELECT
        InvestmentAmount_USD,
        PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY InvestmentAmount_USD)
            OVER ()                                         AS median_val
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
    AND YEAR(Date) BETWEEN 2020 AND 2024
) AS t

UNION ALL

-- 2020-2025 Full Dataset
SELECT
    '2020-2025 Full Dataset'                                AS scope,
    COUNT(*)                                                AS total_deals,
    ROUND(AVG(InvestmentAmount_USD)/1000000, 2)             AS mean_millions,
    ROUND(SUM(InvestmentAmount_USD)/1000000000, 2)          AS total_billions,
    ROUND(MIN(median_val)/1000000, 4)                       AS median_millions
FROM (
    SELECT
        InvestmentAmount_USD,
        PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY InvestmentAmount_USD)
            OVER ()                                         AS median_val
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
) AS t;


/* Result : Median changes only 0.9% with 2025 included, conclusions are robust 
   2025 separation is correct for trend analysis but does not affect distribution findings.
*/

/*
    ROBUSTNESS CHECK
    Does inequality conclusion hold without top 5 mega deals?
    Is the high Gini coefficient due to a handful of outliers?
*/

WITH ranked AS (
    SELECT
        InvestmentAmount_USD,
        ROW_NUMBER() OVER 
            (ORDER BY InvestmentAmount_USD DESC)    AS size_rank,
        ROW_NUMBER() OVER 
            (ORDER BY InvestmentAmount_USD)         AS rn,
        COUNT(*) OVER ()                            AS n
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
    AND YEAR(Date) BETWEEN 2020 AND 2024
),
without_top5 AS (
    SELECT
        InvestmentAmount_USD,
        ROW_NUMBER() OVER 
            (ORDER BY InvestmentAmount_USD)         AS rn,
        COUNT(*) OVER ()                            AS n
    FROM ranked
    WHERE size_rank > 5
),
gini_calc AS (
    SELECT
        n,
        SUM(InvestmentAmount_USD)                   AS total,
        SUM((2.0 * rn - n - 1) 
            * InvestmentAmount_USD)                 AS weighted_sum
    FROM without_top5
    GROUP BY n
)
SELECT
    ROUND(weighted_sum / (n * total), 4)            AS gini_without_top5,
    0.8673                                          AS gini_with_all_deals,
    ROUND(0.8673 - weighted_sum / (n * total), 4)   AS difference
FROM gini_calc;

/* Result : Gini drops only 0.006 without top 5 deals, inequality is structural not outlier-driven */

-- Yearly trend 

SELECT DISTINCT
    yr,
    total_deals,
    total_funding_millions,
    avg_deal_millions,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY InvestmentAmount_USD)
    OVER (PARTITION BY yr) / 1000000, 4)                AS median_deal_millions
FROM (
    SELECT 
        YEAR(Date)                                      AS yr,
        COUNT(*) OVER (PARTITION BY YEAR(Date))         AS total_deals,
        ROUND(SUM(InvestmentAmount_USD) 
        OVER (PARTITION BY YEAR(Date))/1000000, 2)      AS total_funding_millions,
        ROUND(AVG(InvestmentAmount_USD) 
        OVER (PARTITION BY YEAR(Date))/1000000, 2)      AS avg_deal_millions,
        InvestmentAmount_USD
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
    AND YEAR(Date) BETWEEN 2020 AND 2024
) AS yearly
GROUP BY yr, total_deals, total_funding_millions, 
         avg_deal_millions, InvestmentAmount_USD
ORDER BY yr;

/* Result : 2021 boom, 2022-2023 slowdown, 2024 recovery, more deals but smaller cheques in the market slowdown  */

-- Gini Coefficients of each year

WITH ranked AS (
    SELECT
        YEAR(Date)                                                                 AS FundingYear, 
        InvestmentAmount_USD,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Date) ORDER BY InvestmentAmount_USD)  AS rn,
        COUNT(*) OVER (PARTITION BY YEAR(Date))                                    AS n,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY InvestmentAmount_USD) OVER (PARTITION BY YEAR(Date)) AS median_deal_value
    FROM investor_funding
    WHERE InvestmentAmount_USD IS NOT NULL
      AND YEAR(Date) BETWEEN 2020 AND 2024
),
gini_calc AS (
    SELECT
        FundingYear,
        n,
        MAX(median_deal_value)                             AS median_deal_value,
        SUM(InvestmentAmount_USD)                          AS total,
        SUM((2.0 * rn - n - 1) * InvestmentAmount_USD)    AS weighted_sum
    FROM ranked
    GROUP BY FundingYear, n
)
SELECT
    FundingYear,
    ROUND(median_deal_value, 2)                            AS median_deal_value,
    ROUND(weighted_sum / (n * total), 4)                   AS gini_coefficient
FROM gini_calc
ORDER BY FundingYear ASC;

/* Result : All years between 0.85-0.89, inequality is consistent across boom and slowdown alike */

-- Year-over-year funding growth

WITH yearly_funding AS (

    SELECT
        YEAR(Date) AS funding_year,

        ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)
        AS total_funding_million

    FROM investor_funding

    WHERE YEAR(Date) BETWEEN 2020 AND 2024

    GROUP BY YEAR(Date)
)

SELECT
    funding_year,

    total_funding_million,

    LAG(total_funding_million) OVER (
        ORDER BY funding_year
    ) AS previous_year_funding,

    ROUND(
        (
            total_funding_million
            - LAG(total_funding_million) OVER (
                ORDER BY funding_year
            )
        )
        * 100.0
        /
        LAG(total_funding_million) OVER (
            ORDER BY funding_year
        ),
    2) AS yoy_growth_percent

FROM yearly_funding

ORDER BY funding_year;

/* Result : 2021 peak growth, sharp drops in 2022-2023, positive recovery in 2024 */

-- Sector performance by funding

SELECT
    Industry,
    COUNT(*)                                    AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000, 2) AS total_funding_millions,
    ROUND(AVG(InvestmentAmount_USD)/1000000, 2) AS avg_deal_millions
FROM investor_funding
WHERE InvestmentAmount_USD IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024
GROUP BY Industry
ORDER BY total_funding_millions DESC;

/* Result : FoodTech recieved the highest total funding, supported by consistently large deal sizes relative to other sectors. */

-- Industry leaders by year

SELECT
    YEAR(Date)                                      AS funding_year,
    Industry,
    
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)  AS funding_million,

    DENSE_RANK() OVER(
        PARTITION BY YEAR(Date)
        ORDER BY SUM(InvestmentAmount_USD) DESC
    ) AS industry_rank

FROM investor_funding
WHERE Industry IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024
GROUP BY YEAR(Date), Industry;

/* Result : Sector rankings shift each year, no single industry dominated all five years */

-- City-wise startup ecosystem analysis

SELECT
    City,
    COUNT(*)                                        AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)   AS total_funding_million,
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)   AS avg_deal_million
FROM investor_funding
WHERE City IS NOT NULL
AND YEAR(Date) BETWEEN 2020 AND 2024
GROUP BY City
ORDER BY total_funding_million DESC;

/* Result : Pune leads total funding, Bengaluru strong on deals but not total capital */

/*
   City-sector heatmap (top sector per city only)
   To find which sectors dominate each city (Based on total funding)
*/

WITH city_sector AS (
    SELECT
        City,
        Industry,
        COUNT(*)                                            AS deals,
        ROUND(SUM(InvestmentAmount_USD)/1000000, 2)         AS funding_million,
        DENSE_RANK() OVER (
            PARTITION BY City
            ORDER BY SUM(InvestmentAmount_USD) DESC
        )                                                   AS sector_rank
    FROM investor_funding
    WHERE City IS NOT NULL
    AND Industry IS NOT NULL
    AND YEAR(Date) BETWEEN 2020 AND 2024
    GROUP BY City, Industry
)
SELECT
    City,
    Industry,
    deals,
    funding_million,
    sector_rank
FROM city_sector
WHERE sector_rank <= 1
ORDER BY City, sector_rank;

/* Result : Each city has a clear dominant sector */

-- Top investors by capital deployed

SELECT TOP 15
    Investors,
    COUNT(*)                                        AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)   AS total_funding_million,
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)   AS avg_deal_million
FROM investor_funding
WHERE Investors IS NOT NULL
GROUP BY Investors
ORDER BY total_funding_million DESC;

/* Result : A small group of investors appear repeatedly — mirrors the concentration seen in deal sizes */

-- Top funded startups

SELECT TOP 10
    Startup,
    
    COUNT(*)                                        AS total_rounds,
    
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)   AS total_funding_million,
    
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)   AS avg_round_million

FROM investor_funding
WHERE Startup IS NOT NULL
GROUP BY Startup
ORDER BY total_funding_million DESC;

/* Result : Top 10 startups raised significantly more than the rest */

-- Investment stage analysis

SELECT
    InvestmentType,
    
    COUNT(*)                                        AS total_deals,
    
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)   AS total_funding_million,
    
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)   AS avg_deal_million

FROM investor_funding
WHERE InvestmentType IS NOT NULL
GROUP BY InvestmentType
ORDER BY total_funding_million DESC;

/* Result : Later stage rounds dominate total funding, early stage high in count but low in capital */

/* 2025 Partial Year Analysis */

-- 2025 Mid-Year Funding Overview

WITH overview AS (

    SELECT
        InvestmentAmount_USD,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY InvestmentAmount_USD)
        OVER () AS median_deal

    FROM investor_funding

    WHERE YEAR(Date) = 2025
)

SELECT DISTINCT

    COUNT(*) OVER () AS total_deals,

    ROUND(SUM(InvestmentAmount_USD)
    OVER () / 1000000.0, 2)
    AS total_funding_million,

    ROUND(AVG(InvestmentAmount_USD)
    OVER () / 1000000.0, 2)
    AS avg_deal_million,

    ROUND(median_deal / 1000000.0, 2)
    AS median_deal_million

FROM overview;

/* Result : 84 deals in Jan-Jun 2025, median $1.65M, highest across all years suggesting quality over quantity */

/*
    Leading industries in 2025 Mid-Year Overview 
*/

SELECT
    Industry,
    COUNT(*)                                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)       AS funding_million,
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)       AS avg_deal_million,
    DENSE_RANK() OVER(
        ORDER BY SUM(InvestmentAmount_USD) DESC
    )                                                   AS industry_rank
FROM investor_funding
WHERE YEAR(Date) = 2025
AND Industry IS NOT NULL
GROUP BY Industry;

/* Result : Consumer Electronics leads 2025 funding, 
   notable shift from FoodTech which dominated 2020-2024 */

/*
    2025 Annualised Projection
    Project full year 2025 based on deals so far
    Projection assumes consistent deal pace throughout year
*/
WITH overview AS (
    SELECT
        InvestmentAmount_USD,
        Date,
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY InvestmentAmount_USD)
        OVER ()                                         AS median_deal
    FROM investor_funding
    WHERE YEAR(Date) = 2025
),
date_range AS (
    SELECT
        DATEDIFF(DAY, MIN(Date), MAX(Date)) + 1         AS days_covered
    FROM investor_funding
    WHERE YEAR(Date) = 2025
)
SELECT DISTINCT
    COUNT(*) OVER ()                                    AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)
        OVER () / 1000000.0, 2)                         AS total_funding_million,
    ROUND(AVG(InvestmentAmount_USD)
        OVER () / 1000000.0, 2)                         AS avg_deal_million,
    ROUND(median_deal / 1000000.0, 2)                   AS median_deal_million,
    d.days_covered                                      AS days_in_dataset,
    ROUND((SUM(InvestmentAmount_USD) OVER ()
        / d.days_covered) * 365 / 1000000.0, 2)         AS projected_full_year_million
FROM overview
CROSS JOIN date_range d;

/* Result : 2025 projected full year funding of $5.70bn,
   slightly below 2024's $5.98bn but well above the full year funding of 2023 */

/*
    2024 vs 2025 pace comparison
    Is 2025 tracking above or below 2024 at the same point?
    Compares 2024 deals in same date range as 2025 data
*/
WITH date_range_2025 AS (
    SELECT
        MIN(Date)   AS start_date,
        MAX(Date)   AS end_date
    FROM investor_funding
    WHERE YEAR(Date) = 2025
)
SELECT
    '2024 Same Period'                                  AS scope,
    COUNT(*)                                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)       AS total_funding_million,
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)       AS avg_deal_million
FROM investor_funding
CROSS JOIN date_range_2025
WHERE Date BETWEEN DATEADD(YEAR, -1, start_date)
              AND DATEADD(YEAR, -1, end_date)
AND InvestmentAmount_USD IS NOT NULL

UNION ALL

SELECT
    '2025 Actual'                                       AS scope,
    COUNT(*)                                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD)/1000000.0, 2)       AS total_funding_million,
    ROUND(AVG(InvestmentAmount_USD)/1000000.0, 2)       AS avg_deal_million
FROM investor_funding
CROSS JOIN date_range_2025
WHERE Date BETWEEN start_date AND end_date
AND InvestmentAmount_USD IS NOT NULL;

/* 2025 shows fewer deals than the same period in 2024, 
   but both mean and median deal sizes are the highest across all years in the dataset */




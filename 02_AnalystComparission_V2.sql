/*
This query is supposed to be used as a complement to the first query. Once an analyst is identified,
this query can be used to visualize past performance of the analyst. With some modifications, it can
also be used to compare a few different analysts.

This is also one of the queries that could benefit being sandwiched between Python layers. Alongside 
the presentation layer that follows SQL, an additional Python layer that precedes SQL needs to be used 
to change which analysts are being compared.
*/

WITH Cleaned AS ( 
	SELECT 

		date AS Date,
		ticker AS Ticker,
		company_name AS Company_Name,
		SAFE_CAST(broker_number AS INT) AS Broker,
		SAFE_CAST(analyst_id AS INT) AS Analyst_Id,
		analyst_name AS Analyst,
		price_target_before AS PT_Before,
		price_target_after AS PT_After,
		close_price AS Close,
		rating_before_simplified AS Rating_Before,
		rating_after_simplified AS Rating_After
		
		
	FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.NASDAQ100`
),
Pivoted AS (
  SELECT *
  FROM (
    SELECT Date, Ticker, Analyst, PT_After, Rating_After
    FROM Cleaned
    WHERE Ticker = 'AAPL'
  )
  PIVOT(
    MAX(PT_After)
    FOR Analyst IN (
      -- 'WILLIAM POWER',
      'RICHARD GARDNER'
    )
  )
)
SELECT
  a.Date,
  -- COALESCE(LAST_VALUE(a.`WILLIAM POWER` IGNORE NULLS) OVER (PARTITION BY a.Ticker ORDER BY a.Date), 0) AS `WILLIAM POWER`,
  COALESCE(LAST_VALUE(a.`RICHARD GARDNER` IGNORE NULLS) OVER (PARTITION BY a.Ticker ORDER BY a.Date), 0) AS `RICHARD GARDNER`,
  a.Rating_After,
  b.Close_AAPL
FROM Pivoted AS a
JOIN `aly6080-2026-496616.extraData.DailyOpenClose` AS b ON a.Date = b.Date

ORDER BY Date;
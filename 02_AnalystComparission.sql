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
    Date,
    Company_Name AS Ticker,
    Ticker AS Company_Name,
    Broker,
    Analyst,
    Rating_Before,
    Rating_After,
    SAFE_CAST(Price_Target_Before AS FLOAT64) AS PT_Before,
    SAFE_CAST(Price_Target_After AS FLOAT64) AS PT_After
  FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.nasadaq100table`
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
      'WILLIAM POWER',
      'ANANDA BARUAH'
    )
  )
)
SELECT
  a.Date,
  COALESCE(LAST_VALUE(a.`WILLIAM POWER` IGNORE NULLS) OVER (PARTITION BY a.Ticker ORDER BY a.Date), 0) AS `WILLIAM POWER`,
  COALESCE(LAST_VALUE(a.`ANANDA BARUAH` IGNORE NULLS) OVER (PARTITION BY a.Ticker ORDER BY a.Date), 0) AS `ANANDA BARUAH`,
  a.Rating_After,
  b.Close_AAPL
FROM Pivoted AS a
JOIN `aly6080-2026-496616.extraData.DailyOpenClose` AS b ON a.Date = b.Date
ORDER BY Date;
/*
ARCHIVED QUERY

This query is the prelimnary test towards the third use case you provided me. It returns the 
average delay between when a price target was set and when it hit, as well as the standard 
deviation in this delay.
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
HitDates as (
  SELECT 
    MIN(b.Date) as DateMet,
    a.Analyst,
    a.Date,
    a.Ticker
  FROM Cleaned AS a

  JOIN `aly6080-2026-496616.extraData.aapl_high` AS b ON b.Date > a.Date

  WHERE high > a.PT_After AND a.Ticker = "AAPL"

  GROUP BY Analyst, Date, Ticker

  HAVING COUNT(*) > 75

)

SELECT
  Analyst,
  AVG(DATE_DIFF(DateMet, Date, day)) as avg_delay,
  STDDEV(DATE_DIFF(DateMet, Date, day)) as std_delay

FROM HitDates

WHERE Ticker = "AAPL"

GROUP BY Analyst

ORDER BY avg_delay;

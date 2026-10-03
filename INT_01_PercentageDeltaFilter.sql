/*
INTERMEDIARY QUERY

This query is the foundation to the percentage delta part (dmax and davg) part of the main query.
*/

WITH Cleaned AS
(
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
)


SELECT a.Analyst, MAX((ABS(a.PT_After - b.Close_AAPL)) * 0.001) AS dmax, AVG((Abs(a.PT_After - b.Close_AAPL)) * 0.001) AS davg FROM Cleaned a 

JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b on a.Date = b.Date

WHERE a.Ticker = "AAPL"

GROUP BY a.ANALYST

ORDER BY davg 

LIMIT 10;


-- SELECT a.Date, a.PT_After, (a.PT_After - b.Close_AAPL) * 1 as delta, b.Close_AAPL FROM Cleaned a

-- JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b on a.Date = b.Date

-- WHERE a.Ticker = "AAPL" AND Analyst = "DANIEL IVES"

-- ORDER BY Date;




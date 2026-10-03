/*
INTERMEDIARY QUERY

This query is the foundation for the Analyst information part of the final query.
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
)

SELECT
  a.Analyst,
  COUNT(DISTINCT a.TICKER) AS SectorBreadth,   
  COUNT(a.Date) AS total_recs,
  MIN(a.Date) AS first_rec,
  MAX(a.Date) AS last_rec,
  DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY) AS active_days,
  ROUND(COUNT(a.Date) / NULLIF(DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY), 0) * 90, 2) AS Quartarly_recs,

FROM Cleaned a

JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b on a.Date = b.Date

WHERE a.Ticker = "AAPL"
GROUP BY Analyst

ORDER BY total_recs Desc, Quartarly_recs, SectorBreadth

;
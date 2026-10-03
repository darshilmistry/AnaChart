/*
README

This is the closest I could get to getting a list of analysts that published fairly accurate Price Targets.
To get this I defined a "good analyst" as:

  - Focusing on a small number of stocks, so as to not be stretched thin across a large number of stocks
  - Preceding price movement not just reacting to stock movement
  - Publishing Price targets fairly often.

In the results the table can be divided into groups of features that represent each of these.

  - Analyst information
    - Analyst: Name
    - SectorBreadth: How many stocks they monitor
    - total_recs: Total number of recommendations they published in total
    - first_rec: Date when they first published
    - last_rec: Date when they last published
    - active_days: Number of days they were active
    - Quarterly_recs: Number of recommendations they publish per quarter on average
  
  - Price target delta: Difference between price target and actual closing prices
    - dmax: Maximum delta over all times 
    - davg: Average delta over all times
  
  - Action timing: Delay between when a price target is published and when its hit
    - avg_delay: Average delay over all times
    - std_delay: Standard deviation of the delay over all times
        Note: for most analysts this is approximately equal to avg_delay, 
        suggesting high variance — interpret with caution.
  
This is a strong foundation, and there are clear next steps I would want to pursue with expanded access. The result 
that this query returns is also not to be used as the final customer-facing data to back a dashboard. I recommend 
it be passed through another customer-facing Python layer with some further filtering. However, I could not 
demonstrate that efficiently with the current permissions.

With experimentation, I found out that ordering the list with davg, total_recs DESC, Quarterly_recs, SectorBreadth 
in this exact order produced the best results.

This file alone can be said to be a deliverable all by itself with all other files being a stepping stone, moving 
towards this one.
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
HitDates AS (
  SELECT 
    MIN(b.Date) AS DateMet,
    a.Analyst,
    a.Date,
    a.Ticker
  FROM Cleaned AS a
  JOIN `aly6080-2026-496616.extraData.aapl_high` AS b ON b.Date > a.Date
  WHERE high > a.PT_After AND a.Ticker = "AAPL"
  GROUP BY Analyst, Date, Ticker
),
TimingStats AS (
  SELECT
    Analyst,
    AVG(DATE_DIFF(DateMet, Date, DAY)) AS avg_delay,
    STDDEV(DATE_DIFF(DateMet, Date, DAY)) AS std_delay
  FROM HitDates
  GROUP BY Analyst
)
SELECT
  a.Analyst,
  COUNT(DISTINCT a.TICKER) AS SectorBreadth,
  COUNT(a.Date) AS total_recs,
  MIN(a.Date) AS first_rec,
  MAX(a.Date) AS last_rec,
  DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY) AS active_days,
  ROUND(COUNT(a.Date) / NULLIF(DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY), 0) * 90, 2) AS Quartarly_recs,
  MAX((ABS(a.PT_After - b.Close_AAPL)) * 1) AS dmax, 
  AVG((ABS(a.PT_After - b.Close_AAPL)) * 0.01) AS davg,
  t.avg_delay,
  t.std_delay
FROM Cleaned a
JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b ON a.Date = b.Date
LEFT JOIN TimingStats t ON a.Analyst = t.Analyst
WHERE a.Ticker = "AAPL"
GROUP BY a.Analyst, t.avg_delay, t.std_delay
ORDER BY davg, total_recs DESC, Quartarly_recs, SectorBreadth

LIMIT 100;
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
		rating_after_simplified AS Rating_After,
    price_target_after - 0.05 * price_target_after AS PT_Lag
		
		
	FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.NASDAQ100`
),
HitDates AS (
  SELECT 
    MIN(b.Date) AS DateMet,
    a.Analyst,
    a.Date,
    a.Ticker
  FROM Cleaned AS a
  JOIN `aly6080-2026-496616.extraData.aapl_high` AS b ON b.Date >= a.Date
  WHERE high >= PT_Lag AND a.Ticker = "AAPL"
  GROUP BY Analyst, Date, Ticker
),
TimingStats AS (
  SELECT
    Analyst,
    AVG(DATE_DIFF(DateMet, Date, DAY)) AS avg_delay,
    STDDEV(DATE_DIFF(DateMet, Date, DAY)) AS std_delay
  FROM HitDates
  GROUP BY Analyst
),
Selection AS (

  SELECT
    a.Analyst,
    COUNT(DISTINCT a.TICKER) AS SectorBreadth,
    COUNT(a.Date) AS total_recs,
    MIN(a.Date) AS first_rec,
    MAX(a.Date) AS last_rec,
    DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY) + 1 AS active_days,
    ROUND(COUNT(a.Date) / NULLIF(DATE_DIFF(MAX(a.Date), MIN(a.Date), DAY), 0) * 90, 2) AS Quartarly_recs,
    MAX((ABS(a.PT_After - b.Close_AAPL)) * 0.01) AS dmax, 
    AVG((ABS(a.PT_After - b.Close_AAPL)) * 0.01) AS davg,
    t.avg_delay,
    t.std_delay
  FROM Cleaned a
  JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b ON a.Date = b.Date
  LEFT JOIN TimingStats t ON a.Analyst = t.Analyst
  WHERE a.Ticker = "AAPL"
  GROUP BY Analyst, t.avg_delay, t.std_delay
)

SELECT * FROM Selection
WHERE dmax IS NOT NULL
ORDER BY davg, total_recs DESC, Quartarly_recs, SectorBreadth

LIMIT 100;


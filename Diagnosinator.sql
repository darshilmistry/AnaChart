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
    price_target_after - 0.1 * price_target_after AS PT_Lag
		
		
	FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.NASDAQ100`
)


SELECT

  Analyst,
  MAX((ABS(a.PT_After - b.Close_AAPL)) * 1) AS dmax, 
  AVG((ABS(a.PT_After - b.Close_AAPL)) * 0.01) AS davg,

FROM Cleaned a
JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b ON a.Date = b.Date
WHERE a.Ticker = "AAPL"
GROUP BY a.Analyst

LIMIT 10;
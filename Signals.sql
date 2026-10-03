/*

The Signals

  - Monitoring Width: How many stocks is someone looking at
  - Adjusted Activity: Check consistency with exponential gain over longer steaks
  - Undershoot Delta Ratio: Closing prices scoot within 10% of PT before reversing
    - Undershoot Delta Ratio 5% -- REMOVED FOR LATTER TESTING
    - Undershoot Delta Ratio 10%
    - Undershoot Delta Ratio 15% -- REMOVED FOR LATTER TESTING
  - PT Hit Delay
  - Undershoot Hit Delay
    - Undershoot Delay 5% -- REMOVED FOR LATTER TESTING
    - Undershoot Delay 10%
    - Undershoot Delay 15% -- REMOVED FOR LATTER TESTING
  - Rating Match: Rating Matches Directionality or not
    - Rating Match 90 days
    - Rating Match 180 days
    - Rating Match Before next Recommendation

  +----------------+
  | - PT Hit Raito |
  +----------------+

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
		rating_after_simplified AS Rating_After,
    price_target_after - 0.1 * price_target_after AS PT_Lag
		
		
	FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.NASDAQ100`

)

-- Monitoring Width
-- SELECT
--   Analyst,
--   COUNT(DISTINCT Ticker)
-- FROM Cleaned
-- GROUP BY Analyst;

-- Adjusted Activity
-- SELECT 
--   Analyst,
--   Ticker,
--   COUNT(DISTINCT Date)
-- FROM Cleaned
-- GROUP BY Analyst, Ticker

-- Undershoot Ratio
-- , close_near_pt AS (
--   SELECT
--     a.Analyst,
--     a.Ticker,
--     a.Date,
--     b.Close_AAPL,
--     a.PT_After,
--     LEAD(b.Close_AAPL) OVER (PARTITION BY a.Analyst, a.Ticker ORDER BY a.Date) as next_close,
--     MAX(b.Close_AAPL) OVER (
--       PARTITION BY a.Analyst, a.Ticker 
--       ORDER BY a.Date 
--       ROWS BETWEEN CURRENT ROW AND 7 FOLLOWING
--     ) as max_close_next_week
--   FROM Cleaned a
--   JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b ON a.Date = b.Date
--   WHERE b.Close_AAPL >= a.PT_After * 0.90 AND b.Close_AAPL < a.PT_After
-- )

-- SELECT *
-- FROM close_near_pt
-- WHERE (PT_After > Close_AAPL AND next_close < Close_AAPL)
--   AND max_close_next_week < PT_After

-- SELECT 
--   a.Date,
--   a.Analyst,
--   a.Ticker,
--   a.PT_After,
--   b.Close_AAPL
-- FROM Cleaned a
-- JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b 
--   ON b.Date > a.Date
--   AND b.Date <= DATE_ADD(a.Date, INTERVAL 120 DAY)
-- WHERE a.Ticker = 'AAPL'
--   AND b.Close_AAPL >= a.PT_After * 0.95
--   AND b.Close_AAPL <= a.PT_After * 1.05
-- LIMIT 10;

SELECT 
  a.Date,
  a.Analyst,
  a.Ticker,
  a.PT_After,
  MAX(b.Close_AAPL) as max_close_in_range,
  CASE WHEN MAX(b.Close_AAPL) >= a.PT_After * 0.98 
       AND MAX(b.Close_AAPL) <= a.PT_After * 1.02 
  THEN 1 ELSE 0 END as pt_hit
FROM Cleaned a
LEFT JOIN `aly6080-2026-496616.extraData.DailyOpenClose` b 
  ON b.Date > a.Date
  AND b.Date <= DATE_ADD(a.Date, INTERVAL 120 DAY)
WHERE a.Ticker = 'AAPL'
GROUP BY a.Date, a.Analyst, a.Ticker, a.PT_After;
















SELECT 

  date AS Date,
  ticker AS Ticker,
  company_name AS Compnay_Name,
  SAFE_CAST(broker_number AS INT) AS Broker,
  SAFE_CAST(analyst_id AS INT) AS Analyst_Id,
  analyst_name AS Analyst_Name,
  price_target_before AS PT_Before,
  price_target_after AS PT_After,
  close_price AS Close,
  rating_before_simplified AS Rating_Before,
  rating_after_simplified AS Rating_After


FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.NASDAQ100` LIMIT 10;
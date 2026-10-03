/*
ARCHIVED QUERY

This is one of the early queries I wrote that compares pricetargets with actual close prices.
*/


-- SELECT 
--   Date, 
--   Rating_After, 
--   Price_Target_After 

-- FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.nasadaq100table` 

-- WHERE Company_Name = "AAPL" 

-- ORDER BY Date DESC LIMIT 100;

with recomendations as (

  SELECT 
    Date,
    pt_Type,
    Price_Target

  FROM (
    SELECT 
      Company_Name,
      Analyst, 
      DATE, 
      SAFE_CAST(Price_Target_Before AS INT) AS Price_Target_Before, 
      SAFE_CAST(Price_Target_After AS INT) AS Price_Target_After
    
    FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.nasadaq100table` 
  ) AS t

  UNPIVOT(

    Price_Target FOR pt_Type IN(Price_Target_Before, Price_Target_After)

  )

  WHERE Company_Name = "AMZN" AND Analyst = "BRIAN NOWAK"

  ORDER BY Date

)

SELECT a.*, b.Close FROM recomendations as a JOIN `aly6080-2026-496616.extraData.DailyCloseAMZN0526` as b ON a.Date = b.Date ORDER BY Date;



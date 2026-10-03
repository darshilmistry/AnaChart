/*
This is another query that can go alongside the main query. On its own, the results from
it make little sense. However, with some additional Python code, closing price movements
can be highlighted and shaded, after which, rating adjusted price targets as well as price 
targets can be used to check how accurate ratings are.
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
    SAFE_CAST(Price_Target_After AS FLOAT64) AS PT_After,

    CASE 
      WHEN TRIM(UPPER(REGEXP_REPLACE(Rating_After, r'[^a-zA-Z ]', ''))) IN (
        'BUY', 'STRONG BUY', 'STRONGBUY', 'OVERWEIGHT', 'OUTPERFORM', 
        'POSITIVE', 'TOP PICK', 'TOPPICK', 'CONVICTION BUY', 'ACCUMULATE',
        'MARKET OUTPERFORM', 'MKT OUTPERFORM', 'SECTOR OUTPERFORM',
        'OUTPERFORMER', 'SHORT'
      ) THEN 'Buy'
      
      WHEN TRIM(UPPER(REGEXP_REPLACE(Rating_After, r'[^a-zA-Z ]', ''))) IN (
        'HOLD', 'NEUTRAL', 'EQUAL WEIGHT', 'EQUALWEIGHT', 'MARKET PERFORM',
        'MARKETPERFORM', 'SECTOR PERFORM', 'SECTORPERFORM', 'PEER PERFORM',
        'PEERPERFORM', 'IN LINE', 'INLINE', 'PERFORM', 'SECTOR WEIGHT',
        'MKT PERFORM', 'MARKET PERF', 'SECTOR PERF', 'IN LINE',
        'FAIR VALUE', 'MIXED', 'BELOW AVERAGE', 'BELOWAVERAGE'
      ) THEN 'Hold'
      
      WHEN TRIM(UPPER(REGEXP_REPLACE(Rating_After, r'[^a-zA-Z ]', ''))) IN (
        'SELL', 'UNDERPERFORM', 'UNDERWEIGHT', 'NEGATIVE', 'REDUCE',
        'AVOID', 'UNDERPERFORMER', 'MKT UNDERPERFORM', 'UNDER PERFORM'
      ) THEN 'Sell'
      
      ELSE 'Unknown'
    END AS Rating_Clean
   
  FROM `aly6080-2026-496616.nasdaq100_stock_analysts_price_targets_and_ratings.nasadaq100table`
)



SELECT 

  Date,
  Ticker,
  Analyst,
  PT_After,
  Rating_Clean,

  CASE
    WHEN Rating_Clean = "Buy" THEN PT_After + 10
    WHEN Rating_Clean = "Hold" THEN PT_After
    WHEN Rating_Clean = "Sell" Then PT_After - 10
    ELSE PT_After 
  END AS RATING_ADJ_PT

FROM Cleaned

WHERE Ticker = "TSLA" AND Analyst = "ADAM JONAS"

ORDER BY Date

LIMIT 100;
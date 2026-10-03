/*
INTERMEDIARY QUERY

This is one of the most important stepping stones in this project. It should be used before
each query as a CTE to query a cleaned version of the raw data. With some further exploration,
I might need to update this but at its current state, it addresses most of the problems.
*/

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
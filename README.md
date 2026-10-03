<a href="https://github.com/darshilmistry">< Go to profile</a>

# AnaChart: Evaluating Equity Analyst Price Target Accuracy

This repository contains the SQL work produced for an integrated experiential learning course (ALY6080, Northeastern University) over a twelve-week term. The project examines historical price targets and ratings issued by sell-side analysts covering NASDAQ-100 constituents, with the objective of identifying analysts whose forecasts demonstrate meaningful predictive value.

The project was undertaken without prior domain expertise in equity research. Accordingly, the repository documents both the analytical approach and the development of domain understanding over the course of the term. A retrospective assessment of methodological limitations and a proposed redesign are included in the final sections.

> **Note on reproducibility:** Access to the underlying datasets was revoked upon completion of the course. The queries are preserved as a record of methodology and will not execute without the original BigQuery tables.

---

## Research Question

Analysts publish price targets and buy/hold/sell ratings at high frequency, and the informational value of these forecasts varies considerably across individuals. This project asks whether an analyst's historical track record can be used to distinguish reliable forecasters from unreliable ones.

## Operational Definition of Analyst Quality

Prior to constructing the primary query, analyst quality was operationalized along three dimensions:

1. **Coverage focus:** the analyst monitors a limited number of securities, reducing the likelihood that attention is distributed too thinly.
2. **Forecast lead:** price targets are reached *subsequent* to publication, indicating anticipation of price movement rather than reaction to it.
3. **Publication consistency:** the analyst issues recommendations at a regular cadence over an extended period.

These dimensions correspond to the column groups in the final output:

| Dimension | Columns | Description |
|---|---|---|
| Coverage and activity | `SectorBreadth`, `total_recs`, `first_rec`, `last_rec`, `active_days`, `Quarterly_recs` | Breadth of coverage and publication frequency |
| Price target deviation | `dmax`, `davg` | Deviation between the published target and the closing price |
| Forecast timing | `avg_delay`, `std_delay` | Elapsed days between publication and the target being reached |

The analysis was scoped to a single security (AAPL) to remain tractable within the course timeline.

## Technical Environment

Google BigQuery (Standard SQL). Techniques employed include common table expressions, window functions (`LAST_VALUE ... IGNORE NULLS`, `LEAD`), `PIVOT` and `UNPIVOT` operations, `SAFE_CAST` type coercion, and regular-expression-based text normalization.

## Repository Structure

**Primary deliverable**
- `01_FinalList.sql`: analyst ranking query integrating activity, deviation, and timing metrics.
- `Full_List_V2.sql`: revised implementation against the cleaned source table, incorporating a 5% tolerance band for target attainment.

**Supplementary queries**
- `02_AnalystComparission.sql` and `_V2`: pivot one or more analysts' price targets against observed closing prices for visualization.
- `03_Ratings.sql`: consolidates over fifty raw rating labels into a standardized Buy / Hold / Sell taxonomy and derives a rating-adjusted target.

**Intermediary components** (`INT_` prefix)
- `INT_01_Cleaning.sql`: base cleaning logic, intended for reuse as a CTE across queries.
- `INT_01_PercentageDeltaFilter.sql`: foundation for the `dmax` and `davg` metrics.
- `INT_03_SectorBreadth.sql`: foundation for the coverage and activity metrics.

**Exploratory work**
- `Signals.sql`: development of additional signals, including target attainment rate within a 120-day window, near-miss ("undershoot") detection, and rating directionality.
- `Diagnosinator.sql`, `Cleaning_V2.sql`: diagnostic and schema validation queries.

**Archived prototypes** (`Z_ARCH_` prefix)
- Early iterations, including the initial target-versus-close comparison and the first forecast delay test.

---

## Limitations

A review of the queries after the course identified the following issues:

- **`davg` compares targets to the same-day closing price.** Price targets are generally longer-horizon forecasts, so this comparison may not reflect forecast accuracy, and it is used as the primary ranking key.
- **`SectorBreadth` is computed after the AAPL filter**, so it always equals 1. To function as intended, it would need to be calculated across all securities before filtering.
- **Target attainment logic handles upside targets only.** Targets set below the prevailing price are counted as reached almost immediately, and targets that are never reached are excluded from the timing statistics.
- **Price data is stored in wide format** (one column per security), which limits the queries to a single hardcoded ticker.

## Future Work

Should the project be continued and data access restored, the next steps would be to consolidate the cleaning logic into a single reusable stage, convert price data to long format to support multiple securities, and evaluate each recommendation individually (direction, attainment within a fixed horizon, and time to attainment) before aggregating to an analyst-level scorecard.

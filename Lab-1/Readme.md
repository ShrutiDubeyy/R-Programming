# Lab 1: Air-Quality Data Cleaning Using R

## Overview
This practical demonstrates data cleaning of a real-world air-quality dataset
using R — covering loops, user-defined functions, error handling, and
advanced missing-data management (`NA`, `NULL`, `NaN`).

**Topic:** Loops, Functions, Error Handling, and Advanced Missing Data Handling
**Subtopic:** Management of NA, NULL, and NaN Values

## Dataset
- **Source:** [Beijing Multi-Site Air Quality Dataset – UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/501/beijing+multi+site+air+quality+data)
- **Station file used:** `PRSA_Data_Aotizhongxin_20130301-20170228.csv`
- Hourly air-quality and weather observations including PM2.5, PM10, SO2,
  NO2, CO, O3, TEMP, PRES, DEWP, RAIN, wd (wind direction), and WSPM.

## Files in this folder
| File | Description |
|---|---|
| `air_quality_cleaning.R` | Complete R script covering Tasks 1–10 |
| `PRSA_Data_Aotizhongxin_20130301-20170228.csv` | Raw input dataset |
| `cleaned_air_quality_data.csv` | Cleaned dataset exported by the script (Task 10) |
| `missing_values_before_after.png` | Bar chart comparing missing values before/after cleaning (Task 9) |
| `interpretation.md` | ~100–150 word interpretation of the cleaning results |

## What the script does
1. **Import & Inspect** — loads the CSV with `tryCatch()` error handling, shows structure, dimensions, and missing-value counts.
2. **NA vs NULL vs NaN** — demonstrates the difference using `is.na()`, `is.null()`, `is.nan()`.
3. **Missing-Value Summary** — a reusable `missing_summary()` function producing a summary table, with a warning when a variable exceeds 20% missing values.
4. **Invalid Numerical Results** — creates `pollution_ratio` (PM2.5/PM10) and checks/replaces NA, NaN, and infinite values.
5. **Loop-Based Numeric Imputation** — a single generic `for` loop imputes missing values in PM2.5, PM10, SO2, NO2, TEMP, and WSPM using the median.
6. **Categorical Imputation** — a `calculate_mode()` function fills missing `wd` (wind direction) values with the most frequent category.
7. **Reusable Error-Handling Function** — `clean_variable()` safely handles non-existent columns, categorical columns, and all-missing columns via `tryCatch()`.
8. **Before/After Comparison** — builds a table of missing values before and after cleaning for all selected variables.
9. **Visualization** — generates a bar chart of missing values before vs. after cleaning.
10. **Export** — saves the cleaned dataset as `cleaned_air_quality_data.csv`.

## How to run
1. Make sure R (≥ 4.0) is installed.
2. Open this folder in RStudio or VS Code (with the R extension).
3. Ensure the CSV file is in the same folder as the script (already the case here).
4. Run:
   ```r
   install.packages("skimr")   # if not already installed
   source("air_quality_cleaning.R")
   ```
5. Outputs (`cleaned_air_quality_data.csv` and `missing_values_before_after.png`) will be generated in this folder.

## Learning Outcomes
- Differentiate between `NA`, `NULL`, and `NaN` in R.
- Identify and summarize missing values.
- Develop reusable functions for data cleaning.
- Apply loops to process multiple variables without repetitive code.
- Handle numerical and categorical missing values.
- Implement error handling using `tryCatch()`.
- Generate and export a cleaned real-world dataset.

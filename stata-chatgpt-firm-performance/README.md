# The Impact of Introducing ChatGPT on Firm Fundamentals (Stata)

**University of Münster – Empirical Lab II (WS 2024/25)**  
This repository contains my Stata implementation of the case study assignment: *“The Impact of Introducing ChatGPT.”*

## Context
The assignment required an empirical analysis of how the introduction of ChatGPT (from **2023q1** onward) affected firm fundamentals using US Compustat data (**2018–2024**).  
Tasks included:
1) Short review of existing research on AI & firm performance  
2) Empirical analysis of four outcomes: cost efficiency, investments, revenue growth, profitability  
3) Identify industry heterogeneity (Resource, Production, Technology)

## Methods
- Panel fixed-effects models: `xtreg … , fe vce(cluster gvkey)`  
- Diagnostics: OV test, VIF, Breusch–Pagan, White test  
- Outlier handling (5–95th percentile of sales)  
- Industry-level splits via loops

## Structure
```
code/01_cleaning.do       # data preparation, feature engineering
code/02_models.do         # regressions, clustered SEs, industry loops, exports
code/99_repro.do          # runs the full pipeline
data/                     # no raw data; see data/README.md
results/tables & figures  # outputs
docs/assignment.md        # case study context (optional)
```
## How to run
1. Open Stata (17+).  
2. `cd` to the repository root.  
3. Run: `do code/99_repro.do`  
   - Outputs will be written to `results/tables` and `results/figures`.

## Tools
Stata 17 · Panel econometrics (`xtset`, `xtreg`) · `esttab/outreg2` (optional)

## Data & License
The raw data cannot be redistributed due to licensing (Compustat). This repo ships only code and structure.  
License: MIT.
// 01_cleaning.do — data preparation and feature engineering
version 17
clear all
set more off

// Project roots (assumes called from repo root)
global ROOT : pwd
global DATA "$ROOT/data"
global OUT  "$ROOT/results"

// Load data (replace filename if needed)
use "$DATA/case_study_data.dta", clear

// Dates & panel id
format datadate %td
gen quarter_date = qofd(datadate)
format quarter_date %tq
xtset gvkey quarter_date

// ChatGPT cutoff
gen post_chatgpt = (quarter_date >= tq(2023q1))

// Industries (coarse)
gen naics_major = real(substr(naics,1,1))
gen industry = .
replace industry = 1 if inlist(naics_major,1,2,4)
replace industry = 2 if inlist(naics_major,5,6,7)
replace industry = 3 if inlist(naics_major,3,8,9)
label define industry 1 "Resource" 2 "Production" 3 "Technology"
label values industry industry

// Drops
drop if naics=="525910"
drop if missing(naics) | missing(industry)

// Keep consistent industry per firm
bys gvkey (industry): gen _incon = (industry!=industry[_n-1])
drop if _incon
drop _incon

// Outlier trimming for sales (5–95 pct)
xtile pct_saleq = saleq, nq(100)
drop if inrange(pct_saleq,1,5) | inrange(pct_saleq,95,100)
drop pct_saleq

// Outcomes
gen cost_efficiency     = cogsq/revtq
gen log_cost_efficiency = log(cost_efficiency) if cost_efficiency>0
gen investments_capex   = capxy/atq
gen profitability_rev   = niq/revtq
gen revenue_growth      = (revtq - L.revtq)/L.revtq

// Controls
gen current_to_total_assets = actq/atq
gen debt_to_assets          = ltq/atq
gen roa                     = niq/atq
gen inventory_turnover      = cogsq/invtq
gen log_inventory_turnover  = log(inventory_turnover)
gen asinh_roa               = asinh(roa)
gen log_debt_to_assets      = log(debt_to_assets + 1)
gen log_firm_size           = log(atq)
gen rnd_to_sales            = xrdq/saleq

save "$OUT/panel_clean.dta", replace
display "Saved cleaned panel to results/panel_clean.dta"
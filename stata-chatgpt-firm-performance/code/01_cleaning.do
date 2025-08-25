// 01_cleaning.do — data preparation and feature engineering
version 18.5
clear all
set more off

// ---- project paths (assumes called from repo root) ----
global ROOT : pwd
global DATA "$ROOT/data"
global OUT  "$ROOT/results"

// ---- load & basic date handling ----
use "$DATA/case_study_data.dta", clear

// ensure Stata date & quarter
format datadate %td
gen quarter_date = qofd(datadate)
format quarter_date %tq

// cutoff for ChatGPT introduction
gen byte post_chatgpt = quarter_date >= tq(2023q1)

// ---- industries (coarse buckets) ----
// safer: real(substr()) avoids destring twice
gen byte naics_major  = real(substr(naics,1,1))
gen byte naics_major2 = real(substr(naics,1,2))

gen byte industry = .
replace industry = 1 if inlist(naics_major,1,2,4)    // Resource
replace industry = 2 if inlist(naics_major,5,6,7)    // Production/Trade
replace industry = 3 if inlist(naics_major,3,8,9)    // Technology

label define industry_lbl 1 "Resource" 2 "Production" 3 "Technology", replace
label values industry industry_lbl

// ---- panel id ----
xtset gvkey quarter_date, quarterly

// ====================== CLEANING ======================

// drop ETFs and obs w/ missing NAICS or industry
drop if naics == "525910"
drop if missing(naics) | missing(industry)

// keep firms with at least one 2023q1 report (as in your brief)
gen byte reported_2023q1 = (fyearq==2023 & fqtr==1)
bys gvkey: egen byte has_2023q1 = max(reported_2023q1)
drop if has_2023q1==0

// ensure consistent industry per firm: use modal industry instead of deleting
bys gvkey: egen mode_ind = mode(industry), maxmode
replace industry = mode_ind if !missing(mode_ind)
drop mode_ind

// drop obs with missing industry after harmonization
drop if missing(industry)

// remove extreme sales outliers (5–95 pct) — or winsorize if you prefer
quietly xtile pct_saleq = saleq, nq(100)
drop if pct_saleq <= 5 | pct_saleq >= 95
drop pct_saleq

// ====================== FEATURES ======================

// helper: safe division (returns . if denom<=0 or missing)
program define _safediv, rclass
    // usage: gen X = r(safe), after you set locals num den
end

// 1) cost efficiency = COGS / revenue
gen double cost_efficiency = (revtq>0 & !missing(revtq) ? cogsq/revtq : .)
gen double log_cost_efficiency = (cost_efficiency>0 ? log(cost_efficiency) : .)
label var cost_efficiency     "COGS / Revenue"
label var log_cost_efficiency "log(COGS/Revenue)"

// 2) investments = CAPEX / total assets
gen double investments_capex = (atq>0 & !missing(atq) ? capxy/atq : .)
label var investments_capex "CAPEX / Assets"

// 3) revenue growth (q/q)
gen double revenue_growth = (L.revtq>0 & !missing(L.revtq) ? (revtq-L.revtq)/L.revtq : .)
label var revenue_growth "Revenue growth (q/q)"

// 4) profitability = NI / revenue
gen double profitability_revenue = (revtq!=0 & !missing(revtq) ? niq/revtq : .)
label var profitability_revenue "Net income / Revenue"

// controls
gen double current_to_total_assets = (atq>0 ? actq/atq : .)
gen double debt_to_assets          = (atq>0 ? ltq/atq  : .)
gen double roa                     = (atq!=0 & !missing(atq) ? niq/atq : .)
gen double inventory_turnover      = (invtq>0 ? cogsq/invtq : .)
gen double log_inventory_turnover  = (inventory_turnover>0 ? log(inventory_turnover) : .)
gen double asinh_roa               = asinh(roa)
gen double log_debt_to_assets      = (debt_to_assets>=0 ? log(debt_to_assets+1) : .)
gen double log_firm_size           = (atq>0 ? log(atq) : .)
gen double rnd_to_sales            = (saleq>0 ? xrdq/saleq : .)
gen double log_rnd                 = (xrdq>=0 ? log(xrdq+1) : .)

label var current_to_total_assets "Current assets / Total assets"
label var debt_to_assets          "Debt / Assets"
label var roa                     "Return on Assets"
label var inventory_turnover      "Inventory turnover"
label var log_inventory_turnover  "log(Inventory turnover)"
label var asinh_roa               "asinh(ROA)"
label var log_debt_to_assets      "log(Debt/Assets + 1)"
label var log_firm_size           "log(Total assets)"
label var rnd_to_sales            "R&D / Sales"
label var log_rnd                 "log(1+R&D)"

// quick sanity checks
summarize cost_efficiency investments_capex revenue_growth profitability_revenue
summarize current_to_total_assets log_inventory_turnover asinh_roa log_debt_to_assets

// drop temporary vars & tidy
drop reported_2023q1 has_2023q1

// compress, order, and save
compress
order gvkey quarter_date post_chatgpt industry, first
save "$OUT/panel_clean.dta", replace
display as result "Saved cleaned panel to: $OUT/panel_clean.dta"

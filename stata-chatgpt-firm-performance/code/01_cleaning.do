// 01_cleaning.do — data preparation and feature engineering
version 18.5
clear all
set more off

// prepare the data 
format datadate %td // make sure it is in the correct Stata format 

// generate quarter date variable for better comparison
gen quarter_date = qofd(datadate)
format quarter_date %tq
list gvkey datadate fyearq fqtr quarter_date in 1/10

gen post_chatgpt = (quarter_date >= tq(2023q1))
// will be 0 until 2022q4
// will be 1 from 2023q1


// generate industries 
gen naics_major = substr(naics, 1, 1)
destring naics_major, replace

gen naics_major2 = substr(naics, 1, 2)
destring naics_major2, replace


gen industry = .
replace industry = 1 if naics_major == 1 | naics_major == 2 | naics_major == 4 // resource based industries  
replace industry= 2 if naics_major == 5 | naics_major == 6 | naics_major == 7 // production/trade  
replace industry = 3 if naics_major == 3 | naics_major == 8 | naics_major == 9  // technology 

label define industry_label ///
    1 "Resource" ///
    2 "Production" ///
    3 "Technology " ///
	
label values industry industry_label

// set up panel data structure
xtset gvkey quarter_date



// clean data set 


// drop ETF's 
count if naics == "525910"
drop if naics == "525910"


// drop if Naics code is missing 
count if missing(naics)
drop if missing(naics)


// drop firms when reporting 2023q1 is missing 
gen reported_2023q1 = (fyearq == 2023 & fqtr == 1) 
order reported_2023q1, after (post_chatgpt)
bysort gvkey: egen has_2023q1 = max(reported_2023q1)
drop if has_2023q1 == 0


// drop if inconsistent industry  
bysort gvkey (industry): gen inconsistent_industry = (industry != industry[_n-1])
count if inconsistent_industry
drop if inconsistent_industry // 11,731 observations deleted 


// drop if there is no industry belonging to company 
drop if industry == .


// delete variables that only helped us clean the dataset 
bysort gvkey (fyearq): gen nquarters = _N 
bysort gvkey: egen max_nquarters = max(nquarters)
drop nquarters max_nquarters has_2023q1 inconsistent_industry reported_2023q1


// Remove outliers for saleq:
* Step 1: Create a variable for the percentiles of saleq
xtile pct_saleq = saleq, nq(100)

* Step 2: Drop observations in the top and bottom 5% (i.e., top 5 and bottom 5 percentiles)
drop if pct_saleq <= 5 | pct_saleq >= 95

* Step 3: Check if the drop was successful
summarize saleq





// generate dependent variables 

// 1. cost efficiency 
generate cost_efficiency = cogsq/revtq // cost efficiency = operating expenses/revenue 
sum cost_efficiency, detail
bysort industry: summarize cost_efficiency



// 2.investments 
gen investments_capex = capxy/atq // investments = capex/assets 
sum investments_capex, detail 
bysort industry: summarize investments_capex



// 3.revenue growth 
xtset gvkey quarter_date
gen revenue_growth = (revtq - L.revtq) / L.revtq 
bysort post_chatgpt: sum revenue_growth
bysort post_chatgpt industry: sum revenue_growth



// 4. overall profitability 
generate profitability_revenue = niq/revtq
count if missing(profitability_revenue)
sum profitability_revenue, detail
bysort industry: summarize profitability_revenue





// generate independent variables
gen current_to_total_assets = actq / atq
label var current_to_total_assets "Current Assets to Total Assets Ratio"

gen debt_to_assets = ltq / atq
label var debt_to_assets "Debt to Asset Ratio"

gen roa = niq / atq
label var roa "Return on Assets (ROA)"


gen inventory_turnover = cogsq / invtq
label var inventory_turnover "Inventory Turnover"


gen log_cost_efficiency = log(cost_efficiency) if cost_efficiency > 0


// Create log of total assets as a proxy for firm size
gen log_firm_size = log(atq)

// Create R&D expense to sales ratio
gen rnd_to_sales = xrdq / saleq

// Alternatively, you can use raw R&D expense log-transformed
gen log_rnd = log(xrdq + 1)


// Summarize the generated variables to verify
summarize current_to_total_assets debt_to_assets roa inventory_turnover, detail


// transform variables 

// Log-transform Inventory Turnover
gen log_inventory_turnover = log(inventory_turnover)
label var log_inventory_turnover "Log of Inventory Turnover"


// Arcsinh-transform ROA to handle negative and extreme values
gen asinh_roa = asinh(roa)
label var asinh_roa "Arcsinh of Return on Assets"

// Log-transform Debt to Asset Ratio to stabilize skewness
gen log_debt_to_assets = log(debt_to_assets + 1) // Add 1 to avoid log(0)
label var log_debt_to_assets "Log of Debt to Asset Ratio"

// No transformation for Current Assets to Total Assets Ratio
summarize current_to_total_assets log_inventory_turnover asinh_roa log_debt_to_assets

// transform cost efficiency 
summarize cost_efficiency, detail

//histogram current_to_total_assets, percent normal title("Current to Total Assets Ratio")
//histogram log_inventory_turnover, percent normal title("Log of Inventory Turnover")
//histogram asinh_roa, percent normal title("Arcsinh ROA")
//histogram log_debt_to_assets, percent normal title("Log Debt to Asset Ratio")

correlate current_to_total_assets log_inventory_turnover asinh_roa log_debt_to_assets



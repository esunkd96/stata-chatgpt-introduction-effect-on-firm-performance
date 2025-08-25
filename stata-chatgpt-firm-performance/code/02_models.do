// 02_models.do — regressions and exports
version 17
clear all
set more off

global ROOT : pwd
global OUT  "$ROOT/results"
global TABS "$OUT/tables"
global FIGS "$OUT/figures"

use "$OUT/panel_clean.dta", clear
xtset gvkey quarter_date

cap which esttab
if _rc ssc install estout, replace

// Main FE models (cluster by firm)
eststo clear
foreach y in log_cost_efficiency investments_capex revenue_growth profitability_rev {
    eststo `y': xtreg `y' log_inventory_turnover asinh_roa log_debt_to_assets ///
        current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
}
esttab using "$TABS/main_fe.tex", se star(* 0.10 ** 0.05 *** 0.01) replace label title(Main FE Regressions)

// Industry splits
levelsof industry, local(inds)
foreach i of local inds {
    eststo clear
    foreach y in log_cost_efficiency investments_capex revenue_growth profitability_rev {
        eststo `y': xtreg `y' log_inventory_turnover asinh_roa log_debt_to_assets ///
            current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry==`i', fe vce(cluster gvkey)
    }
    esttab using "$TABS/fe_industry`i'.tex", se replace label title(Industry `i')
}
display "Models finished. Tables in results/tables"
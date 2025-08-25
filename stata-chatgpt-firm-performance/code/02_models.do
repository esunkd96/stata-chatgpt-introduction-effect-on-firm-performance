* ---- ensure export tools are available ----
cap which esttab
if _rc ssc install estout, replace
eststo clear

// ========================== COST EFFICIENCY ==========================

// OLS
reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales
eststo ce_ols

// OLS diagnostics
estat ovtest
vif
estat hettest, iid
estat imtest, white

// Robust OLS
reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust
eststo ce_ols_r

// Clustered OLS
reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)
eststo ce_ols_c

// FE vs RE decision
xtset gvkey datadate
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe
estimates store ce_fe
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store ce_re
hausman ce_fe ce_re

// Correlations
pwcorr log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig

// Clustered FE (main spec)
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
eststo ce_fe_c

// Export main CE models
esttab ce_ols ce_ols_r ce_ols_c ce_fe ce_fe_c using "$TABS/costeff_main.tex", ///
    se star(* 0.10 ** 0.05 *** 0.01) replace label title("Cost Efficiency Models")

// Industry splits (clustered FE) + export per-industry table
levelsof industry, local(industry_list)
foreach i of local industry_list {
    eststo clear
    xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets ///
        current_to_total_assets post_chatgpt log_firm_size rnd_to_sales ///
        if industry==`i', fe vce(cluster gvkey)
    esttab using "$TABS/costeff_industry`i'.tex", se replace label ///
        title("Cost Efficiency – Industry `i'")
    display "Results for industry: `i'"
}


// ============================== INVESTMENT ==============================

// OLS
reg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales
eststo inv_ols

// Diagnostics
estat ovtest
vif
estat hettest, iid
estat imtest, white

// Robust & clustered OLS
regress investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust
eststo inv_ols_r
regress investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)
eststo inv_ols_c

// FE vs RE
xtset gvkey datadate
xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe
estimates store inv_fe
xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store inv_re
hausman inv_fe inv_re

// Correlations
pwcorr investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig

// Clustered FE (main)
xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
eststo inv_fe_c

// Export main Investment models
esttab inv_ols inv_ols_r inv_ols_c inv_fe inv_fe_c using "$TABS/invest_main.tex", ///
    se star(* 0.10 ** 0.05 *** 0.01) replace label title("Investment Models")

// Industry splits
levelsof industry, local(industry_list)
foreach i of local industry_list {
    eststo clear
    xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets ///
        current_to_total_assets post_chatgpt log_firm_size rnd_to_sales ///
        if industry==`i', fe vce(cluster gvkey)
    esttab using "$TABS/invest_industry`i'.tex", se replace label ///
        title("Investment – Industry `i'")
    display "Results for industry: `i'"
}


// ============================== REVENUE ==============================

// OLS
reg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales
eststo rev_ols

// Diagnostics
estat ovtest
vif
estat hettest, iid
estat imtest, white

// Robust & clustered OLS
regress revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust
eststo rev_ols_r
regress revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)
eststo rev_ols_c

// FE vs RE
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe
estimates store rev_fe
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store rev_re
hausman rev_fe rev_re

// Correlations
pwcorr revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig

// Clustered FE (main) + alt dep var (revtq) as robustness
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
eststo rev_fe_c

xtreg revtq log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
eststo revtq_fe_c

// Export main Revenue models
esttab rev_ols rev_ols_r rev_ols_c rev_fe rev_fe_c revtq_fe_c using "$TABS/revenue_main.tex", ///
    se star(* 0.10 ** 0.05 *** 0.01) replace label title("Revenue Models")

// Industry splits
levelsof industry, local(industry_list)
foreach i of local industry_list {
    eststo clear
    xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets ///
        current_to_total_assets post_chatgpt log_firm_size rnd_to_sales ///
        if industry==`i', fe vce(cluster gvkey)
    esttab using "$TABS/revenue_industry`i'.tex", se replace label ///
        title("Revenue – Industry `i'")
    display "Results for industry: `i'"
}


// =========================== PROFITABILITY ===========================

// OLS
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales
eststo pr_ols

// Diagnostics
estat ovtest
vif
estat hettest, iid
estat imtest, white

// Robust & clustered OLS
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust
eststo pr_ols_r
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)
eststo pr_ols_c

// FE vs RE
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe
estimates store pr_fe
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store pr_re
hausman pr_fe pr_re

// Correlations
pwcorr profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig

// Clustered FE (main)
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
    current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)
eststo pr_fe_c

// Export main Profitability models
esttab pr_ols pr_ols_r pr_ols_c pr_fe pr_fe_c using "$TABS/profit_main.tex", ///
    se star(* 0.10 ** 0.05 *** 0.01) replace label title("Profitability Models")

// Industry splits
levelsof industry, local(industry_list)
foreach i of local industry_list {
    eststo clear
    xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets ///
        current_to_total_assets post_chatgpt log_firm_size rnd_to_sales ///
        if industry==`i', fe vce(cluster gvkey)
    esttab using "$TABS/profit_industry`i'.tex", se replace label ///
        title("Profitability – Industry `i'")
    display "Results for industry: `i'"
}

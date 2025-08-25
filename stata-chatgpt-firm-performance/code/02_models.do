// 02_models.do — regressions and exports
// Regressions 


// _________________________________________COST EFFICIENCY____________________________________________________

// OLS:  

reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales

// Test Assumptions for OLS Regression: 

// omitted variable bias 
estat ovtest
// p = 0.000 --> model likely has omitted variable bias 

// Mulitcolinearity
vif // very low multicollinearity in the model, no need to worry 

// Homoskedasticity (A4)
// 1. Breusch-Pagan test 
estat hettest, iid
// p-value = 0.000 --> Heteroscedasticity 
// 2. White test 
estat imtest, white
// p-value = 0.000 --> Heteroscedasticity --> use robust standard errors 

// robust standard errors 
reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust

// use clusters 
reg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)



// Test fixed or random effects model 

xtset gvkey datadate
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe 
estimates store fe

xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store re

hausman fe re // use fixed effects model for our estimation 


// Correlation analysis to check relationships between variables
pwcorr log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig

// use clusters to make standard errors robust to heteroscedasticity and autocorrelation within clusters 
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt, fe cluster(gvkey)


// Fixed-effects regression with the added variables (log_firm_size and rnd_to_sales)
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe

// Adjust standard errors for clustering by firm (gvkey)
xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe vce(cluster gvkey)



// create loop command for industries 
levelsof industry, local(industry_list)
foreach i of local industry_list {
    xtreg log_cost_efficiency log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry == `i', fe vce(cluster gvkey)
    display "Results for industry: `i'"
}




//_______________________________________Investment_________________________________________________________

// OLS: 
reg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales

// Test Assumptions for OLS Regression: 

// omitted variable bias 
estat ovtest
// p = 0.000 --> model likely has omitted variable bias 

// Mulitcolinearity
vif // very low multicollinearity in the model, no need to worry 

// Homoskedasticity (A4)
// 1. Breusch-Pagan test 
estat hettest, iid
// p-value = 0.000 --> Heteroscedasticity 
// 2. White test 
estat imtest, white
// p-value = 0.000 --> Heteroscedasticity --> use robust standard errors


// robust standard errors 
regress investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , robust

// use clusters 
regress investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , cluster(gvkey)


// Test fixed or random effects 
xtset gvkey datadate
xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , fe 
estimates store fe

xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re 
estimates store re
hausman fe re // test does not deliver solution --> better to use fixed effects 

// Correlation analysis
pwcorr investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , sig


// Fixed-effects models 
xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , fe robust

xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , fe robust cluster(gvkey)


// create loop command for industries
levelsof industry, local(industry_list) 
foreach i of local industry_list {       
    xtreg investments_capex log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry == `i', fe robust cluster(gvkey)
    display "Results for industry: `i'"
}



//____________________________________________Revenue______________________________________________________

// OLS: 
reg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales


// Test Assumptions for OLS Regression: 

// omitted variable bias 
estat ovtest
// p = 0.0029 --> only at a 1% significance level 

// Mulitcolinearity
vif // very low multicollinearity in the model, no need to worry 


// Homoskedasticity (A4)
// 1. Breusch-Pagan test 
estat hettest, iid
// p-value = 0.0117 --> heteroscedasticity 
// 2. White test 
estat imtest, white
// p-value = 0.9936 --> no heteroscedasticity --> use robust standard errors

// robust standard errors 
regress revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust 

// use clusters 
regress revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)


// Test fixed or random effects model 
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe
estimates store fe
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re
estimates store re
hausman fe re // --> use fixed effects model 

// Correlation analysis 
pwcorr revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig



// Fixed-effects model 

// use revenue_growth as dependent variable 
xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , fe robust cluster(gvkey)

levelsof industry, local(industry_list)  
foreach i of local industry_list {       
    xtreg revenue_growth log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry == `i', fe robust cluster(gvkey)
    display "Results for industry: `i'"
}



// use revtq as dependent variable 
xtreg revtq log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales , fe robust cluster(gvkey)

levelsof industry, local(industry_list)  
foreach i of local industry_list {       
    xtreg revtq log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry == `i', fe robust cluster(gvkey)
    display "Results for industry: `i'"
}



//___________________________________________Overall profitability_______________________________________

// OLS: 
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales

// Test Assumptions for OLS Regression: 

// omitted variable bias 
estat ovtest
// p = 0.000 --> model likely has omitted variable bias 

// Mulitcolinearity
vif // very low multicollinearity in the model, no need to worry 

// Homoskedasticity (A4)
// 1. Breusch-Pagan test 
estat hettest, iid
// p-value = 0.000 --> heteroscedasticity 
// 2. White test 
estat imtest, white
// p-value = 0.000 --> heteroscedasticity --> use robust standard errors

// use robust standard errors 
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, robust

// use clusters 
reg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, cluster(gvkey)



// Test for fixed or random effects 
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe 
estimates store fe
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, re 
estimates store re
hausman fe re // --> use fixed effects 

// Correlation analysis: 
pwcorr profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, sig 


// Fixed effects model
xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales, fe robust cluster(gvkey)




// create loop command for industries
levelsof industry, local(industry_list)
foreach i of local industry_list {
    xtreg profitability_revenue log_inventory_turnover asinh_roa log_debt_to_assets current_to_total_assets post_chatgpt log_firm_size rnd_to_sales if industry == `i', fe robust cluster(gvkey)
    display "Results for industry: `i'"
}



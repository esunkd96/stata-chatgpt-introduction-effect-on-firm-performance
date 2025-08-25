// 99_repro.do — run full pipeline
version 18.5
clear all
set more off

do "code/01_cleaning.do"
do "code/02_models.do"

display "All done — see results/ for outputs."

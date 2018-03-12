// ======================================================
// PT- PX script for power estimation
//=======================================================


vcd2saif -64 -input dump.vcd -output out.saif
pt_shell -64bit
set stdcells_home /research/brg/install/bare-pkgs/noarch/synopsys-90nm/toolflow
set search_path "$stdcells_home"
set target_library "cells.db"
set link_path "* $target_library"
set power_enable_analysis "true"
read_verilog "./Flicker.output.v"  
current_design "FABSCALAR"
//=======================================================================================//
//--------------------------------use one of the method-------------------
//=======================================================================================//
set power_analysis_mode "averaged"
read_saif "./out.saif" -strip_path "simulate/fabscalar"
report_switching_activity -list_not_annotated
read_parasitics -increment -format sbpf "./Flicker.output.sbpf.max"
report_power -verbose -hierarchy
//=========================================================================================//
set power_analysis_mode "time_based"
read_vcd "./FABSCALAR.vcd"
report_switching_activity -list_not_annotated
read_parasitics -increment -format sbpf "./FABSCALAR.sbpf.max"
report_power -verbose -hierarchy


uplevel #0 source /icc/scripts/initialize.tcl
create_floorplan -left_io2core 10 -bottom_io2core 10 -right_io2core 10 -top_io2core 10
gui_set_current_task -name {Design Planning}
create_fp_placement
remove_floorplan
remove_placement
gui_set_current_task -name {Block Implementation}
gui_set_current_task -name {Design Planning}
set_fp_macro_array -name MacroArray_1 -elements [list [get_cells "rename/specfreelist/FREE_LIST"]] -x_offset 0 -y_offset 0 -align_edge center -rectilinear
create_fp_placement
remove_placement
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start RulerTool
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_remove_all_rulers -window [gui_get_current_window -types Layout -mru];  gui_remove_all_rulers -window global
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -start RulerTool
gui_mouse_tool -window [gui_get_current_window -types Layout -mru] -reset
set_fp_macro_array -name MacroArray_2 -elements [list [get_cells "reg_read/PhyRegFile1"]] -x_offset 100 -y_offset 0.000000 -align_edge center -rectilinear
set_fp_macro_array -name MacroArray_3 -elements [list [get_cells "rename/RMT/RenameMap"]] -x_offset 200 -y_offset 0.000000 -align_edge center -rectilinear
set_fp_macro_array -name MacroArray_4 -elements [list [get_cells "issueq/src1cam"]] -x_offset 300.000000 -y_offset 0.000000 -align_edge center -rectilinear
create_fp_placement
remove_placement
gui_set_current_task -name {Block Implementation}
gui_set_current_task -name {Design Planning}
move_objects -delta {-962.070 -109.280} [get_selection]
gui_set_current_task -name {Block Implementation}
move_objects -delta {170.495 -987.680} [get_selection]
move_objects -delta {-2.435 -288.000} [get_selection]
move_objects -delta {-36.535 0.000} [get_selection]
move_objects -delta {41.405 0.000} [get_selection]
move_objects -delta {-38.970 0.000} [get_selection]
gui_set_current_task -name {Design Planning}
set_fp_macro_array -name MacroArray_3 -reset
set_fp_macro_array -name MacroArray_4 -reset
set_fp_macro_array -name MacroArray_1 -reset
set_fp_macro_array -name MacroArray_2 -reset
set_fp_placement_strategy -fix_macros all
create_placement_blockage -coordinate {{24.400 1173.520} {1264.080 1262.800}} -name placement_blockage_0 -type hard
create_placement_blockage -coordinate {{163.280 18.640} {859.920 64.720}} -name placement_blockage_1 -type hard
create_placement_blockage -coordinate {{854.800 18.640} {1093.520 82.000}} -name placement_blockage_2 -type hard
create_fp_placement
gui_set_current_task -name {Block Implementation}
set power                    "VDD"
set ground                   "VSS"
set powerPort                "VDD"
set groundPort               "VSS"
set mw_logic0_net 	     "VSS"
set mw_logic1_net 	     "VDD"
derive_pg_connection -power_net VDD					 -ground_net VSS				 -power_pin VDD					 -ground_pin VSS
create_rectangular_rings  -nets  {VDD VSS}  -left_offset 0.2 -left_segment_layer M4 -right_offset 0.2 -right_segment_layer M4 -bottom_offset 0.2 -bottom_segment_layer M3 -extend_bh -top_offset 0.2 -top_segment_layer M3
create_power_straps  -direction horizontal  -nets  {VDD}  -layer M4 -configure groups_and_step  -num_groups 184 -step 10
create_power_straps  -direction horizontal  -start_at 1.5 -nets  {VSS}  -layer M4 -configure groups_and_step  -num_groups 184 -step 10
create_power_straps  -direction vertical  -nets  {VDD}  -layer M3 -configure groups_and_step  -num_groups 184 -step 10
create_power_straps  -direction vertical  -start_at 1.5 -nets  {VSS}  -layer M3 -configure groups_and_step  -num_groups 184 -step 10

#uplevel #0 source /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/scripts/setup.tcl

set stdcells_home /research/brg/install/bare-pkgs/noarch/synopsys-90nm/toolflow
set_app_var search_path "$stdcells_home"
set_app_var target_library "cells.db"
set_app_var link_library "* $target_library"

#set_tlu_plus_files -max_tluplus /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/tluplus/saed90nm_1p9m_1t_Cmax.tluplus -min_tluplus /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/tluplus/saed90nm_1p9m_1t_Cmin.tluplus -tech2itf_map  /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/tluplus/tech2itf.map
set_tlu_plus_files -max_tluplus "$stdcells_home/max.tluplus" \ -min_tluplus "$stdcells_home/min.tluplus" \ -tech2itf_map "$stdcells_home/tech2itf.map"


#create_mw_lib  -technology /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/techfiles/saed90nm_icc_1p9m.tf -mw_reference_library {/net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/saed90nm_fr /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/ref/memory} -bus_naming_style {[%d]}  -open  /net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/work/fabscalar

create_mw_lib  -technology "$stdcells_home/techfile.tf" \ -bus_naming_style {[%d]} \ -mw_reference_library "$stdcells_home/milkyway.fr" \ "FABSCALAR_LIB"

#import_designs -format ddc -top FABSCALAR -cel FABSCALAR {/net/plato.ee.virginia.edu/users/wz6pc/synopsys/syn_tut/icc/source/FABSCALAR_compiled.ddc}

import_designs -format ddc -top FABSCALAR -cel FABSCALAR {/source/FABSCALAR_compiled.ddc} 

uniquify_fp_mw_cel

link

read_sdc  -version Latest "/source/FABSCALAR.sdc"

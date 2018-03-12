create_mw_lib  -technology ../ref/techfiles/saed90nm_icc_1p9m.tf	\
		-mw_reference_library {../ref/saed90nm_fr }	\
		-hier_separator {/}				\
		-bus_naming_style {[%d]}			\
		-open  ./fabscalar


set tlupmax	"../ref/tluplus/saed90nm_1p9m_1t_Cmax.tluplus"
set tlupmin	"../ref/tluplus/saed90nm_1p9m_1t_Cmin.tluplus"
set tech2itf	"../ref/tluplus/tech2itf.map"

set_tlu_plus_files -max_tluplus $tlupmax \
                        -min_tluplus $tlupmin \
			-tech2itf_map $tech2itf



		

#lappend search_path ../ref/models
#set link_library  "* saed90nm_typ_ht.db"

set target_library  "saed90nm_typ_ht.db"

set synthetic_library "dw_foundation.sldb"

set link_library [concat  $target_library $synthetic_library]

set symbol_library "saed90nm.sdb"
#define_design_lib WORK -path .

alias h history
alias rc "report_constraint -all_violators"


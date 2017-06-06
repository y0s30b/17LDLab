
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name TAXI -dir "D:/0606/17LDLab/TAXI/planAhead_run_2" -part xc3s200pq208-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "TAXI.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {SEG_DISPLAY.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {DATA_PROCESS.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {TAXI.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top TAXI $srcset
add_files [list {TAXI.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s200pq208-4

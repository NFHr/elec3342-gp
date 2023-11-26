set_property SRC_FILE_INFO {cfile:/media/sf_ELEC3342/HW4/elec3342_prj_tmpl.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../elec3342_prj_tmpl.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:clk_wiz_inst/inst} [current_design]
current_instance clk_wiz_inst/inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_100m]] 0.1

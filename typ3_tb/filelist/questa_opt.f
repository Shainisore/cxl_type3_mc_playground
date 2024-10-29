-detectzerodelayloop \
-c \
-sv \
+libext+.v+.vs+.sv+.vh+.svh+.svhp+.svp+.vp+.svip \
-incr \
-64 \
-timescale=1ps/1fs \
-suppress 19,7063,2577,2579,2574,2244,2388,13389,13314,13276,2732,7061,12003,14408,2912,16053 \
-suppress 2635,13232,13233,13234,13314,13361,13365,2121,2182,2217,2240,2241,2248,2250,2263,2275,2283,2570,2583,2600,2685,2697,2718,2958,3691,3003,3015,7033 \
-no_autoacc \
-noglitch \
-solvefaildebug \
-permit_unmatched_virtual_intf \
-ccflags -DQUESTA \
-sv_lib $UVM_HOME/../../uvm-1.2/linux_x86_64/uvm_dpi \
 \
-voptargs="+acc=npr+/." \
-voptargs=-noprotectopt \
-wlf cxl_tb_top.wlf \
-top \
cxl_tb_top \
-work \
tb_lib \
\
-pli \
$AVERY_PLI/lib.linux/libtb_ms64.a \

#!/usr/intel/bin/perl
##--------------------------------------------------------------------------------
# Copyright (c) Programmable Solutions Group (PSG),
# Intel Corporation 2022.
# All rights reserved.
#--------------------------------------------------------------------------------
# File name       : vcs_execute.pl 
# Date Created    : Mon 13 December 2021
#--------------------------------------------------------------------------------
# Description  :
#     
#    1. This script does preprocess to find the required paths.
#    2. Executes commands for IP and TB Compilation, Elaboration and Simulation.
#    3. Postprocess for the VCS log-file analysis to identify statements
#    containing “error”, “fatal”, “warning” and “fail” keywords.
#
#--------------------------------------------------------------------------------
# Version Map     :
#
#   -----------------------------
#    Version             : 1.10
#    Version Information : 
#       1. Added Questasim support.
#       2. Updated post process waiver list for new warnings.
#
#   -----------------------------
#    Version             : 1.9
#    Version Information : 
#       1. Moved "check_for_failure" routine usage for sim stage only and for
#          on-demand debug.
#
#   -----------------------------
#    Version             : 1.8
#    Version Information : 
#       1. Added Each stage based postpartum checks - can be controlled by waivers.
#          Compilation (IP and TB) and Elaboration stages will be flagged as “warning” 
#          message by the script, but Simulation stage will be flagged as “error”. 
#          This update creates a logfile named PASS or FAIL postprocess report which 
#          can be used to analyze the completion of each stage. The waivers of above 
#          mentioned failure keywords are added for the expected ones.
#          Refer “check_for_failure” subroutine for the current list of waivers and 
#          add if any new expected statements in REGEX form. 
#
#   -----------------------------
#    Version             : 1.7
#    Version Information : 
#       1. Added Filelist grab from ED RTL generation setup.
#       2. Added DTL mechanism.
#       3. Added Hotfix cmdline Option.
#
#   -----------------------------
#    Version             : 1.6
#    Version Information : 
#       1. Added T2IP and T3IP QPDS RTL support.
#       2. Added Manual filelist generation for RTL out of Quartus IP.
#
#   -----------------------------
#    Version             : 1.5
#    Version Information : 
#       1. Added QPDS_B0A0_ED , QPDS_B0A0 option for CXLTYP3DDR.
#       2. Added CFG_IP / QHIP_MIRROR_IP option.
#
#   -----------------------------
#    Version             : 1.4
#    Version Information : 
#       1. Added QPDS_ED option for CXLTYP3DDR.
#       2. Added option for External simulation directoy name.
#
#   -----------------------------
#    Version             : 1.3
#    Version Information : 
#       1. Added QPDS option for CXLTYP3DDR.
#
#   -----------------------------
#    Version             : 1.2
#    Version Information : 
#       1. Tool Invoke variables reporting.
#       2. Untarred and Tarred Release paths are accepted.
#
#   -----------------------------
#    Version             : 1.1
#    Version Information : 
#       1. File Header Updates.
#       2. Added option for External only VCS  Simulation argunments.
#
#   -----------------------------
#    Version             : 1.0
#    Version Information : 
#       1. Initial Version.
#
##--------------------------------------------------------------------------------


use strict;
use warnings;
use File::Basename;
use Env;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use Data::Dumper qw(Dumper);
use Term::ANSIColor qw(:constants);
use Cwd;


################################################
## Script Information gatherer 
################################################
my $start_time = time();
my $PROGNAME = basename($0);

################################################
## Usage description for the script ############
################################################
my $help_statement;
$help_statement =  "\n";
$help_statement .=  "Usage:\n";
$help_statement .=  "      -r_path      <Expects input;  RTL Release path (untarred or tarred path).>\n";
$help_statement .=  "      -t_path      <Expects input;  TB Release path (untarred or tarred path).>\n";
$help_statement .=  "      -cmd         <Optional input; Default: run_all_d; Optional inputs are ip_comp, tb_comp, comp_all, elab, sim, sim_d, questa_run_d, questa_run, run_all or run_all_d.>\n";
$help_statement .=  "      -rundir      <Optional input; Default: \$PWD\/run_dir; Run Directory for library compile or simulation.>\n";
$help_statement .=  "      -s_pargs     <Optional input; Default: +UVM_TESTNAME=cxl_base_test +seqname=cxl_m2s_self_check_seq +TEST_MC0_MC1_INCR_ADDR +num_m2s_req=1500; TB sim Test and Sequence name as arguments.>\n";
$help_statement .=  "      -simdir_n    <Optional input; Default: <rundir>; Sim Directory name for simulation.>\n";
$help_statement .=  "      -c_defines   <Optional input; Default: +define+T2IP +define+QPDS_ED_B0; IP and TB common define options.>\n";
$help_statement .=  "      -hotfix      <Optional input; TB Setup has a reference hotfix for RTL Open BUGs, which will be patched with this switch.>\n";
$help_statement .=  "      -clean       <Optional input; Default: disabled; Cleans the Run directory before lauching the requested command.>\n";
$help_statement .=  "      -debug       <Optional input; Default: disabled; Enables debug print messages for the script flow.>\n";
$help_statement .=  "      -help        <Optional input; Default: disabled; Prints this message.>\n";
$help_statement .=  "\n";
$help_statement .=  "The terminal/shell has to be set for VCS_HOME, VERDI_HOME, UVM_HOME, LM_LICENSE_FILE, SNPSLMD_LICENSE_FILE, AVERY_PCIE, AVERY_PLI, QUARTUS_INSTALL_DIR and QUARTUS_LIB_DIR.\n";
$help_statement .=  "For Further information, Contact Intel Release Team.\n";
$help_statement .=  "\n";
$help_statement .=  "\n";

################################################
## Absorb the Args #############################
################################################
my $opt_cmd = "run_all_d";
my $opt_rundir = "run_dir";
my $opt_simdir = "";
my $opt_r_path;
my $opt_t_path;
my $opt_c_defines = "+define+T3IP +define+QPDS_ED_B0";
my $opt_s_pargs = "+UVM_TESTNAME=cxl_base_test +seqname=cxl_m2s_self_check_seq +TEST_MC0_MC1_INCR_ADDR +num_m2s_req=1500";
my $opt_hotfix;
#my $opt_debug = 1;
my $opt_clean;
my $opt_debug;
my $opt_help;
my $scal_argv = join(",",@ARGV);
my $result = &GetOptions(
    "cmd=s" => \$opt_cmd,
    "rundir=s" => \$opt_rundir,
    "simdir_n=s" => \$opt_simdir,
    "r_path=s" => \$opt_r_path,
    "t_path=s" => \$opt_t_path,
    "hotfix" => \$opt_hotfix,
    "clean" => \$opt_clean,
    "debug" => \$opt_debug,
    "s_pargs=s" => \$opt_s_pargs,
    "c_defines=s" => \$opt_c_defines,
    "help" => \$opt_help
) or die "$help_statement";

my $rtl_filelist_gen = "QPDS_ED_FLIST_RDY";

my $script_debug_log .= print_i_d("Input ARGS are- $scal_argv",$opt_debug);

my $my_base_log_content;
$my_base_log_content  = "    RTL Tarball used: $opt_r_path\n";
$my_base_log_content .= "    TB  Tarball used: $opt_t_path\n";

$opt_r_path = `realpath $opt_r_path`;
chomp $opt_r_path;
$ENV{'ED_PATH'} = $opt_r_path;

$script_debug_log .= $my_base_log_content;


################################################
## Basic checks for script argument parsing#####
################################################
my $status = 1;
my $r_path_dir;
my $l_r_path_dir;
my $t_path_dir;

if($scal_argv !~ /-/) {
    print_e("No option is specified. Refer below Usage statement.");
    print $help_statement;
    exit;
} else {
    if(defined $opt_cmd) {
        $script_debug_log .= print_i_d("Cmd requested is $opt_cmd",$opt_debug); 
        if($opt_cmd =~ /(run_all)|(comp)|(elab)|(sim)|(dtl)|(questa)/) {
            print_i("CMD: \"$opt_cmd\" will be executed.");
            $status = 0;
        } else {
            print_e("$opt_cmd doesn't exist.");
            print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
            print $help_statement;
            $status = 1;
            exit;
        }     
    }
    if(defined $opt_rundir) {
        $opt_rundir = $opt_rundir . "\/" if($opt_rundir !~ /\/$/);
        system("mkdir -p $opt_rundir");
        $opt_rundir = `realpath $opt_rundir`;
        chomp $opt_rundir;
        print_i("Output will be generated at $opt_rundir");
        $status = 0;
    } else {
        print_e("Run Directory is not passed on \"-rundir\" option.");
        print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
        print $help_statement;
        $status = 1;
        exit;
    }     
    
    if(defined $opt_r_path) {
        $opt_r_path = `realpath $opt_r_path`;
        chomp $opt_r_path;
        $r_path_dir = $opt_r_path;
        $r_path_dir =~ s/\.tar\.gz//g;
        untar_file($opt_r_path,$r_path_dir,$opt_debug) if($opt_r_path =~ /tar\.gz/);
        if(! -e $r_path_dir) {
            print_e("$r_path_dir doesnt exist. Please assign valid RTL Release Path using \"-r_path\" option.");
            print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
            print $help_statement;
            $status = 1;
            exit;
        } else {
            print_i("$r_path_dir will be used as the RTL Release Path for Testbench build and simulation.");
            $status = 0;
        }
    } else {
        print_e("Please assign valid RTL Release Path using \"-r_path\" option.");
        print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
        print $help_statement;
        $status = 1;
        exit;
    }
    $l_r_path_dir = $r_path_dir;
    
    if(defined $opt_t_path) {
        $opt_t_path = `realpath $opt_t_path`;
        chomp $opt_t_path;
        $t_path_dir = $opt_t_path;
        $t_path_dir =~ s/\.tar\.gz//g;
        untar_file($opt_t_path,$t_path_dir,$opt_debug) if($opt_t_path =~ /tar\.gz/);
        if(! -e $t_path_dir) {
            print_e("$t_path_dir doesnt exist. Please assign valid TB Release Path using \"-t_path\" option.");
            print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
            print $help_statement;
            $status = 1;
            exit;
        } else {
            print_i("$t_path_dir will be used as the TB Release Path for Testbench build and simulation.");
            $status = 0;
        }
    } else {
        print_e("Please assign TB Release Path using \"-t_path\" option.");
        print_e("Script hit Fatal error. Will exit now. Please re-run with \"-debug\" option enabled for further script debug.");
        print $help_statement;
        $status = 1;
        exit;
    }

    print "\n";
    print_i("All expected options are received from the commandline.") if($status eq '0');
    print "\n";

    $script_debug_log .= print_i_d("Expected Tool variables are:",$opt_debug);
    my $local_VCS_HOME = $ENV{VCS_HOME};
    if (defined $local_VCS_HOME) {
        $script_debug_log .= print_i_d("Expected Shell variable: VCS_HOME set to $local_VCS_HOME",$opt_debug);
    } else {
        print_e("Expected Shell variable: VCS_HOME is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_VERDI_HOME = $ENV{VERDI_HOME};
    if (defined $local_VERDI_HOME) {
        $script_debug_log .= print_i_d("Expected Shell variable: VERDI_HOME set to $local_VERDI_HOME",$opt_debug);
    } else {
        print_e("Expected Shell variable: VERDI_HOME is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_UVM_HOME = $ENV{UVM_HOME};
    if (defined $local_UVM_HOME) {
        $script_debug_log .= print_i_d("Expected Shell variable: UVM_HOME set to $local_UVM_HOME",$opt_debug);
    } else {
        print_e("Expected Shell variable: UVM_HOME is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_LM_LICENSE_FILE = $ENV{LM_LICENSE_FILE};
    if (defined $local_LM_LICENSE_FILE) {
        $script_debug_log .= print_i_d("Expected Shell variable: LM_LICENSE_FILE set to $local_LM_LICENSE_FILE",$opt_debug);
    } else {
        print_e("Expected Shell variable: LM_LICENSE_FILE is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_SNPSLMD_LICENSE_FILE = $ENV{SNPSLMD_LICENSE_FILE};
    if (defined $local_SNPSLMD_LICENSE_FILE) {
        $script_debug_log .= print_i_d("Expected Shell variable: SNPSLMD_LICENSE_FILE set to $local_SNPSLMD_LICENSE_FILE",$opt_debug);
    } else {
        print_e("Expected Shell variable: SNPSLMD_LICENSE_FILE is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_AVERY_PCIE = $ENV{AVERY_PCIE};
    if (defined $local_AVERY_PCIE) {
        $script_debug_log .= print_i_d("Expected Shell variable: AVERY_PCIE set to $local_AVERY_PCIE",$opt_debug);
    } else {
        print_e("Expected Shell variable: AVERY_PCIE is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_AVERY_PLI = $ENV{AVERY_PLI};
    if (defined $local_AVERY_PLI) {
        $script_debug_log .= print_i_d("Expected Shell variable: AVERY_PLI set to $local_AVERY_PLI",$opt_debug);
    } else {
        print_e("Expected Shell variable: AVERY_PLI is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_QUARTUS_INSTALL_DIR = $ENV{QUARTUS_INSTALL_DIR};
    if (defined $local_QUARTUS_INSTALL_DIR) {
        $script_debug_log .= print_i_d("Expected Shell variable: QUARTUS_INSTALL_DIR set to $local_QUARTUS_INSTALL_DIR",$opt_debug);
    } else {
        print_e("Expected Shell variable: QUARTUS_INSTALL_DIR is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

    my $local_QUARTUS_LIB_DIR = $ENV{QUARTUS_LIB_DIR};
    if (defined $local_QUARTUS_LIB_DIR) {
        $script_debug_log .= print_i_d("Expected Shell variable: QUARTUS_LIB_DIR set to $local_QUARTUS_LIB_DIR",$opt_debug);
    } else {
        print_e("Expected Shell variable: QUARTUS_LIB_DIR is not set in the current executing terminal");
        print $help_statement;
        $status = 1;
        exit;
    }

}

#################################################
#Execute the requested commands#
#################################################

##Create and set RUNDIR
my $scripts_path;
my $scripts_path_Makefile;
my $sh_cmd;
my $bkp_rundir = $opt_rundir . "_bkp";

my $qhip_rtl_path;
my $top_module="cxl_tb_top";
my $top_module_cfg="cxl_tb_top_config";
my $prj_sim_defines;
my $tb_ram_file_paths=$t_path_dir . "\/tb_models\/";
my $prj_sim_defines_d;
my $filename_s_args = $opt_rundir . "\/" . $opt_simdir . "\/extra_sim_args.args";
my $filename_c_defines = $opt_rundir . "\/extra_cmp_defines.args";


##Clean and Create Workdir
$scripts_path = $t_path_dir . "/scripts";
$scripts_path_Makefile = $scripts_path . "/Makefile";
if(defined $opt_clean) {
    $sh_cmd = "xterm -e \"make -C $scripts_path clean_all WORK_DIR=$opt_rundir\;mkdir -p $opt_rundir\; cp -n $scripts_path_Makefile $opt_rundir\; mkdir -p $opt_rundir\/$opt_simdir\; \"";
    $script_debug_log .= print_i_d("Shell command to create WORKDIR is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
    $script_debug_log .= print_i_d("Rundir is cleaned and created at $opt_rundir", $opt_debug);
} else {
    $sh_cmd = "xterm -e \"mkdir -p $opt_rundir\; cp -n $scripts_path_Makefile $opt_rundir\; mkdir -p $opt_rundir\/$opt_simdir\; \"";
    $script_debug_log .= print_i_d("Shell command to create WORKDIR is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
    $script_debug_log .= print_i_d("Rundir is created at $opt_rundir", $opt_debug);
}

##Define the VCS Setup file
my $default_vcs_setup_str = set_default_vcs_file($opt_rundir,$opt_debug);

##Create VCS Setup file
my $vcs_setup_content;
$vcs_setup_content = "WORK > DEFAULT\n";
$vcs_setup_content .= $default_vcs_setup_str;

my $vcs_setup_fname = $opt_rundir . "\/synopsys_sim.setup";

##create extra sim plusargs file
create_file($filename_s_args,$opt_s_pargs);
my $prj_sim_args = "$filename_s_args";

##create extra cmp defines file
my $prj_cmp_defines = "$filename_c_defines";
if ($opt_c_defines =~ /(REPO)/) {
    my $global_def_from_rtl = `cat $l_r_path_dir/rtlcompchk/filelist/global_defs.f`;
    chomp $global_def_from_rtl;
    $opt_c_defines .= "\n";
    $opt_c_defines .= $global_def_from_rtl;
}
create_file($filename_c_defines,$opt_c_defines);

##General declaration
my $log_f;
my $stage;
my $full_log_f;
my $fail_sigs;

##Define the Variant selection from the cmdline args
my $variant;
if ($opt_c_defines =~ /(ENABLE_1_BBS_SLICE)/) {
    $variant = "1S";
} elsif ($opt_c_defines =~ /(ENABLE_2_BBS_SLICE)/) {
    $variant = "2S";
} elsif ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
    $variant = "4S";
} else {
    $variant = "2S";
}

if(defined $opt_hotfix) {
    do_hotfix($opt_r_path, $opt_t_path, $variant, $opt_debug);
}

if($opt_cmd =~ /(ip_comp)|(all)|(ip_comp_dtl)|(full_dtl_save)/) {
    ## Standalone
    if ($rtl_filelist_gen =~ /(QPDS_SA_AF)/) {  
       if ($opt_c_defines =~ /(T1IP)/) {
          #Prepare the RTL Filelist from the Quartus generated RTL
          $sh_cmd = "rm -fr $opt_rundir/qpds_sa_rtl_t1ip;cp -fr $l_r_path_dir $opt_rundir/qpds_sa_rtl_t1ip;";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist cleanup is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ###for incdir
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_sa_rtl_t1ip/intel_rtile_cxl_top_type1/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/+incdir/\\n +incdir/g' flist_ip.txt > flist_ip_temp.txt;sed 's/ dict set design_files \"//g' flist_ip_temp.txt > flist_ip.txt ;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;sed 's/\\\\//g' flist_ip_temp.txt > flist_ip.txt;sed 's/\$QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_type1/g' flist_ip.txt > flist_ip_temp.txt;cat -n flist_ip_temp.txt | sort -uk2 | sort -nk1 | cut -f2- > flist_ip.txt;grep \"incdir\" flist_ip.txt > filelist_t1ip.txt; rm -rf flist_ip.txt flist_ip_temp.txt;";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ##for filelist
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_sa_rtl_t1ip/intel_rtile_cxl_top_type1/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/\\./\\ \\./g' flist_ip.txt > flist_ip_temp.txt;rm -fr flist_ip.txt ; mv flist_ip_temp.txt flist_ip.txt ;sed -i '1 i\\dummy_line_added 1 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 2 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 3 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 4 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 5 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 6 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 7 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 8 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 9 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 10 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;cat -n flist_ip.txt | sort -u -t' ' -k11,11 | sort -nk1 | cut -f2- > flist_ip_temp.txt;sed 's/ \\./\\./g' flist_ip_temp.txt > flist_ip.txt;sed -i '/dummy_line_added/d' flist_ip.txt;sed 's/.*QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_type1/g' flist_ip.txt > flist_ip_temp.txt;sed 's/.*QSYS_SIMDIR/\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_type1\\/sim/g' flist_ip_temp.txt > flist_ip.txt;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;cat flist_ip_temp.txt >> filelist_t1ip.txt; find $opt_rundir/qpds_sa_rtl_t1ip/hardware_test_design/ -type d > temp_f1.txt; sed 's/.*hardware_test_design/+incdir+\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f_hwd.f; find $opt_rundir/qpds_sa_rtl_t1ip/hardware_test_design/ -name \"*.sv\" -o -name \"*.v\" > temp_f1.txt; sed 's/.*hardware_test_design/\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f2.txt; grep \"pkg\" temp_f2.txt >> temp_f_hwd.f;grep \"parameters\" temp_f2.txt >> temp_f_hwd.f; sed 's/.*pkg.*//g' temp_f2.txt > temp_sed_f.txt; sed 's/.*parameters.*//g' temp_sed_f.txt >> temp_f_hwd.f; sed 's/.*\\/synth.*//g' temp_f_hwd.f > temp_f_hwd_f.f ; sed 's/.*_bb\\..*//g' temp_f_hwd_f.f > temp_f_hwd_f2.f; sed 's/.*_inst\\..*//g' temp_f_hwd_f2.f > temp_f_hwd_f3.f; rm -fr temp_f1.txt temp_f2.txt ; cat temp_f_hwd_f3.f >> filelist_t1ip.txt; mkdir -p rtl_filelist;mv filelist_t1ip.txt rtl_filelist/filelist_t1ip.f;cp $t_path_dir/qpds_rtl_ref/filelist/filelist_cxlip_lib.f rtl_filelist/.;grep \"altera_dcfifo_synchronizer_bundle\" $opt_rundir/qpds_sa_rtl_t1ip/intel_rtile_cxl_top_type1 -r | grep \"module\" | grep \"sim\" | grep \"cxl_io_slave\"  > rtl_filelist/avmm_interconnect.f;sed 's/:module.*//g' rtl_filelist/avmm_interconnect.f > rtl_filelist/avmm_interconnect2.f;rm -fr rtl_filelist/avmm_interconnect.f; mv rtl_filelist/avmm_interconnect2.f rtl_filelist/avmm_interconnect.f;mv rtl_filelist $opt_rundir/qpds_sa_rtl_t1ip/filelist; rm -rf flist_ip.txt temp_f_hwd.f flist_ip_temp.txt ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          #For 4slice
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
          $sh_cmd = "mv $opt_rundir/qpds_sa_rtl_t1ip/filelist $opt_rundir/qpds_sa_rtl_t1ip/filelist_4s; ";
          
          system($sh_cmd);
          }
    
          #Local RTL Copy
          $l_r_path_dir = "$opt_rundir/qpds_sa_rtl_t1ip/";
       }
    }
    
    ## ED
    if ($rtl_filelist_gen =~ /(QPDS_ED_AF)/) {  
       if ($opt_c_defines =~ /(T1IP)/) {
          #Prepare the RTL Filelist from the Quartus generated RTL
    #      $sh_cmd = "rm -fr $opt_rundir/qpds_ed_rtl_t1ip;cp -fr $l_r_path_dir $opt_rundir/qpds_ed_rtl_t1ip;rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/ccv_afu/ccv_afu_cdc_fifo_vcd.v;rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/ccv_afu/mwae_poison_injection.sv ;rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/afu/afu_top.sv ;rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/afu/afu_csr_avmm_slave.sv ;cp -fr $t_path_dir/qpds_rtl_ref/ccv_afu_cdc_fifo_vcd.v $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/ccv_afu/ccv_afu_cdc_fifo_vcd.v;cp -fr $t_path_dir/qpds_rtl_ref/mwae_poison_injection.sv $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/ccv_afu/mwae_poison_injection.sv ;cp -fr $t_path_dir/qpds_rtl_ref/afu_top.sv $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/afu/afu_top.sv ;cp -fr $t_path_dir/qpds_rtl_ref/afu_csr_avmm_slave.sv $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/common/afu/afu_csr_avmm_slave.sv ;";
          $sh_cmd = "rm -fr $opt_rundir/qpds_ed_rtl_t1ip;cp -fr $l_r_path_dir $opt_rundir/qpds_ed_rtl_t1ip;";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist cleanup is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ###for incdir
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t1ip/intel_rtile_cxl_top_cxltyp1_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/+incdir/\\n +incdir/g' flist_ip.txt > flist_ip_temp.txt;sed 's/ dict set design_files \"//g' flist_ip_temp.txt > flist_ip.txt ;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;sed 's/\\\\//g' flist_ip_temp.txt > flist_ip.txt;sed 's/\$QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp1_ed/g' flist_ip.txt > flist_ip_temp.txt;cat -n flist_ip_temp.txt | sort -uk2 | sort -nk1 | cut -f2- > flist_ip.txt;grep \"incdir\" flist_ip.txt > filelist_t1ip.txt; rm -rf flist_ip.txt flist_ip_temp.txt; ";
          #rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/cxltyp1_ed.sv; cp -fr $t_path_dir/qpds_rtl_ref/typ1/cxltyp1_ed.sv $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/cxltyp1_ed.sv; rm -fr $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/ed_top_wrapper_typ1.sv; cp -fr $t_path_dir/qpds_rtl_ref/typ1/ed_top_wrapper_typ1.sv $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/ed_top_wrapper_typ1.sv;";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ##for filelist
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t1ip/intel_rtile_cxl_top_cxltyp1_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/\\./\\ \\./g' flist_ip.txt > flist_ip_temp.txt;rm -fr flist_ip.txt ; mv flist_ip_temp.txt flist_ip.txt ;sed -i '1 i\\dummy_line_added 1 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 2 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 3 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 4 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 5 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 6 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 7 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 8 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 9 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 10 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;cat -n flist_ip.txt | sort -u -t' ' -k11,11 | sort -nk1 | cut -f2- > flist_ip_temp.txt;sed 's/ \\./\\./g' flist_ip_temp.txt > flist_ip.txt;sed -i '/dummy_line_added/d' flist_ip.txt;sed 's/.*QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp1_ed/g' flist_ip.txt > flist_ip_temp.txt;sed 's/.*QSYS_SIMDIR/\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp1_ed\\/sim/g' flist_ip_temp.txt > flist_ip.txt;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;cat flist_ip_temp.txt >> filelist_t1ip.txt; find $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/ -type d > temp_f1.txt; sed 's/.*hardware_test_design/+incdir+\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f_hwd.f; find $opt_rundir/qpds_ed_rtl_t1ip/hardware_test_design/ -name \"*.sv\" -o -name \"*.v\" > temp_f1.txt; sed 's/.*hardware_test_design/\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f2.txt; grep \"pkg\" temp_f2.txt >> temp_f_hwd.f;grep \"parameters\" temp_f2.txt >> temp_f_hwd.f; sed 's/.*pkg.*//g' temp_f2.txt > temp_sed_f.txt; sed 's/.*parameters.*//g' temp_sed_f.txt >> temp_f_hwd.f; sed 's/.*\\/synth.*//g' temp_f_hwd.f > temp_f_hwd_f.f ; sed 's/.*_bb\\..*//g' temp_f_hwd_f.f > temp_f_hwd_f2.f; sed 's/.*_inst\\..*//g' temp_f_hwd_f2.f > temp_f_hwd_f3.f; rm -fr temp_f1.txt temp_f2.txt ; cat temp_f_hwd_f3.f >> filelist_t1ip.txt; mkdir -p rtl_filelist;mv filelist_t1ip.txt rtl_filelist/filelist_t1ip.f;cp $t_path_dir/qpds_rtl_ref/filelist/filelist_cxlip_lib.f rtl_filelist/.;grep \"altera_dcfifo_synchronizer_bundle\" $opt_rundir/qpds_ed_rtl_t1ip/intel_rtile_cxl_top_cxltyp1_ed -r | grep \"module\" | grep \"sim\" | grep \"cxl_io_slave\"  > rtl_filelist/avmm_interconnect.f;sed 's/:module.*//g' rtl_filelist/avmm_interconnect.f > rtl_filelist/avmm_interconnect2.f;rm -fr rtl_filelist/avmm_interconnect.f; mv rtl_filelist/avmm_interconnect2.f rtl_filelist/avmm_interconnect.f;mv rtl_filelist $opt_rundir/qpds_ed_rtl_t1ip/filelist; rm -rf flist_ip.txt temp_f_hwd.f flist_ip_temp.txt ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          #For 4slice
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
          $sh_cmd = "mv $opt_rundir/qpds_ed_rtl_t1ip/filelist $opt_rundir/qpds_ed_rtl_t1ip/filelist_4s; ";
          
          system($sh_cmd);
          }
    
          #Local RTL Copy
          $l_r_path_dir = "$opt_rundir/qpds_ed_rtl_t1ip/";
       }
       if ($opt_c_defines =~ /(T2IP)/) {
          #Prepare the RTL Filelist from the Quartus generated RTL
          $sh_cmd = "rm -fr $opt_rundir/qpds_ed_rtl_t2ip;cp -fr $l_r_path_dir $opt_rundir/qpds_ed_rtl_t2ip;";
    #rm -fr $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/ccv_afu/ccv_afu_cdc_fifo_vcd.v;rm -fr $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/ccv_afu/mwae_poison_injection.sv ;rm -fr $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/afu/afu_top.sv ;rm -fr $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/afu/afu_csr_avmm_slave.sv ;cp -fr $t_path_dir/qpds_rtl_ref/ccv_afu_cdc_fifo_vcd.v $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/ccv_afu/ccv_afu_cdc_fifo_vcd.v;cp -fr $t_path_dir/qpds_rtl_ref/mwae_poison_injection.sv $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/ccv_afu/mwae_poison_injection.sv ;cp -fr $t_path_dir/qpds_rtl_ref/afu_top.sv $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/afu/afu_top.sv ;cp -fr $t_path_dir/qpds_rtl_ref/afu_csr_avmm_slave.sv $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/common/afu/afu_csr_avmm_slave.sv ;";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist cleanup is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ###for incdir
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t2ip/intel_rtile_cxl_top_cxltyp2_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/+incdir/\\n +incdir/g' flist_ip.txt > flist_ip_temp.txt;sed 's/ dict set design_files \"//g' flist_ip_temp.txt > flist_ip.txt ;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;sed 's/\\\\//g' flist_ip_temp.txt > flist_ip.txt;sed 's/\$QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp2_ed/g' flist_ip.txt > flist_ip_temp.txt;cat -n flist_ip_temp.txt | sort -uk2 | sort -nk1 | cut -f2- > flist_ip.txt;grep \"incdir\" flist_ip.txt > filelist_t2ip.txt; rm -rf flist_ip.txt flist_ip_temp.txt; ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ##for filelist
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t2ip/intel_rtile_cxl_top_cxltyp2_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/\\./\\ \\./g' flist_ip.txt > flist_ip_temp.txt;rm -fr flist_ip.txt ; mv flist_ip_temp.txt flist_ip.txt ;sed -i '1 i\\dummy_line_added 1 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 2 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 3 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 4 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 5 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 6 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 7 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 8 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 9 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 10 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;cat -n flist_ip.txt | sort -u -t' ' -k11,11 | sort -nk1 | cut -f2- > flist_ip_temp.txt;sed 's/ \\./\\./g' flist_ip_temp.txt > flist_ip.txt;sed -i '/dummy_line_added/d' flist_ip.txt;sed 's/.*QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp2_ed/g' flist_ip.txt > flist_ip_temp.txt;sed 's/.*QSYS_SIMDIR/\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp2_ed\\/sim/g' flist_ip_temp.txt > flist_ip.txt;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;cat flist_ip_temp.txt >> filelist_t2ip.txt;find $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/ -type d > temp_f1.txt; sed 's/.*hardware_test_design/+incdir+\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f_hwd.f; find $opt_rundir/qpds_ed_rtl_t2ip/hardware_test_design/ -name \"*.sv\" -o -name \"*.v\" > temp_f1.txt; sed 's/.*hardware_test_design/\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f2.txt; grep \"pkg\" temp_f2.txt >> temp_f_hwd.f;grep \"parameters\" temp_f2.txt >> temp_f_hwd.f; sed 's/.*pkg.*//g' temp_f2.txt > temp_sed_f.txt; sed 's/.*parameters.*//g' temp_sed_f.txt >> temp_f_hwd.f; sed 's/.*\\/synth.*//g' temp_f_hwd.f > temp_f_hwd_f.f ; sed 's/.*_bb\\..*//g' temp_f_hwd_f.f > temp_f_hwd_f2.f; sed 's/.*_inst\\..*//g' temp_f_hwd_f2.f > temp_f_hwd_f3.f;sed 's/.*altera_std_synchronizer_nocut\\..*//g' temp_f_hwd_f3.f > temp_f_hwd_f4.f; rm -fr temp_f1.txt temp_f2.txt ; cat temp_f_hwd_f4.f >> filelist_t2ip.txt; mkdir -p rtl_filelist;mv filelist_t2ip.txt rtl_filelist/filelist_t2ip.f;cp $t_path_dir/qpds_rtl_ref/filelist/filelist_cxlip_lib.f rtl_filelist/.;grep \"altera_dcfifo_synchronizer_bundle\" $opt_rundir/qpds_ed_rtl_t2ip/intel_rtile_cxl_top_cxltyp2_ed -r | grep \"module\" | grep \"sim\" | grep \"cxl_io_slave\" > rtl_filelist/avmm_interconnect.f;sed 's/:module.*//g' rtl_filelist/avmm_interconnect.f > rtl_filelist/avmm_interconnect2.f;rm -fr rtl_filelist/avmm_interconnect.f; mv rtl_filelist/avmm_interconnect2.f rtl_filelist/avmm_interconnect.f;mv rtl_filelist $opt_rundir/qpds_ed_rtl_t2ip/filelist; rm -rf flist_ip.txt flist_ip_temp.txt ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          #For 4slice
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
          $sh_cmd = "mv $opt_rundir/qpds_ed_rtl_t2ip/filelist $opt_rundir/qpds_ed_rtl_t2ip/filelist_4s; ";
          
          system($sh_cmd);
          }
    
          #Local RTL Copy
          $l_r_path_dir = "$opt_rundir/qpds_ed_rtl_t2ip/";
       }
       if ($opt_c_defines =~ /(T3IP)/) {
          #Prepare the RTL Filelist from the Quartus generated RTL
          $sh_cmd = "rm -fr $opt_rundir/qpds_ed_rtl_t3ip;cp -fr $l_r_path_dir $opt_rundir/qpds_ed_rtl_t3ip; ";
          
          
          system($sh_cmd);
          
          ###for incdir
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t3ip/intel_rtile_cxl_top_cxltyp3_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/+incdir/\\n +incdir/g' flist_ip.txt > flist_ip_temp.txt;sed 's/ dict set design_files \"//g' flist_ip_temp.txt > flist_ip.txt ;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;sed 's/\\\\//g' flist_ip_temp.txt > flist_ip.txt;sed 's/\$QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp3_ed/g' flist_ip.txt > flist_ip_temp.txt;cat -n flist_ip_temp.txt | sort -uk2 | sort -nk1 | cut -f2- > flist_ip.txt;grep \"incdir\" flist_ip.txt > filelist_t3ip.txt; rm -rf flist_ip.txt flist_ip_temp.txt; ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          ##for filelist
          $sh_cmd = "grep \"dict set design_files\" $opt_rundir/qpds_ed_rtl_t3ip/intel_rtile_cxl_top_cxltyp3_ed/sim/common/vcs_files.tcl > flist_ip.txt;sed 's/\\./\\ \\./g' flist_ip.txt > flist_ip_temp.txt;rm -fr flist_ip.txt ; mv flist_ip_temp.txt flist_ip.txt ;sed -i '1 i\\dummy_line_added 1 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 2 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 3 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 4 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 5 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 6 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 7 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 8 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 9 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;sed -i '1 i\\dummy_line_added 10 1 \\n dummy_line_added 2 \\n dummy_line_added 3 \\n dummy_line_added 4 \\n dummy_line_added 5 \\n dummy_line_added 6 \\n dummy_line_added 7 \\n dummy_line_added 8 \\n dummy_line_added 9 \\n dummy_line_added 10 \\n' flist_ip.txt;cat -n flist_ip.txt | sort -u -t' ' -k11,11 | sort -nk1 | cut -f2- > flist_ip_temp.txt;sed 's/ \\./\\./g' flist_ip_temp.txt > flist_ip.txt;sed -i '/dummy_line_added/d' flist_ip.txt;sed 's/.*QSYS_SIMDIR\\/\\.\\./\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp3_ed/g' flist_ip.txt > flist_ip_temp.txt;sed 's/.*QSYS_SIMDIR/\\.\\.\\/\\.\\.\\/intel_rtile_cxl_top_cxltyp3_ed\\/sim/g' flist_ip_temp.txt > flist_ip.txt;sed 's/\".*//g' flist_ip.txt > flist_ip_temp.txt;cat flist_ip_temp.txt >> filelist_t3ip.txt;find $opt_rundir/qpds_ed_rtl_t3ip/hardware_test_design/ -type d > temp_f1.txt; sed 's/.*hardware_test_design/+incdir+\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f_hwd.f; find $opt_rundir/qpds_ed_rtl_t3ip/hardware_test_design/ -name \"*.sv\" -o -name \"*.v\" > temp_f1.txt; sed 's/.*hardware_test_design/\\.\\.\\/\\.\\.\\/hardware_test_design/g' temp_f1.txt > temp_f2.txt; grep \"pkg\" temp_f2.txt >> temp_f_hwd.f;grep \"parameters\" temp_f2.txt >> temp_f_hwd.f; sed 's/.*pkg.*//g' temp_f2.txt > temp_sed_f.txt; sed 's/.*parameters.*//g' temp_sed_f.txt >> temp_f_hwd.f; sed 's/.*\\/synth.*//g' temp_f_hwd.f > temp_f_hwd_f.f ; sed 's/.*_bb\\..*//g' temp_f_hwd_f.f > temp_f_hwd_f2.f; sed 's/.*_inst\\..*//g' temp_f_hwd_f2.f > temp_f_hwd_f3.f;sed 's/.*altera_std_synchronizer_nocut\\..*//g' temp_f_hwd_f3.f > temp_f_hwd_f4.f; rm -fr temp_f1.txt temp_f2.txt ; cat temp_f_hwd_f4.f >> filelist_t3ip.txt; mkdir -p rtl_filelist;mv filelist_t3ip.txt rtl_filelist/filelist_t3ip.f;cp $t_path_dir/qpds_rtl_ref/filelist/filelist_cxlip_lib.f rtl_filelist/.;grep \"altera_dcfifo_synchronizer_bundle\" $opt_rundir/qpds_ed_rtl_t3ip/intel_rtile_cxl_top_cxltyp3_ed -r | grep \"module\" | grep \"sim\" | grep \"cxl_io_slave\"  > rtl_filelist/avmm_interconnect.f;sed 's/:module.*//g' rtl_filelist/avmm_interconnect.f > rtl_filelist/avmm_interconnect2.f;rm -fr rtl_filelist/avmm_interconnect.f; mv rtl_filelist/avmm_interconnect2.f rtl_filelist/avmm_interconnect.f;mv rtl_filelist $opt_rundir/qpds_ed_rtl_t3ip/filelist; rm -rf flist_ip.txt flist_ip_temp.txt ";
          $script_debug_log .= print_i_d("Shell Command to setup Filelist incdir is $sh_cmd",$opt_debug); 
          
          system($sh_cmd);
          
          #For 4slice
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
          $sh_cmd = "mv $opt_rundir/qpds_ed_rtl_t3ip/filelist $opt_rundir/qpds_ed_rtl_t3ip/filelist_4s; ";
          
          system($sh_cmd);
          }
    
          #Local RTL Copy
          $l_r_path_dir = "$opt_rundir/qpds_ed_rtl_t3ip/";
       }
    }
        
    ##ED Generated RTL Filelist exists
    if ($rtl_filelist_gen =~ /(QPDS_ED_FLIST_RDY)/) {  
        if($opt_c_defines =~ /(REPO)/) {
            $sh_cmd = "rm -fr $opt_rundir/qpds_ed_flist; cp -fr $l_r_path_dir/rtlcompchk/filelist/ $opt_rundir/qpds_ed_flist;";
        } else {
            $sh_cmd = "rm -fr $opt_rundir/qpds_ed_flist; cp -fr $l_r_path_dir/sim_filelist $opt_rundir/qpds_ed_flist;";
        }

        $script_debug_log .= print_i_d("Shell command to update filelist is:$sh_cmd",$opt_debug);
        system($sh_cmd);
        $l_r_path_dir = "$opt_rundir/qpds_ed_flist/";
    }
}

##do compile_ip for all th IP Filelists
if($opt_cmd =~ /(ip_comp)|(all)|(ip_comp_dtl)|(full_dtl_save)/) {

    my $libname;
    my $r_filelist_path;

    ## From RTL release filelist path

    if ($rtl_filelist_gen =~ /(QPDS_ED_FLIST_RDY)/) {  
       $r_filelist_path = $l_r_path_dir;
    } elsif ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
       $r_filelist_path = $l_r_path_dir . "/filelist_4s/";
    } else {
       $r_filelist_path = $l_r_path_dir . "/filelist/";
    }

    $script_debug_log .= print_i_d("IP Filelist path is: $r_filelist_path",$opt_debug);

    my @ip_filelists;
    my @ip_all_flist = get_dir_ls($r_filelist_path,$opt_debug);
    for(my $j=0; $j<=5;$j=$j+1) {
        for(my $i=0; $i<=$#ip_all_flist;$i=$i+1) {
            my $l_ip_f = `realpath $ip_all_flist[$i]`;
            chomp $l_ip_f;
            if($j =~ /(0)/){
                if($l_ip_f =~ /(\b\/cxlbasehip_lib_1\.f\b$)|(\b\/cxl_memexp_lib_1\.f\b$)|(\b\/cxl_t2ip_top_lib_1\.f\b$)|(\b\/lvf_sip_lib_1\.f\b$)|(\b\/cxl_memexp_sip_top\.f\b$)|(\b\/filelist_t2ip_lib\.f\b$)|(\b\/filelist_t3ip_lib\.f\b$)|(\b\/filelist_cxlip_lib\.f\b$)|(\b\/cxltyp1_ed_lib_1\.f\b$)/) {
                  push (@ip_filelists ,$ip_all_flist[$i])
                }
            }
            if($j =~ /(1)/){
                if ($l_ip_f =~ /(\b\/cxl_t2ip_top_4\.f\b$)|(\b\/cxl_t2ip_top_slice_based_4\.f\b$)|(\b\/cxlbasehip_top_4\.f\b$)|(\b\/cxl_memexp_top_4\.f\b$)|(\b\/cxl_memexp_top_slice_based_4\.f\b$)|(\b\/lvf_sip_top_wrapper_4\.f\b$)|(\b\/filelist_t1ip\.f\b$)|(\b\/filelist_t2ip\.f\b$)|(\b\/filelist_t3ip\.f\b$)|(\b\/cxltyp1_ed_4\.f\b$)|(\b\/cxltyp1_ed_slice_based_4\.f\b$)/) {
                  push (@ip_filelists ,$ip_all_flist[$i])
                }
                if ($opt_c_defines =~ /(SIM_REVB_DEVKIT)/) {
                   if ($l_ip_f =~ /(\b\/ed_ip_emif_filelist\.f\b$)/) {
                     push (@ip_filelists ,$ip_all_flist[$i])
                   }
                }
            }
            if($j =~ /(2)/){
                if ($l_ip_f =~ /(\b\/qhip_lib_2\.f\b$)|(\b\/rtile_cxl_ip\.f\b$)|(\b\/filelist\.f\b$)|(\b\/eda_lib\.f\b$)/) {
                  push (@ip_filelists ,$ip_all_flist[$i])
                }
            }
            if($j =~ /(3)/){
                if ($l_ip_f =~ /(\b\/avmm_interconnect\.f\b$)/) {
                  push (@ip_filelists ,$ip_all_flist[$i])
                }
            }
            if($j =~ /(4)/){
                if ($l_ip_f =~ /(\b\/mem_model_tb\.f\b$)/) {
                  push (@ip_filelists ,$ip_all_flist[$i])
                }
            }
        }
    }
    $script_debug_log .= print_i_d("IP Filelists are: @ip_filelists",$opt_debug);

    my $abs_f_path;
    for(my $i=0; $i<=$#ip_filelists;$i=$i+1) {
        my $l_ip_f = `realpath $ip_filelists[$i]`;
        chomp $l_ip_f;
       {
            $libname = $ip_filelists[$i];
            chomp $libname;
            $libname =~ s/\.f\b//gi;
            $libname =~ s/.*\///gi;
            $libname =~ s/filelist/lib/g;
            my $append_vcs_setup_str .= modify_vcs_setup_file($opt_rundir,$libname,$opt_debug);
            my $ip_f_num = $i;

            if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
                $abs_f_path = get_abs_path($l_r_path_dir,$l_ip_f,$opt_rundir,"int_4s_$i"."_",$opt_debug);
            } else {
                $abs_f_path = get_abs_path($l_r_path_dir,$l_ip_f,$opt_rundir,"int_$i"."_",$opt_debug);
            }

            $vcs_setup_content .= $append_vcs_setup_str;
            create_file($vcs_setup_fname,$vcs_setup_content);

            print_i("Please refer $opt_rundir for \"compile_ip_$ip_f_num.log\"");
            $log_f = "compile_ip_$ip_f_num.log";
            if($opt_cmd =~ /(ip_comp_dtl)|(full_dtl_save)/) {
                $sh_cmd = "xterm -e \"cd $opt_rundir; make compile_dtl_ip CXL_TOP_DIR=$t_path_dir PRJ_IP_FILELIST=$abs_f_path WORK_DIR=$opt_rundir LOGNAME=$log_f LIBNAME=$libname PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
            } elsif($opt_cmd =~ /(ip_comp)|(all)/) {
                $sh_cmd = "xterm -e \"cd $opt_rundir; make compile_ip CXL_TOP_DIR=$t_path_dir PRJ_IP_FILELIST=$abs_f_path WORK_DIR=$opt_rundir LOGNAME=$log_f LIBNAME=$libname PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
            }
            $script_debug_log .= print_i_d("Shell command to compile IP is:$sh_cmd",$opt_debug);
            system("$sh_cmd");

            $stage = "IP Compilation $i";
            $full_log_f = $opt_rundir . "/" . $log_f;
            if(defined $opt_debug) {
                $fail_sigs = check_for_failure($full_log_f, $opt_debug);
                if($fail_sigs ne '') {
                    print_w("Error Signatures found in the $full_log_f from the execution of $stage .");
                } else {
                    print_i("No Error Signatures found in the $full_log_f . $stage Passed!");
                }
            }
        }
    }

}

##do compile_tb for all th TB Filelists
if($opt_cmd =~ /(tb_comp_dtl_restore)|(full_dtl_restore)/) {

    my $libname;

    my $t_filelist_path = $t_path_dir . "/filelist/";
    $script_debug_log .= print_i_d("TB Filelist path is: $t_filelist_path",$opt_debug);
    
    my @tb_filelists = get_dir_ls($t_filelist_path,$opt_debug);
    for(my $i=0; $i<=$#tb_filelists;$i=$i+1) {
        my $l_tb_f = `realpath $tb_filelists[$i]`;
        chomp $l_tb_f;
        if($l_tb_f =~ /\b\/tb_dtl_filelist\.f\b$/) {
            $libname = $tb_filelists[$i];
            chomp $libname;
            $libname =~ s/\.f\b//gi;
            $libname =~ s/.*\///gi;
            $libname =~ s/filelist/lib/g;
            my $append_vcs_setup_str .= modify_vcs_setup_file($opt_rundir,$libname,$opt_debug);
            my $tb_f_num = $i - 2;

            append_file($vcs_setup_fname,$append_vcs_setup_str);

            print_i("Please refer $opt_rundir for \"compile_tb_dtl_restore_$tb_f_num.log\"");
            $log_f = "compile_tb_dtl_restore_$tb_f_num.log";
            $sh_cmd = "xterm -e \"cd $opt_rundir; make compile_dtl_restore_tb PRJ_TB_FILELIST=$l_tb_f CXL_TOP_DIR=$t_path_dir TOP_MODULE=$top_module WORK_DIR=$opt_rundir LOGNAME=$log_f LIBNAME=$libname PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
            $script_debug_log .= print_i_d("Shell command to compile TB is:$sh_cmd",$opt_debug);
            system("$sh_cmd");
            $stage = "TB Compilation $tb_f_num";
            $full_log_f = $opt_rundir . "/" . $log_f;
            if(defined $opt_debug) {
                $fail_sigs = check_for_failure($full_log_f, $opt_debug);
                if($fail_sigs ne '') {
                    print_w("Error Signatures found in the $full_log_f from the execution of $stage .");
                } else {
                    print_i("No Error Signatures found in the $full_log_f . $stage Passed!");
                }
            }
        }
    }
}elsif($opt_cmd =~ /(tb_comp)|(all)|(tb_comp_dtl_save)|(full_dtl_save)/) {

    my $libname;

    my $t_filelist_path = $t_path_dir . "/filelist/";
    $script_debug_log .= print_i_d("TB Filelist path is: $t_filelist_path",$opt_debug);
    
    my @tb_filelists = get_dir_ls($t_filelist_path,$opt_debug);

    for(my $i=0; $i<=$#tb_filelists;$i=$i+1) {
        my $l_tb_f = `realpath $tb_filelists[$i]`;
        chomp $l_tb_f;
        if($l_tb_f =~ /\b\/tb_filelist\.f\b$/) {
            $libname = $tb_filelists[$i];
            chomp $libname;
            $libname =~ s/\.f\b//gi;
            $libname =~ s/.*\///gi;
            $libname =~ s/filelist/lib/g;
            my $append_vcs_setup_str .= modify_vcs_setup_file($opt_rundir,$libname,$opt_debug);
            my $tb_f_num = $i - 2;

            append_file($vcs_setup_fname,$append_vcs_setup_str);

            if($opt_cmd =~ /(tb_comp_dtl_save)|(full_dtl_save)/) {
               print_i("Please refer $opt_rundir for \"compile_dtl_save_tb_$tb_f_num.log\"");
               $log_f = "compile_tb_dtl_save_$tb_f_num.log";
               $sh_cmd = "xterm -e \"cd $opt_rundir; make compile_dtl_save_tb PRJ_TB_FILELIST=$l_tb_f CXL_TOP_DIR=$t_path_dir TOP_MODULE=$top_module WORK_DIR=$opt_rundir LOGNAME=$log_f LIBNAME=$libname PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
            }elsif($opt_cmd =~ /(tb_comp)|(all)/) {
               print_i("Please refer $opt_rundir for \"compile_tb_$tb_f_num.log\"");
               $log_f = "compile_tb_$tb_f_num.log";
               $sh_cmd = "xterm -e \"cd $opt_rundir; make compile_tb PRJ_TB_FILELIST=$l_tb_f CXL_TOP_DIR=$t_path_dir TOP_MODULE=$top_module WORK_DIR=$opt_rundir LOGNAME=$log_f LIBNAME=$libname PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
            }
            $script_debug_log .= print_i_d("Shell command to compile TB is:$sh_cmd",$opt_debug);
            system("$sh_cmd");
            $stage = "TB Compilation $tb_f_num";
            $full_log_f = $opt_rundir . "/" . $log_f;
            if(defined $opt_debug) {
                $fail_sigs = check_for_failure($full_log_f, $opt_debug);
                if($fail_sigs ne '') {
                    print_w("Error Signatures found in the $full_log_f from the execution of $stage .");
                } else {
                    print_i("No Error Signatures found in the $full_log_f . $stage Passed!");
                }
            }
        }
    }
}

##do elab for the TOP_MODULE on the compiled library at WORKDIR
my $elab_log_fname;
if($opt_cmd =~ /(elab_dtl_save)|(full_dtl_save)/) {
    $elab_log_fname = "elab_dtl_save.log";
    print_i("Please refer $opt_rundir for \"$elab_log_fname\"");
    $sh_cmd = "xterm -e \"cd $opt_rundir; make elab_dtl_save TOP_MODULE_CFG=$top_module_cfg WORK_DIR=$opt_rundir\;\"";
    $script_debug_log .= print_i_d("Shell command to elab_dtl_save is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
}elsif($opt_cmd =~ /(elab_dtl_restore)|(full_dtl_restore)/) {
    $elab_log_fname = "elab_dtl_restore.log";
    print_i("Please refer $opt_rundir for \"$elab_log_fname\"");
    $sh_cmd = "xterm -e \"cd $opt_rundir; make elab_dtl_restore TOP_MODULE_CFG=$top_module_cfg WORK_DIR=$opt_rundir\;\"";
    $script_debug_log .= print_i_d("Shell command to elab_dtl_restore is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
}elsif($opt_cmd =~ /(elab)|(run_all)/) {
    $elab_log_fname = "elab.log";
    print_i("Please refer $opt_rundir for \"$elab_log_fname\"");
    $sh_cmd = "xterm -e \"cd $opt_rundir; make elab TOP_MODULE_CFG=$top_module_cfg WORK_DIR=$opt_rundir\;\"";
    $script_debug_log .= print_i_d("Shell command to elab is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
}

if($opt_cmd =~ /(elab)|(full)|(all)/) {
    $stage = "Elaboration";
    $full_log_f = $opt_rundir . "/" . $elab_log_fname;
    if(defined $opt_debug) {
        $fail_sigs = check_for_failure($full_log_f, $opt_debug);
        if($fail_sigs ne '') {
            print_w("Error Signatures found in the $full_log_f from the execution of $stage .");
        } else {
            print_i("No Error Signatures found in the $full_log_f . $stage Passed!");
        }
    }
}

##do VCS Sim w/o dump for elaborated library at WORKDIR
my $sim_log_fname;
if($opt_cmd =~ /(questa_run_d)/) {
    $sim_log_fname = "mti.log";
    print_i("Please refer $opt_rundir for \"mti.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $prj_sim_defines_d = "+APCI_DUMP_WLF";
    $sh_cmd = "xterm -e \"mkdir -p $opt_rundir\; cd $opt_rundir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make questa_run CXL_TOP_DIR=$t_path_dir E_PRJ_SIM_DEFINES=$prj_sim_defines_d CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
    $script_debug_log .= print_i_d("Shell command to questa_run_d is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(questa_run)/) {
    $sim_log_fname = "mti.log";
    print_i("Please refer $opt_rundir for \"mti.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $sh_cmd = "xterm -e \"mkdir -p $opt_rundir\; cd $opt_rundir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make questa_run CXL_TOP_DIR=$t_path_dir CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args PRJ_CMP_DEFINES=$prj_cmp_defines\;\"";
    $script_debug_log .= print_i_d("Shell command to questa_run is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim_dtl_save_d)|(full_dtl_save_d)/) {
    $sim_log_fname = "sim.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $prj_sim_defines_d = "+APCI_DUMP_FSDB";
    $sh_cmd = "xterm -e \"mkdir -p $opt_rundir\/SNPS_SAVE\; cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim_dtl_save_d CXL_TOP_DIR=$t_path_dir E_PRJ_SIM_DEFINES=$prj_sim_defines_d CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim_dtl_restore_d)|(full_dtl_restore_d)/) {
    $sim_log_fname = "sim_restore.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $prj_sim_defines_d = "+APCI_DUMP_FSDB";
    $sh_cmd = "xterm -e \"cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim_dtl_restore_d CXL_TOP_DIR=$t_path_dir E_PRJ_SIM_DEFINES=$prj_sim_defines_d CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim_dtl_save)|(full_dtl_save)/) {
    $sim_log_fname = "sim.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $sh_cmd = "xterm -e \"mkdir -p $opt_rundir\/SNPS_SAVE\; cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim_dtl_save CXL_TOP_DIR=$t_path_dir CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim_dtl_restore)|(full_dtl_restore)/) {
    $sim_log_fname = "sim_restore.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $sh_cmd = "xterm -e \"cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim_dtl_restore CXL_TOP_DIR=$t_path_dir CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim_d)|(run_all_d)/) {
    $sim_log_fname = "sim.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $prj_sim_defines_d = "+APCI_DUMP_FSDB";
    $sh_cmd = "xterm -e \"cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim_d CXL_TOP_DIR=$t_path_dir E_PRJ_SIM_DEFINES=$prj_sim_defines_d CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} elsif($opt_cmd =~ /(sim)|(run_all)/) {
    $sim_log_fname = "sim.log";
    print_i("Please refer $opt_rundir\/$opt_simdir for \"sim.log\"");
    $qhip_rtl_path = get_qhip_rtl_path($r_path_dir, $opt_debug);
    $sh_cmd = "xterm -e \"cd $opt_rundir\/$opt_simdir\; cp -n $scripts_path_Makefile $opt_rundir\/$opt_simdir\;";
    $sh_cmd .= set_sim($r_path_dir,"$opt_rundir\/$opt_simdir",$opt_debug) if($opt_c_defines !~ /BASE_IP/);
    $sh_cmd .= "make sim CXL_TOP_DIR=$t_path_dir CXL_TILE_RTL_PATH=$qhip_rtl_path WORK_DIR=$opt_rundir PRJ_SIM_ARGS=$prj_sim_args SIM_DIR_NAME=$opt_simdir\;\"";
    $script_debug_log .= print_i_d("Shell command to sim is:$sh_cmd",$opt_debug);
    system("$sh_cmd");
} 

if($opt_cmd =~ /(sim)|(full)|(all)/) {
    $stage = "Simulation";
    $full_log_f = $opt_rundir . '/' . $opt_simdir . "/" . $sim_log_fname;
    $fail_sigs = check_for_failure($full_log_f, $opt_debug);
    if($fail_sigs ne '') {
        print_e("Error Signatures found in the $full_log_f from the execution of $stage .");
        exit;
    } else {
        print_i("No Error Signatures found in the $full_log_f . $stage Passed!");
    }
}


print "\n";
print_i("All requested \"-cmd\" options are executed and completed. Please refer respective logs at $opt_rundir.");
print "\n";

my $filename = $opt_rundir . '/' . $opt_simdir .'/' . $PROGNAME;
$filename =~ s/\.pl/_debug.log/;
if(defined $opt_debug) {
    print_dbg_file($filename,$script_debug_log);
} else {
    print_dbg_file($filename,$my_base_log_content);
}

my $end_time = time();
my $run_time = $end_time -$start_time;
if(!$status) {
  print_i("Script completed the execution successfully in $run_time seconds. The output is at $opt_rundir. Please refer log files \".log\" under $opt_rundir .");
} else {
  print_e("Script completed the execution un-successfully which ran for $run_time seconds. Please review the flow of the script with \"-debug\" option enabled.");
}
exit;


################################################################################
# Subroutines
################################################################################
sub check_for_failure{
    my ($logfile, $opt_debug) = @_;

    chomp $logfile;
    my $out_postproc_fail_log = $logfile;
    my $out_postproc_pass_log = $logfile;
    $out_postproc_fail_log =~ s/\.log/\.FAIL/;
    $out_postproc_pass_log =~ s/\.log/\.PASS/;

    my $test_pass = 0;
    my $test_fail = 0;
    my $output = "";
    my $sh_cmd = "rm -rf $out_postproc_fail_log $out_postproc_pass_log; grep -i \"error\\\|fatal\\\|warning\\\|fail\" $logfile \|sort -u";
    print_i_d("Shell Command to check failure in $logfile is: $sh_cmd",$opt_debug);
    $output = `$sh_cmd`;

    ##Note: Add the waiver keywords here.
    ##Compile Waivers
    $output =~ s/^Warning-.*\n//mg;
    $output =~ s/.*warning will disappear.*\n//mg;
    $output =~ s/.*assert enable_diag.*svaext.*\n//mg;
    $output =~ s/^Back to file.*\n//mg;
    $output =~ s/^Parsing design file.*\n//mg;
    $output =~ s/.*Ignoring axi2cpi_errors_pkg.*\n//mg;
    $output =~ s/.*Package.*axi2cpi_errors_pkg.*already wildcard imported.*\n//mg;
    $output =~ s/.*error in a future.*\n//mg;
    $output =~ s/.*this will be an error.*\n//mg;

    ##Elab Waivers
    $output =~ s/^Verdi KDB elaboration done.*\n//mg;
    $output =~ s/.*warnElog failElog fatalElog.*\n//mg;
    $output =~ s/.*\+error\+1000.*\n//mg;
    $output =~ s/.*liberrorinf.*\n//mg;
    $output =~ s/^-lnuma -lerrorinf.*\n//mg;
    $output =~ s/.*\.load_DEVICE_ERROR_LOG3.*\n//mg;
    $output =~ s/^\/p\/psg\/eda\/synopsys\/vcsmx\/.*\/linux64\/suse\/linux64\/bin\/comelab .*\n//mg;
    $output =~ s/^Makefile.*\n//mg;
    $output =~ s/^recompiling.*\n//mg;
    $output =~ s/^recompiling.*\n//mg;
    $output =~ s/^recompiling.*\n//mg;
    $output =~ s/^recompiling.*\n//mg;
    $output =~ s/^\.user2ip_cxlreset_initiate.*ip2usr_cxlreset_error.*\n//mg;
    $output =~ s/^GEN_CHAN_COUNT_EMIF.*\n//mg;
    $output =~ s/^\(ip2usr_cxlreset_error.*\n//mg;
    $output =~ s/^\(.*\.ip2usr_cxlreset_error.*\n//mg;
    $output =~ s/^cxlbasehip_top.*\.ip2uio_pm_p1_gpf_pwr_fail_emminent.*\n//mg;
    $output =~ s/^cxlbasehip_top.*\.ip2usr_cxlreset_error.*\n//mg;
    $output =~ s/.*lerrorinf.*\n//mg;
    $output =~ s/^  output port \'bbs_error_det\' is not connected.*\n//mg;
    $output =~ s/^ the VCS_LIC_EXPIRE_WARNING environment variable to the number of days.*\n//mg;
    $output =~ s/^\(HdmRdCmpAttrRam_IDs_available\),  \.error \(HdmRdCmpAttrRam_error\).*\n//mg;
    $output =~ s/^\(HdmWrCmpAttrRam_IDs_available\),  \.error \(HdmWrCmpAttrRam_error\).*\n//mg;
    $output =~ s/^Warning.*\n//mg;
    $output =~ s/^bbs_fme_top.*\.load_BBS_ERRORINJ_STATUS.*\n//mg;
    $output =~ s/^genBufIdFifo.*\.fifo_err.*\n//mg;
    $output =~ s/^make.*Warning.*\n//mg;
    $output =~ s/.*_error.*\n//mg;
    $output =~ s/.*warning.*Clock skew detected.*\n//mg;
    $output =~ s/.*\.error \(.*\n//mg;
    $output =~ s/.*\.load_Uncorrectable_Error_S.*\n//mg;
    $output =~ s/.*ld: warning:.*\n//mg;

    ##Sim Waivers
    $output =~ s/^Warning-.*\n//mg;
    $output =~ s/^UVM_INFO.*\n//mg;
    $output =~ s/^Number of.*\n//mg;
    $output =~ s/^UVM_WARNING :.*\n//mg;
    $output =~ s/^UVM_ERROR :.*\n//mg;
    $output =~ s/^UVM_FATAL :.*\n//mg;
    $output =~ s/^\[AVY_ERROR\].*\n//mg;
    $output =~ s/^== csr_ltssmerrsts0\[0\]\.speedchangefail = 0 .*\n//mg;
    $output =~ s/^cxl_tb_top.*\n//mg;
    $output =~ s/^Command.*\n//mg;
    $output =~ s/.*SpeedFailState=0\/00000.*\n//mg;
    $output =~ s/.*WARNING: Attempting to read from uninitialized location.*\n//mg;

    my $return_val;
    if ($output eq '') {
        if($out_postproc_pass_log =~ /sim\.log\|sim_restore\.log/) {
            $return_val = grep_file_content($out_postproc_pass_log,"Test Passed",$opt_debug);
            if(defined $return_val){
                $test_pass = 1;
                create_file($out_postproc_pass_log,$return_val);
            } else {
                $test_fail = 1;
                create_file($out_postproc_fail_log,"Pass signature not found in $logfile");
            }
        } else {
            create_file($out_postproc_pass_log,$return_val);
        }
    } else {
        create_file($out_postproc_fail_log,$output);
    }
    return $output;

}

sub do_hotfix{
    my ($r_path, $t_path, $var, $opt_debug) = @_;
    my $hotfix_filepath;
    if($var =~ /1S/) {
        $hotfix_filepath = $t_path . "/hotfix/1S/";
    } elsif ($var =~ /2S/) {
        $hotfix_filepath = $t_path . "/hotfix/2S/";
    } elsif ($var =~ /4S/) {
        $hotfix_filepath = $t_path . "/hotfix/4S/";
    }
    my @temp_hotfix_files = get_dir_ls($hotfix_filepath, $opt_debug);
    my @hotfix_files;
    print_i_d("Hotfix directory contains - @temp_hotfix_files",$opt_debug);
    foreach my $idx (@temp_hotfix_files) {
        chomp $idx;
        if ($idx !~ /\/\.\.|\/\./) {
            $idx =~ s/.*\///g; 
            push(@hotfix_files, $idx);
        }
    }
    print_i_d("Cleaned Hotfix directory contains - @hotfix_files",$opt_debug);

    my $status = 1;
    if (@hotfix_files) {
        foreach my $i (@hotfix_files) {
            my $fname_to_find = $i;
            my $sh_cmd = "find $r_path -name \"$fname_to_find\" -type f;";
            print_i_d("Shell Command to find file - $fname_to_find at directory - $r_path is $sh_cmd",$opt_debug);
            my @cmd_output = `$sh_cmd`;
            print_i_d("Command output - @cmd_output",$opt_debug);
            foreach my $idx (@cmd_output) {
                chomp $idx;
                my $sh_cmd = "cp -rf $hotfix_filepath" . "/" . "$fname_to_find $idx;";
                print_i_d("Shell Command to overwrite file - $fname_to_find is: $sh_cmd",$opt_debug);
                system($sh_cmd);
                $sh_cmd = "diff -q $hotfix_filepath" . "/" . "$fname_to_find $idx;";
                print_i_d("Shell Command to diff files is: $sh_cmd",$opt_debug);
                $status = `$sh_cmd`;
                print_i_d("Diff output is: $status",$opt_debug);
                if($status eq "") {
                    print_i("Merge successfully done between hotfix file:$fname_to_find and RTL:$idx");
                } else {
                    print_e("Merge successfully not done between $fname_to_find and $idx . Please check the files to merge.");
                }
            }
        }
    }
    else {
        print_e("Nothing specified in the $hotfix_filepath to patch into the $r_path . Please go through the help statement using the \"-help\" switch.")
    }

}

sub untar_file{
    my ($tar_f,$output_d,$opt_debug) = @_;

    $output_d = `realpath $output_d`;
    chomp $output_d;
    my $sh_cmd = "rm -rf $output_d; mkdir $output_d; tar -xvf $tar_f -C $output_d;";
    print_i_d("Shell Command to untar file - $tar_f at directory - $output_d is $sh_cmd");
    my $stdout = `$sh_cmd`;
}

sub append_file{
    my ($filename,$string,$opt_debug) = @_;

    $script_debug_log .= print_i_d("File appending data is:$filename",$opt_debug);

    open(my $fh, '>>:encoding(UTF-8)', $filename)
    or die_error("Could not open file Filename:'$filename' $!");
    
    print {$fh} $string;
    
    close $fh;
}

sub create_file{
    my ($filename,$string,$opt_debug) = @_;

    $script_debug_log .= print_i_d("File created is:$filename",$opt_debug);;

    system("rm -rf $filename");
    open(my $fh, '>:encoding(UTF-8)', $filename)
    or die_error("Could not open file Filename:'$filename' $!");
    
    if (defined $string) {
        print {$fh} $string;
    }
    
    close $fh;

}

sub modify_vcs_setup_file{
    my ($rundir,$lib_name,$opt_debug) = @_;

    my $str_to_append;
    $str_to_append .= "$lib_name:\t\t\t$rundir" . "\/libs\/$lib_name\/\n";

    return $str_to_append;

}

sub set_default_vcs_file{
    my ($rundir,$opt_debug) = @_;

    my $str_default;
    $str_default .= "DEFAULT:\t\t\t$rundir" . "\/libs\/work\/\n"; 
    $str_default .= "work:\t\t\t$rundir" . "\/libs\/work\/\n"; 

    return $str_default;

}

sub get_abs_path {
    my ($r_path,$ffile,$o_path,$str,$opt_debug) = @_;
    my $output_abs_ffile = "$o_path/". "$str" . "ip_filelist.f";

    my $fpath;
    if($str =~ /int_4s_/) {
        $fpath = $ffile;
        $script_debug_log .= print_i_d("Fpath bfore is:$fpath",$opt_debug);;
        $fpath =~ s/filelist_4s\/\w+.f//g;
        $script_debug_log .= print_i_d("Fpath is:$fpath",$opt_debug);;
    } elsif($str =~ /int_/) {
        $fpath = $ffile;
        $script_debug_log .= print_i_d("Fpath bfore is:$fpath",$opt_debug);;
        $fpath =~ s/filelist\/\w+.f//g;
        $script_debug_log .= print_i_d("Fpath is:$fpath",$opt_debug);;
    } elsif($str =~ /ext_/) {
        $fpath = $r_path;
        $script_debug_log .= print_i_d("Fpath bfore is:$fpath",$opt_debug);;
        $r_path =~ s/$/\/filelist/g;
        $script_debug_log .= print_i_d("Fpath is:$fpath",$opt_debug);;
    }

    $script_debug_log .= print_i_d("$ffile will replace relative paths",$opt_debug);
    my $sh_cmd = "sed -e 's+\\\.\\\.\/\\\.\\\.\/+$fpath\//+' $ffile >>$output_abs_ffile\;";
    $script_debug_log .= print_i_d("Shell command to abs_path_gen is:$sh_cmd",$opt_debug);;
    system($sh_cmd);
    $script_debug_log .= print_i_d("New IP Filelist is at: $output_abs_ffile",$opt_debug);;

    return $output_abs_ffile;
}

sub set_sim {
    my ($r_path,$rundir,$opt_debug) = @_;
    my $cmd = "find $r_path -type f -name \"\*.hex\"";
    $script_debug_log .= print_i_d("Command to collect all HEX Files from the RTL path is:$cmd",$opt_debug);

    my @hex_files = `$cmd`;
    my @output_statement;
    my $output;
    foreach my $i (@hex_files) {
        chomp $i;
        $i =~ /(.+?)\/(\w+.hex)/;
        my $rundir_hex = $rundir . "\/". $2;
        chomp $rundir_hex;
        $script_debug_log .= print_i_d("Got one HEX File:$rundir_hex",$opt_debug);
        push(@output_statement, "ln -sf $i $rundir_hex\;");
    }

    $output = join('',@output_statement);
    $script_debug_log .= print_i_d("Final hex file link command is:$output",$opt_debug);
    return $output;

}

sub get_qhip_rtl_path {
    my ($r_path,$opt_debug) = @_;
    my $cmd;
    my $rnr_ver;
    my $freq;

    if(defined $ENV{RNR_VER}){
      $rnr_ver = $ENV{RNR_VER};
    }

    if(defined $ENV{FREQ}){
      $freq = $ENV{FREQ};
    }

    if ($opt_c_defines =~ /(QPDS_ED_B0)/) {
       my $r_QHIP_path = $r_path ;
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep \"sim\/common\" | sed 's/lutlen.*//g'|sort -u";
    } elsif ($opt_c_defines =~ /(QPDS_B0A0)/) {
       my $r_QHIP_path = $r_path . "\/Quartus_IPs\/intel_rtile_cxl_top\/";
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
    } elsif ($opt_c_defines =~ /(QHIP_MIRROR_CFG)/) {
       my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io\/";
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
    } elsif ($opt_c_defines =~ /(QPDS_ED)/) {
       my $r_QHIP_path = $r_path . "\/Quartus_IPs\/intel_rtile_cxl_top_0_ed\/";
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
    } elsif ($opt_c_defines =~ /(QPDS)/) {
       my $r_QHIP_path = $r_path . "\/Quartus_IPs\/intel_rtile_cxl_top\/";
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
    } elsif ($opt_c_defines =~ /(REPO)/) {
       if ($opt_c_defines =~ /(CXLTYP3DDR)/) {
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0_slice_based\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } elsif ($opt_c_defines =~ /(QHIP_B0A0)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } else {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          }
       } elsif ($opt_c_defines =~ /(T2IP)/) {
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0_slice_based\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } elsif ($opt_c_defines =~ /(QHIP_B0A0)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } else {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          }
       } elsif ($opt_c_defines =~ /(T1IP)/) {
          if ($opt_c_defines =~ /(QHIP_B0A0)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } else {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          }
       } elsif ($opt_c_defines =~ /(T3IP)/) {
          if ($opt_c_defines =~ /(ENABLE_4_BBS_SLICE)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0_slice_based\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } elsif ($opt_c_defines =~ /(QHIP_B0A0)/) {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io_b0\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          } else {
             my $r_QHIP_path = $r_path . "\/rtl\/subIP\/qhip_csb2io\/";
             $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u";
          }
       }
    } else {
       my $r_QHIP_path = $r_path . "\/Quartus_IPs\/rtile_cxl_ip\/rtile_cxl_ip_$rnr_ver" . "_" . "$freq";
       $cmd = "find $r_QHIP_path -type f -name \"\*.mif\" | grep sim | sed 's/lutlen.*//g'|sort -u|grep -v qhip_nov22|grep synopsys";
    }
    $script_debug_log .= print_i_d("Command to find the MIF path is:$cmd",$opt_debug);
    my $qhip_rtl_path = `$cmd`;
    chomp $qhip_rtl_path;

    $script_debug_log .= print_i_d("CXL_TILE RTL PATH is $qhip_rtl_path",$opt_debug);

    return $qhip_rtl_path;
}

sub grep_file_content {
    my ($file,$pattern,$opt_debug) = @_;
    my @grep_results;
    
    my $filename = $file;
    $filename =~ s/\.gz\Z//g; 
    $script_debug_log .= print_i_d("Updated File for grep is $filename",$opt_debug);
    system("gunzip $file") if ($file =~ /gz/);
    open(my $fh, '<:encoding(UTF-8)', $filename)
    or die_error("Could not open file Filename:'$filename' $!");
    
    while (my $row = <$fh>) {
        chomp $row;
        push (@grep_results ,$row) if ($row =~ /$pattern/);
    }
    close $fh;
    system("gzip $filename") if ($file =~ /gz/);
    my $scalar_grep_results = join("\'\n",@grep_results);
    $script_debug_log .= print_i_d("Grep results for pattern->\'$pattern\' in file->\'$filename\' is \n\'$scalar_grep_results\'",$opt_debug);
    return @grep_results;
}

sub get_dir_ls {
    my ($dir,$verbosity) = @_;  
    opendir my $dh, $dir or die_error("Could not open '$dir' for reading '$!'");
    my @things = readdir $dh;
    closedir $dh;
    for(my $i=0; $i<=$#things;$i=$i+1) {
        $things[$i] = $dir . $things[$i];
    }
    my $scalar_things = join("\n",@things);
    $script_debug_log .= print_i_d("List the dir - $dir:\n$scalar_things",$opt_debug);
    return @things;
}

sub print_i {
    print "$PROGNAME: -I-   ";
    print @_ ;
    print "\n";
}

sub print_dbg_file {
    my ($output_f,$content) = @_;

    $script_debug_log .= print_i_d("Script Debug file will be at $output_f",$opt_debug);

    system("rm -rf $output_f");
    open(my $fh, '>:encoding(UTF-8)', $output_f)
    or die_error("Could not open file Filename:'$output_f' $!");
    
    print {$fh} $content;
    
    close $fh;
}

sub print_i_d {
    my $print_msgs = "";
    $print_msgs .=  "$PROGNAME: -I-   " if ($_[1]);
    $print_msgs .=  $_[0] if ($_[1]) ;
    $print_msgs .=  "\n" if ($_[1]);
    return $print_msgs;
}

sub print_w {
    print "\n";
    print "$PROGNAME: -W-   ";
    print @_ ;
    print "\n";
}

sub print_e {
    print "\n";
    print "$PROGNAME: -E-   ";
    print @_ ;
    print "\n";
}

sub die_error {
    print "\n";
    die "$PROGNAME: -E- ", @_, "\n";
}



#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : compile.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for compiling the simulation design source files
#
# Generated by Vivado on Sun Nov 26 19:31:14 HKT 2023
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: compile.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xvlog --incr --relax -prj sim_top_tb_vlog.prj"
xvlog --incr --relax -prj sim_top_tb_vlog.prj 2>&1 | tee compile.log

echo "xvhdl --incr --relax -prj sim_top_tb_vhdl.prj"
xvhdl --incr --relax -prj sim_top_tb_vhdl.prj 2>&1 | tee -a compile.log


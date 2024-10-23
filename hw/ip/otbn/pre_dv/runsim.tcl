# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set TESTBENCH $1

if {$DEBUG == "ON"} {
    set VOPT_ARG "+acc"
    echo $VOPT_ARG
    set DB_SW "-debugdb"
} else {
    set DB_SW ""
}

if {$COVERAGE == "ON"} {
    set COV_SW -coverage
} else {
    set COV_SW ""
}

vsim -voptargs=$VOPT_ARG $DB_SW $COV_SW -pedanticerrors -lib $LIB $TESTBENCH

if {$DEBUG == "ON"} {
    log -r /*
    add wave -r /dut/*
}

run -a

if {$COVERAGE == "ON"} {
    coverage report -summary -out myreport.txt
    coverage report -html
}

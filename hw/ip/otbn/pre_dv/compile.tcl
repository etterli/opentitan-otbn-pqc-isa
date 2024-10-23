# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set DUT_FILE_LIST $1
set TB_FILE_LIST $2

set DEBUG ON
set COVERAGE OFF

# Set working library.
set LIB work

# If a simulation is loaded, quit it so that it compiles in a clean working library.
set STATUS [runStatus]
if {$STATUS ne "nodesign"} {
    quit -sim
}

# Start with a clean working library.
if { [file exists $LIB] == 1} {
    echo "lib exist"
    file delete -force -- $LIB
}
vlib $LIB

if {$COVERAGE == "ON"} {
    set COV_TYPE bcst
} else {
    set COV_TYPE 0
}

# Compile DUT from file list.
vlog -sv -pedanticerrors -cover $COV_TYPE -work $LIB -f $DUT_FILE_LIST

# Compile TB from file list.
vlog -sv -work $LIB -cover $COV_TYPE -f $TB_FILE_LIST

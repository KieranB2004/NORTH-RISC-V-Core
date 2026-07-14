# -----------------------------------------------------------------------
# Makefile — simulate rtl/core/pc.sv with Verilator, driven by the
# cocotb testbench in test_pc.py.
# -----------------------------------------------------------------------
#
# Prerequisites (see scripts/setup_env.sh for install commands):
#   - Verilator >= 5.036 (older versions are rejected by cocotb >= 2.0
#     for correctness reasons -- see docs/05_verification_plan.md)
#   - Python 3.9+ with cocotb >= 2.0 (pip install "cocotb>=2.0")
#
# Usage:
#   make            # build and run every @cocotb.test() in test_pc.py
#   make WAVES=1    # also dump a waveform (sim_build/dump.vcd) for
#                   # GTKWave / Surfer
#   make clean      # remove simulation build artifacts
#
# This file is intentionally self-contained rather than sharing logic
# with future per-module Makefiles. Once there are two or three modules
# with an identical pattern, that is the right time to factor out a
# common include -- not before, since guessing the shared shape from a
# single example tends to produce the wrong abstraction.

SIM           ?= verilator
TOPLEVEL_LANG ?= verilog

# The RTL file(s) under test.
VERILOG_SOURCES = $(abspath /Users/kieranbrousseau/NORTH-RISC-V-Core/rtl/core/fetch/pc.sv)

# The SystemVerilog module cocotb attaches its testbench to.
COCOTB_TOPLEVEL = pc

# Python test module
COCOTB_TEST_MODULES = test_pc

# Make Python find tests/test_pc.py
PYTHONPATH := $(shell pwd)/sim/cocotb
export PYTHONPATH

# Load cocotb simulation rules
include $(shell cocotb-config --makefiles)/Makefile.sim

# Verilator-specific flags:
#   -Wall               enable Verilator's full lint warning set, so
#                        width mismatches and similar bugs are caught at
#                        compile time rather than in simulation
#   -Wno-DECLFILENAME    this project's file-per-module naming will
#                        diverge from Verilator's default expectation for
#                        a small number of future wrapper files; silence
#                        only that one stylistic warning
ifeq ($(WAVES), 1)
EXTRA_ARGS += --trace --trace-structs
endif
EXTRA_ARGS += -Wall -Wno-DECLFILENAME

# Pull in cocotb's own Makefile machinery, which knows how to invoke
# Verilator, build the simulation executable, and run the Python tests.
include $(shell cocotb-config --makefiles)/Makefile.sim
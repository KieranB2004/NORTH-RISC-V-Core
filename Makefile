# ============================================================
# Verilator Simulation Makefile
# ============================================================

# Top-level SystemVerilog module name
TOP_MODULE = counter

# Source files
RTL_FILES = rtl/counter.sv
TB_FILES  = tb/tb_counter.cpp

# Verilator options
VERILATOR_FLAGS = \
	--cc \
	--exe \
	--build \
	--trace \
	--sv \
	--top-module $(TOP_MODULE)

# Generated executable
EXECUTABLE = obj_dir/V$(TOP_MODULE)


# ============================================================
# Default target
# ============================================================

all: build


# ============================================================
# Compile Verilator simulation
# ============================================================

build:
	verilator $(VERILATOR_FLAGS) $(RTL_FILES) $(TB_FILES)


# ============================================================
# Run simulation
# ============================================================

run: build
	./$(EXECUTABLE)


# ============================================================
# Open waveform
# ============================================================

wave:
	gtkwave counter.vcd


# ============================================================
# Clean generated files
# ============================================================

clean:
	rm -rf obj_dir
	rm -f counter.vcd


# ============================================================
# Help
# ============================================================

help:
	@echo "Available commands:"
	@echo "  make        - Build simulation"
	@echo "  make run    - Build and run simulation"
	@echo "  make wave   - Open GTKWave"
	@echo "  make clean  - Remove generated files"
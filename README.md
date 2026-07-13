# NORTH RISC-V Core

> A custom, from-scratch RV64 multicore RISC-V processor with vector processing, hardware acceleration, and an AI-focused software ecosystem.

[![License](https://img.shields.io/badge/License-NTL-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/SystemVerilog-IEEE%201800-green.svg)]()
[![Verification](https://img.shields.io/badge/UVM-IEEE%201802.2-orange.svg)]()
[![Simulator](https://img.shields.io/badge/Verilator-Supported-red.svg)]()

---

## Overview

**NORTH RISC-V Core** is an open hardware project that aims to design a **completely original** 64-bit multicore RISC-V processor from first principles while remaining compatible with the RISC-V ISA specification.

Unlike many educational processor projects that modify existing cores, NORTH is designed from the ground up. Every major architectural component is implemented independently, including the pipeline, control logic, vector execution units, memory hierarchy, cache subsystem, and hardware accelerators.

The long-term objective is to create a modern research platform suitable for:

- Embedded systems
- Robotics
- Computer vision
- Reinforcement learning
- High-performance embedded AI
- FPGA development
- ASIC migration
- Computer architecture research

---

# Project Goals

The project has several primary objectives:

- Design an original RV64 processor implementation
- Support the RISC-V Vector Extension (RVV)
- Implement a scalable multicore architecture
- Develop custom hardware accelerators
- Follow industry-standard RTL design practices
- Verify every module using UVM
- Simulate using Verilator before FPGA deployment
- Maintain FPGA portability
- Enable future ASIC implementation
- Build a complete software ecosystem around the processor

---

# Planned Features

## Processor

- RV64 architecture
- 64-bit addressing
- Modular pipeline
- Integer execution units
- Branch prediction
- CSR implementation
- Machine mode support
- Supervisor mode (planned)
- User mode (planned)

---

## Vector Processing

- RVV-compatible vector execution
- Configurable vector length
- Multiple execution lanes
- Masking support
- Gather / Scatter operations
- Reduction instructions
- Vector arithmetic
- Vector load/store
- Matrix-oriented optimizations

---

## Multicore

Planned architecture includes:

- Multiple CPU cores
- Shared L2 cache
- Cache coherency
- Inter-core synchronization
- Atomic operations
- Scalable interconnect

---

## Hardware Accelerators

The project will investigate dedicated accelerators for:

- Matrix multiplication
- Convolution
- FFT
- Image filtering
- Edge detection
- DSP
- Linear algebra
- Neural network inference
- Robotics workloads
- Reinforcement learning primitives

Accelerators may be implemented either as:

- ISA extensions
- Memory-mapped coprocessors
- Streaming accelerators

depending on workload characteristics.

---

# Software Stack

Planned software support includes:

- GCC
- LLVM
- Newlib
- C
- C++
- Assembly
- FreeRTOS
- Zephyr RTOS
- Embedded Linux (future)
- Python tooling
- PyTorch integration
- ONNX Runtime
- Robotics middleware

---

# Verification

Verification is a first-class component of the project.

Every RTL module will be independently verified before system integration.

Current verification technologies include:

- SystemVerilog
- UVM
- Assertions (SVA)
- Functional coverage
- Constrained random testing
- Directed testing
- Regression testing

Simulation tools include:

- Verilator
- GTKWave

Formal verification may be introduced during later development.

---

# Repository Structure

```
.
├── docs/
├── fpga/
├── rtl/
│   ├── accelerator/
│   ├── bus/
│   ├── cache/
│   ├── common/
│   ├── core/
│   ├── csr/
│   ├── debug/
│   ├── memory/
│   ├── mmu/
│   ├── uncore/
│   └── vector/
├── scripts/
├── sim/
├── sw/
├── tests/
├── tools/
└── verif/
```

---

# Development Philosophy

The project follows several core engineering principles.

- Modular architecture
- Clean interfaces
- Extensive documentation
- Verification before integration
- Simulation before hardware
- Incremental development
- Reproducible builds

---

# Roadmap

## Phase 1

- ISA definition
- Pipeline architecture
- Datapath
- Control unit
- Integer execution
- Memory interface

## Phase 2

- Cache subsystem
- CSR subsystem
- Exceptions
- Interrupt handling
- Debug support

## Phase 3

- Vector architecture
- Vector register file
- Vector execution units
- Vector memory operations

## Phase 4

- Multicore implementation
- Cache coherency
- Shared memory
- Performance optimization

## Phase 5

- Hardware accelerators
- Robotics interfaces
- Computer vision pipeline
- AI acceleration

## Phase 6

- FPGA deployment
- Software stack
- RTOS support
- Benchmarking

---

# Coding Standards

RTL development follows:

- IEEE SystemVerilog
- Consistent naming conventions
- Fully documented source code
- Synthesizable RTL
- Parameterized modules
- Lint-clean code
- Deterministic simulation

---

# Contributing

Contributions are welcome.

Please ensure that all contributions:

- Follow project coding standards
- Include documentation
- Include verification
- Pass regression testing
- Do not reduce code quality

Major architectural changes should be discussed before implementation.

---

# Documentation

Project documentation will include:

- Architecture specification
- Microarchitecture specification
- ISA documentation
- Vector architecture
- Memory subsystem
- Verification plan
- FPGA implementation
- Software development guides

---

# Project Status

Current status:

**Architecture Design**

The processor is currently in the architectural design stage.

No production-ready RTL has been released.

The project is expected to evolve significantly as the architecture matures.

---

# License

This project is licensed under the **North Technology License (NTL)**.

See the `LICENSE` file for complete licensing information.

---

# Acknowledgements

This project builds upon the open RISC-V instruction set architecture while implementing an independent processor microarchitecture.

RISC-V is a registered trademark of RISC-V International.

# Hardware Differential Filter (VHDL)

## Overview
This repository contains the VHDL implementation of a digital differential filter tailored for a Xilinx Artix-7 FPGA (xc7a200tfbg484-1). The hardware module processes a sequence of integers from a Single-Port Block RAM, applies an order-3 or order-5 differential filter, performs normalization via logical shifts (with specific corrections for negative numbers), and writes the output back to memory.

## Architecture
The core architecture is built around a custom Finite State Machine (FSM) designed to handle memory read/write requests, configuration fetching, and mathematical computations. To ensure maximum reliability and clean synthesis, the FSM strictly separates sequential logic (state transitions) and combinatorial logic (next-state and output computation).

## Tech Stack
* **Hardware Description Language:** VHDL
* **Synthesis & Simulation:** Xilinx Vivado WebPACK 2018.3
* **Target Hardware:** Artix-7 FPGA (xc7a200tfbg484-1)

## Results and Performance
The implementation successfully met all functional specifications and corner cases (including overflow saturation and maximum sequence lengths) while strictly maintaining a linear theoretical time complexity \(\mathcal{O}(n)\).

* **Timing Optimization:** Initially facing a critical path violation, the heavy arithmetic operations (partial sums and logical shifts) were pipelined and distributed across multiple FSM states. This optimization resolved a -25.374 ns negative slack, achieving a highly stable **positive slack of 12.242 ns** under a strict 20 ns clock period constraint.
* **Resource Utilization:** Achieved a highly compact hardware footprint utilizing only **0.83% of Slice LUTs** and **0.13% of Flip-Flops**, with **0 latches inferred** due to rigorous combinatorial logic definitions.

# 32-bit MIPS Microprocessor Design

![Language](https://img.shields.io/badge/Language-VHDL-blue)
![Tools](https://img.shields.io/badge/Tools-Quartus%20|%20ModelSim-orange)
![Architecture](https://img.shields.io/badge/Architecture-MIPS32%20RISC-green)

## 📌 Project Overview
This repository contains the VHDL source code and testbenches for a **32-bit, 5-stage pipelined RISC processor** based on the MIPS Instruction Set Architecture (ISA).

Designed as a core component of the *Digital Design* curriculum at the University of Florida, this processor implements a comprehensive datapath and control unit capable of executing arithmetic, logical, memory, and branch operations. The design focuses on pipeline efficiency, utilizing hardware-based hazard mitigation strategies to maximize instruction throughput (IPC).

## 🏗️ Architecture Features

### 1. 5-Stage Pipeline
The processor utilizes a classic 5-stage pipeline to increase instruction throughput:
1.  **Fetch (IF):** Retrieves instructions from Instruction Memory.
2.  **Decode (ID):** Decodes instructions and reads from the Register File.
3.  **Execute (EX):** Performs ALU operations or address calculations.
4.  **Memory (MEM):** Accesses Data Memory for load/store operations.
5.  **Writeback (WB):** Writes results back to the Register File.

### 2. Advanced Hazard Handling
To minimize stall cycles (bubbles) and ensure correct execution order, the design includes:
*   **Forwarding Unit:** Solves **Data Hazards** (Read-After-Write) by routing ALU results from the EX/MEM or MEM/WB stages directly back to the ALU inputs, bypassing the Register File.
*   **Hazard Detection Unit:** Identifies **Load-Use Hazards** and inserts a stall (bubble) into the pipeline when a dependent instruction follows a memory load, preserving data integrity.
*   **Branch Handling:** Implements "Flush" logic to discard instructions in the fetch/decode stages when a branch is taken.

## 💻 Supported Instruction Set (MIPS Subset)
The processor supports a subset of the MIPS32 ISA, including:

| Type | Instructions | Description |
| :--- | :--- | :--- |
| **R-Type** | `ADD`, `SUB`, `AND`, `OR`, `SLT`, `NOR`, `XOR` | Arithmetic and Logical operations on registers. |
| **I-Type** | `ADDI`, `ANDI`, `ORI`, `XORI` | Immediate arithmetic/logical operations. |
| **Memory** | `LW`, `SW` | Load Word and Store Word for memory access. |
| **Branch** | `BEQ`, `BNE` | Conditional branching for flow control. |
| **Jump** | `J`, `JAL`, `JR` | Unconditional jumps and function linking. |


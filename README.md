# 🧩 ALSU Project — Standalone Arithmetic/Logic/Shift Unit

![Verilog](https://img.shields.io/badge/Verilog-HDL-1f6feb?style=flat-square)
![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-red?style=flat-square)
![Status](https://img.shields.io/badge/status-early%20design-yellow?style=flat-square)

An early, standalone version of the **ALSU** (Arithmetic/Logic/Shift Unit) design that
later evolved into the more feature-rich `alsu` used in
[`sv-oop-randomization`](https://github.com/HadeerAbdlmonem/sv-oop-randomization/tree/main/ALSU), [`functional-coverage-verification`](https://github.com/HadeerAbdlmonem/functional-coverage-verification/tree/main/ALSU), and
[`uvm-intro-verification`](https://github.com/HadeerAbdlmonem/uvm-intro-verification/tree/main/ALSU_part_3).

## 📦 Module

| Module | File | Description |
|---|---|---|
| 🧮 `alsu` | [`ALSU_.v`](./ALSU_.v) | Registered ALSU: AND, XOR (each with reduction-op variants), ADD (+carry-in), MULT, shift-by-1, rotate-by-1, and operand bypass |

## ⚙️ Opcode Map

| `opcode_i` | Operation |
|:---:|---|
| `000` | AND / reduction-AND |
| `001` | XOR / reduction-XOR |
| `010` | ADD (with optional carry-in) |
| `011` | MULT |
| `100` | Shift by 1 |
| `101` | Rotate by 1 |

`leds_o` blinks (toggles every cycle) whenever a reduction operation is requested
together with an opcode other than AND/XOR, or the opcode is one of the two unused
encodings (`110`, `111`).

## ✅ Verification

[`test_ALSU.v`](./test_ALSU.v) is a directed testbench that:
- verifies asynchronous reset
- verifies the bypass paths
- walks through every opcode (0–5) with randomized operands, printing the DUT state
  for inspection

## ▶️ Running the Testbench

```bash
vsim -do run.do
```

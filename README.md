UART COMMUNICATION MODULE USING VERILOG HDL

Project 4 - VLSI RTL Design Portfolio

Designed by:
SHAIK ZAIBA FARAAZ


PROJECT DESCRIPTION
-------------------

This project implements a UART communication module using
SystemVerilog RTL.

The design contains:

1. UART Transmitter
2. UART Receiver
3. Start Bit
4. 8-bit Data
5. Even Parity
6. Stop Bit
7. Clock-based Bit Timing
8. TX Busy Signal
9. RX Done Signal
10. Parity Error Detection
11. TX-to-RX Loopback Verification


UART FRAME
----------

IDLE -> START -> DATA -> PARITY -> STOP


DATA FORMAT
-----------

Start Bit : 1 bit
Data      : 8 bits
Parity    : Even parity
Stop Bit  : 1 bit


PARAMETER
---------

CLKS_PER_BIT = 44


TEST PATTERNS
-------------

55
AA
A5
3C
F0
0F
96


EXPECTED VERIFICATION
---------------------

TOTAL TESTS   : 7
PASSED TESTS  : 7
FAILED TESTS  : 0

RESULT        : ALL TESTS PASSED


FILES
-----

design.sv
testbench.sv
README.txt


WAVEFORM FILE
-------------

uart_waveform.vcd


RECOMMENDED GTKWave SIGNALS
---------------------------

clk
reset
tx_data[7:0]
tx_start
tx
tx_busy
serial_line
rx_data[7:0]
rx_done
parity_error
total_tests
passed_tests
failed_tests


SIMULATION USING ICARUS VERILOG
--------------------------------

iverilog -g2012 -o uart_sim design.sv testbench.sv

vvp uart_sim

gtkwave uart_waveform.vcd


TOOLS
-----

SystemVerilog
Icarus Verilog
GTKWave / EPWave
EDA Playground


KEY LEARNING
------------

UART protocol
RTL FSM design
Serial communication
Parity generation
Parity checking
Clock-based timing
Loopback verification
Self-checking testbench
Waveform analysis

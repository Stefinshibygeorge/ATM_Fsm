# 💳 FPGA-Based ATM Finite State Machine (FSM)

## 📘 Overview
This project implements a **Finite State Machine (FSM)**-based **ATM System** on an FPGA using **Verilog HDL**. The design simulates the basic operations of a real-world ATM, such as authentication, balance inquiry, withdrawal, and inter-account transactions. It uses a **clock divider** to generate slower timing signals and a **seven-segment display** to show the current balance.

---

## ⚙️ System Components
1. **ATM FSM (`ATM.v`)**  
   - Implements the main control logic using FSM states:
     - `IDLE` — Waits for input  
     - `AUTH` — Verifies account and PIN  
     - `MENU` — User selects operation mode  
     - `BALANCE` — Displays current balance  
     - `WITHDRAW` — Performs withdrawal operation  
     - `TRANSACTION` — Transfers amount to another account  

2. **Clock Divider (`clk_divider.v`)**  
   - Generates a slower clock signal from the main 100 MHz FPGA clock for simulation and display timing.

3. **Seven Segment Display (`seven_seg_display.v`)**  
   - Displays the balance value (`bal`) in a human-readable format.  
   - Multiplexing is used to display multi-digit numbers using four 7-segment displays.

---

## 🧠 Working Principle
1. **Input Phase**
   - The user enters the account and PIN via a simulated keypad input (`keypad`).
   - The input is latched into `keypad_buffer` when the **load** signal is high.

2. **Authentication**
   - The system checks the entered credentials against the internal database of 4 accounts.
   - On a successful match, the system transitions to the `MENU` state.

3. **Operation Selection**
   - The 2-bit `mode` signal decides the next operation:
     - `01` → Balance Inquiry  
     - `10` → Withdraw Money  
     - `11` → Fund Transfer  

4. **Transaction Execution**
   - For **withdrawal**, the requested amount is checked against the account balance.
   - For **transfer**, both source and target account balances are updated if conditions are valid.
   - For **balance**, the current balance is displayed on the 7-segment display.

---

## 🧾 Simulation Results


The FSM was simulated in **Vivado**, showing correct state transitions and balance updates for all valid transactions.  
Below is a sample simulation output image:

![Simulation Output](simulation.jpg)

### 🖥️ Sample Output Waveform
- `pstate` and `nstate` transitions visible in simulation.
- `auth` asserted on successful login.
- `bal` updated dynamically after each operation.

---

## 🧰 Hardware Setup (FPGA)
- **FPGA Board:** Xilinx Basys 3 
- **Inputs:** Switches for `mode`, `load`, and keypad data.  
- **Outputs:** 7-segment display for showing balance and LED for authentication status.  
- **Clock Source:** Onboard 100 MHz clock divided using `clk_divider`.

---
## 👨‍💻 Author
**Stefin Shiby George**  
📍 M.Tech in Signal Processing, NIT Calicut  
Passionate about hardware design and embedded AI systems.

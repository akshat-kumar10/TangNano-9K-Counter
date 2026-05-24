# Tang Nano 9K: Synchronous 6-Bit Auto-Counter

A hardware-level 6-bit up-counter implemented on the **Sipeed Tang Nano 9K** (Gowin GW1NR-9C FPGA). This project demonstrates fundamental VLSI and digital logic design principles, including synchronous logic, mechanical switch debouncing, metastability prevention, and clock division.

## 🛠️ Hardware Specifications
* **FPGA:** Gowin GW1NR-LV9QN88PC6/I5 (8640 LUTs)
* **Clock Engine:** 27 MHz onboard crystal oscillator
* **Inputs:** 2x Onboard User Buttons (Active-Low)
* **Outputs:** 6x Onboard LEDs (Active-Low)

## 🧠 System Architecture

The design is entirely synchronous and relies on a hierarchical module structure to ensure clean logic routing and prevent race conditions.

1. **Dual Debouncers (`debouncer`):** Mitigates mechanical switch bounce and prevents metastability using a double-flop synchronizer (`sync_0`, `sync_1`) followed by a 20-bit timer. Ensures a clean, steady state only after the physical switch has settled for ~38ms.
2. **Prescaler / Clock Divider:** Hardware cannot operate at human speeds. The 27 MHz system clock is divided down using a 23-bit counter (`23'd6_750_000`) to generate a slow tick (~4 Hz) for the auto-increment functionality.
3. **Priority Logic Logic:** Implements an explicit logic tree where the Reset condition holds strict priority over the Count condition, holding the state at zero regardless of conflicting inputs.

### State-Driven Behavior
* **Hold Key 1:** The 6-bit LED array auto-increments at ~4 ticks per second, counting in binary.
* **Hold Key 2:** The system resets to `000000` (Priority override).
* **Release:** The system cleanly holds its current state.

## 🚀 Getting Started

### Prerequisites
* **Gowin EDA:** V1.9.11.03 (Education Version) or later.
* **Programmer:** Zadig configured with `WinUSB` on Interface 0 (for Composite Device recognition) - Install zadig at zadig.akeo.ie
* *If you see "Interface 0" and "Interface 1" options, select Interface 0 (Interface 0 handles the JTAG programming, Interface 1 handles UART serial communication).*

### Build Instructions
1. Clone this repository to your local machine.
2. Open the `.gprj` project file in the Gowin IDE.
3. The project utilizes two primary source files:
   * `src/top.v` (The Verilog hardware description)
   * `src/board.cst` (The physical pin constraints)
4. Run **Synthesize**.
5. Run **Place & Route**.
6. Open the **Gowin Programmer**, select your device (`GW1NR-9C`), and execute an **SRAM Program** for volatile testing, or **Embedded Flash Program** for permanent deployment.

## 📁 Project Structure

```text
├── src/
│   ├── top.v       # Main top-level module, prescaler, and debouncer sub-modules
│   └── board.cst   # Physical pin constraints for clock, LEDs, and keys
├── led_blink.gprj  # Gowin Project File
└── .gitignore      # Ignores heavy impl/ bitstreams and synthesis reports
```

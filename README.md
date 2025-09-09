# FPGA Workout Timer

This project was developed as the **final project for Logic Circuits Laboratory (Spring 2025)**

## 📌 Project Overview
The goal of this project is to design and implement a digital system on **FPGA** that calculates the required workout duration to burn a specific amount of calories and guides the user through timed workout sessions.

The system consists of two main components:

1. **Combinational Circuit for Workout Time Calculation**
   - Inputs: User weight (W), target calories (Cal), activity intensity (MET), and gender factor (G)
   - Output: Required workout duration (T)

2. **Finite State Machine (FSM) for Workout Scheduling**
   - Manages workout intervals and rest periods
   - Displays information on a **7-Segment Display**
   - Provides audio feedback via **Buzzer** at the end of each phase

##   Tools & Technologies
- **Verilog HDL** for hardware description  
- **FPGA platform**: AVA3S400 (or equivalent)  
- Simulation & Synthesis tools: **Xilinx ISE / ISIM**  

##   Features
- Calculates workout duration based on user inputs  
- Schedules workout sessions and rest times  
- Displays workout information on 7-segment display  
- Control via push buttons: **Start / Skip / Reset**  
- Audio alert at the end of each workout session  

## 👥 Contributors
- **Danial Seyedi**  
- **Pendar Rabiey**  

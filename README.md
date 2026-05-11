# MIPS-Pipelined-Processor 
5-Stage Pipelined MIPS Processor
University of Ottawa — CEG3156 Computer Systems Design | Winter 2026
Tools: Quartus II · ModelSim · Altera Cyclone IV FPGA (DE2-115)
Language: Structural VHDL (RTL only — no behavioral modeling)
Authors: Mahmoud Zourob · Jordan Burgess

Overview
A fully structural 5-stage pipelined MIPS processor implemented in VHDL, targeting the Altera Cyclone IV FPGA. The design executes a subset of MIPS instructions across overlapping pipeline stages, resolves all three hazard types in hardware, and includes a complete 32-bit datapath and BNE instruction as bonus deliverables.
All components are built from the ground up using enARdFF_2 (enabled, asynchronous-reset D flip-flop) and genericRegister primitives. No behavioral VHDL. No IP cores except the permitted LPM ROM and LPM RAM DQ for instruction and data memory.

Pipeline Architecture
   ┌────┐   ┌────┐   ┌────┐   ┌─────┐   ┌────┐
   │ IF │──▶│ ID │──▶│ EX │──▶│ MEM │──▶│ WB │
   └────┘   └────┘   └────┘   └─────┘   └────┘
     IF/ID    ID/EX   EX/MEM   MEM/WB
StageFunctionKey ComponentsIFFetch instruction, increment PCPC, pc_inc_alu, instructionmemory, if_id_registerIDDecode, register read, branch compareregister_file, main_control, sign_ext, hazardDetectionUnit, id_ex_registerEXALU execute, address compute, forwardingzeroALU, alu_control, forwardingunit, mux3to1_generic, ex_mem_registerMEMData memory access, branch resolutiondata_memory, branch_target_adder, mem_wb_registerWBWrite result back to register fileMEM/WB → register file write port
Pipeline Registers
Four registers propagate both data and control signals between stages:
RegisterCarriesif_id_registerPC+4, instruction[31:0]id_ex_registerAll control signals (EX/MEM/WB groups), ReadData1/2, sign-extended immediate, RS/RT/RD fieldsex_mem_registerBranch target, Zero flag, ALU result, RT write data, destination register, MEM/WB controlsmem_wb_registerALU result, memory read data, destination register, WB controls

Instruction Set
InstructionTypeOpcodeOperationaddR000000 / funct 100000$rd = $rs + $rtsubR000000 / funct 100010$rd = $rs − $rtorR000000 / funct 100101$rd = $rs OR $rtlwI100011$rt = mem[$rs + imm]swI101011mem[$rs + imm] = $rtbeqI000100Branch if $rs = $rtbneI000101Branch if $rs ≠ $rt (bonus)jJ000010Unconditional jump
Control Signal Truth Table
InstructionRegDstALUSrcMemtoRegRegWriteMemReadMemWriteBranchBranchNEJumpALUOpR-type10010000010lw01111000000swX1X00100000beqX0X00010001bneX0X00001001jXXX000001XX

Hazard Resolution
Data Hazards — Forwarding Unit
The forwarding unit bypasses results from later pipeline stages directly to the EX-stage ALU inputs, eliminating stalls for most RAW (read-after-write) hazards. It compares source register fields of the current instruction with destination register fields of instructions in EX/MEM and MEM/WB, and controls 3-to-1 muxes at both ALU inputs.
ForwardA / ForwardB selection:
ValueConditionData Source10EX/MEM.RegWrite=1 AND EX/MEM.Rd = ID/EX.RsEX/MEM ALU result01MEM/WB.RegWrite=1 AND MEM/WB.Rd = ID/EX.Rs AND no EX hazardMEM/WB write-back data00No hazardRegister file output
Same logic applies independently for ForwardB using ID/EX.Rt.
Load-Use Hazard — Stall
When a lw is immediately followed by an instruction that reads the loaded register, one pipeline bubble is inserted:
Stall condition:
ID/EX.MemRead = 1
AND (ID/EX.RT = IF/ID.RS  OR  ID/EX.RT = IF/ID.RT)
Effect: PCWrite disabled → IF/ID write disabled → ID/EX flushed to NOP bubble.
Control Hazards — Branch Flush
Branch outcome is resolved at the EX/MEM stage. On a taken branch, the two instructions that entered the pipeline behind the branch are flushed to NOPs:
PCSrc = (EX/MEM.Branch    AND     EX/MEM.Zero)   -- BEQ taken
     OR (EX/MEM.BranchNEQ AND NOT EX/MEM.Zero)   -- BNE taken
On taken branch: if_id_register and id_ex_register are cleared.

32-Bit Bonus
All datapaths extended from 8-bit to 32-bit:
ComponentExtensionRegister file8 × 32-bit registersData memory256 × 32-bit wordsALU, PC, all pipeline data buses32-bit throughoutSign extender16-bit → 32-bit sign-extended outputBranch offset32-bit sign-extended, shifted left 2, added to PC+4Jump target{PC+4[31:28], instr[25:0], 2'b00}
Instruction memory remains 32-bit wide (unchanged from base spec).

Verification
Memory Initialization
mem[0x00] = 0x00000055
mem[0x01] = 0x000000AA
All others = 0x00000000
Benchmark Program (Section 5.2 — full 32-bit with BNE)
asmlw   $2, 0($0)      ; $2 = mem[0]  = 0x00000055
lw   $3, 1($0)      ; $3 = mem[1]  = 0x000000AA
sub  $1, $2, $3     ; $1 = 0x55 - 0xAA
or   $4, $1, $3     ; $4 = $1 OR $3
beq  $1, $1, +20    ; always taken → skips sw below
sw   $4, 3($0)      ; SKIPPED (flushed by branch)
add  $1, $2, $3     ; $1 = 0x55 + 0xAA = 0x000000FF
sw   $1, 4($0)      ; mem[4] = 0xFF
lw   $2, 3($0)      ; $2 = mem[3]
lw   $3, 4($0)      ; $3 = mem[4] = 0xFF
j    11             ; jump to instruction 11
beq  $1, $1, -44    ; loop back to start
beq  $1, $2, -8     ; branch if $1 = $2
Expected State After First Full Pass
RegisterExpected ValueWritten By$10x000000FFadd $1, $2, $3$20x000000FFlw $2, 3($0)$30x000000FFlw $3, 4($0)
AddressExpected ValueWritten Bymem[4]0x000000FFsw $1, 4($0)
Hazard Trace
Load-use stall (lw → sub):
lw  $3, 1($0)   ; $3 available at WB (cycle N+4)
sub $1, $2, $3  ; needs $3 in EX (cycle N+2) → load-use hazard
                ; → 1 bubble inserted, sub delayed one cycle
EX forwarding (add → beq):
add $1, $2, $3  ; $1 written at WB (cycle N+4)
beq $1, $1, +20 ; needs $1 in EX — forwarded from EX/MEM (ForwardA = 10)
                ; → branch TAKEN → 2 bubbles flushed from IF and ID

Simulation Waveforms
Unit-level and system-level simulation performed in ModelSim. All key signals verified:
WaveformWhat Was VerifiedZeroALUZero flag asserts correctly on subtract and compare; confirmed 1 when result is all zerosALU ControlCorrect operation codes: 010 (add/sub), 000 (lw/sw address), 001 (branch subtract)Main ControlAll output signals decode correctly from opcode; BranchNE asserts only on opcode 000101Top-LevelPC advances correctly; instructions visible propagating through all 5 pipeline stages; forwarding and stall signals activate at expected cyclesID/EX BufferControl and data fields propagate correctly through ID/EX register across all instruction typesForwarding UnitForwardA/ForwardB cycle through 00→10→01 correctly on back-to-back dependent instructionsHazard DetectionPCWrite and IF/IDWrite deassert; Stall asserts on lw followed immediately by dependent read

Screenshots in sim/waveforms/.


Performance Analysis
Critical Path
Worst-case combinational path: 32-bit ripple-carry ALU carry chain in EX stage.
Assumptions (lab spec): gate delay = 0.01 ns, memory = 200 ps, register file = 100 ps.
32 full adders × 2 gate delays = 64 × 0.01 ns = 0.64 ns (ALU)
EX stage total (MUX + ALU + zero detect) ≈ 0.66 ns
Theoretical fmax ≈ 1.5 GHz
Post-synthesis fmax from Quartus Timing Analyzer will be lower due to routing delays on Cyclone IV.
CPI
ConditionCPI ImpactNo hazards1.0Load-use stall+1 per occurrenceTaken branch+2 per taken branchUntaken branch+0
Benchmark 1 (no active BEQ): ~14 instructions, ~1 stall → CPI ≈ 1.07
Benchmark 2 (BEQ active): +2 cycles per loop branch → CPI ≈ 1.2–1.3
Pipelined vs Single-Cycle
MetricSingle-CyclePipelinedCPI1.01.07–1.3Clock period~1.0+ ns (all stages in series)~0.66 ns (one stage)Throughput1 instr / long cycle~1 instr / short cycleSpeedup on benchmark1×~1.4–1.8×
The pipelined design achieves higher throughput by reducing the clock period, at the cost of occasional stall and flush cycles. On instruction sequences with few hazards, the throughput gain is substantial. On tight branch loops or load-use chains, the penalty cycles narrow the gap.

Repository Structure
mips-pipelined-processor/
├── rtl/
│   ├── top/
│   │   └── pipelinedProc.vhd
│   ├── pipeline_registers/
│   │   ├── if_id_register.vhd
│   │   ├── id_ex_register.vhd
│   │   ├── ex_mem_register.vhd
│   │   └── mem_wb_register.vhd
│   ├── datapath/
│   │   ├── PC.vhd
│   │   ├── pc_inc_alu.vhd
│   │   ├── register_file.vhd
│   │   ├── sign_ext.vhd
│   │   ├── zeroALU.vhd
│   │   ├── alu_control.vhd
│   │   ├── branch_target_adder.vhd
│   │   └── jump_address_calc.vhd
│   ├── control/
│   │   ├── main_control.vhd
│   │   ├── hazardDetectionUnit.vhd
│   │   └── forwardingunit.vhd
│   ├── memory/
│   │   ├── instructionmemory.vhd
│   │   └── data_memory.vhd
│   └── primitives/
│       ├── enARdFF_2.vhd
│       ├── genericRegister.vhd
│       ├── genericComparator.vhd
│       ├── mux2to1_generic.vhd
│       └── mux3to1_generic.vhd
├── sim/
│   ├── tb_pipelinedProc.vhd
│   └── waveforms/
│       ├── zeroalu.png
│       ├── alucontrol.png
│       ├── maincontrol.png
│       ├── toplevel.png
│       ├── idex_buffer.png
│       ├── forwarding_unit.png
│       └── hazard_unit.png
├── mif/
│   ├── instruction_memory.mif
│   └── data_memory.mif
└── README.md

Design Constraints
Per CEG3156 Lab 3, Section 6:

VHDL only — Verilog not accepted
Structural RTL only — behavioral modeling not accepted
All atomic modules built from enARdFF_2 primitives
LPM ROM (256×32) and LPM RAM DQ (256×32) permitted for memories only
All remaining building blocks designed and realized by the group
Synchronous design with global clock and asynchronous global reset throughout
Top-level I/O matches Table 1 of the lab handout

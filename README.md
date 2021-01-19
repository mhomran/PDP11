## About 

This project is about an implementation for PDP-11 minicomputer instruction set architecture (ISA) and its CPU KA-11 in VHDL. 

### CPU specs 

- data and address bus of 16-bit width.
- 12 clock per instruction (CPI).
- can handle one interrupt request.
- Register file og 8 general purpose registers including 2 special registers (SP, PC).

### RAM specs

- 4 KB RAM.
- Word addressable.

### assembler features.
- not case sensetive.

### List of the implemented instructions

## two operands instructions

| Instruction mnemonic  |          syntax            |            Description            |
| --------------------- | -------------------------- | --------------------------------- |
| MOV                   | `MOV Op1, Op2`             | Op1 <- Op2                        |
| ADD                   | `ADD Op1, Op2`             | Op2 <- Op1 + Op2                  |
| ADC                   | `ADC Op1, Op2`             | Op2 <- Op1 + Op2 + carry flag     |
| SUB                   | `SUB Op1, Op2`             | Op2 <- Op1 - Op2                  |
| SBC                   | `SBC Op1, Op2`             | Op2 <- Op1 - Op2 - carry flag     |
| AND                   | `AND Op1, Op2`             | Op2 <- Op1 & Op2 (bitwise and)    |
| OR                    | `OR Op1, Op2`              | Op2 <- Op1 | Op2 (bitwise or)     |
| XOR                   | `XOR Op1, Op2`             | Op2 <- Op1 ^ Op2 (bitwise xor)    |
| CMP                   | `CMP Op1, Op2`             | Op1 - Op2 (just flags change)     |

## single operand instructions

| Instruction mnemonic  |          syntax            |            Description            |
| --------------------- | -------------------------- | --------------------------------- |
| INC                   | `INC Op`                   | Op <- Op + 1                      |
| DEC                   | `DEC Op`                   | Op <- Op - 1                      |
| CLR                   | `CLR Op`                   | Op <- 0                           |
| INV                   | `INV Op`                   | Op <- ~OP (bitwise inversion)     |
| LSR                   | `LSR Op1`                  | Op <- Op >> 1                     |
| ROR                   | `ROR Op`                   | Op <- Op(0) concat. Op(15:1)      |
| ASR                   | `ASR Op`                   | Op <- Op(15) concat. Op (15:1)    |
| LSL                   | `LSL Op`                   | Op <- Op << 1                     |
| ROL                   | `ROL Op`                   | Op <- Op(14:0) concat. Op(15)     |

## Branch instructions

| Instruction mnemonic  |          syntax            |         Branch condition(s)       |
| --------------------- | -------------------------- | --------------------------------- |
| BR                    | `BR label`                 | None                              |
| BEQ                   | `BEQ label`                | Z = 1                             |
| BNE                   | `BNE label`                | Z = 0                             |
| BLO                   | `BLO label`                | C = 0                             |
| BLS                   | `BLS label`                | C = 0 or Z = 1                    |
| BHI                   | `BHI label`                | C = 1                             |
| BHS                   | `BHS label`                | C = 1 or Z = 1                    |

## No operand instructions

| Instruction mnemonic  |          syntax            |            Description            |
| --------------------- | -------------------------- | --------------------------------- |
| HLT                   | `HLT`                      | stops the cpu                     |
| NOP                   | `NOP`                      | do nothing                        |
| JSR                   | `JSR label`                | far jump to a subroutune          |
| RTS                   | `RTS`                      | return to a subroutune            |
| IRET                  | `IRET`                     | return to main program before interruption            |


# Programmer guide
- To write a comment use `;`
- The variables should be written in the end of the assembly file. It also should be in this format `DEFINE VAR 5`.
- The interrupt subroutine should be written before the variables and has this label `Interrupt:`.
- Labels must be written in a separate line.
- To assemble the project `python <assembly_file> <output_file>`. You should have python3.

# to run the test cases
- Install ModelSim (there's a free edition for students)
- Create a project, then add the vhdl files in it
- In the tcl console, write `do do_file` where `do_file` is the file that contains the simulation instructions for ModelSim. 
You can find them in the codes_do_files folder for each testcase.
- To avoid changing the relative paths in the do files, make sure that your model sim project is in the directory prior to the repository.



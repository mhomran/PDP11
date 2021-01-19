## About 

This project is about an implementation for PDP-11 minicomputer instruction set architecture (ISA) and its CPU KA-11. 

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

| Instruction mnemonic  |          syntax          |            Description            |
| --------------------- | ------------------------ | --------------------------------- |
| MOV                   | MOV Op1, Op2             | Op1 <- Op2                        |
| ADD                   | ADD Op1, Op2             | Op2 <- Op1 + Op2                  |
| ADC                   | ADC Op1, Op2             | Op2 <- Op1 + Op2 + carry flag     |
| SUB                   | SUB Op1, Op2             | Op2 <- Op1 - Op2                  |
| SBC                   | SBC Op1, Op2             | Op2 <- Op1 - Op2 - carry flag     |
| AND                   | AND Op1, Op2             | Op2 <- Op1 & Op2 (bitwise and)    |
| OR                    | OR Op1, Op2              | Op2 <- Op1 | Op2 (bitwise or)     |
| XOR                   | XOR Op1, Op2             | Op2 <- Op1 ^ Op2 (bitwise xor)    |
| CMP                   | CMP Op1, Op2             | Op1 - Op2 (just flags change)     |

## single operand instructions

| Instruction mnemonic  |          syntax          |            Description            |
| --------------------- | ------------------------ | --------------------------------- |
| INC                   | INC Op                   | Op <- Op + 1                      |
| DEC                   | DEC Op                   | Op <- Op - 1                      |
| CLR                   | CLR Op                   | Op <- 0                           |
| INV                   | INV Op                   | Op <- ~OP (bitwise inversion)     |
| LSR                   | LSR Op1                  | Op <- Op >> 1                     |
| ROR                   | ROR Op                   | Op <- Op(0) concat. Op(15:1)      |
| ASR                   | ASR Op                   | Op <- Op(15) concat. Op (15:1)    |
| LSL                   | LSL Op                   | Op <- Op << 1                     |
| ROL                   | ROL Op                   | Op <- Op(14:0) concat. Op(15)     |



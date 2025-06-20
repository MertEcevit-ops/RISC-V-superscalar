package core_types_pkg;
    
    import riscv_pkg::*;
    
    // ALU Operation Enumeration
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,  // Addition
        ALU_SUB  = 4'b1000,  // Subtraction  
        ALU_SLL  = 4'b0001,  // Shift Left Logical
        ALU_SLT  = 4'b0010,  // Set Less Than
        ALU_SLTU = 4'b0011,  // Set Less Than Unsigned
        ALU_XOR  = 4'b0100,  // XOR
        ALU_SRL  = 4'b0101,  // Shift Right Logical
        ALU_SRA  = 4'b1101,  // Shift Right Arithmetic
        ALU_OR   = 4'b0110,  // OR
        ALU_AND  = 4'b0111,  // AND
        ALU_CTZ  = 4'b1001,  // Count Trailing Zeros
        ALU_CLZ  = 4'b1010,  // Count Leading Zeros
        ALU_CPOP = 4'b1011   // Count Population (number of 1s)
    } alu_op_e;
    
    // RISC-V Instruction Opcodes
    typedef enum logic [6:0] {
        OP_REG    = 7'b0110011,  // R-type instructions
        OP_IMM    = 7'b0010011,  // I-type ALU instructions
        OP_LOAD   = 7'b0000011,  // Load instructions
        OP_STORE  = 7'b0100011,  // Store instructions
        OP_BRANCH = 7'b1100011,  // Branch instructions
        OP_JAL    = 7'b1101111,  // Jump and Link
        OP_JALR   = 7'b1100111,  // Jump and Link Register
        OP_LUI    = 7'b0110111,  // Load Upper Immediate
        OP_AUIPC  = 7'b0010111   // Add Upper Immediate to PC
    } opcode_e;
    
    // Decode stage signals
    typedef struct packed {
        // Instruction fields
        logic [31:0] pc;
        logic [31:0] inst;
        opcode_e opcode;
        logic [4:0] rd;
        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [2:0] funct3;
        logic [6:0] funct7;
        
        // Immediate value
        logic [31:0] imm;
        
        // Control signals
        logic reg_write;     // Write to register file
        logic mem_read;      // Memory read enable
        logic mem_write;     // Memory write enable
        logic branch;        // Branch instruction
        logic jump;          // Jump instruction
        logic alu_src;       // ALU source: 0=register, 1=immediate
        alu_op_e alu_op;     // ALU operation
        logic [1:0] wb_sel;  // Writeback select: 00=ALU, 01=MEM, 10=PC+4, 11=IMM
    } decode_signals_t;
    
    // Execute stage signals  
    typedef struct packed {
        logic valid;         // Valid instruction
        logic [4:0] rd;      // Destination register
        logic reg_write;     // Register write enable
        logic [31:0] result; // Execution result
        logic [31:0] pc;     // Program counter
        logic [31:0] inst;   // Instruction word
        
        // Memory interface
        logic [31:0] mem_addr;  // Memory address
        logic [31:0] mem_data;  // Memory data (read or write)
        logic mem_write;        // Memory write enable
    } execute_signals_t;

endpackage

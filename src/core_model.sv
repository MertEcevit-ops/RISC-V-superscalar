// Main Processor Module
//==============================================================================
module core_model
  
(
    parameter DMemInitFile  = "./test/core/dmem.hex",     // data memory initialization file
    parameter IMemInitFile  = ".test/core/imem.hex",     // instruction memory initialization file
    parameter TableFile     = "./test/core/table.log",    // processor state and used for verification/grading
    parameter IssueWidth    = 2               // 
);  (
    input  logic             clk_i,                       // system clock
    input  logic             rstn_i,                      // system reset
    input  logic  [XLEN-1:0] addr_i,                      // memory adddres input for reading
    output logic  [XLEN-1:0] data_o,                      // memory data output for reading
    output logic             update_o    [IssueWidth],    // retire signal
    output logic  [XLEN-1:0] pc_o        [IssueWidth],    // retired program counter
    output logic  [XLEN-1:0] instr_o     [IssueWidth],    // retired instruction
    output logic  [     4:0] reg_addr_o  [IssueWidth],    // retired register address
    output logic  [XLEN-1:0] reg_data_o  [IssueWidth],    // retired register data
    output logic  [XLEN-1:0] mem_addr_o  [IssueWidth],    // retired memory address
    output logic  [XLEN-1:0] mem_data_o  [IssueWidth],    // retired memory data
    output logic             mem_wrt_o   [IssueWidth]     // retired memory write enable signal
);
import riscv_pkg::*;

    // Internal signals
    logic [XLEN-1:0] pc, next_pc;
    logic [XLEN-1:0] inst_a, inst_b;
    logic stall, flush;
    logic [XLEN-1:0] branch_target;
    logic branch_taken;
    
    // Memory signals
    logic [XLEN-1:0] imem_addr_a, imem_addr_b;
    logic [XLEN-1:0] imem_data_a, imem_data_b;
    logic [XLEN-1:0] dmem_addr, dmem_wdata, dmem_rdata;
    logic [3:0] dmem_we;
    logic dmem_re;
    
    // Retirement signals
    logic retire_valid_a, retire_valid_b;
    logic [XLEN-1:0] retire_pc_a, retire_pc_b;
    logic [XLEN-1:0] retire_inst_a, retire_inst_b;
    logic [4:0] retire_reg_addr_a, retire_reg_addr_b;
    logic [XLEN-1:0] retire_reg_data_a, retire_reg_data_b;
    logic [XLEN-1:0] retire_mem_addr_a, retire_mem_addr_b;
    logic [XLEN-1:0] retire_mem_data_a, retire_mem_data_b;
    logic retire_mem_wrt_a, retire_mem_wrt_b;
    
    // Instruction Memory
    instruction_memory #(
        .InitFile(IMemInitFile)
    ) imem (
        .clk(clk_i),
        .addr_a(imem_addr_a),
        .addr_b(imem_addr_b),
        .data_a(imem_data_a),
        .data_b(imem_data_b)
    );
    
    // Data Memory
    data_memory #(
        .InitFile(DMemInitFile)
    ) dmem (
        .clk(clk_i),
        .addr(dmem_addr),
        .wdata(dmem_wdata),
        .we(dmem_we),
        .re(dmem_re),
        .rdata(dmem_rdata),
        .read_addr(addr_i),
        .read_data(data_o)
    );
    
    // Processor Core
    superscalar_core core (
        .clk(clk_i),
        .reset(~rstn_i),
        .imem_addr_a(imem_addr_a),
        .imem_addr_b(imem_addr_b),
        .imem_data_a(imem_data_a),
        .imem_data_b(imem_data_b),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_we(dmem_we),
        .dmem_re(dmem_re),
        .dmem_rdata(dmem_rdata),
        .retire_valid_a(retire_valid_a),
        .retire_valid_b(retire_valid_b),
        .retire_pc_a(retire_pc_a),
        .retire_pc_b(retire_pc_b),
        .retire_inst_a(retire_inst_a),
        .retire_inst_b(retire_inst_b),
        .retire_reg_addr_a(retire_reg_addr_a),
        .retire_reg_addr_b(retire_reg_addr_b),
        .retire_reg_data_a(retire_reg_data_a),
        .retire_reg_data_b(retire_reg_data_b),
        .retire_mem_addr_a(retire_mem_addr_a),
        .retire_mem_addr_b(retire_mem_addr_b),
        .retire_mem_data_a(retire_mem_data_a),
        .retire_mem_data_b(retire_mem_data_b),
        .retire_mem_wrt_a(retire_mem_wrt_a),
        .retire_mem_wrt_b(retire_mem_wrt_b)
    );
    
    // Output assignments - pc_o[0] is always first instruction when retiring
    always_comb begin
        update_o[0] = retire_valid_a;
        pc_o[0] = retire_pc_a;
        instr_o[0] = retire_inst_a;
        reg_addr_o[0] = retire_reg_addr_a;
        reg_data_o[0] = retire_reg_data_a;
        mem_addr_o[0] = retire_mem_addr_a;
        mem_data_o[0] = retire_mem_data_a;
        mem_wrt_o[0] = retire_mem_wrt_a;
        
        update_o[1] = retire_valid_b;
        pc_o[1] = retire_pc_b;
        instr_o[1] = retire_inst_b;
        reg_addr_o[1] = retire_reg_addr_b;
        reg_data_o[1] = retire_reg_data_b;
        mem_addr_o[1] = retire_mem_addr_b;
        mem_data_o[1] = retire_mem_data_b;
        mem_wrt_o[1] = retire_mem_wrt_b;
    end

endmodule

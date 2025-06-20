module superscalar_core (
    input logic clk,
    input logic reset,
    
    // Instruction Memory Interface
    output logic [31:0] imem_addr_a,
    output logic [31:0] imem_addr_b,
    input logic [31:0] imem_data_a,
    input logic [31:0] imem_data_b,
    
    // Data Memory Interface
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic [3:0] dmem_we,
    output logic dmem_re,
    input logic [31:0] dmem_rdata,
    
    // Retirement Interface
    output logic retire_valid_a,
    output logic retire_valid_b,
    output logic [31:0] retire_pc_a,
    output logic [31:0] retire_pc_b,
    output logic [31:0] retire_inst_a,
    output logic [31:0] retire_inst_b,
    output logic [4:0] retire_reg_addr_a,
    output logic [4:0] retire_reg_addr_b,
    output logic [31:0] retire_reg_data_a,
    output logic [31:0] retire_reg_data_b,
    output logic [31:0] retire_mem_addr_a,
    output logic [31:0] retire_mem_addr_b,
    output logic [31:0] retire_mem_data_a,
    output logic [31:0] retire_mem_data_b,
    output logic retire_mem_wrt_a,
    output logic retire_mem_wrt_b
);

    // Pipeline registers and control signals
    logic [31:0] pc, next_pc;
    logic [31:0] inst_a, inst_b;
    logic stall, flush;
    logic [31:0] branch_target;
    logic branch_taken;
    
    // Fetch stage
    fetch_stage fetch_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .pc(pc),
        .next_pc(next_pc),
        .imem_addr_a(imem_addr_a),
        .imem_addr_b(imem_addr_b),
        .inst_a(inst_a),
        .inst_b(inst_b),
        .imem_data_a(imem_data_a),
        .imem_data_b(imem_data_b)
    );
    
    // Decode and issue logic
    issue_unit issue_logic (
        .clk(clk),
        .reset(reset),
        .inst_a(inst_a),
        .inst_b(inst_b),
        .pc_a(pc),
        .pc_b(pc + 4),
        .stall(stall),
        .flush(flush),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
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

endmodule

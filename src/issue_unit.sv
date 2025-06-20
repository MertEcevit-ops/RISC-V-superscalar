typedef struct packed {
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm;
    logic [31:0] pc;
    logic [31:0] inst;
    
    // Control signals
    logic reg_write;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic alu_src;
    alu_op_e alu_op;
    logic [1:0] wb_sel;
} decode_signals_t;

typedef struct packed {
    logic [4:0] rd;
    logic [31:0] result;
    logic [31:0] pc;
    logic [31:0] inst;
    logic [31:0] mem_addr;
    logic [31:0] mem_data;
    logic mem_write;
    logic reg_write;
    logic valid;
} execute_signals_t;

module issue_unit (
    input logic clk,
    input logic reset,
    input logic [31:0] inst_a,
    input logic [31:0] inst_b,
    input logic [31:0] pc_a,
    input logic [31:0] pc_b,
    
    output logic stall,
    output logic flush,
    output logic [31:0] branch_target,
    output logic branch_taken,
    
    // Memory interface
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic [3:0] dmem_we,
    output logic dmem_re,
    input logic [31:0] dmem_rdata,
    
    // Retirement interface
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

    // Decode signals for both instructions
    decode_signals_t decode_a, decode_b;
    logic [31:0] scoreboard; // Bit vector for register dependencies
    
    // Pipeline registers
    execute_signals_t ex_a, ex_b;
    logic issue_a, issue_b;
    logic [31:0] rs1_data_a, rs2_data_a, rs1_data_b, rs2_data_b;
    logic branch_taken_a, branch_taken_b;
    logic [31:0] branch_target_a, branch_target_b;
    
    // Instantiate decoders
    decoder decoder_a (
        .inst(inst_a),
        .pc(pc_a),
        .decode_out(decode_a)
    );
    
    decoder decoder_b (
        .inst(inst_b),
        .pc(pc_b),
        .decode_out(decode_b)
    );
    
    // Hazard detection and issue logic
    hazard_unit hazard_detector (
        .decode_a(decode_a),
        .decode_b(decode_b),
        .scoreboard(scoreboard),
        .ex_a(ex_a),
        .ex_b(ex_b),
        .stall(stall),
        .issue_a(issue_a),
        .issue_b(issue_b)
    );
    
    // Register file
    register_file rf (
        .clk(clk),
        .reset(reset),
        .rs1_a(decode_a.rs1),
        .rs2_a(decode_a.rs2),
        .rs1_b(decode_b.rs1),
        .rs2_b(decode_b.rs2),
        .rd_a(ex_a.rd),
        .rd_b(ex_b.rd),
        .rd_data_a(ex_a.result),
        .rd_data_b(ex_b.result),
        .we_a(ex_a.reg_write && ex_a.valid),
        .we_b(ex_b.reg_write && ex_b.valid),
        .rs1_data_a(rs1_data_a),
        .rs2_data_a(rs2_data_a),
        .rs1_data_b(rs1_data_b),
        .rs2_data_b(rs2_data_b)
    );
    
    // Execution units
    datapath_a exec_a (
        .clk(clk),
        .reset(reset),
        .decode_in(decode_a),
        .rs1_data(rs1_data_a),
        .rs2_data(rs2_data_a),
        .valid_in(issue_a),
        .ex_out(ex_a),
        .branch_taken(branch_taken_a),
        .branch_target(branch_target_a)
    );
    
    datapath_b exec_b (
        .clk(clk),
        .reset(reset),
        .decode_in(decode_b),
        .rs1_data(rs1_data_b),
        .rs2_data(rs2_data_b),
        .valid_in(issue_b),
        .ex_out(ex_b),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_we(dmem_we),
        .dmem_re(dmem_re),
        .dmem_rdata(dmem_rdata),
        .branch_taken(branch_taken_b),
        .branch_target(branch_target_b)
    );
    
    // Branch resolution
    always_comb begin
        branch_taken = branch_taken_a || branch_taken_b;
        branch_target = branch_taken_a ? branch_target_a : branch_target_b;
        flush = branch_taken;
    end
    
    // Retirement assignments
    always_comb begin
        retire_valid_a = ex_a.valid;
        retire_valid_b = ex_b.valid;
        retire_pc_a = ex_a.pc;
        retire_pc_b = ex_b.pc;
        retire_inst_a = ex_a.inst;
        retire_inst_b = ex_b.inst;
        retire_reg_addr_a = ex_a.rd;
        retire_reg_addr_b = ex_b.rd;
        retire_reg_data_a = ex_a.result;
        retire_reg_data_b = ex_b.result;
        retire_mem_addr_a = ex_a.mem_addr;
        retire_mem_addr_b = ex_b.mem_addr;
        retire_mem_data_a = ex_a.mem_data;
        retire_mem_data_b = ex_b.mem_data;
        retire_mem_wrt_a = ex_a.mem_write;
        retire_mem_wrt_b = ex_b.mem_write;
    end
    
    // Scoreboard update
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            scoreboard <= 32'h0;
        end else begin
            // Clear bits for completed instructions
            if (ex_a.valid && ex_a.reg_write && ex_a.rd != 0)
                scoreboard[ex_a.rd] <= 1'b0;
            if (ex_b.valid && ex_b.reg_write && ex_b.rd != 0)
                scoreboard[ex_b.rd] <= 1'b0;
                
            // Set bits for issued instructions
            if (issue_a && decode_a.reg_write && decode_a.rd != 0)
                scoreboard[decode_a.rd] <= 1'b1;
            if (issue_b && decode_b.reg_write && decode_b.rd != 0)
                scoreboard[decode_b.rd] <= 1'b1;
        end
    end

endmodule

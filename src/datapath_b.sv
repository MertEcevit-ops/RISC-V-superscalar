// Datapath B (Memory + ALU Operations)
//==============================================================================
module datapath_b (
    input logic clk,
    input logic reset,
    input decode_signals_t decode_in,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic valid_in,
    
    output execute_signals_t ex_out,
    
    // Memory interface
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic [3:0] dmem_we,
    output logic dmem_re,
    input logic [31:0] dmem_rdata,
    
    output logic branch_taken,
    output logic [31:0] branch_target
);

    logic [31:0] alu_a, alu_b, alu_result;
    logic [31:0] pc_plus_4, pc_plus_imm;
    logic [31:0] mem_result;
    
    // ALU input selection
    always_comb begin
        alu_a = rs1_data;
        alu_b = decode_in.alu_src ? decode_in.imm : rs2_data;
        
        if (decode_in.opcode == OP_AUIPC)
            alu_a = decode_in.pc;
    end
    
    // ALU instance
    alu alu_inst (
        .a(alu_a),
        .b(alu_b),
        .alu_op(decode_in.alu_op),
        .result(alu_result)
    );
    
    // Memory interface
    always_comb begin
        dmem_addr = alu_result;
        dmem_wdata = rs2_data;
        dmem_re = decode_in.mem_read && valid_in;
        dmem_we = 4'h0;
        
        if (decode_in.mem_write && valid_in) begin
            case (decode_in.funct3)
                3'b000: dmem_we = 4'b0001 << alu_result[1:0]; // SB
                3'b001: dmem_we = 4'b0011 << {alu_result[1], 1'b0}; // SH
                3'b010: dmem_we = 4'b1111; // SW
            endcase
        end
    end
    
    // Memory result formatting
    always_comb begin
        case (decode_in.funct3)
            3'b000: mem_result = {{24{dmem_rdata[7]}}, dmem_rdata[7:0]}; // LB
            3'b001: mem_result = {{16{dmem_rdata[15]}}, dmem_rdata[15:0]}; // LH
            3'b010: mem_result = dmem_rdata; // LW
            3'b100: mem_result = {24'h0, dmem_rdata[7:0]}; // LBU
            3'b101: mem_result = {16'h0, dmem_rdata[15:0]}; // LHU
            default: mem_result = dmem_rdata;
        endcase
    end
    
    // PC calculations
    assign pc_plus_4 = decode_in.pc + 4;
    assign pc_plus_imm = decode_in.pc + decode_in.imm;
    
    // Branch logic (similar to datapath A)
    always_comb begin
        branch_taken = 1'b0;
        branch_target = 32'h0;
        
        if (decode_in.branch && valid_in) begin
            case (decode_in.funct3)
                3'b000: branch_taken = (rs1_data == rs2_data);
                3'b001: branch_taken = (rs1_data != rs2_data);
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data));
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data));
                3'b110: branch_taken = (rs1_data < rs2_data);
                3'b111: branch_taken = (rs1_data >= rs2_data);
            endcase
            branch_target = pc_plus_imm;
        end else if (decode_in.jump && valid_in) begin
            branch_taken = 1'b1;
            if (decode_in.opcode == OP_JAL)
                branch_target = pc_plus_imm;
            else
                branch_target = (rs1_data + decode_in.imm) & ~32'h1;
        end
    end
    
    // Pipeline register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_out <= '0;
        end else begin
            ex_out.valid <= valid_in;
            ex_out.rd <= decode_in.rd;
            ex_out.reg_write <= decode_in.reg_write;
            ex_out.pc <= decode_in.pc;
            ex_out.inst <= decode_in.inst;
            ex_out.mem_addr <= dmem_addr;
            ex_out.mem_data <= decode_in.mem_write ? dmem_wdata : dmem_rdata;
            ex_out.mem_write <= decode_in.mem_write;
            
            case (decode_in.wb_sel)
                2'b00: ex_out.result <= alu_result;
                2'b01: ex_out.result <= mem_result;
                2'b10: ex_out.result <= pc_plus_4;
                2'b11: ex_out.result <= decode_in.imm;
                default: ex_out.result <= alu_result;
            endcase
        end
    end

endmodule

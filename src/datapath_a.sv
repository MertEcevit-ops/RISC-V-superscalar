module datapath_a (
    input logic clk,
    input logic reset,
    input decode_signals_t decode_in,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic valid_in,
    
    output execute_signals_t ex_out,
    output logic branch_taken,
    output logic [31:0] branch_target
);

    logic [31:0] alu_a, alu_b, alu_result;
    logic [31:0] pc_plus_4, pc_plus_imm;
    
    // ALU input selection
    always_comb begin
        alu_a = rs1_data;
        alu_b = decode_in.alu_src ? decode_in.imm : rs2_data;
        
        // Special case for AUIPC
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
    
    // PC calculations
    assign pc_plus_4 = decode_in.pc + 4;
    assign pc_plus_imm = decode_in.pc + decode_in.imm;
    
    // Branch logic
    always_comb begin
        branch_taken = 1'b0;
        branch_target = 32'h0;
        
        if (decode_in.branch && valid_in) begin
            case (decode_in.funct3)
                3'b000: branch_taken = (rs1_data == rs2_data); // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data); // BNE
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
                3'b110: branch_taken = (rs1_data < rs2_data); // BLTU
                3'b111: branch_taken = (rs1_data >= rs2_data); // BGEU
            endcase
            branch_target = pc_plus_imm;
        end else if (decode_in.jump && valid_in) begin
            branch_taken = 1'b1;
            if (decode_in.opcode == OP_JAL)
                branch_target = pc_plus_imm;
            else // JALR
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
            ex_out.mem_addr <= 32'h0;
            ex_out.mem_data <= 32'h0;
            ex_out.mem_write <= 1'b0;
            
            case (decode_in.wb_sel)
                2'b00: ex_out.result <= alu_result;
                2'b10: ex_out.result <= pc_plus_4;
                2'b11: ex_out.result <= decode_in.imm;
                default: ex_out.result <= alu_result;
            endcase
        end
    end

endmodule

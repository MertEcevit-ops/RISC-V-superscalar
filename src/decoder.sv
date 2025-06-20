module decoder (
    input logic [31:0] inst,
    input logic [31:0] pc,
    output decode_signals_t decode_out
);

    always_comb begin
        // Default values
        decode_out = '0;
        decode_out.pc = pc;
        decode_out.inst = inst;
        
        // Extract fields
        decode_out.opcode = inst[6:0];
        decode_out.rd = inst[11:7];
        decode_out.rs1 = inst[19:15];
        decode_out.rs2 = inst[24:20];
        decode_out.funct3 = inst[14:12];
        decode_out.funct7 = inst[31:25];
        
        case (decode_out.opcode)
            OP_REG: begin // R-type
                decode_out.reg_write = 1'b1;
                decode_out.wb_sel = 2'b00; // ALU result
                
                // Check for bit manipulation instructions
                if (decode_out.funct7 == 7'b0110000) begin
                    case (decode_out.funct3)
                        3'b001: decode_out.alu_op = ALU_CTZ;  // ctz
                        3'b010: decode_out.alu_op = ALU_CLZ;  // clz
                        3'b100: decode_out.alu_op = ALU_CPOP; // cpop
                        default: decode_out.alu_op = alu_op_e'({decode_out.funct7[5], decode_out.funct3});
                    endcase
                end else begin
                    decode_out.alu_op = alu_op_e'({decode_out.funct7[5], decode_out.funct3});
                end
            end
            
            OP_IMM: begin // I-type (ALU immediate)
                decode_out.imm = {{20{inst[31]}}, inst[31:20]};
                decode_out.reg_write = 1'b1;
                decode_out.alu_src = 1'b1;
                decode_out.alu_op = alu_op_e'({1'b0, decode_out.funct3});
                decode_out.wb_sel = 2'b00;
            end
            
            OP_LOAD: begin // Load
                decode_out.imm = {{20{inst[31]}}, inst[31:20]};
                decode_out.reg_write = 1'b1;
                decode_out.mem_read = 1'b1;
                decode_out.alu_src = 1'b1;
                decode_out.alu_op = ALU_ADD;
                decode_out.wb_sel = 2'b01; // Memory
            end
            
            OP_STORE: begin // Store
                decode_out.imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                decode_out.mem_write = 1'b1;
                decode_out.alu_src = 1'b1;
                decode_out.alu_op = ALU_ADD;
            end
            
            OP_BRANCH: begin // Branch
                decode_out.imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                decode_out.branch = 1'b1;
                decode_out.alu_op = alu_op_e'({1'b0, decode_out.funct3});
            end
            
            OP_JAL: begin // JAL
                decode_out.imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
                decode_out.reg_write = 1'b1;
                decode_out.jump = 1'b1;
                decode_out.wb_sel = 2'b10; // PC + 4
            end
            
            OP_JALR: begin // JALR
                decode_out.imm = {{20{inst[31]}}, inst[31:20]};
                decode_out.reg_write = 1'b1;
                decode_out.jump = 1'b1;
                decode_out.alu_src = 1'b1;
                decode_out.wb_sel = 2'b10; // PC + 4
            end
            
            OP_LUI: begin // LUI
                decode_out.imm = {inst[31:12], 12'b0};
                decode_out.reg_write = 1'b1;
                decode_out.wb_sel = 2'b11; // Immediate
            end
            
            OP_AUIPC: begin // AUIPC
                decode_out.imm = {inst[31:12], 12'b0};
                decode_out.reg_write = 1'b1;
                decode_out.alu_op = ALU_ADD;
                decode_out.wb_sel = 2'b00; // ALU result (PC + imm)
            end
        endcase
    end

endmodule

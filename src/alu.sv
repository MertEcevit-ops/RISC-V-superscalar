module alu 
    import core_types_pkg::*;
(
    input logic [31:0] a,
    input logic [31:0] b,
    input alu_op_e alu_op,
    output logic [31:0] result
);

    // Helper functions for bit manipulation
    function automatic logic [31:0] count_trailing_zeros(logic [31:0] value);
        logic [31:0] count;
        count = 0;
        for (int i = 0; i < 32; i++) begin
            if (value[i] == 1'b1) begin
                count = i;
                break;
            end else if (i == 31) begin
                count = 32; // All zeros
            end
        end
        return count;
    endfunction
    
    function automatic logic [31:0] count_leading_zeros(logic [31:0] value);
        logic [31:0] count;
        count = 0;
        for (int i = 31; i >= 0; i--) begin
            if (value[i] == 1'b1) begin
                count = 31 - i;
                break;
            end else if (i == 0) begin
                count = 32; // All zeros
            end
        end
        return count;
    endfunction
    
    function automatic logic [31:0] count_population(logic [31:0] value);
        logic [31:0] count;
        count = 0;
        for (int i = 0; i < 32; i++) begin
            if (value[i] == 1'b1) begin
                count = count + 1;
            end
        end
        return count;
    endfunction

    always_comb begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_SLL:  result = a << b[4:0];
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            ALU_SLTU: result = (a < b) ? 32'h1 : 32'h0;
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            ALU_CTZ:  result = count_trailing_zeros(a);  // Count Trailing Zeros
            ALU_CLZ:  result = count_leading_zeros(a);   // Count Leading Zeros
            ALU_CPOP: result = count_population(a);      // Count Population
            default:  result = 32'h0;
        endcase
    end

endmodule

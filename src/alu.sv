module alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_op,
    output logic [31:0] result
);

    // ALU Operation Definitions
    localparam ALU_ADD  = 4'b0000;  // Addition
    localparam ALU_SUB  = 4'b1000;  // Subtraction  
    localparam ALU_SLL  = 4'b0001;  // Shift Left Logical
    localparam ALU_SLT  = 4'b0010;  // Set Less Than
    localparam ALU_SLTU = 4'b0011;  // Set Less Than Unsigned
    localparam ALU_XOR  = 4'b0100;  // XOR
    localparam ALU_SRL  = 4'b0101;  // Shift Right Logical
    localparam ALU_SRA  = 4'b1101;  // Shift Right Arithmetic
    localparam ALU_OR   = 4'b0110;  // OR
    localparam ALU_AND  = 4'b0111;  // AND
    localparam ALU_CTZ  = 4'b1001;  // Count Trailing Zeros
    localparam ALU_CLZ  = 4'b1010;  // Count Leading Zeros
    localparam ALU_CPOP = 4'b1011;  // Count Population

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

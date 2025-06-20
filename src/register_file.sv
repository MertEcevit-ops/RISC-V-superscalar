module register_file (
    input logic clk,
    input logic reset,
    
    // Read ports
    input logic [4:0] rs1_a, rs2_a, rs1_b, rs2_b,
    output logic [31:0] rs1_data_a, rs2_data_a, rs1_data_b, rs2_data_b,
    
    // Write ports
    input logic [4:0] rd_a, rd_b,
    input logic [31:0] rd_data_a, rd_data_b,
    input logic we_a, we_b
);

    logic [31:0] registers [31:0];
    
    // Initialize registers
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'h0;
            end
        end else begin
            if (we_a && rd_a != 0)
                registers[rd_a] <= rd_data_a;
            if (we_b && rd_b != 0)
                registers[rd_b] <= rd_data_b;
        end
    end
    
    // Read ports
    assign rs1_data_a = (rs1_a == 0) ? 32'h0 : registers[rs1_a];
    assign rs2_data_a = (rs2_a == 0) ? 32'h0 : registers[rs2_a];
    assign rs1_data_b = (rs1_b == 0) ? 32'h0 : registers[rs1_b];
    assign rs2_data_b = (rs2_b == 0) ? 32'h0 : registers[rs2_b];

endmodule

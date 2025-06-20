module instruction_memory #(
    parameter InitFile = "./test/core/imem.mem"
) (
    input logic clk,
    input logic [31:0] addr_a,
    input logic [31:0] addr_b,
    output logic [31:0] data_a,
    output logic [31:0] data_b
);

    logic [31:0] memory [0:4095]; // 16KB instruction memory
    
    initial begin
        if (InitFile != "") begin
            $readmemh(InitFile, memory);
        end
    end
    
    always_ff @(posedge clk) begin
        data_a <= memory[addr_a[13:2]];
        data_b <= memory[addr_b[13:2]];
    end

endmodule

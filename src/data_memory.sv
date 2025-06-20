// Data Memory
//==============================================================================
module data_memory #(
    parameter InitFile = ".test/core/dmem.mem"
) (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input logic [3:0] we,
    input logic re,
    output logic [31:0] rdata,
    
    // External read port
    input logic [31:0] read_addr,
    output logic [31:0] read_data
);

    logic [31:0] memory [0:4095]; // 16KB data memory
    
    initial begin
        if (InitFile != "") begin
            $readmemh(InitFile, memory);
        end
    end
    
    always_ff @(posedge clk) begin
        if (we[0]) memory[addr[13:2]][7:0] <= wdata[7:0];
        if (we[1]) memory[addr[13:2]][15:8] <= wdata[15:8];
        if (we[2]) memory[addr[13:2]][23:16] <= wdata[23:16];
        if (we[3]) memory[addr[13:2]][31:24] <= wdata[31:24];
        
        if (re) begin
            rdata <= memory[addr[13:2]];
        end
    end
    
    // External read port
    assign read_data = memory[read_addr[13:2]];

endmodule

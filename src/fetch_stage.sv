module fetch_stage (
    input logic clk,
    input logic reset,
    input logic stall,
    input logic flush,
    input logic [31:0] branch_target,
    input logic branch_taken,
    
    output logic [31:0] pc,
    output logic [31:0] next_pc,
    output logic [31:0] imem_addr_a,
    output logic [31:0] imem_addr_b,
    output logic [31:0] inst_a,
    output logic [31:0] inst_b,
    
    input logic [31:0] imem_data_a,
    input logic [31:0] imem_data_b
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h0;
        end else if (!stall) begin
            if (branch_taken) begin
                pc <= branch_target;
            end else begin
                pc <= next_pc;
            end
        end
    end
    
    always_comb begin
        next_pc = pc + 8; // Fetch 2 instructions
        imem_addr_a = pc;
        imem_addr_b = pc + 4;
        
        if (flush) begin
            inst_a = 32'h00000013; // NOP (addi x0, x0, 0)
            inst_b = 32'h00000013; // NOP
        end else begin
            inst_a = imem_data_a;
            inst_b = imem_data_b;
        end
    end

endmodule

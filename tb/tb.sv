module tb ();
  parameter int IssueWidth = 2;
  logic [riscv_pkg::XLEN-1:0] addr;
  logic [riscv_pkg::XLEN-1:0] data;
  logic [IssueWidth-1:0] [riscv_pkg::XLEN-1:0] pc;
  logic [IssueWidth-1:0] [riscv_pkg::XLEN-1:0] instr;
  logic [IssueWidth-1:0] [                4:0] reg_addr;
  logic [IssueWidth-1:0] [riscv_pkg::XLEN-1:0] reg_data;
  logic [IssueWidth-1:0] [riscv_pkg::XLEN-1:0] mem_addr;
  logic [IssueWidth-1:0] [riscv_pkg::XLEN-1:0] mem_data;
  logic [IssueWidth-1:0]                       mem_wrt;
  logic [IssueWidth-1:0]                       update;
  logic                       clk;
  logic                       rstn;

  core_model  #(
    .DMemInitFile("./test/dmem.hex"),
    .IMemInitFile("./test/test.hex"),
    .TableFile   ("table.log"),
    .IssueWidth  (2)
  ) i_core_model (
      .clk_i(clk),
      .rstn_i(rstn),
      .addr_i(addr),
      .update_o(update),
      .data_o(data),
      .pc_o(pc),
      .instr_o(instr),
      .reg_addr_o(reg_addr),
      .reg_data_o(reg_data),
      .mem_addr_o(mem_addr),
      .mem_data_o(mem_data),
      .mem_wrt_o(mem_wrt)

  );
  integer file_pointer;
  initial begin
    file_pointer = $fopen("model.log", "w");
    if (file_pointer == 0) $display("File model.log was not opened");
    #1;
    forever begin
      for (int i=0; i < IssueWidth; ++i) begin
        if (rstn && update[i]) begin
          if (reg_addr[i] == 0) begin
            $fwrite(file_pointer, "0x%8h (0x%8h)", pc[i], instr[i]);
          end else begin
            if (reg_addr[i] > 9) begin
              $fwrite(file_pointer, "0x%8h (0x%8h) x%0d 0x%8h", pc[i], instr[i], reg_addr[i], reg_data[i]);
            end else begin
              $fwrite(file_pointer, "0x%8h (0x%8h) x%0d  0x%8h", pc[i], instr[i], reg_addr[i], reg_data[i]);
            end
          end
          if (mem_wrt[i] == 1) begin
            $fwrite(file_pointer, "mem 0x%8h 0x%8h", mem_addr[i], mem_data[i]);
          end
          $fwrite(file_pointer, "\n");
        end
      end
      @(negedge clk);
    end
  end
  initial
    forever begin
      clk = 0;
      #1;
      clk = 1;
      #1;
    end
  initial begin
    $display("starting\n");
    rstn = 0;
    #4;
    rstn = 1;
    #10000;
    for (logic [31:0] i = 32'h8000_0000; i < 32'h8000_0000 + 'h20; i = i + 4) begin
      addr = i;
      $display("data @ mem[0x%8h] = %8h", addr, data);
    end
    $finish;
  end


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

endmodule

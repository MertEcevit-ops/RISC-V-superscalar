module hazard_unit
    import core_types_pkg::*;
(
    input decode_signals_t decode_a,
    input decode_signals_t decode_b,
    input logic [31:0] scoreboard,
    input execute_signals_t ex_a,
    input execute_signals_t ex_b,
    
    output logic stall,
    output logic issue_a,
    output logic issue_b
);

    logic hazard_a, hazard_b, structural_hazard;
    
    // Check for data hazards
    always_comb begin
        hazard_a = 1'b0;
        hazard_b = 1'b0;
        
        // Check instruction A dependencies
        if (decode_a.rs1 != 0 && scoreboard[decode_a.rs1])
            hazard_a = 1'b1;
        if (decode_a.rs2 != 0 && scoreboard[decode_a.rs2])
            hazard_a = 1'b1;
            
        // Check instruction B dependencies
        if (decode_b.rs1 != 0 && scoreboard[decode_b.rs1])
            hazard_b = 1'b1;
        if (decode_b.rs2 != 0 && scoreboard[decode_b.rs2])
            hazard_b = 1'b1;
            
        // Check for dependency between A and B
        if (decode_a.reg_write && decode_a.rd != 0) begin
            if (decode_b.rs1 == decode_a.rd || decode_b.rs2 == decode_a.rd)
                hazard_b = 1'b1;
        end
        
        // Structural hazard: both instructions need datapath B (memory)
        structural_hazard = (decode_a.mem_read || decode_a.mem_write) && 
                           (decode_b.mem_read || decode_b.mem_write);
    end
    
    // Issue logic
    always_comb begin
        issue_a = !hazard_a;
        issue_b = !hazard_b && !structural_hazard;
        
        // If instruction B has structural hazard, only issue A
        if (structural_hazard) begin
            issue_b = 1'b0;
        end
        
        stall = hazard_a || (hazard_b && !structural_hazard);
    end

endmodule

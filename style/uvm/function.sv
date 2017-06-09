module arbitrator(
    // -- Global signals
    input ref_clk,
    input radu_clk,
    input reset_b,

    // -- Inputs for arbitration
    input select,
    input [3:0] vld_abs,
    input [3:0] vld_rel,

    // -- Output ready for strobe interface
    output logic [3:0] abs_idx,
    output logic [3:0] rel_idx,
    output logic       busy     // more than two valids
);

    // -- Multiple Event Detection
    logic busy_rel, busy_abs;
    function BUSY_FLAG (input [3:0] in);
        BUSY_FLAG = (in[0] & in[1]) | (in[0] & in[2]) | (in[0] & in[3])
        | (in[1] & in[2]) | (in[1] & in[3]) | (in[2] & in[3]);
    endfunction

    assign busy_abs = BUSY_FLAG(vld_abs);
    assign busy_rel = BUSY_FLAG(vld_rel);
    assign busy = busy_rel | busy_abs;



    // -- reservation station coding style
    always_comb begin
        assert(!BUSY_FLAG(abs_idx));
        assert(!BUSY_FLAG(rel_idx));
    end

    always_comb begin
         abs_idx = 4'd0;
         rel_idx = 4'd0;
         if(vld_abs[0])
              abs_idx = 'b0001;
         else if(vld_abs[1])
              abs_idx = 'b0010;
         else if(vld_abs[2])
              abs_idx = 'b0100;
         else if(vld_abs[3])
              abs_idx = 'b1000;
         if(vld_rel[0])
              rel_idx = 'b0001;
         else if(vld_rel[1])
              rel_idx = 'b0010;
         else if(vld_rel[2])
              rel_idx = 'b0100;
         else if(vld_rel[3])
              rel_idx = 'b1000;
         end
endmodule



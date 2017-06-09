module gen_clk #(PERIOD_NS = 2);
    bit clk = 0;
    always #(PERIOD_NS/2) clk = ~clk;
endmodule: gen_clk


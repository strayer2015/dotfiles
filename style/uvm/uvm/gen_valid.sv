module gen_valid#(parameter CYCLES=5)(vif TVIF);

    int cnt;

    // -- counter loop
    always_ff@(posedge TVIF.clk) begin
        if (~TVIF.rn)
            cnt <= 0;
        else if (TVIF.en)
            cnt <= (cnt==CYCLES-1) ? 0 : (cnt+1);
        else
            cnt <= cnt;
    end

    always_ff @(posedge TVIF.clk) begin
        if (~TVIF.rn)
            TVIF.InValid <= 'b0;
        else if (cnt == CYCLES-1) begin
            TVIF.InValid <= 'b1;
            TVIF.nTestSamp++;
        end
        else
            TVIF.InValid <= 'b0;
    end
endmodule: gen_valid

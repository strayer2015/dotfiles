// ---- DUT
`include "../ecyn_top.sv"


module tb_ecyn_top;

    // ---- Clock generator
    gen_clk #(.PERIOD_NS(6)) gen_clk();

    // ---- Interface
    vif TVIF(.clk(gen_clk.clk));

    // ---- Valid generator
    gen_valid #(.CYCLES(5)) gen_valid(TVIF);

    // ---- Testbench
    transactor env0 = new(TVIF);

    initial env0.run();

    // ---- DUT
    ecyn_top z_ecyn_top_wrap(
        .clk(TVIF.clk),
        .rn(TVIF.rn),
        .en(TVIF.en),
        .InValid(TVIF.InValid),
        .TxIn_I_(TVIF.TxIn_I_),
        .TxIn_Q_(TVIF.TxIn_Q_),
        .RxIn_Q_(TVIF.RxIn_Q_),
        .RxIn_I_(TVIF.RxIn_I_),

        .CleanSigValid(TVIF.CleanSigValid),
        .CleanSig_I_(TVIF.CleanSig_I_),
        .CleanSig_Q_(TVIF.CleanSig_Q_)
    );

    // ---- Debugging Files
    int oFile_X, oFile_HB, oFile_DM, oFile_Ker, oFile_Dec, oFile_AE;
    initial oFile_X = $fopen("outputs/debug/X", "w");
    initial oFile_HB = $fopen("outputs/debug/DMlIn", "w");
    initial oFile_DM = $fopen("outputs/debug/KernelIn", "w");
    initial oFile_Ker = $fopen("outputs/debug/KernelOut", "w");
    initial oFile_Dec = $fopen("outputs/debug/DecOut", "w");
    initial oFile_AE = $fopen("outputs/debug/AE", "w");


    task Write_KerIn();
        int ii;
        int i_tempi, i_tempq;
        for(ii=3; ii>-1; ii--) begin
            assign i_tempi = $signed(z_ecyn_top_wrap.z_ecyn_7k_top.SP_.DMSig122p88Value[ii].I);
            assign i_tempq = $signed(z_ecyn_top_wrap.z_ecyn_7k_top.SP_.DMSig122p88Value[ii].Q);
            $fwrite(oFile_DM, "%d %d\n", i_tempi, i_tempq);
        end
    endtask

    task Write_X();
        int ii;
        int i_tempi, i_tempq;
        for(ii=0; ii<spPkg::K; ii++)    begin
            assign i_tempi = $signed(z_ecyn_top_wrap.z_ecyn_7k_top.X_A.value[ii].I);
            assign i_tempq = $signed(z_ecyn_top_wrap.z_ecyn_7k_top.X_A.value[ii].Q);
            $fwrite(oFile_X, "%d %d \n", i_tempi, i_tempq);
        end
        $fwrite(oFile_X,"\n");
    endtask

    always_ff@(posedge TVIF.clk)begin
        if(z_ecyn_top_wrap.z_ecyn_7k_top.SP_.DMSig122p88Valid) Write_KerIn();
        if(z_ecyn_top_wrap.z_ecyn_7k_top.SP_.z_sp_kg2chol_top.Akernel.UkerValid[0]) Write_KerOut();
        if(z_ecyn_top_wrap.z_ecyn_7k_top.SP_.z_sp_kg2chol_top.Achol_top.state=='d4) Write_DecOut();
        if(z_ecyn_top_wrap.z_ecyn_7k_top.X_A.valid) Write_X();
    end
endmodule


interface vif(input bit clk) ;
    // ---- Simulation Trackers
    int     nTestSamp;
    int     nRecordSamp;
    string  TESTCASE;

    // ---- Global Signals
    logic rn;
    logic en;

    // ---- Data Control & Paths
    logic                          InValid;
    logic [sp_types::SP12_LEN-1:0] TxIn_I_;
    logic [sp_types::SP12_LEN-1:0] TxIn_Q_;
    logic [sp_types::SP12_LEN-1:0] RxIn_I_;
    logic [sp_types::SP12_LEN-1:0] RxIn_Q_;

    logic                          CleanSigValid;
    logic [sp_types::SP12_LEN-1:0] CleanSig_I_;
    logic [sp_types::SP12_LEN-1:0] CleanSig_Q_;
endinterface: vif


class transactor;
    // -- Parameter Definition
    parameter TOT_SAMPLE      = 300000;
    const int EN_START        = 2;
    const int PERIOD          = 6;
    const int TIMEOUT         = 50000000;
    const int RST_START       = 3;
    parameter RST_POLARITY    = 1'd0;
    parameter SYNC            = 0;

    // -- Class declaration
    virtual vif  TVIF;
    SampFile insamp;
    RecordFile outsamp;
    // -- Constructor
    function new(virtual vif vif_in);
        TVIF    = vif_in;
        insamp  = new(vif_in);
        outsamp = new(vif_in);
    endfunction: new
    
    task reset();
        $write("  ---->> Starting Reset...\n");
        TVIF.nTestSamp      = 'd0;
        TVIF.nRecordSamp    = 'd0;
        TVIF.en             = 1'b0;
        TVIF.rn             = RST_POLARITY;
        TVIF.InValid        = 'd0;
        TVIF.TxIn_I_        = 'd0;
        TVIF.TxIn_Q_        = 'd0;
        TVIF.RxIn_I_        = 'd0;
        TVIF.RxIn_Q_        = 'd0;
        # (PERIOD*RST_START)  TVIF.rn = ~RST_POLARITY;
        # (PERIOD*EN_START)   TVIF.en = 1'b1;
        $write("  ---->> Reset completed!\n");
    endtask: reset

    task init(); // Read values from the command lineh
        $value$plusargs("TESTCASE=%s",TVIF.TESTCASE);
        insamp.open();
        insamp.read_tx();
        insamp.read_rx();
        `ifdef WAVEDUMP
            $write("\033[91;1m Recording waveform...\033[0m\n");
            $vcdpluson();
            $vcdplusmemon();
        `endif
    endtask: init

  
    // -- Tasks
    task read_data();
        if (TVIF.InValid) begin
            insamp.read_tx();
            if(TVIF.nTestSamp>SYNC+0)insamp.read_rx();
        end
    endtask: read_data

    task start();
        $display("\n  ---->> Preparing input files...\n");
        @(posedge TVIF.clk);
            insamp.read_rx();
        while(TVIF.nTestSamp <= this.TOT_SAMPLE)
            @(posedge TVIF.clk) this.read_data();
        insamp.close();
    endtask: start

    task set_watchdog();
        # TIMEOUT;
        $system(".result -o");
        insamp.close();
        outsamp.close();
        $finish;
    endtask: set_watchdog

    task record();
        $display("\n  ---->> Preparing output files...\n");
        @(posedge TVIF.clk);
            outsamp.open();
        while(TVIF.nRecordSamp <= this.TOT_SAMPLE)
            @(posedge TVIF.clk)
        if (TVIF.CleanSigValid)  outsamp.record_out();
        $system(".result -f");
        outsamp.close();
        $finish;
    endtask: record


    task run();
        this.reset();
        this.init();
        fork
            this.start();
            this.record();
            this.set_watchdog();
        join_none
    endtask
endclass: transactor





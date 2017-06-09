class RecordFile;
    virtual vif TVIF;
    function new(virtual vif vif_in);
        TVIF = vif_in;
    endfunction: new

    int o_Clean;
    bit flag =0;
    int i_tempi, i_tempq;

    task open();
        string o_path = $sformatf("./outputs/%s/Clean",TVIF.TESTCASE);
        this.o_Clean = $fopen(o_path, "w");

        if(this.o_Clean==0) begin
            `EROR("  Failed to open output files >.<");
            `KILL
        end
    endtask: open

    task close();
        $fclose(this.o_Clean);
    endtask: close

    task record_out();
        i_tempi = $signed(TVIF.CleanSig_I_);
        i_tempq = $signed(TVIF.CleanSig_Q_);
        $fwrite(this.o_Clean, "%d %d\n", i_tempi, i_tempq);// $signed(TVIF.CleanSig_I_), $signed(TVIF.CleanSig_Q_));
        TVIF.nRecordSamp++;
    endtask: record_out
endclass:RecordFile


class SampFile;
    virtual vif TVIF;
    function new(virtual vif vif_in);
        TVIF = vif_in;
    endfunction: new

    int i_tx;
    int i_rx;
    bit flag = 0;

    task open();
        string  tx_path = $sformatf("./inputs/%s/TxIn",TVIF.TESTCASE);
        string  rx_path = $sformatf("./inputs/%s/RxIn",TVIF.TESTCASE);
        this.i_tx = $fopen(tx_path, "r");
        this.i_rx = $fopen(rx_path, "r");
        if(this.i_tx==0 || this.i_rx==0) begin
             `EROR("  Failed to open Sample Input files >.<");
             `KILL
        end
    endtask: open

    task close();
        $fclose(this.i_tx);
        $fclose(this.i_rx);
    endtask: close

    task read_tx();
        int I,Q;
        if ($fscanf(this.i_tx, "%d", I) < 0) this.flag = 1;
        if ($fscanf(this.i_tx, "%d", Q) < 0) this.flag = 1;
        TVIF.TxIn_I_ = I;
        TVIF.TxIn_Q_ = Q;
        if (!this.flag) begin
            $display("  ---->> Sample: %5d completed!", TVIF.nTestSamp);
        end else begin
            `EROR("  Failed to read TX sample %5d >.<", TVIF.nTestSamp);
            `KILL
        end
    endtask
    
    task read_rx();
        int I,Q;
        if ($fscanf(this.i_rx, "%d", I) < 0) this.flag = 1;
        if ($fscanf(this.i_rx, "%d", Q) < 0) this.flag = 1;
        TVIF.RxIn_I_ = I;
        TVIF.RxIn_Q_ = Q;

        if (this.flag) begin
             `EROR("  Failed to read RX sample %5d >.<", TVIF.nTestSamp);
             `KILL
        end
    endtask

endclass: SampFile

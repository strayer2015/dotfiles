#!/usr/bin/env perl
# Author: Chia-Hsiang Chen
my $verilog;
my $testbench;
my $v_fh;
my $tb_fh;

    if($ARGV[0]){
        $verilog = $ARGV[0];
    } else {
            print "Enter the verilog design, and I will generate a simple testbench for you!: ";
                chomp(my $verilog = <STDIN>);
    }


    if(-r $verilog){
        open $v_fh, '<', $verilog or die "Cannot open verilog!\n";
    } else {
        die print "verilog file doesn't exist!\n"
    }


    my $module;
    my @ports;
    my @port_name_i;
    my @port_name_o;

    while(<$v_fh>){
        last if(m/\)\;/);
        next if(m#^\s?//#);
    #   if(m/\)\;/){
    #       last
    #   }
        if(m/module\s+(?<module>\w+)/){
            $module = $+{module};
        }
        if(m/input/ or m/inout/ or m/output/){
            chomp;
            push @ports, $_;
        }
    }
    $testbench = "tb_".$module.".sv";
    if(-s $testbench){
        rename $testbench, "$testbench.bak";
        print "Rename previous testbench to $testbench.bak\n";
    }
    print "Writing simple testbench to $testbench\n";
    open $tb_fh, '>', $testbench or die "Cannot open testbench!\n";

    &print_head();

    sub print_head {
        print $tb_fh "\n`include \"design_list.v\"\n";
        print $tb_fh "`include \"tb_list.v\"\n\n";
        print $tb_fh "module tb_$module();\n";

        print $tb_fh "\t// -- I/O ports\n";
        foreach(@ports){
            (my $wire=$_) =~ s/wire//;
            my $type = 0; #0: output 1: input
            $wire =~ s/\s+\/\/.*\Z//;
            $wire =~ s/(,\s+\Z|,?\Z)/;/;
            if($wire !~ m/Pkg/ || $wire =~ m/LEN/){
                if($wire =~ s/(\s+)?(input|inout)/logic/){
                    $type = 1;
                }
                $wire =~ s/(\s+)?output\s(logic|wire)?/wire/;
            }
            else {$wire =~ s/(\s+)?(input|inout|output)\s?//;}
            print $tb_fh "\t$wire\n";
            1 while $wire =~ s/[.*?]//;
            if($type){
                if($wire =~ m/(?<port_name_i>\w+);/){
                    push @port_name_i, $+{port_name_i};
                }
            } else{
                if($wire =~ m/(?<port_name_o>\w+);/){
                    push @port_name_o, $+{port_name_o};
                }
            }

        }

        print $tb_fh "\n\t// -- Global Signals";
        print $tb_fh "\n\t\tgen_clk #(.PERIOD(1.0)) glb_clk();\n";

        print $tb_fh "\n\t// -- DUT Instance\n";
        print $tb_fh "\t$module z_$module\(\n";
        foreach(@port_name_i){
            if(m/rx_clk/  && !m/_/){
                print $tb_fh "\t\t\.$_\(glb_clk.$_\),\n";
            }else{
                print $tb_fh "\t\t\.$_\($_\),\n";
            }
        }
        foreach(@port_name_o){
            print $tb_fh "\t\t\.$_\($_\),\n" if $_ ne $port_name_o[-1];
        }
        print $tb_fh "\t\t\.$port_name_o[-1]\($port_name_o[-1]\)\n";
        print $tb_fh "\t\);\n";
        print $tb_fh "\t// -- End of DUT Instance\n\n";
        
        # Waveform task
        print $tb_fh "\n\t// -- Waveform \n";
        print $tb_fh "\ttask dump_fsdb();\n";
        print $tb_fh "\t\t".'$display("\033[96;1mINFO: test %0t\033[0m", $time);'."\n";
        print $tb_fh "\t\t".'if ($test$plusargs("dumpFSDB")) begin'."\n";
        print $tb_fh "\t\t\t".'$fsdbDumpfile("waves.fsdb");'."\n";
        print $tb_fh "\t\t\t".'$fsdbDumpvars(tb'."_$module);\n";
        print $tb_fh "\t\tend\n";
        print $tb_fh "\tendtask: dump_fsdb\n";

        # Timeout task
        print $tb_fh "\n\t// -- Timeout watchdog \n";
        print $tb_fh "\tint TIMEOUT = 10000;\n";
        print $tb_fh "\ttask set_watchdog();\n";
        print $tb_fh "\t\t#TIMEOUT\n\t\t";
        print $tb_fh '$system("result.pl -o");';
        print $tb_fh "\n\t\t\$finish;\n";
        print $tb_fh "\tendtask: set_watchdog\n";

        # Run task
        print $tb_fh "\n\t// -- Run task\n";
        print $tb_fh "\tparameter RESET_CYC = 5;\n";
        print $tb_fh "\tint r_counter;\n";
        print $tb_fh "\ttask run();\n";
        print $tb_fh "\t\tr_counter = 0;\n";
        print $tb_fh "\t\twhile(r_counter < RESET_CYC - 1)\n";
        print $tb_fh "\t\t\t@(posedge glb_clk.clk) r_counter++;\n";
        print $tb_fh "\t\t@(posedge glb_clk.clk);\n";
        print $tb_fh "\tendtask: run\n";
        
        # Initialization task 
        print $tb_fh "\n\t// -- Initialization \n";
        print $tb_fh "\ttask init();\n";
        foreach(@port_name_i){
            print $tb_fh "\t\t$_ = 'd0;\n";
        }
        print $tb_fh "\tendtask: init\n\n";

        # Main block
        print $tb_fh "\t// -- Main\n";
        print $tb_fh "\tinitial begin\n";
        print $tb_fh "\t\tinit();\n";
        print $tb_fh "\t\tfork\n";
        print $tb_fh "\t\t\tdump_fsdb();\n";
        print $tb_fh "\t\t\trun();\n";
        print $tb_fh "\t\t\tset_watchdog();\n";
        print $tb_fh "\t\tjoin_none\n";
        print $tb_fh "\tend\n";



        print $tb_fh "endmodule\n";
        close $tb_fh;
   }

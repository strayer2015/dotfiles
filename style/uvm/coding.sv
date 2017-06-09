//expect
    `define expect(nodeName, nodeVal, expVal, cycle) if (nodeVal != expVal) begin \
     $display(“\t ASSERTION on %s FAILED @ CYCLE = %d, 0x%h != EXPECTED 0x%h”, \
     nodeName, cycle, nodeVal, expVal); $stop; end

     `define EROR $write(\033[91;1m ERROR: %0dns %m \n ---->”, $time); $display 
     `define KILL $write(“\033[0m”); $finish;



//interface
    interface x_if;
        logic valid;
        spPkg::SP16 [spPkg::K-1:0] value;
                
        modport out (
            Output valid
            Output value
        );
        modport in (
            Input valid,
            Input value
        );
   endinterface


//package
    package coeff_types;
        parameter X_LEN = 8;
        parameter X_INT = 7;
    endpackage: coeff_types

        package spPkg;
            import sp_types::*;
            parameter K=7;

            typedef struct packed{
                logic signed [LEN-1:0] I,Q;
            } type1
            typedef struct packed{
                 logic signed [LEN2-1:0] I,Q;
            } type2
        }
//TODO
//Calling package
module top import pkg::*;(
    //I/O definition
);

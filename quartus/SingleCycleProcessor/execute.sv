module execute (input  logic AluSrc,
                input  logic [3:0] AluControl,
                input  logic [63:0] PC_E, signImm_E, readData1_E, readData2_E,
                output logic [63:0] PCBranch_E, aluResult_E, writeData_E,
                output logic zero_E 
                );
    
    logic [63:0] sl_out, mux_out;

    adder add(PC_E, sl_out, PCBranch_E);
    sl2 shift(signImm_E, sl_out);
    alu ALU(readData1_E, mux_out, AluControl, aluResult_E, zero_E);
    mux2 mux(readData2_E, signImm_E, AluSrc, mux_out);
    assign writeData_E = readData2_E;
endmodule

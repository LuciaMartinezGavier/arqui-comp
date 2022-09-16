module execute #(parameter N = 64)
    (input  logic [1:0] AluSrc,
     input  logic [3:0] AluControl,
     input  logic [N-1:0] PC_E, signImm_E, readData1_E,
                          readData2_E, readData3_E,
     output logic [N-1:0] PCBranch_E, aluResult_E, writeData_E,
     output logic zero_E 
    );
    
    logic [N-1:0] sl_out, mux_out;

    adder add(PC_E, sl_out, PCBranch_E);
    sl2 shift(signImm_E, sl_out);
    alu ALU(readData1_E, mux_out, AluControl, aluResult_E, zero_E);
    mux4 mux(readData2_E, signImm_E, readData3_E, readData3_E, AluSrc, mux_out);
    assign writeData_E = readData2_E;
endmodule

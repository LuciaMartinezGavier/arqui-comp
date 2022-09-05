module execute_tb();
    logic AluSrc, clk, reset;
    logic [3:0] AluControl;
    logic [63:0] PC_E, signImm_E, readData1_E, readData2_E; // input
    logic [63:0] PCBranch_E, aluResult_E, writeData_E; // output
    logic [63:0] PCBranch_E_expected, aluResult_E_expected, writeData_E_expected;
    logic [31:0] vectornum, errors; //bookkeeping variables

    // AluSrc, AluControl, PC_E, signImm_E, readData1_E, readData2_E
    logic [64:0] test_input [0:9] = '{/*COMPLETAR*/};

    //PCBranch_E, aluResult_E, writeData_E, zero_E
    logic [64:0] test_output [0:9] = '{/*COMPLETAR*/};

    // instantiate device
    execute dut(AluSrc, AluControl, PC_E, signImm_E, readData1_E, readData2_E,
                PCBranch_E, aluResult_E, writeData_E, zero_E);

    // generate clock with 100MH frecuency
    always  begin  // no sensitivity list, so it always executes
        clk = 1; #5; clk = 0; #5; // period 10ns
    end

    initial begin // at start of test pulse reset
        #1;
        vectornum = 0;
        errors = 0;
        reset = 1; #48;
        reset = 0; //reset is 1 for 5 first numbers, then 0
    end

    // apply test vectors on rising edge of clk
    always @(negedge clk) begin //??
        {PAluSrc, AluControl, PC_E, signImm_E,
        readData1_E, readData2_E} = test_input[vectornum];

        {PCBranch_E, aluResult_E, writeData_E, zero_E} = test_output[vectornum]
        #10;
    end

    // check results on falling edge of clk
    always @(posedge clk) 
        if (~reset) begin
            #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                        vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (imem_addr_F !== imem_addr_F_expected) begin
                $display("Error it test %d", vectornum);
                $display("PCBranch_E = %h, (%h expected)", PCBranch_E);
                $display("aluResult_E = %h, (%h expected)", aluResult_E);
                $display("writeData_E = %h, (%h expected)", writeData_E);
                $display("zero_E = %h, (%h expected)", zero_E);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule


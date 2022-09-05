module maindec_tb ();
    logic clk, reset;
    logic [8:0] outexpected;
    logic [10:0] Op; // Input Opcode
    logic Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch; //out
    logic [1:0] ALUOp;

    logic [31:0] vectornum, errors; //bookkeeping variables
    // Op, Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
    logic [19:0] testvectors [0:4] = '{
        20'b11111000010_011110000, // ldur
        20'b11111000000_110001000, // stur
        20'b10110100111_100000101, // cbz
        20'b10001011000_000100010, // add
        20'b11111111111_000000000  // default
    };

    // instantiate device
    maindec dut(Op, Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead,
                MemWrite, Branch, ALUOp);

    // generate clock with 100MH frecuency
    always begin
        clk = 1; #5; clk = 0; #5; // period 10ns
    end

    initial begin
        #1;
        vectornum = 0;
        errors = 0;
        reset = 1; #48;
        reset = 0; //reset is 1 for 5 first numbers, then 0
    end

    // apply test vectors on falling edge of clk
    always @(negedge clk) begin
        {Op, outexpected} = testvectors[vectornum]; #10;
    end

    // check results on rising edge of clk
    always @(posedge clk)
        if (~reset) begin
            #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 20'bx) begin
                $display("%d tests completed with %d errors",
                        vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end
            if ({Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} !== outexpected) begin
                $display("Error: inputs = %b", {Op});
                $display("outputs = %b (%b expected)",{Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} ,outexpected);
                errors = errors + 1;
            end

            vectornum = vectornum + 1;
        end
endmodule

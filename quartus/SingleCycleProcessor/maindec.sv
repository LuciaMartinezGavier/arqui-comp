module maindec(input  logic [10:0] Op,
               output logic Reg2Loc, ALUSrc, MemtoReg, RegWrite,
                            MemRead, MemWrite, Branch,
               output logic [1:0] ALUOp);
    logic [8:0] control;
    always_comb begin
        casez(Op)
            11'b111_1100_0010: control = 9'b0111100_00;  // LDUR
            11'b111_1100_0000: control = 9'b1100010_00;  // STUR
            11'b101_1010_0???: control = 9'b1000001_01;  //  CBZ
            11'b100_0101_1000: control = 9'b0001000_10;  //  ADD
            11'b110_0101_1000: control = 9'b0001000_10;  //  SUB
            11'b100_0101_0000: control = 9'b0001000_10;  //  AND
            11'b101_0101_0000: control = 9'b0001000_10;  //  ORR
            default: control = 0000000_00;               // default
        endcase
        {Reg2Loc, ALUSrc, MemtoReg, RegWrite,
         MemRead, MemWrite, Branch, ALUOp} = control;
    end

endmodule

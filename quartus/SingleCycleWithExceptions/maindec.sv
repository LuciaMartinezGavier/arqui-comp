module maindec (
    input  logic [10:0] Op,
    input  logic reset, ExtIRQ,
    output logic Reg2Loc, MemtoReg, RegWrite, MemRead, 
    output logic MemWrite, Branch, ERet, NotAnInstr,
    output logic [1:0] ALUOp, ALUSrc,
    output logic [3:0] EStatus);

    logic [15:0] control;
    logic [3:0] EStatus_tmp;
    always_comb begin
        if (~reset)
            casez(Op)
                11'b111_1100_0010: control = 16'b10111100_00_0000_0_0 ; // LDUR
                11'b111_1100_0000: control = 16'b10110010_00_0000_0_0 ; // STUR
                11'b101_1010_0???: control = 16'b10010001_01_0000_0_0 ; //  CBZ
                11'b100_0101_1000: control = 16'b00001000_10_0000_0_0 ; //  ADD
                11'b110_0101_1000: control = 16'b00001000_10_0000_0_0 ; //  SUB
                11'b100_0101_0000: control = 16'b00001000_10_0000_0_0 ; //  AND
                11'b101_0101_0000: control = 16'b00001000_10_0000_0_0 ; //  ORR
                11'b110_1011_0100: control = 16'b00010001_01_0000_1_0;  // ERET
                11'b110_1010_1001: control = 16'b11101000_01_0000_0_0;  // MRS
                default:           control = 16'b11100000_00_0010_0_1;  // default
            endcase
        else control = 16'b0;
        {Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp,
         EStatus_tmp, ERet, NotAnInstr} = control;
    if (ExtIRQ && ~reset) EStatus = 4'b0001;
    else EStatus = EStatus_tmp;
    end

endmodule

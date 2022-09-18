// CONTROLLER

module controller
    (input  logic [10:0] instr, ExcAck,reset, ExtIRQ,
     output logic [3:0] AluControl, EStatus,
     output logic [1:0] AluSrc,
     output logic reg2loc, regWrite, Branch, memtoReg, memRead,
                  memWrite, ERet, Exc, ExtIAck
    );

    logic [1:0] AluOp_s;
    logic NotAnInstr_s;

    assign Exc = ExtIRQ || NotAnInstr_s;
    assign ExtIAck = ExcAck && ExtIRQ;

    maindec decPpal (.Op(instr),
                     .reset(reset),
                     .ExtIRQ(ExtIRQ),
                     .Reg2Loc(reg2loc),
                     .ALUSrc(AluSrc),
                     .MemtoReg(memtoReg),
                     .RegWrite(regWrite),
                     .MemRead(memRead),
                     .MemWrite(memWrite),
                     .Branch(Branch),
                     .ERet(ERet),
                     .NotAnInstr(NotAnInstr_s),
                     .ALUOp(AluOp_s),
                     .EStatus(EStatus)
                     );

    aludec decAlu (.funct(instr),
                   .aluop(AluOp_s),
                   .alucontrol(AluControl));
endmodule
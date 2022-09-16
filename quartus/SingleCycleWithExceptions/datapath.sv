// DATAPATH

module datapath #(parameter N = 64)
    (input logic reset, clk, 
    input logic [1:0] AluSrc,
    input logic [3:0] AluControl, EStatus,
    input logic reg2loc, ERet, memRead, memWrite, regWrite,
				branch, memtoReg, Exc,
    input logic [31:0] IM_readData,
    input logic [N-1:0] DM_readData,

    output logic [N-1:0] IM_addr, DM_addr, DM_writeData,
    output logic DM_writeEnable, DM_readEnable, ExcAck);

    logic PCSrc, EProc;
    logic [N-1:0] PCBranch, PCBranch_tmp, writeData_E, writeData3, NextPC;
    logic [N-1:0] signImm, readData1, readData2, readData3, Exc_vector;
    logic zero;


    fetch #(64) fetch (.PCSrc_F(PCSrc),
					   .clk(clk),
					   .reset(reset),
					   .EProc_F(EProc),
					   .PCBranch_F(PCBranch),
					   .NextPC_F(NextPC),
					   .EVAddr_F(Exc_vector),
					   .imem_addr_F(IM_addr));



    decode #(64) decode (.regWrite_D(regWrite),
						 .reg2loc_D(reg2loc),
						 .clk(clk),
						 .writeData3_D(writeData3),
						 .instr_D(IM_readData),
						 .signImm_D(signImm),
						 .readData1_D(readData1),
						 .readData2_D(readData2));



    execute #(64) execute (.AluSrc(AluSrc),
                           .AluControl(AluControl),
                           .PC_E(IM_addr),
                           .signImm_E(signImm),
                           .readData1_E(readData1),
                           .readData2_E(readData2),
						   .readData3_E(readData3),
                           .PCBranch_E(PCBranch_tmp),
                           .aluResult_E(DM_addr),
                           .writeData_E(DM_writeData),
                           .zero_E(zero));



    memory memory (.Branch_M(branch),
                   .zero_M(zero),
                   .PCSrc_M(PCSrc));

    writeback #(64) writeback (.aluResult_W(DM_addr),
                               .DM_readData_W(DM_readData),
                               .memtoReg(memtoReg),
                               .writeData3_W(writeData3));


	exception #(64) exception (.clk(clk),
							   .reset(reset),
							   .Exc(Exc),
							   .ERet(ERet),
							   .EStatus(EStatus),
							   .IM_readData_Ex(IM_readData[13:12]),
							   .NextPC_Ex(NextPC),
							   .imem_addr_Ex(IM_addr),
							   .ExcAck(ExcAck),
							   .readData3_Ex(readData3),
							   .PCBranch_Ex(PCBranch_tmp),
							   .Exc_vector(Exc_vector)
	);

    // Salida de señales de control:
    assign DM_writeEnable = memWrite;
    assign DM_readEnable = memRead;
    
endmodule

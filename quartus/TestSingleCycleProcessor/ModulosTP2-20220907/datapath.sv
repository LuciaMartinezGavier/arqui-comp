// DATAPATH

module datapath #(parameter N = 64)
					(input logic reset, clk,
					input logic reg2loc,									
					input logic AluSrc,
					input logic [3:0] AluControl,
					input logic	Branch,
					input logic memRead,
					input logic memWrite,
					input logic regWrite,	
					input logic memtoReg,									
					input logic [31:0] IM_readData,
					input logic [N-1:0] DM_readData,
					output logic [N-1:0] IM_addr, DM_addr, DM_writeData,
					output logic DM_writeEnable, DM_readEnable );					
					
	logic PCSrc;
	logic [N-1:0] PCBranch, writeData_E, writeData3; 
	logic [N-1:0] signImm, readData1, readData2;
	logic zero;
	
	
	fetch 	#(64) 	FETCH 	(.PCSrc_F(PCSrc),
										.clk(clk),
										.reset(reset),
										.PCBranch_F(PCBranch),
										.imem_addr_F(IM_addr));								
					
											
	
	decode 	#(64) 	DECODE 	(.regWrite_D(regWrite),
										.reg2loc_D(reg2loc), 
										.clk(clk),
										.writeData3_D(writeData3),
										.instr_D(IM_readData), 
										.signImm_D(signImm), 
										.readData1_D(readData1),
										.readData2_D(readData2));				
																									
									
											
	execute 	#(64) 	EXECUTE 	(.AluSrc(AluSrc),
										.AluControl(AluControl),
										.PC_E(IM_addr), 
										.signImm_E(signImm), 
										.readData1_E(readData1), 
										.readData2_E(readData2), 
										.PCBranch_E(PCBranch), 
										.aluResult_E(DM_addr), 
										.writeData_E(DM_writeData), 
										.zero_E(zero));											
											
										
										
	memory				MEMORY	(.Branch_M(Branch), 
										.zero_M(zero), 
										.PCSrc_M(PCSrc));
										
										
										
	writeback #(64) 	WRITEBACK (.aluResult_W(DM_addr), 
										.DM_readData_W(DM_readData), 
										.memtoReg(memtoReg), 
										.writeData3_W(writeData3));		
			
		
		
	// Salida de señales de control:
	assign DM_writeEnable = memWrite;
	assign DM_readEnable = memRead;
	
endmodule

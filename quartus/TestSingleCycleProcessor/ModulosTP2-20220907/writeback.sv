// Etapa: WRITEBACK

module writeback #(parameter N = 64)
					(input logic [N-1:0] aluResult_W, DM_readData_W,
					input logic memtoReg,
					output logic [N-1:0] writeData3_W);					
	
	mux2 #(64) MtoRmux (.d0(aluResult_W), .d1(DM_readData_W), .s(memtoReg), .y(writeData3_W));
	
endmodule

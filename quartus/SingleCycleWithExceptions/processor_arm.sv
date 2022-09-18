// TOP-LEVEL PROCESSOR

module processor_arm #(parameter N = 64) (
	input  logic CLOCK_50, reset,
	input  logic dump, ExtIRQ,
	output logic [N-1:0] DM_writeData, DM_addr,
	output logic DM_writeEnable, ExtIAck
	);
							
	logic [31:0] q;		
	logic [3:0] AluControl, EStatus;
	logic [1:0] AluSrc;
	logic memtoReg, reg2loc, regWrite, Branch, memRead;
	logic memWrite, ERet, Exc, ExcAck;
	logic [N-1:0] DM_readData, IM_address;  //DM_addr, DM_writeData
	logic DM_readEnable;	
	
	controller c (
		.instr(q[31:21]), 
		.ExcAck(ExcAck),
		.reset(reset),
		.ExtIRQ(ExtIRQ),
		.AluControl(AluControl),
		.EStatus(EStatus),
		.reg2loc(reg2loc), 
		.regWrite(regWrite), 
		.AluSrc(AluSrc), 
		.Branch(Branch),
		.memtoReg(memtoReg), 
		.memRead(memRead), 
		.memWrite(memWrite),
		.ERet(ERet),
		.Exc(Exc),
		.ExtIAck(ExcAck)
	);
														
					
	datapath #(64) dp (
		.reset(reset), 
		.clk(CLOCK_50), 
		.AluSrc(AluSrc), 
		.AluControl(AluControl), 
		.EStatus(EStatus),
		.reg2loc(reg2loc),
		.ERet(ERet),
		.memRead(memRead),
		.memWrite(memWrite), 
		.regWrite(regWrite), 
		.Branch(Branch), 
		.memtoReg(memtoReg),
		.Exc(Exc), 
		.IM_readData(q), 
		.DM_readData(DM_readData), 
		.IM_addr(IM_address), 
		.DM_addr(DM_addr), 
		.DM_writeData(DM_writeData), 
		.DM_writeEnable(DM_writeEnable), 
		.DM_readEnable(DM_readEnable),
		.ExcAck(ExcAck)
	);				
					
					
	imem instrMem (
		.addr(IM_address[7:2]),
		.q(q)
	);
									
	
	dmem dataMem (
		.clk(CLOCK_50), 
		.memWrite(DM_writeEnable), 
		.memRead(DM_readEnable), 
		.address(DM_addr[8:3]), 
		.writeData(DM_writeData), 
		.readData(DM_readData), 
		.dump(dump)
	); 				 
 	
endmodule

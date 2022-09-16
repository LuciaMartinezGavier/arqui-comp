module comp_n #(parameter N = 64)
	(input  logic [N-1:0] a, b,
	 output logic y);
	  assign y = (a === b)? 1'b1 : 1'b0;
endmodule

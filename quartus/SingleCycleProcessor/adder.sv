// ADDER

module adder #(parameter N = 64)
					(input logic [N-1:0] a, b,
					output logic [N-1:0] y);
					
	assign y = a + b;
	
endmodule

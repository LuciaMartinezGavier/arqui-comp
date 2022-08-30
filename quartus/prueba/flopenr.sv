module flopenr(input logic clk,
               input logic reset,
               input logic en,
               input logic [3:0] d,
               output logic [3:0] q);

	always_ff @(posedge clk, posedge reset)
	if (reset) q <= 4'b0;
	else if (en) q <= d;
endmodule


module tb_sillyfunction();
	logic clk, reset;
	logic a, b, c, yexpected;
	logic y;
	logic [31:0] vectornum, errors; // bookkeeping variables
	logic [3:0] testvectors [7:0] = '{  4'b000_1, // array of testvectors
										4'b001_0,
										4'b010_0,
										4'b011_0,
										4'b100_1,
										4'b101_1,
										4'b110_0,
										4'b111_0};
							
	// instantiate device under test
	 sillyfunction dut(a, b, c, y);

	// generate clock
	always // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5;
		end
    
		initial // at start of test pulse reset
			begin
				vectornum = 0; errors = 0; reset = 1; #27;
				reset = 0;
			end

	// apply test vectors on rising edge of clk
	always @(posedge clk)
		begin
			#1; {a, b, c, yexpected} = testvectors[vectornum];
		end

	// check results on falling edge of clk
	always @(negedge clk)
		if (~reset) begin // skip during reset
			if (y !== yexpected)
				begin
					$display("Error: inputs = %b", {a, b, c});
					$display("outputs = %b (%b expected)",y,yexpected);
					errors = errors + 1;
				end

	// Note: to print in hexadecimal, use %h. For example,
	// $display(“Error: inputs = %h”, {a, b, c});
	// increment array index and read next testvector
	vectornum = vectornum + 1;
	if (testvectors[vectornum] === 4'bx)
		begin
			$display("%d tests completed with %d errors",
						vectornum, errors);
			$finish; // Usar $stop para que no se cierre ModelSim
		end
	end
endmodule
// === and !== can compare values that are 1, 0, x, or z

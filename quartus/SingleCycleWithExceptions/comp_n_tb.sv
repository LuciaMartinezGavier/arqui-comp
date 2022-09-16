module comp_n_tb ();
    logic clk, reset, y, yexpected;
    logic [63:0] a, b;
    logic [31:0] vectornum, errors; //bookkeeping variables
    logic [128:0] testvectors [0:3] = '{
        {128'h0000000000000000_0000000000000000, 1'b1},
        {128'h10cac01ac0cac01a_0000000000000000, 1'b0},
        {128'h60cac01ac0cac01a_5123456789abcdef, 1'b0},
        {128'h71acacacacacacaa_71acacacacacacaa, 1'b1}
    };

    // instantiate device
    comp_n dut(a, b, y);

    // generate clock with 100MH frecuency
    always // no sensitivity list, so it always executes
        begin
            clk = 1; #5; clk = 0; #5; // period 10ns
        end

        initial // at start of test pulse reset
            begin
                #1;
                vectornum = 0;
                errors = 0;
                reset = 1; #48;
                reset = 0; //reset is 1 for 5 first numbers, then 0
            end

    // apply test vectors on falling edge of clk
    always @(negedge clk)
        begin
            {a, b, yexpected} = testvectors[vectornum]; #10;
        end

    // check results on rising edge of clk
    always @(posedge clk) 
        if (~reset) begin #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                            vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (y !== yexpected)begin
                $display("Error: a = %h, b = %h", a, b);
                $display("y = %b (%b expected)",y ,yexpected);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

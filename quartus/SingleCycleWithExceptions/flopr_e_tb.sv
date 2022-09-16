module flopr_e_tb ();
    logic clk, reset, enable;
    logic [63:0] d, q, qexpected;
    logic [31:0] vectornum, errors; //bookkeeping variables
    logic [128:0] testvectors [0:9] = '{{128'h0123456789abcdef_0000000000000000, 1'b1},
                                        {128'h10cac01ac0cac01a_0000000000000000, 1'b1},
                                        {128'h21acacacacacacaa_0000000000000000, 1'b1},
                                        {128'h3234123412341230_0000000000000000, 1'b0},
                                        {128'h4afafafafafafafa_0000000000000000, 1'b1},
                                        {128'h5123456789abcdef_5123456789abcdef, 1'b1},
                                        {128'h60cac01ac0cac01a_5123456789abcdef, 1'b0},
                                        {128'h71acacacacacacaa_71acacacacacacaa, 1'b1},
                                        {128'h8234123412341230_8234123412341230, 1'b1},
                                        {128'h9afafafafafafafa_8234123412341230, 1'b0}};

    // instantiate device
    flopr_e dut(clk, reset, enable, d, q);

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
            {d, qexpected, enable} = testvectors[vectornum]; #10;
        end

    // check results on rising edge of clk
    always @(posedge clk) begin
        #1;

        // if is undefined, finish
        if (testvectors[vectornum] === 'bx) begin
            $display("%d tests completed with %d errors",
                        vectornum, errors);
            $stop; // Usar $stop para que no se cierre ModelSim
        end

        if (q !== qexpected)
            begin
                $display("Error: inputs = %h", {d});
                $display("outputs = %h (%h expected)",q ,qexpected);
                errors = errors + 1;
            end

    vectornum = vectornum + 1;
    end
endmodule

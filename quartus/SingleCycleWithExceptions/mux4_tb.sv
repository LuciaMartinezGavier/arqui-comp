module mux4_tb ();
    logic clk, reset;
    // input
    logic [7:0] d0, d1, d2, d3;
    logic [1:0] s;
    // output
    logic [7:0] y, yexpected;
    //bookkeeping variables
    logic [31:0] vectornum, errors;
    // instance of d0, d1, d2, d3, s, yexpected
    logic [41:0] testvectors [0:3] = '{
        {32'h01_02_03_04, 2'b00, 8'h01},
        {32'h01_02_03_04, 2'b01, 8'h02},
        {32'h01_02_03_04, 2'b10, 8'h03},
        {32'h01_02_03_04, 2'b11, 8'h04}
    };


    // instantiate device
    mux4 #4 dut(d0, d1, d2, d3, s, y);

    // generate clock with 100MH frecuency
    always // no sensitivity list, so it always executes
        begin
            clk = 1; #5; clk = 0; #5; // period 10ns
        end

        initial
            begin
                #1;
                vectornum = 0;
                errors = 0;
                reset = 1; #48;
                reset = 0; 
            end
        
    // apply test vectors on falling edge of clk
    always @(negedge clk)
        begin
            {d0, d1, d2, d3, s, yexpected} = testvectors[vectornum];
            #10;
        end

    // check results on rising edge of clk
    always @(posedge clk)
        if (~reset) begin #1; // skip during reset

            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                            vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (y !== yexpected) begin
                    $display("Error: d1 = %h, d2 = %h, d3, %h, s = %b", 
                    d0, d1, d2, d3, s);
                    $display("y = %h (%h expected)",y ,yexpected);
                    errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

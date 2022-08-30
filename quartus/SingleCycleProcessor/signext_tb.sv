module signext_tb ();
    logic clk, reset;
    logic [31:0] a;                        // input
    logic [63:0] y, yexpected;            // output, expected output
    logic [31:0] vectornum, errors;  //bookkeeping variables
    logic [95:0] testvectors [0:9] = '{
        {32'b11111000010_000000000_00_00001_00000, 64'h0},                 // LDUR, x0, [x1, #0x0]
        {32'b11111000000_000000000_00_00001_00000, 64'h0},                 // STUR, x0, [x1, #0x0]
        {32'b11111000010_001010001_00_00101_01101, 64'h51},               // LDUR, x5, [x13, #0x51]
        {32'b11111000000_001010001_00_00101_01101, 64'h51},               // STUR, x5, [x13, #0x51]
        {32'b11111000010_101010001_00_00101_01101, 64'hffffffffffffff51}, // LDUR, x5, [x13, #0x151]
        {32'b11111000000_101010001_00_00101_01101, 64'hffffffffffffff51}, // STUR, x5, [x13, #0x151]
        {32'b10110100_0000000000000000000_00000, 64'h0},                 // CBZ x0, #0x0
        {32'b10110100_0000000000000001111_00000, 64'hf},                 // CBZ x0, #0x78000
        {32'b10110100_1011000101110100001_00000, 64'hfffffffffffd8ba1},    // CBZ x0, #0x58ba1
        {32'b10101010101001010101101010110111, 64'h0} // random junk
    };

    // instantiate device
    signext dut(a, y);

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
            {a, yexpected} = testvectors[vectornum]; #10;
        end

    // check results on rising edge of clk
    always @(posedge clk)
        if (~reset) begin // skip during reset
            #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                            vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (y !== yexpected)
                begin
                    $display("Error: inputs = %h", {a});
                    $display("outputs = %h (%h expected)",y ,yexpected);
                    errors = errors + 1;
                end
            vectornum = vectornum + 1;
        end
endmodule

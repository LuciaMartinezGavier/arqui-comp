module alu_tb ();
    logic clk, reset;
    // input
    logic [63:0] a, b;
    logic [3:0] ALUControl;
    // output
    logic [63:0] result, result_expected;
    logic zero, zero_expected;
    //bookkeeping variables
    logic [31:0] vectornum, errors;
    // instance of a, b and ALUControl
    logic [131:0] test_input [0:10] = '{
        {64'h0000_c0ca_c01a_1111, 64'h0000_0123_4567_0000, 4'b0010}, 
        {64'h0000_0000_0000_0000, 64'h0000_0000_0000_0000, 4'b0010}, // 0 + 0
        {64'hffff_ffff_ffff_fffe, 64'hffff_ffff_ffff_fffc, 4'b0010}, // -2 + (-4)
        {64'hffff_ffff_ffff_fffa, 64'h0000_0000_0000_0001, 4'b0010}, // -6 + 1
        {64'h0000_0000_0000_0000, 64'h0000_c0ca_c01a_1111, 4'b0001}, // a or 0
        {64'h0000_0000_0000_0000, 64'h0000_c0ca_c01a_1111, 4'b0000}, // a and 0
        {64'h0ffff, 64'h01111, 4'b0110}, // 65535 - 4369
        {64'hffff_ffff_ffff_fffa, 64'hffff_ffff_ffff_fffc, 4'b0110}, // -6 - (-4)
        {64'hffff_ffff_ffff_fffa, 64'h6, 4'b0110}, // -6 - 6 = -12
        {64'h7fff_ffff_ffff_ffff, 64'h7fff_ffff_ffff_ffff, 4'b0010}, // overflow
        {64'h0, 64'hcaca, 4'b0111} // pass 0xcaca
    };
    // expected result and zero flag given input from test_input
    logic [64:0] test_output [0:10] = '{
        {64'h0, 1'b1}, // 0 + 0 = 0 (is_zero = 1)
        {64'h0000_c1ee_0581_1111, 1'b0}, // 211977038860561 + 1250999861248 = 213228038721809
        {64'hffff_ffff_ffff_fffa, 1'b0}, // -2 + (-4) = -6
        {64'hffff_ffff_ffff_fffb, 1'b0}, // -6 + 1 = -5
        {64'h0000_c0ca_c01a_1111, 1'b0}, // a or 0 = a
        {64'h0, 1'b1}, // a and 0 = 0
        {64'heeee, 1'b0}, // 65535 - 4369 = 61166
        {64'hffff_ffff_ffff_fffe, 1'b0}, // -6 -(-4) = -2
        {64'hffff_ffff_ffff_fff4, 1'b0}, // -6 - 6 = -12
        {64'h0000_0000_0000_0000, 1'b1}, // ?? overflow
        {64'hcaca, 1'b0}
    };

    // instantiate device
    alu dut(a, b, ALUControl, result, zero);

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
                reset = 0;
            end
        
    // apply test vectors on falling edge of clk
    always @(negedge clk)
        begin
            {a, b, ALUControl} = test_input[vectornum];
            {result_expected, zero_expected} = test_output[vectornum];
            #10;
        end

    // check results on rising edge of clk
    always @(posedge clk)
        if (~reset) begin #1; // skip during reset

            // if is undefined, finish
            if (test_input[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                            vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (result !== result_expected) begin
                    $display("Error: a = %h, b = %h, ALUControl = %b", a, b, ALUControl);
                    $display("result = %h (%h expected)",result ,result_expected);
                    errors = errors + 1;
            end

            if (zero !== zero_expected) begin 
                    $display("Error: a = %h, b = %h, ALUControl = %h", a, b, ALUControl);
                    $display("zero = %b (%b expected)",zero, zero_expected);
                    errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

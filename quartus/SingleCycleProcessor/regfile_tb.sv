module regfile_tb ();
    logic clk, reset, we3;
    logic [4:0] ra1, ra2, wa3;
    logic [63:0] wd3;
    logic [63:0] rd1, rd2, rd1expected, rd2expected;
    logic [31:0] vectornum, errors; //bookkeeping variables
    // we3, ra1, ra2, wa3, wd3
    logic [79:0] test_input [0:18] = '{
        // Test inicial values
        {1'b0, 5'd00, 5'd01, 5'd0, 64'd0}, 
        {1'b0, 5'd02, 5'd03, 5'd0, 64'd0}, 
        {1'b0, 5'd04, 5'd05, 5'd0, 64'd0}, 
        {1'b0, 5'd06, 5'd07, 5'd0, 64'd0}, 
        {1'b0, 5'd08, 5'd09, 5'd0, 64'd0}, 
        {1'b0, 5'd10, 5'd11, 5'd0, 64'd0}, 
        {1'b0, 5'd12, 5'd13, 5'd0, 64'd0}, 
        {1'b0, 5'd14, 5'd15, 5'd0, 64'd0},
        {1'b0, 5'd16, 5'd17, 5'd0, 64'd0}, 
        {1'b0, 5'd18, 5'd19, 5'd0, 64'd0}, 
        {1'b0, 5'd20, 5'd21, 5'd0, 64'd0}, 
        {1'b0, 5'd22, 5'd23, 5'd0, 64'd0}, 
        {1'b0, 5'd24, 5'd25, 5'd0, 64'd0}, 
        {1'b0, 5'd26, 5'd27, 5'd0, 64'd0}, 
        {1'b0, 5'd28, 5'd29, 5'd0, 64'd0},
        {1'b0, 5'd30, 5'd31, 5'd0, 64'd0}, 
    
        // Test write value
        {1'b1, 5'd1, 5'd1, 5'd1, 64'hc0cac01a}, 

        // Test if we3 = 0 then content does not alter
        {1'b0, 5'd12, 5'd12, 5'd12, 64'haaaaaaaa}, 

        // Test that X31 always returns 0
        {1'b1, 5'd31, 5'd31, 5'd31, 64'haaaaaaaa}
    };
    // rd1 rd2
    logic [127:0] test_output [0:18] = '{ 
        
        // Test inicial values
        {64'd00, 64'd01}, 
        {64'd02, 64'd03}, 
        {64'd04, 64'd05}, 
        {64'd06, 64'd07}, 
        {64'd08, 64'd09}, 
        {64'd10, 64'd11}, 
        {64'd12, 64'd13}, 
        {64'd14, 64'd15},
        {64'd16, 64'd17}, 
        {64'd18, 64'd19}, 
        {64'd20, 64'd21}, 
        {64'd22, 64'd23}, 
        {64'd24, 64'd25}, 
        {64'd26, 64'd27}, 
        {64'd28, 64'd29},
        {64'd30, 64'd00}, 
    
        // Test write value
        {64'hc0cac01a, 64'hc0cac01a},

        // Test if we3 = 0 then content does not alter
        {64'd12, 64'd12},

        // Test that X31 always returns 0
        {64'h0, 64'h0}
    };
    
    // instantiate device
    regfile dut(clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);
     
    // generate clock with 100MH frecuency
    always begin  // no sensitivity list, so it always executes
        clk = 1; #5; clk = 0; #5; // period 10ns
    end

    initial begin // at start of test pulse reset
        #1;
        vectornum = 0;
        errors = 0;
        reset = 1; #48;
        reset = 0; //reset is 1 for 5 first numbers, then 0
    end

    // apply test vectors on rising edge of clk
    always @(negedge clk) begin //??
        {rd1expected, rd2expected} = test_output[vectornum];
        {we3, ra1, ra2, wa3, wd3} = test_input[vectornum];
        #10;
    end

    // check results on falling edge of clk
    always @(posedge clk) 
        if (~reset) begin
            #1;
            // if is undefined, finish
            if (test_input[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                        vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (rd1 !== rd1expected || rd2 !== rd2expected) begin //??
                $display("Error: inputs = %h", {we3, ra1, ra2, wa3, wd3, rd1, rd2});
                $display("outputs: rd1 = %h (%h expected)", rd2, rd1expected);
                $display("         rd2 = %h (%h expected)", rd2, rd2expected);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

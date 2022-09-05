module fetch_tb();

    logic PCSrc_F, clk, reset;
    logic [63:0] PCBranch_F;
    logic [63:0] imem_addr_F, imem_addr_F_expected;
    logic [31:0] vectornum, errors; //bookkeeping variables

    // PCSrc_F, imem_addr_F_expected
    logic [64:0] testvectors [0:9] = '{
        {1'b0, 64'd4},
        {1'b0, 64'd8},
        {1'b0, 64'd12},
        {1'b0, 64'd16},
        {1'b1, 64'h0},
        {1'b0, 64'd4},
        {1'b0, 64'd8},
        {1'b0, 64'd12},
        {1'b0, 64'd16},
        {1'b0, 64'd20}
    };

    // instantiate device
    fetch dut(PCSrc_F, clk, reset, PCBranch_F, imem_addr_F);

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
        PCBranch_F = 64'h0; // fixed value
    end

    // apply test vectors on rising edge of clk
    always @(negedge clk) begin //??
        {PCSrc_F, imem_addr_F_expected} = testvectors[vectornum];
        #10;
    end

    // check results on falling edge of clk
    always @(posedge clk) 
        if (~reset) begin
            #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                        vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (imem_addr_F !== imem_addr_F_expected) begin
                $display("Error:\nPCSrc_F = %b\nPCBranch_F = %h",
                         PCSrc_F, PCBranch_F);
                $display("outputs: imem_addr_F = %h (%h expected)",
                         imem_addr_F, imem_addr_F_expected);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

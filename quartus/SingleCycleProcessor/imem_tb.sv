module imem_tb ();
    logic clk, reset;
    logic [5:0] addr;
    logic [31:0] q, qexpected; // N = 32 as default
    logic [31:0] vectornum, errors; //bookkeeping variables
    logic [37:0] testvectors [0:49] = '{
        {6'd00, 32'hf8000001},        // STUR X1, [X0, #0]
        {6'd01, 32'hf8008002},        // STUR X2, [X0, #8]
        {6'd02, 32'hf8000203},        // STUR X3, [X16, #0]
        {6'd03, 32'h8b050083},        // ADD X3, X4, X5
        {6'd04, 32'hf8018003},        // STUR X3, [X0, #24]
        {6'd05, 32'hcb050083},        // SUB X3, X4, X5
        {6'd06, 32'hf8020003},        // STUR X3, [X0, #32]
        {6'd07, 32'hcb0a03e4},        // SUB X4, XZR, X10
        {6'd08, 32'hf8028004},        // STUR X4, [X0, #40]
        {6'd09, 32'h8b040064},        // ADD X4, X3, X4
        {6'd10, 32'hf8030004},        // STUR X4, [X0, #48]
        {6'd11, 32'hcb030025},        // SUB X5, X1, X3
        {6'd12, 32'hf8038005},        // STUR X5, [X0, #56]
        {6'd13, 32'h8a1f0145},        // AND X5, X10, XZR
        {6'd14, 32'hf8040005},        // STUR X5, [X0, #64]
        {6'd15, 32'h8a030145},        // AND X5, X10, X3
        {6'd16, 32'hf8048005},        // STUR X5, [X0, #72]
        {6'd17, 32'h8a140294},        // AND X20, X20, X20
        {6'd18, 32'hf8050014},        // STUR X20, [X0, #80]
        {6'd19, 32'haa1f0166},        // ORR X6, X11, XZR
        {6'd20, 32'hf8058006},        // STUR X6, [X0, #88]
        {6'd21, 32'haa030166},        // ORR X6, X11, X3
        {6'd22, 32'hf8060006},        // STUR X6, [X0, #96]
        {6'd23, 32'hf840000c},        // LDUR X12, [X0, #0]
        {6'd24, 32'h8b1f0187},        // ADD X7, X12, XZR
        {6'd25, 32'hf8068007},        // STUR X7, [X0, #104]
        {6'd26, 32'hf807000c},        // STUR X12, [X0, #112]
        {6'd27, 32'h8b0e01bf},        // ADD XZR, X13, X14
        {6'd28, 32'hf807801f},        // STUR XZR, [X0, #120]
        {6'd29, 32'hb4000040},        // CBZ X0, loop1
        {6'd30, 32'hf8080015},        // STUR X21, [X0, #128]
        {6'd31, 32'hf8088015},        // loop1: STUR X21, [X0, #136]
        {6'd32, 32'h8b0103e2},        // ADD X2, XZR, X1
        {6'd33, 32'hcb010042},        // loop2: SUB X2, X2, X1
        {6'd34, 32'h8b0103f8},        // ADD X24, XZR, X1
        {6'd35, 32'hf8090018},        // STUR X24, [X0, #144]
        {6'd36, 32'h8b080000},        // ADD X0, X0, X8
        {6'd37, 32'hb4ffff82},        // CBZ X2, loop2
        {6'd38, 32'hf809001e},        // STUR X30, [X0, #144]
        {6'd39, 32'h8b1e03de},        // ADD X30, X30, X30
        {6'd40, 32'hcb1503f5},        // SUB X21, XZR, X21
        {6'd41, 32'h8b1403de},        // ADD X30, X30, X20
        {6'd42, 32'hf85f83d9},        // LDUR X25, [X30, #-8]
        {6'd43, 32'h8b1e03de},        // ADD X30, X30, X30
        {6'd44, 32'h8b1003de},        // ADD X30, X30, X16
        {6'd45, 32'hf81f83d9},        // STUR X25, [X30, #-8]
        {6'd46, 32'hb400001f},        // finloop: CBZ XZR, finloop
        {6'd47, 32'h00000000},        // empty
        {6'd48, 32'h00000000},        // empty
        {6'd49, 32'h00000000}         // empty
    };

    // instantiate device
    imem dut(addr, q);

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
            {addr, qexpected} = testvectors[vectornum]; #10;
        end

    // check results on rising edge of clk
    always @(posedge clk)
        if (~reset) begin
            #1;
            // if is undefined, finish
            if (testvectors[vectornum] === 'bx) begin
                $display("%d tests completed with %d errors",
                                vectornum, errors);
                $stop; // Usar $stop para que no se cierre ModelSim
            end

            if (q !== qexpected) begin
                $display("Error: inputs = %h", {addr});
                $display("outputs = %h (%h expected)",q ,qexpected);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
        end
endmodule

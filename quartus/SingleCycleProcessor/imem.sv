module imem #(parameter N = 32)
                (input  logic [5:0] addr,
                 output logic [N-1:0] q);

    logic [N-1:0] ROM [0:63] = '{
        32'hf8000001,        // STUR X1, [X0, #0]
        32'hf8008002,        // STUR X2, [X0, #8]
        32'hf8000203,        // STUR X3, [X16, #0]
        32'h8b050083,        // ADD X3, X4, X5
        32'hf8018003,        // STUR X3, [X0, #24]
        32'hcb050083,        // SUB X3, X4, X5
        32'hf8020003,        // STUR X3, [X0, #32]
        32'hcb0a03e4,        // SUB X4, XZR, X10
        32'hf8028004,        // STUR X4, [X0, #40]
        32'h8b040064,        // ADD X4, X3, X4
        32'hf8030004,        // STUR X4, [X0, #48]
        32'hcb030025,        // SUB X5, X1, X3
        32'hf8038005,        // STUR X5, [X0, #56]
        32'h8a1f0145,        // AND X5, X10, XZR
        32'hf8040005,        // STUR X5, [X0, #64]
        32'h8a030145,        // AND X5, X10, X3
        32'hf8048005,        // STUR X5, [X0, #72]
        32'h8a140294,        // AND X20, X20, X20
        32'hf8050014,        // STUR X20, [X0, #80]
        32'haa1f0166,        // ORR X6, X11, XZR
        32'hf8058006,        // STUR X6, [X0, #88]
        32'haa030166,        // ORR X6, X11, X3
        32'hf8060006,        // STUR X6, [X0, #96]
        32'hf840000c,        // LDUR X12, [X0, #0]
        32'h8b1f0187,        // ADD X7, X12, XZR
        32'hf8068007,        // STUR X7, [X0, #104]
        32'hf807000c,        // STUR X12, [X0, #112]
        32'h8b0e01bf,        // ADD XZR, X13, X14
        32'hf807801f,        // STUR XZR, [X0, #120]
        32'hb4000040,        // CBZ X0, loop1
        32'hf8080015,        // STUR X21, [X0, #128]
        32'hf8088015,        // loop1: STUR X21, [X0, #136]
        32'h8b0103e2,        // ADD X2, XZR, X1
        32'hcb010042,        // loop2: SUB X2, X2, X1
        32'h8b0103f8,        // ADD X24, XZR, X1
        32'hf8090018,        // STUR X24, [X0, #144]
        32'h8b080000,        // ADD X0, X0, X8
        32'hb4ffff82,        // CBZ X2, loop2
        32'hf809001e,        // STUR X30, [X0, #144]
        32'h8b1e03de,        // ADD X30, X30, X30
        32'hcb1503f5,        // SUB X21, XZR, X21
        32'h8b1403de,        // ADD X30, X30, X20
        32'hf85f83d9,        // LDUR X25, [X30, #-8]
        32'h8b1e03de,        // ADD X30, X30, X30
        32'h    8b1003de,        // ADD X30, X30, X16
        32'hf81f83d9,        // STUR X25, [X30, #-8]
        32'hb400001f,        // finloop: CBZ XZR, finloop
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0,
        32'h0
    };
    // FIXME: poner default 0 y después rellenar
    assign q = ROM[addr];
endmodule

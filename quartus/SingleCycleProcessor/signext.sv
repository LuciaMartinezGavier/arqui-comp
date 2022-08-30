/*
signext: Extends sign to fit in a 64-bit register.
*/
module signext (input  logic [31:0] a,
                     output logic [63:0] y);
    always_comb
    casez (a[31:21])
        // ldur, stur
        31'b111_1100_00?0: y = {{55{a[20]}}, a[20:12]};

        // cbz (the shifting is done later)
        31'b101_1010_0???: y = {{45{a[23]}}, a[23:5]};

        default: y = 64'b0;
    endcase

endmodule

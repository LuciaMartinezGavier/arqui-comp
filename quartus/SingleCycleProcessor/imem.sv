module imem #(parameter N = 32)
                (input  logic [5:0] addr,
                 output logic [N-1:0] q);

    logic [N-1:0] ROM [0:63] = '{default: 32'h0};
    initial begin
        ROM [0:26] = '{
            32'h8b1f03e9,
            32'hcb1f03ea,
            32'h8b1f028b,
            32'hf800012a,
            32'h8b01014a,
            32'h8b080129,
            32'hcb0a016c,
            32'hb400004c,
            32'hb4ffff7f,
            32'h8b1f03e9,
            32'h8b1f03ea,
            32'h8b1f028b,
            32'hf840012c,
            32'h8b0c014a,
            32'h8b080129,
            32'hcb01016b,
            32'hb400004b,
            32'hb4ffff7f,
            32'hf800012a,
            32'h8b1103e9,
            32'h8b0003ea,
            32'h8b10014a,
            32'hcb010129,
            32'hb4000049,
            32'hb4ffffbf,
            32'hf800000a,
            32'hb400001f
        };
    end
    always_comb begin
        q = ROM[addr];
    end
endmodule

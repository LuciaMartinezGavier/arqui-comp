module flopr #(parameter N = 64)
    (input  logic clk,
     input  logic reset,
     input  logic [N:0] d,
     output logic [N:0] q);

    always_ff @(posedge clk, posedge reset)
        if (reset) q <= 'b0;
        else q <= d;
endmodule
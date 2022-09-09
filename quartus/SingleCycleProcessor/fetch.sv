module fetch #(parameter N = 64)
    (input  logic PCSrc_F, clk, reset,
     input  logic [N-1:0] PCBranch_F,
     output logic [N-1:0] imem_addr_F);

    logic [N-1:0] mux_out, adder_out, flopr_out;

    flopr flop(clk, reset, mux_out, flopr_out);
    mux2 mux(adder_out, PCBranch_F, PCSrc_F, mux_out);
    adder add(flopr_out, 64'd4, adder_out);
    assign imem_addr_F = flopr_out;
    
endmodule

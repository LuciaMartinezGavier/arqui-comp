module fetch (input  logic PCSrc_F, clk, reset,
              input  logic [63:0] PCBranch_F,
              output logic [63:0] imem_addr_F);

    logic [63:0] mux_out, adder_out, flopr_out;

    flopr flop(clk, reset, mux_out, flopr_out);
    mux2 mux(adder_out, PCBranch_F, PCSrc_F, mux_out);
    adder add(flopr_out, 64'd4, adder_out);
    assign imem_addr_F = flopr_out;
    
endmodule

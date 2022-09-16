module fetch #(parameter N = 64) (
    input  logic PCSrc_F, clk, reset, EProc_F,
    input  logic [N-1:0] PCBranch_F, EVAddr_F,
    output logic [N-1:0] imem_addr_F, NextPC_F
    );

    logic [N-1:0] muxA_out, muxB_out, adder_out, flopr_out;

    flopr flop(clk, reset, muxB_out, flopr_out);
    mux2 muxA(adder_out, PCBranch_F, PCSrc_F, muxA_out);
    mux2 muxB(muxA_out, EVAddr_F, EProc_F, muxB_out);
    adder add(flopr_out, 64'd4, adder_out);
    assign imem_addr_F = flopr_out;
    assign NextPC_F = muxA_out;
     
endmodule


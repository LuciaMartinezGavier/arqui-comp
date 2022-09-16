module exception #(parameter N = 64) 
    (   
        input logic clk, reset, Exc, ERet,
        input logic [3:0] EStatus,
        input logic [31:0] IM_readData,
        input logic [N-1:0] NextPC_F, imem_a    ddr_F, PCBranch_E,
    
        output logic ExcAck, 
        output logic [N-1:0] readData3_E, PCBranch_F, Exc_vector,
    );
    
    logic EProc, ExcAck_tmp, esync_out;
    logic [N-1:0] err_out, elr_out;
    logic [3:0] esr_out;

    flopr_e ERR   (clk, reset, EProc, NextPC_F,    err_out);
    flopr_e ELR   (clk, reset, EProc, imem_addr_F, elr_out);
    flopr_e ESR   (clk, reset, EProc, EStatus,     esr_out);

    comp_n  COMPN (Exc_vector, imem_addr_F, ExcAck_tmp);
    esync   ESync (Exc, ExcAck_tmp, reset, esync_out);

    mux2    MUX2  (PCBranch_E, err_out, ERet, PCBranch_F);
    mux4    MUX4  (err_out, elr_out, {60'b0, esr_out},
                   64'b0, IM_readData, readData3_E
                  );

    assign  EProc = esync_out & (~reset);
    assign ExcAck = ExcAck_tmp;
    assign Exc_vector = 64'hD8;

endmodule

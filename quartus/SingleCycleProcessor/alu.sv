module alu #(parameter N = 64)
    (input  logic [N-1:0] a, b,
     input  logic [3:0] ALUControl,
     output logic [N-1:0] result,
     output logic zero);

    always_comb begin
        casez(ALUControl)
            4'b0000: result = a & b;    // a AND b
            4'b0001: result = a | b;     // a  OR b
            4'b0010: result = a + b;    // ADD a, b
            4'b0110:    result = a - b;    // SUB a - b
            4'b0111: result = b;         // PASS INPUT b
            default: result = {64{1'b1}};
        endcase
        zero = result ? 1'b0:1'b1;
    end
endmodule

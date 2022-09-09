/*
Regfile:
Reads registers in addres ra1 and ra2 (asyncronous).
If we3 is active, writes data in register in address wa3 (syncronous).
*/
module regfile #(parameter N = 64)
    (input  logic clk, we3,                // control
     input  logic [4:0] ra1, ra2, wa3,     // adrress
     input  logic [N-1:0] wd3,              // write data
     output logic [N-1:0] rd1, rd2          // read data
    );

    // inicialization
    logic [N-1:0] rf [0:31] = '{64'd00, 64'd01, 64'd02, 64'd03, 64'd04, 64'd05,
                               64'd06, 64'd07, 64'd08, 64'd09, 64'd10, 64'd11,
                               64'd12, 64'd13, 64'd14, 64'd15, 64'd16, 64'd17,
                               64'd18, 64'd19, 64'd20, 64'd21, 64'd22, 64'd23,
                               64'd24, 64'd25, 64'd26, 64'd27, 64'd28, 64'd29,
                               64'd30, 64'd0};
    // FIXME: Inicializar con default 0 y después rellenar
    // read (concurrent)
    // if register is X31, always read 0.
    assign rd1 = (ra1 == 5'd31) ? 64'b0 : rf[ra1];
    assign rd2 = (ra2 == 5'd31) ? 64'b0 : rf[ra2];

    
    // write syncronous regarding clock
    always_ff @(posedge clk)
        if (we3) rf[wa3] <= wd3;
endmodule
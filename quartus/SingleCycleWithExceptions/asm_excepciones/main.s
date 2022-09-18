.text
.org 0x00
add x0,x0,x0
add x0,x0,x0
loop: 
cbz x0, loop


// Vector de excepciones
.org 0xD8
mrs X0, S2_0_C0_C0_0 // ERR
mrs X1, S2_0_C1_C0_0 // ELR
mrs X2, S2_0_C2_C0_0 // ESR
eret

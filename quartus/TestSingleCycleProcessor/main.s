/*
 * Inicializar con el valor de su índice las
 * primeras N posiciones de memoria (del 0 al 19).
 * Registros leídos y escritos    = X9, X10, X11, X12;
 * Registros leídos y no escritos = X1, X8, X20, X31
 */


ADD  X9, XZR, XZR               @ Inicializar  X9 con 0 (indice)
SUB X10, XZR, XZR               @ Inicializar X10 con 0 (valor)
ADD X11, X20, XZR               @ Inicializar X11 con N = 20
loop:
    STUR X10, [X9, #0]          @ Guardar X10 en memoria
    ADD  X10, X10,  X1          @ Siguiente valor +1
    ADD   X9,  X9,  X8          @ Siguiente posición de memoria +8
    SUB X12, X11, X10            @ Comparar que X10 sea N
    CBZ X12, end                @ Si no son iguales entonces seguir
    CBZ XZR, loop
end:

/*
8b1f03e9
cb1f03ea
8b1f028b
f800012a
8b01014a
8b080129
cb0a016c
b400004c
b4ffff7f
*/

/*
 * Realizar la sumatoria de las primeras N posiciones (del 0 al 19)
 * de memoria y guardar el resultado en la posición N+1 (pos 20).
 * Regisros leídos y escritos    = X9, X10, X11, X12    
 * Regisros leídos y no escritos = X1, X8, X20, XZR
 */

ADD  X9, XZR, XZR               @ Inicializar  X9 con 0 (indice array)
ADD X10, XZR, XZR               @ Inicializar X10 con 0 (suma)
ADD X11, X20, XZR               @ Inicializar X11 con N = 20

loop:
    LDUR X12, [X9, #0]          @ Leer de memoria en la posición X9
    ADD  X10, X10, X12          @ Sumar valor leído
    ADD   X9, X9, X8            @ Siguiente posición de memoria +8
    SUB  X11, X11, X1           @ Registrar iteración en X11
    CBZ  X11, end
    CBZ XZR, loop          
end:
    STUR X10, [X9, #0]         @ Guardar la suma en la siguiete posicion


/*
8b1f03e9,
cb1f03ea,
8b1f028b,
f800012a,
8b01014a,
8b080129,
cb0a016c,
b400004c,
b4ffff7f,
8b1f03e9,
8b1f03ea,
8b1f028b,
f840012c,
8b0c014a,
8b080129,
cb01016b,
b400004b,
b4ffff7f,
f800012a
b400001f

 */
/*
 * Realizar la multiplicación de dos registros: X16 y X17
 * y guardar el resultado en la posición “0” de la memoria.
 * (Se podría sacar el uso del registro X9, pero quería solo pisar temporales)
 * Registros leídos y escritos = X9, X10
 * Registros leídos y no escritos = X0, X1, X16, X17, XZR
 */

ADD  X9, XZR, X17                @ Inicializar X9 con X17
ADD X10, XZR, X0                 @ Inciaializar X10 con 0 (producto)

loop:
    ADD X10, X10, X16           @ Sumar a X10 el valor X16, X17 veces
    SUB  X9,  X9,  X1           @ Registrar la iteración en X9
    CBZ X9, end
    CBZ XZR, loop
end:
    STUR X10, [X0, #0]        @ Guardar el producto en la posición 0

/*
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

 */
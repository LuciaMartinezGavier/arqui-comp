# Introducción a System Verilog

## HL a Gates
 **Simulación**
* Inputs aplicados a un circuito.
* Output chequeado para la correctitud.
* Es mejor debuggear en la simulación.

**Síntesis**
* Transforma el código HDL en una *netlist* que describe el hardware 
* La lógica del sintetizador puede hacer optimizaciones para redudir la cantidad de hardware requerido.

## Módulos
### Comportamental SystemVerilog:
describe lo que hace un módulo. Describe un módulo en términos de las relaciones entre inputs y outputs

```verilog
// Boolean function y = a'b'c' + ab'c' + ab'c
module example (input  logic a, b, c,
				output logic y);
	assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;

endmodule 
```
`module/endmodule:` requerido para comenzar y terminar el módulo. Un módulo representa un circuito.
`logic` siempre vamos a utilizar logic. Una variable puede tomar valor 0, 1, 'z' (entrada libre, no deberíamos ver ninguna), 'x' (valor desconocido imposible de calcular). Declaración de tipos de cables por eso se usa `input`  o  `output` . Un solo bit.
`assing` describe  **lógica combinacional**.

'z' = valor indererminado. **Alta impedancia**.
'x' = la basura que queda en un flip flop por ejemplo. Si hay muchas x's algo está maliendo sal.

### **Structural**
Cómo se conectan las compuertas
describe como está construído desde módulos más simples.

## HDL Simulation
### Test
cuando se pueda hacer **test exahustivo**: probar todos los valores de la tabla de verdad
O probar algunos casos clave.

## Sintaxis
Case sensitive
Los nombres de los módulos no empiezan con número
Los espacios en blanco se ignoran
Comentarios como en C `// una línea` o `/* multilinea */`

<!-- tabla de precedencias-->

#### Bitwise Operation
```verilog
module inv (input  logic [3:0] a,
		    output logic [3:0] y);
	assign y = ~a;
endmodule
```

El bit 0 es el menos significativo 1000 es 8
Operacion es bit a bit poruqe el bus de entrada es igual al bus de salida.

Todo lo que se **declara** dentro de un módulo es **concurrente**.
Todo lo que pasa en la lógica combinacional se actualiza cuando se produce una entrada.

Las asignaciones **continuas** (=) todo el tiempo está conectado el cable (se evalúa todo el tiepo, no es discontinuo en el tiempo). 

### Operaciones de reducción
La salida tiene 1 solo bit.

```verilog
module and8 (input  logic [7:0] a,
			 output logic       y);
	assign y = &a;
endmodule
```

Hace la & (and) de todos los bits de a. Es equivalente a `y =  a[0] & a[1] & ...`.

### Asignación condicional
Para multiplexores.
```verilog
module mux2 (input  logic [3:0] d0, d1m
			 input  logic       s,
			 output logic [3:0] y);
	assign y = s ? d1 : d0; // operador ternario
endmodule
```

### Numeros
Siempre ser lo más claros posibles. Para no confundir al sintetizador. Probrecito.
**Format:**
* N'Bvalue
* N = number of bits, B = base.
* SystemVerilog supports 'b for binary, 'o for octal, 'd for decimal and 'h for hexadecimal.
* N'B is optional but recommended (default is decimal).
* '0 and '1: filling a bus with all 0s or all 1s, respectively.
* Los guiones bajos se ignoran en los números `8'b1010_1011`


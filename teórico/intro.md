# Introducción

* HDL: Hardware description Language
* FPGA: Field Programmable Gate Array
* SISD: Simple Instruction Simple Data
* SIMD: Simple Instruction Multiple Data
* RISC: Reduced Instruction Set Computer
* CISC: Complex Instruction Set Computer
* IEEE: Institute of Electrical and Electronics Engineers (IE³)

## Hardware Description Languages
* Proveen una descripción abstracta del hardware para simular y debuguear el
diseño.
* Pueden ser compilados a la implementación del hardwate mediante el uso de
síntesis lógica y herramientas de compilación de hardaware.

## VHDL y System Verilog
### VHDL
*VHDL*: Derivado del lenguaje Ada.
VHDL: VHSIC Hardware Description Language
VHSIC: Very High Speed Integrated Circuits

```vhdl
library IEEE; use IEEE.STD_LOGIC_1164.all;

entity sillyfunction is
    port(a, b, c: in  STD_LOGIC;
         y:       out STD_LOGIC);
end;

architecture synth of sillyfunction is
begin
    y <= ((not a) and (not b) and (not c)) or 
          (a and (not b) and (not c)) or
          (a and (not b) and c);
end;
```
Se puede trabajar con vectores

```vhdl
# descripción de un sumador
library IEEE; use IEEE.STD_LOGIC_1164.all;

entity adder is
    port(a, b, c: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
         y:       out STD_LOGIC_VECTOR(31 DOWNTO 0));
end;

architecture synth of adder is
begin
    y <= a + b;
end;
```

### Sysstem Verilog
Mejora de *Verilog*

```verilog
module sillyfunction(inpur logic a, b, c,
                     output logic y);

    assign y = ~a & ~b & ~c |
                a & ~b & ~c |
                a & ~b & c;
end module  
```
~ : es bit a bit
Se pueden sintetizar y simular estos módulos.
La sintetización optimiza y dibuja el circuito.

Como en VHDL, se pueden usar vectores
```verilog
# Sumador puede terner problemas de overflow
module sillyfunction(input  logic [31:0] a,
                     input  logic [31:0] b,
                     output logic [31:0] y);

    assign y = a + b;
end module
```

## Un Estudio Comparativos

|   VHDL  |System Verilog |
|  ------ | ------------- |
| verboso | parecido a *C*|


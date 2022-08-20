# Introducción a FPGA

## ¿Qué son las FPGAs?
Arreglos de Compuertas Programables en Campo
Programables: Configurables

Son circuitos integrados digitales que contienen bloques lógicos programables junto con interconexiones configurables entre dichos bloques.
Electrónica digital

## Microprocesador, ASIC, FPGA
La diferencia está en cómo fueron fabricadas.

| Microporocesador|ASIC (Aplication Specific IC) | FPGA|
|--- | --- | --- |
|Hardware fijo. Las funciones se realizan en software | Diseñado para implementar una función lógica particular. "Hechos a medida". Hardware fijo. | Las funciones se realizan en hardware. No son hechas a medida por lo que el usuario puede configurarlas de acuerdo a sus necesidades. |

## ¿Cómo se configuran las FPGAs?
* Configurables en campo "in the field" lo hace el desarrollador (miles de veces). 
* Hay alginas que puden ser proegramadas una sola vez. OTP: One Time Programmable. 
* Si un dispositivo puede ser programado mientras embebido en un sistema mayor, se dice que es ISP (In System Programmable)

## Elementos básicos de una FPGA
Secreto de los fabricantes: como se configura. Cómo se modifica el hardware de acuerdo a la configuración que hace el desarrollador.

* Elementos lógicos: núcleo central (le da el funcionamiento)
* Recursos de memoria: Bloques de memoria que se pueden conectar de diferentes formas.
* I/O configurables: Dispositivos con muchas patas. Los pines son configurables.
* Recursos de ruteo: son los programables
* bloque DSP (multiplicadores). Bloque matemático?
* Recursos adicionales: hardware adicional para que no se gasten los elementos lógicos.

![](https://imgur.com/1cSPFNm.png)

### LUT (elementos lógicos) Look up table
Memoria con la tabla de verdad de 2³ = 8 o 2⁴ = 16 casos.
Se implementa con un multiplexor

Todas las FPGA se basan en arrays de pequeños elementos de lógica digital.
Para usar un determinado dispositivo, los problemas de lógica digital deben ser
descompuestos en circuitos lógicos que puedan ser mapeados en una o más
de estas “celdas lógicas”.

![](https://imgur.com/yJGafwg.png)

### LAB (Logic Array BLocks: Bloques de Arreglos lógicis)
Contiednen grupos de LEs (varios pero no tantos):

![](https://imgur.com/DM87ntC.png)

Unidad logica con estructuras de interconexión. 

### Recursos de memoria
Circuitos de Retención de datos.
las FPGAs cuentan con bloques de memoria disponibles. La cantidad de bloques disponibles depende del tamaño de la FPGA.

### I/O Configurable
Para poder recibir y transmitir señales digitales, las FPGAs disponen de un
complejo bloque de E/S que posibilita su uso en muy diversos rangos de
tensiones, frecuencias de trabajo, estándares de señales digitales, etc., lo que
las hace muy adaptables a las necesidades del sistema del que forman parte.
Existe un bloque E/S por cada terminal de la FPGA, por lo que cada una puede
ser configurada como entrada, como salida o bidireccional.

## Flujo de diseño
* **Design Entry**: El circuito deseado es especificado mediante un diagrama
  esquemático o utilizando algún lenguaje de descripción de Hardware como
  SystemVerilog.
* **Synthesis**: A partir del diseño ingresado, se infiere la lógica correspondiente
  y se sintetiza a un circuito utilizando los elementos lógicos (LEs) del chip
  FPGA.
* Functional Simulation: Se verifica la funcionalidad del diseño sintetizado
  mediante simulación.
* **Placement & Routing**: acá se pueden hacer la mayor cantidad de análisis (de diseño 
  electrónico). Cuantas y cuales LUTs voy a usar. Configurar la interconexión.
  (Tambien se llama Fitting) La herramienta Fitter determina la ubicación de los LEs del diseño en los LEs disponibles en el chip FPGA y elige las interconecciones entre ellos.
* Timing Analisis: Para hacer simulación funcional ¿Va a la velocidad que
  necesito?
* **Configuration**: El circuito diseñado es implementado físicamente en el chip
  FPGA.

## ¿Para qué se usan las FPGAs?
* DSP (procesamiento digital de señales)
* Sistemas aeroespaciales y de defensa
* Prototipos de ASICs
* Sistemas para medicina
* Bioinformática
* Computación reconfigurable
* Inteligencia artificial
* Emulación de hardware de computadora, entre otras


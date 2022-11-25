# I/O y excepciones

Las excepciones son eventos diferentes a los branches que cambian el flujo normal de la ejecución de instrucciones.

El microprocesador se comunica con otros dispositivos usando alguno de sus pines.
Formas de direccionar los puertos.

+ **Port-based I/O** (Arquitecturas antiguas)
  + Se direcciona al igual que se redireccionan registros.
  + Son N puertos de M bits(no tantos).
  + Había instrucciones especiales para comunicarse con esos puertos.
+ **Bus-based I/O** (Hoy)
  + Se conectan a un único bus de datos del sistema (address, datos, control, i/o)
  + En el procesador se construye un protocolo de comunicación.
  + Hay pocos estándares de conexión.

## Bus-based I/O

El procesador **se comunica con la memoria y periféricos usando el mismo bus**. Hay dos formas de comunicación con periféricos: (dependen de las arquitecturas)

+ **Memory-mapped I/O** (ARM o Risk)
  + Peripheral registers occupy addresses in same address space as memory
  + Los registros periféricos ocupan direcciones en el mismo espacio de direcciones que la memoria: Se comparte el mapa.
  + No se necesitan instrucciones de assembler nuevas (se usan LOAD y STORE).
  + e.g., Bus has 16-bit address
    + lower 32 K addresses may correspond to memory
    + upper 32 K addresses may correspond to peripherals
  + Las computadoras actuales no tienen tantas interfaces de I/O, entonces tiene más sentido usar esta distribución.
  + Hay un rango de direcciones de memoria y otro de puertos.
+ **Standard I/O (I/O-mapped)** (Intel)
  + El procesador tiene **instrucciones diferentes** de Assembly para la ram y instrucciones para la I/O.
  + Se pone una **señal de control** para determinar esto. Additional pin (**M/IO**) on bus indicates whether a memory or peripheral access.
  + Mapa dedicado para entrada salida y otro para memoria.
  + La ventaja es que no me desperdicia espacio de memoria
  + all 64 K addresses correspond to memory when M/IO set to 0.
  + all 64 K addresses correspond to peripherals when M/IO set to 1.

## Métodos de Operaciones I/O

### E/S Programada - Polling-driven

|                                                                                                                                                                                                    Polling | -                                  |     |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:| ---------------------------------- | --- |
| El manejo se realiza mediante el uso de instrucciones de E/S por código de programa. **Principal desventaja:** se desperdician muchos ciclos de instrucción en revisar el estado del módulo E/S (polling). | ![a](https://imgur.com/7WkGanq.png) |     |

El polling se realiza por software. Incluidos los lazos de espera.
El procesador es inútil durante el polling.
No hay interacción directa entre el procesador y la E/S.

### Interrupción

Los módulos de entrada salida pueden interrumpir al procesador.

+ Es un recurso de HW propio de la CPU: señal de Int externa para periféricos.
+ Es literalmente una “interrupción” o quiebre de la ejecución normal del código de programa
+ Al **finalizar cada ciclo de instrucción el CPU verifica automáticamente si hay Int pendientes**.
+ De esta forma el “polling” lo realiza la CPU por HW: **no consume ciclos de instrucción**!!
+ Hay un cable que conecta a los módulos de I/O y a la CPU, *Int* para interrumpir el flujo normal de interrupciones: Obliga a un salto incondicional. Si hay Int, el CPU salta automáticamente a una posición de memoria especifica llamada **vector de interrupciones**.
+ El vector de interrupciones contiene el código (o su referencia) con los **procedimientos** necesarios para dar servicio a dicha interrupción. Este código se denomina **ISR** (*Interrupt Service Routine*)

#### Donde se aloja la ISR? (interrupt address vector)

+ **Dirección fija** (Fixed interrupt)
  + La dirección esta **establecida en la lógica de la CPU**, no puede ser modificada
  + La CPU puede contener la dirección real, o contener una instrucción de salto a la dirección real de la ISR si no hay suficiente espacio reservado.
  + Para sistemas chicos donde no hay muchos eventos que pueden generar interrupciones.
+ **Dirección vectorizada** (Vectored interrupt)
  + El periférico provee la dirección al CPU por medio del bus de datos
  + Para esto, se agrega una señal mas: **INT ACK**.
  + Muy utilizado en sistemas con múltiples periféricos conectados por un bus.

| E/S genera interrupción | →   | Procesador reconoce la instrucción, levanta la señal INT ACK | →   | Periferico pone en el bus de datos la dirección de su vector de interrupciones. | → |Procesador ejecuta el código que indica el vector de interrupciones. |
| ----------------------- | --- | ------------------------------------------------------------ | --- | ------------------------------------------------------------------------------- | --- |-------------------------------------------------------------------- |
|                         |     |                                                              |     |                                                                                 |      |                                                                |
![a](https://imgur.com/gvcvqJ2.png)

\* "controlador de HW" se refuere a un controlador de entrada salida.
\* CPU guarda el PC y status para poder restablecerse.

### DMA (Direct Memory Access)

+ Se incorporan módulos DMA.
+ Le sacan la responsabilidad al procesador de hacer el movimiento de datos de E/S y la memoria.
+ Es un trabajo muy automático, entonces se relega a otro módulo para que el procesador se aproveche mejor.
+ La CPU ya no accede al módulo de entrada salida.

## Interrupciones Enmascarables vs no-enmascarables

+ **Enmascarables:** El procesador las puede ignorar. El periférico genera una interrupción pero el procesador si tiene una señal de "no molestar" GEI ("*general enable interrupts*") entonces esa interrupción se ignora.
+ **No-enmascarables:** se deben atender si o si. El procesador no puede seguir ejecutando instrucciones. Internas a la CPU

Usamos el término *excepción* para referirnos a *cualquier* **cambio de control** si es no-enmascarable y en general es interna; usamos el término *interrupción* solo cuando el evento fue **causado externamente**, estos son enmascarables.

## Múltiples periféricos: Arbitraje

Considere la situación donde muchos periféricos solicitan el servicio de una CPU simultáneamente (microcontrolador) – **Cual será atendida primero y en que orden?**

+ **Software polling**
  + Muy simple implementación por HW (una sola línea de INT).
  + Se va preguntado a cada periférico si fue el generador de la interrupción.
  + El programador debe determinar en la ISR el origen de la INT buscando banderas **INT FLG**.
  + La prioridad es establecida en la ISR según el orden de la búsqueda.
+ **Arbitro de prioridades (Priority arbiter)**
  + Un módulo que se encarga de gestionar pedidos de interrupciones. Y este es quien interrumpen al procesador.
  + Es el más utilizado
+ **Conexión en cadena (Daisy chain)**
  + Barato de implementar pero poco versátil.
  + La prioridad está dada por la posición de los periféricos.
  + La interrupción se va propagando hasta llegar al micro.
+ **Arbitraje de bus (Network-oriented)**
  + Utilizado en arquitecturas de múltiples procesadores.
  + El periférico debe primero obtener la sesión del bus para luego requerir una interrupción.

### Árbitro de prioridades

+ El árbitro tiene un canal dedicado a cada periférico.
+ Esquema vectorizado.
+ El periférico hace la petición INT REQ al controlador, y esta a la CPU.En orden inverso para los INT ACK.
+ Tiene un canal para cada .

#### Esquema de prioridades

+ Fijo configurable (es el más común)
+ Round-Robin
+ FIFO

![a](https://imgur.com/cj2Iaau.png)

### Conexión en cadena

+ La lógica de control de arbitraje esta embebida en cada periférico: Se agrega una señal de entrada *IntReq* y de salida *IntAck*
+ Los periféricos difunden la señal IntReq hacia el CPU y la señal IntAck hacia el origen de la interrupción

![a](https://imgur.com/ORAh0jd.png)

+ Ideal si es necesario agregar o sacar periféricos
+ Bajo rendimiento con muchos periféricos
+ Es necesario agregar lógica por seguridad (periférico fuera de servicio)
+ Esquema de prioridad único

## Excepciones e Interrupciones

Excepción: Los eventos "inesperados" que requieren un cambio en el flujo de control. Pueden provenir de la CPU.
Interrupt: De un controlador externo de I/O.

### Manejo de excepciones

El procesador debe poder:

+ Guardar el PC de la instrucción interrumpida.
  + Se guarda en el registro *ELR* (*Exception Link Register*)
+ Guardar el indicador el problema. (¿Quién generó la excepción?)
  + Se guarda en el registro *ESR* (*Exception Syndrome Register*)
  + Asumimos que es de 1 bit (0 por opcode indefinido y 1  por overflow
+ Guardar el valor que hubiese tenido la dirección de la próxima instrucción que se hubiera ejecutado.
  + *ERR* (*Exception Return Register*) Es propio de nuestro micro
  + Sirve para saltos, donde la instrucción a la cual quiero volver no es el valor de PC + 4.
  + Saca el valor de lo que se hubiera cargado en el PC de no ser por la excepción

## Procesador con Excepciones

Se agregan las interfaces *ExtIRQ* (*External Interrupt Request*) y *ExtAck* (*External Interrupt acknowledge*) para que el procesador pueda atender excepciones. Ya sean señales producidas por un periférico o el árbitro de prioridades.

![a](https://imgur.com/pEvyKT1.png)

+ *EStatus*: informa la excepción que se produjo
+ *Exc*: Indica que se produjo una excepción
+ *ExcAck*: Indica que se está procesando la excepción
+ *ERet*: Determina si se va a utilizar el ERR

## Nuevas instrucciones

+ *ERET* (Exception Return)
  + Type: R - OpCode: `1101011(0100)`
  + Sintaxis: `ERET`
  + Semántica: Cuando se termina de ejecutar el vector de excepciones y quiero volver a donde me sacaron ejecuto ERET
+ *MRS* (*Move (from)SystemReg to GeneralPurposeReg*)
  + Sintaxis: `MRS <Rt>, <systemReg>`
  + Semántica: Lee un registro de sistema (los que creamos nuevos: ERR, ELR, ESR) y lo vuelva en un registro de propósito general (los de siempre).
  + Type: S (new!) - OpCode: `1101010100(1)`
  + \<systemReg> = “S<2+op0>\_\<op1>\_\<CRn>\_\<CRm>\_\<op2>”
    + `S2_0_C0_C0_0` → ERR
    + `S2_0_C1_C0_0` → ELR
    + `S2_0_C2_C0_0` → ESR
    + `S2_0_C3_C0_0` → Reserved

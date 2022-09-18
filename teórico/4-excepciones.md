# I/O y excepciones
El microprocesador se comunica con otros dispositivos usando alguno de sus pines.
+ **Port-based I/O** (Arquitecturas antiguas)
	+ Se direcciona al igual que se redireccionan registros
	+ Son N puertos (no tantos).
+ **Bus-based I/O** (Hoy)
	+ Se conectan a un único bus de datos del sistema (address, datos, control, i/o)
	+ En el procesador se construye un protocolo de comunicación.

## Bus-based I/O
El procesador se comunica con la memoria y periféricos usando el mismo bus. Hay dos formas de comunicación con periféricos:
+ **Memory-mapped I/O** (ARM)
	+ Peripheral registers occupy addresses in same address space as memory 
	+ Se comparte el mapa.
	+ No se necesitan instrucciones de assembler nuevas (se usan LOAD y STORE).
	+ e.g., Bus has 16-bit address
	+ lower 32 K addresses may correspond to memory 
	+ upper 32 K addresses may correspond to peripherals
	+ Las computadoras actuales no tienen tantas interfaces de I/O, entonces tiene más sentido usar esta.
+ **Standard I/O (I/O-mapped)** (Intel)
	+ El procesador tiene instrucciones de Assembly para la ram y instrucciones para la I/O.
	+ Se pone una señal de control para determinar esto. Additional pin (M/IO) on bus indicates whether a memory or peripheral access
	+ Mapa dedicado para entrada salida y otro para memoria
	+ all 64 K addresses correspond to memory when M/IO set to 0
	+ all 64 K addresses correspond to peripherals when M/IO set to 1

## Métodos de Operaciones I/O

### E/S Programada
+ El manejo se realiza mediante el uso de instrucciones de E/S por código de programa 
+ Principal desventaja: se desperdician muchos ciclos de instrucción en revisar el estado del módulo E/S (polling)

### Interrupción
+ Es un recurso de HW propio de la CPU: señal de Int externa para periféricos
+ Es literalmente una “interrupción” o quiebre de la ejecución normal del código de programa
+ Al finalizar cada ciclo de instrucción el CPU verifica automáticamente si hay Int pendientes. 
+ De esta forma el “polling” lo realiza la CPU por HW: no consume ciclos de instrucción!! 
+ Si hay Int, el CPU salta automáticamente a una posición de memoria especifica llamada vector de interrupciones.
+ El vector de interrupciones contiene el código (o su referencia) con los procedimientos necesarios para dar servicio a dicha interrupción. Este código se denomina **ISR** (*Interrupt Service Routine*)

#### Donde se aloja la ISR? (interrupt address vector) 
+ **Dirección fija** (Fixed interrupt) 
	+ La dirección esta establecida en la lógica de la CPU, no puede ser modificada 
	+ La CPU puede contener la dirección real, o contener una instrucción de salto a la dirección real de la ISR si no hay suficiente espacio reservado.
+ **Dirección vectorizada** (Vectored interrupt) 
	+ El periférico provee la dirección al CPU por medio del bus de datos 
	+ Para esto, se agrega una señal mas: INT ACK. 
	+ Muy utilizado en sistemas con múltiples periféricos conectados por un bus.

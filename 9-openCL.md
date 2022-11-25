# Introducción a OpenCL

Estándar que permite hacer programas que se ejecuten en paralelo en dispositivos heterogeneos (se abstrae de la arquitectura).

Permite aprender un solo "lenguaje" y hacer código que se paralelice en cualquier arquitectura.

Bibliografía: *Heterogeneous Computing with OpenCL*

No hay una arquitectura que sea buena para cualquier tipo de problema.

Si tenemos un código con muchos condicionales y no es muy regular, conviene usar un CPU

Si es altamente paralelizable, se hace muchas veces lo mismo con los mismos datos conviene usar una GPU.

## Arquitectura

Necesitamos dos dispositivos (que pueden ser el mismo):

+ **Host**: Encargado de analizar que dispositivo se tiene, mandarle tareas,... El código es más regular. Prepara el dispositivo para que pueda hacer el cómputo. Hay un solo host.
+ **Device** Donde se ejecuta el código. El código es muy dependiente del problema. Puede haber más de un dispositivo. Cada unidad de procesamiento tiene su propio PC.

![](https://imgur.com/849RNNe.png)

## OpenCL WorkFlow

```C
// OpenCL includes
#include <CL/cl.h>
(C[i] = A[i] + B[i] forall i from 0 to 2048)
```

Se complica un poco si en un proceso obtenemos un resultado y ese resultado lo tenemos que pasar a otro core.

## Plataformas

Las plataformas se ordenan por fabricante.
Se puede *pedir* un tipo de plataforma específico.

## Dispositivos

Elegir dispositivos
Crear el **contexto**: Es el entorno para que OpenCL ordene ls objetos y recursos. Puede haber más de un contexto.

## Queues de comandos

Es la cadena que conecta el contexto con el dispositivo.
Hay una por dispositivo.

+ Síncrono o asíncrono
+ Comandos ejecutados en orden o fuera de orden

## Objetos de memoria

Datos que pueden moverse a los dispositivos
Los objetos pueden ser

+ Buffers:
  + Pedazo de memoria contiguo (una dimensión)
  + Pueden ser de lectura (son más optimizables) o escritura
+ Imágenes:
  + Pueden ser de dos o tres dimensiones

## Transferencia de datos

`clEnqueue{Read|Write}{Buffer|Image}`
Así se pasan del contexto al dispositivo.

## Programa

Hacemos código genérico en C. Y usamos librerías para compilar para el dispositivo en el que se va a ejecutar.

1. Se crea el objeto del programa (no lo compila).
2. *Compilación:* una vez que tengo el objeto con todos los kernels, compila el programa completo para el dispositivo.

## Kernels

Un kernel es una función declarada en un programa que es ejecutada en un dispositivo de OpenCL.

Los objetos de kernel son creados a partir de un objeto programa al especificar el nombre de la función de kernel.

![](https://imgur.com/5svku04.png)

```C
// create a compute context with GPU device
context = clCreateContextFromType(CL_DEVICE_TYPE_GPU);

// create a work-queue
queue = clCreateWorkQueue(context, NULL, NULL, 0);

// allocate the buffer memory objects
memobjs[0] = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, sizeof(float)*2*num_entries, srcA);
memobjs[1] = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(float)*2*num_entries, NULL);

// create the compute program
program = clCreateProgramFromSource(context, 1, &fft1D_1024_kernel_src, NULL);

// build the compute program executable
clBuildProgramExecutable(program, false, NULL, NULL);

// create the compute kernel
kernel = clCreateKernel(program, “fft1D_1024”);

// create N-D range object with work-item dimensions
global_work_size[0] = n;
local_work_size[0] = 64;
range = clCreateNDRangeContainer(context, 0, 1, global_work_size, local_work_size);

// set the args values
clSetKernelArg(kernel, 0, (void *)&memobjs[0], sizeof(cl_mem), NULL);
clSetKernelArg(kernel, 1, (void *)&memobjs[1], sizeof(cl_mem), NULL);
clSetKernelArg(kernel, 2, NULL, sizeof(float)*(local_work_size[0]+1)*16, NULL);
clSetKernelArg(kernel, 3, NULL, sizeof(float)*(local_work_size[0]+1)*16, NULL);

 // execute kernel
```

### Setear argumentos de kernel

A cada buffer hay que especificar
Argumentos para cada dispositivo.
`clSetKernelArg(...)`

## Estructura de hilos

Se crean N threads que van a procesar una porción del problema.

### Work items

La unidad de ejecución concurrente en OpenCL es un *work-item*. Cada *work-item* ejecuta el cuerpo de la función kernel.
Es una instancia de un kernel.

### Grupos

Cada *work-item* está en un *work-group*.
Puede haber información global dentro de un grupo(?)
`get_global_id()`

## Memory model

La memoria de modelo define varios tipos de memorias (relacionadas a la jerarquía de memoria de la GPU).

| Memoria   | Descripción                        |
| --------- | ---------------------------------- |
| Global    | Accesible por todos los work-items |
| Constante | Read-only, global                  |
| Local     | Local para un work-group           |
| Privada   | Privada a un work-item             |

El host solo tiene acceso a la memoria global.

**Documentación**: [https://registry.khronos.org/OpenCL/sdk/3.0/docs/man/html/](https://registry.khronos.org/OpenCL/sdk/3.0/docs/man/html/)

```Python
!pip install pyopencl
```

## Sincronismos y eventos

### Sincronismo

Para sincronizar el trabajo entre distintos work items.
Si un core va demasiado avanzado, que espere a los resultados de otros.
Hay que explicitar las dependencias, así no se leen datos desactualizados.

### Command Queues

Sirven para mandar tareas a un dispositivo.
Se pueden ejecutar las instrucciones en order o fuera de orden.

La queue out of order, permite paralelizar tareas.

```C
cl_command_queue_propierties = {  
 CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
 ...
}
```

#### Sincronismo a nivel de Host

Especifica las dependencias.

+ Finish: `clFinish(cl_coammandqueue)` el **host se bloquea** hasta que termina de ejecutarse las instrucciones en la command queue (se dejan de ejecutar los comandos del host)
+ Barrier: El **host no se bloquea**, pero no se siguen ejecutando cosas en la command queue.

Como las dependencias se dan en escritura y lectura, los búferes tienen una bandera que indica si la lectura o escritura sean bloqueantes así no hace falta poner barreras para que se bloquee el host.

## Kernel space

Sirve cuando dentro **dentro de una tarea** hay dependencias de datos.
Work items y work groups nos permiten sincronizar a nivel de tarea.

Poner todos los work items dentro del mismo work group para que sea más rápido.

+ **Barriers**: (por tarea) si un work item necesita un dato de otro work item, se espera que esté liso el primer WI para seguir con el siguiente.
Las barreras pueden ser locales (por work group) o globales (para todos los work groups).

%%no hay banderas tmb? %%

## Eventos

Las barreras se pueden usar como eventos, así se pueden detallar más detalles.
x tarea depende de y.

Permite sincronización entre distintos command queues.

```c
// antes de ejecutar el kernel, hay una waiting list
clEnqueueuNDRRangeKernel(..., const cl_event *event_wait_list)
```

Se puede crear eventos de

+ Escrituras a memoria
+ Lecturas
+ ?

Se puede obtener información a partir de un evento

+ el comando está en espera o se empezzo a ejecutar
+ si el comando está en la command queue
+ en qué momento comenzó
+ en qué momento terminó (información en milisegundos)

Se puede poner un comando `clWaitForEvents` que espera a que sucedan todos los eventos. `clFinish` también se puede poner.

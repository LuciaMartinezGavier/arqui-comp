transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/sl2.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/signext.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/mux2.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/regfile.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/maindec.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/imem.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/flopr.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/fetch.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/execute.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/adder.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/SingleCycleProcessor/alu.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/processor_arm.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/memory.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/decode.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/datapath.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/controller.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/aludec.sv}
vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/writeback.sv}
vcom -93 -work work {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/dmem.vhd}

vlog -sv -work work +incdir+/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907 {/home/lucia/Documents/Arquitectura/arqui-comp/quartus/TestSingleCycleProcessor/ModulosTP2-20220907/processor_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  processor_tb

add wave *
view structure
view signals
run -all

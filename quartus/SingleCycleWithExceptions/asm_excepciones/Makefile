ARMGNU ?= aarch64-linux-gnu

AOPS = --warn --fatal-warnings

asm : main.list

all : asm

clean :
	rm -f *.o
	rm -f *.img
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f memory_map.txt

main.o : main.s
	$(ARMGNU)-as $(AOPS) main.s -o main.o


main.list : memmap main.o
	$(ARMGNU)-ld main.o -T memmap -o main.elf -M > memory_map.txt
	$(ARMGNU)-objdump -D main.elf > main.list
	$(ARMGNU)-objcopy main.elf -O ihex main.hex

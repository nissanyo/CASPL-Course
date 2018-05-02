# All Targets
all: root

root: asm.o
	gcc -g -Wall -o root asm.o -lm

# Depends on the source and header files
asm.o: asm.s 
	nasm -g -f elf64 -w+all -o asm.o asm.s

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o root 

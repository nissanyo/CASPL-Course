# All Targets
all: calc

# Tool invocations
# Executable "hello" depends on the files hello.o and run.o.
calc: asm.o calc.o
	gcc -g -Wall -o calc asm.o calc.o

# Depends on the source and header files
calc.o: calc.c 
	gcc -g -Wall -c -o calc.o calc.c

asm.o: asm.s
	nasm -g -f elf64 -w+all -o asm.o asm.s


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o calc
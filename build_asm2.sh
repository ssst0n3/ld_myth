#!/bin/bash
nasm -f elf64 asm2.asm -o asm2.o
ld -s -static -o asm2 asm2.o
gcc -Wl,-dynamic-linker,asm2 -o hello hello.c
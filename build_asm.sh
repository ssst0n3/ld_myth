#!/bin/bash
filename=$1
nasm -f elf64 $filename.asm -o $filename.o
ld -s -static -T asm.lds -o $filename $filename.o
gcc -Wl,-dynamic-linker,$filename   -o hello hello.c
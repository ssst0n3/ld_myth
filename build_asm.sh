#!/bin/bash
filename=$1
nasm -f elf64 $filename.asm -o $filename.o
ld -s -static -o $filename $filename.o
gcc -Wl,-dynamic-linker,$filename   -o hello hello.c
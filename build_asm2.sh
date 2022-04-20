#!/bin/bash
nasm -f elf64 asm2.asm -o asm2.o
ld -s -static -T asm.lds -o asm2 asm2.o
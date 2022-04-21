#!/bin/bash
nasm -f bin dirty2.asm -o dirty2
gcc -Wl,-dynamic-linker,dirty2   -o hello hello.c

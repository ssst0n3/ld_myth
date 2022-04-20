section .text

          global    _start

section   .data
msg db  'Hello, world!',0xa ;our dear string
len equ $ - msg         ;length of our dear string

section   .text
_start:   
          mov       rdx, len                 ; number of bytes
          mov       rsi, msg            ; address of string to output
          mov       rdi, 1                  ; file handle 1 is stdout
          mov       rax, 1                  ; system call for write
          syscall                           ; invoke operating system to do the write
; exit via the kernel
          xor       rdi, rdi                ; exit code 0
          mov       rax, 60                 ; system call for exit
          syscall                           ; invoke operating system to exit


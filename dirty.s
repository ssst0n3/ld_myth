	.file	"dirty.c"
	.text
	.globl	dirty
	.type	dirty, @function
dirty:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	%edx, -36(%rbp)
	movq	-24(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open@PLT
	movl	%eax, -4(%rbp)
	leaq	-12(%rbp), %rax
	movq	%rax, %rdi
	call	pipe@PLT
	movl	-8(%rbp), %eax
	movl	$65536, %edx
	leaq	buffer.0(%rip), %rsi
	movl	%eax, %edi
	call	write@PLT
	movl	-12(%rbp), %eax
	movl	$65536, %edx
	leaq	buffer.0(%rip), %rsi
	movl	%eax, %edi
	call	read@PLT
	movl	-8(%rbp), %edx
	movl	-4(%rbp), %eax
	movl	$0, %r9d
	movl	$1, %r8d
	movl	$0, %ecx
	movl	$0, %esi
	movl	%eax, %edi
	call	splice@PLT
	movl	-36(%rbp), %eax
	movslq	%eax, %rdx
	movl	-8(%rbp), %eax
	movq	-32(%rbp), %rcx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	dirty, .-dirty
	.local	buffer.0
	.comm	buffer.0,65536,32
	.ident	"GCC: (Debian 10.2.1-6) 10.2.1 20210110"
	.section	.note.GNU-stack,"",@progbits

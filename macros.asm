%ifndef MACROS_ASM
%define MACROS_ASM

section .data
int_printf_arg:	db	'%d',0
str_printf_arg: db	'%s',0
dbl_printf_arg: db	'%f',0
newline:	db	10,0
separator:	db	':',0

section .text
extern printf
extern scanf

%macro write_string 1 ;1 - buffer
	mov	rsi,	%1		;buffer
	mov	rdi,	str_printf_arg	;printf arg
	mov	rax,	0	
	call printf
%endmacro

%macro newline 0
	write_string newline
%endmacro

%macro write_int 1 ;1 - variable
	mov	rsi,	%1
	mov	rdi,	int_printf_arg
	mov	rax,	0
	mov	rdx, 	0	
	call 	printf
%endmacro

%macro write_top_int 0
	write_int [rsp]
%endmacro
	
%macro dump_qword 1 ;1 - qword address
	write_int [ %1 ]
	write_string separator
	write_int [ %1 + 4 ]
	newline
%endmacro

%macro write_double 1 ;1 - variable
	mov	rdi,	dbl_printf_arg
;	mov	rsi,	qword %1
	movq	xmm0,	qword %1
	mov	rax,	1
	call	printf
%endmacro

%macro push_xmm 1 ;1 - xmm register
	sub	rsp,	8
	movd	[rsp],	%1
%endmacro

%macro pop_xmm 1 ;1 - xmm register
	movdqu	%1,	[rsp]
	add	rsp,	16
%endmacro

%macro prologue 1 ;1 - argc
	push	rbp
	mov	rbp,	rsp
	sub	rsp,	%1	
%endmacro

%macro epilogue 0
	mov	rsp,	rbp
	pop 	rbp
	ret
%endmacro

%endif

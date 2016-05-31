global asm_mandel

%include "macros.asm"

extern log2                                             
extern sqrt                                             

SECTION .data
dbl:	dq	123.456
msg:	db	':',0

SECTION .text

asm_mandel:
	prologue 128
	
;<<< MAP VARIABLES TO STACK >>>
;LOCALS:
;double pr 	:	rbp - 8
;double pi	:	rbp - 16
;double newRe	:	rbp - 24
;double newIm	:	rbp - 32
;double oldRe	:	rbp - 40
;double oldIm	:	rbp - 48
;char* iterator	:	rbp - 56
;double z	:	rbp - 64
;int i		:	rbp - 68
;int x		:	rbp - 72
;int y		:	rbp - 76
;int brightness	:	rbp - 80
;
;CONST:
;int maxInterat :	rbp - 84
;int WINDOW_WID	:	rbp - 88
;int WINDOW_HEI	:	rbp - 92
;unused		:	rbp - 96
;
;ARGUMENTS:
;void* buffer	:	rbp - 104
;double zoom	:	rbp - 112
;double moveX	:	rbp - 120
;double moveY	:	rbp - 128
dbg:
;INITIALIZATION
;arguments
	mov	qword [rbp - 104],	rdi 
	movsd	qword [rbp - 112],	xmm0
	movsd	qword [rbp - 120], 	xmm1
	movsd	qword [rbp - 128], 	xmm2
;consts
	mov	dword [rbp - 84],	1000
	mov	dword [rbp - 88],	800
	mov	dword [rbp - 92],	640
;locals
	mov	rax,	qword [rbp - 104]
	mov	qword [rbp - 56],	rax
	mov	dword [rbp - 72],	0
	mov	dword [rbp - 76],	0
OUTER_DO:
INNER_DO:
LOOP_BEGIN:
;(x - WINDOW_WIDTH / 2) start
	mov 	ebx,	dword [rbp - 72]
	sub	ebx,	400
	cvtsi2sd	xmm0,	ebx
;done, result in xmm0
		
;(0.5 * zoom * WINDOW_WIDTH)
	movsd	xmm1,	[rbp - 112]
	sub	rsp,	16
	mov	[rsp],	dword 400
	cvtsi2sd	xmm2,	[rsp]
	mulsd	xmm1,	xmm2
;done, result in xmm1

;1.5 * xmm0 / xmm1 + moveX - 0.5
	mov	[rsp],		dword 3
	mov	[rsp + 4],	dword 2
	cvtsi2sd	xmm2,	[rsp]
	cvtsi2sd	xmm3,	[rsp + 4]
	movsd	xmm4,	xmm2
	divsd	xmm2,	xmm3
;1.5 in xmm2
	mulsd	xmm0,	xmm2
	divsd	xmm0,	xmm1
	addsd	xmm0,	[rbp - 120]
	divsd	xmm2,	xmm4
	subsd	xmm0,	xmm2
;done, result in xmm0

;pr = xmm0
	movsd	qword [rbp - 8], xmm0

;(y - WINDOW_HEIGHT / 2) 
	mov 	ebx,	dword [rbp - 76]
	sub	ebx,	320
	cvtsi2sd	xmm0,	ebx
;done, result in xmm0
		
;(0.5 * zoom * WINDOW_HEIGHT)
	movsd	xmm1,	[rbp - 112]
	mov	[rsp],	dword 320
	cvtsi2sd	xmm2,	[rsp]
	mulsd	xmm1,	xmm2
;done, result in xmm1

;xmm0 / xmm1 + moveY
	divsd	xmm0,	xmm1
	addsd	xmm0,	[rbp - 128]
;done, result in xmm0

;pi = xmm0
	movsd	qword [rbp - 16], xmm0
	add	rsp,	16
	
;newRe = newIm = oldRe = oldIm = 0
	mov	qword [rbp - 24],	qword 0
	mov	qword [rbp - 32],	qword 0
	mov	qword [rbp - 40],	qword 0
	mov	qword [rbp - 48],	qword 0
;done

;i = 0
	mov	dword [rbp - 68],	dword 0
;done
INNER_LOOP_BEGIN:
;oldRe = newRe
;oldIm = newIm
	mov	rax,	qword [rbp - 24]
	mov	[rbp - 40],	rax
	mov	rax,	qword [rbp - 32]
	mov	[rbp - 48],	rax
;done

;newRe = oldRe * oldRe - oldIm * oldIm + pr
	movsd	xmm0,	qword [rbp - 40]
	movsd	xmm1,	qword [rbp - 48]
	movsd	xmm2,	qword [rbp - 8]
	mulsd	xmm0,	[rbp - 40]
	mulsd	xmm1,	[rbp - 48]
	subsd	xmm0,	xmm1
	addsd	xmm0,	xmm2
	movsd	qword [rbp - 24], xmm0
;done
	
;newIm = 2 * oldRe * oldIm + pi
	mov	dword [rbp - 96],	dword 2
	cvtsi2sd	xmm0,	dword [rbp - 96]
	movsd	xmm1,	qword [rbp - 40]
	movsd	xmm2,	qword [rbp - 48]
	movsd	xmm3,	qword [rbp - 16]
	mulsd	xmm0,	xmm1
	mulsd	xmm0,	xmm2
	addsd	xmm0,	xmm3
	movsd	qword [rbp - 32],	xmm0
;done
	
;if((newRe * newRe + newIm * newIm) > 4) break;
	movsd	xmm0,	qword [rbp - 24]
	movsd	xmm1,	qword [rbp - 32]
	mov	dword [rbp - 96],	dword 4	
	cvtsi2sd	xmm2,	dword [rbp - 96]
	mulsd	xmm0,	xmm0
	mulsd	xmm1,	xmm1
	addsd	xmm0,	xmm1
	ucomisd	xmm0,	xmm2
	ja	INNER_LOOP_END
;done

;while (i < maxIterations)
	add	dword [rbp - 68], 	1
	mov	eax,	dword [rbp - 68]
	cmp	eax,	[rbp - 84]
	jl	INNER_LOOP_BEGIN	
;done
INNER_LOOP_END:
;if(i == maxIterations)
	mov	eax,	dword [rbp - 68]
	cmp	eax,	[rbp - 84]
	jne	ELSE_BLOCK_BEGIN
;done

;*iterator++ = 0;
;*iterator++ = 0;
;*iterator++ = 0;
;*iterator++ = 255;
	mov	rax,	[rbp - 56]
	mov	[rax],		byte 0
	mov	[rax + 1],	byte 0
	mov	[rax + 2],	byte 0
	mov	[rax + 3],	byte 255
	add	qword [rbp - 56],	4
	jmp	ELSE_BLOCK_END
;done
ELSE_BLOCK_BEGIN:
;z = sqrt(newRe * newRe + newIm * newIm)
	movsd	xmm0,	qword [rbp - 24]
	movsd	xmm1,	qword [rbp - 32]
	mulsd	xmm0,	[rbp - 24]
	mulsd	xmm1,	[rbp - 32]
	addsd	xmm0,	xmm1
	call sqrt
	movsd	[rbp - 64], 	xmm0
;done

;brightness = 256. * log2(1.75 + i - log2(log2(z))) / log2((double) maxIterations);
	;log2((double) maxIterations)
		cvtsi2sd	xmm0,	dword [rbp - 84]
		call log2
		sub	rsp,	16
		movsd	[rsp],	xmm0
	;done, value is in [rsp]

	;log2(log2(z))
		movsd	xmm0,	qword [rbp - 64]
		call log2
		call log2
		movsd	xmm4,	xmm0
	;done, value is in xmm4
	
	;log2(1.75 + i - xmm4)
		sub	rsp,	16
		mov	[rsp],	dword 7
		mov	[rsp+4],dword 4
		cvtsi2sd	xmm3,	[rsp]
		cvtsi2sd	xmm0,	[rsp+4]
		divsd	xmm3,	xmm0
		add	rsp,	16
	;1.75 in xmm3
		cvtsi2sd	xmm2,	[rbp - 68]
		addsd	xmm3,	xmm2
		subsd	xmm3,	xmm4	
		movsd 	xmm0,	xmm3
		call	log2
		movsd	xmm3,	xmm0
	;done, vaule is in xmm3

	;256 * xmm3 / [rsp]
		mov	[rbp - 96],	dword 256
		cvtsi2sd	xmm4,	dword [rbp - 96]
		mulsd	xmm4,	xmm3
		divsd	xmm4,	[rsp]
		add	rsp,	16
	;done, value in xmm4

	cvttsd2si	eax,	xmm4
	mov	[rbp - 80],	eax	
;done

;*iterator++ = 0;
;*iterator++ = brightness
;*iterator++ = brightness
;*iterator++ = 255;
	mov	rax,	qword [rbp - 56]
	mov	ebx,	dword [rbp - 80]
	mov	[rax],	byte 0
	mov	byte [rax + 1],	bl
	mov	byte [rax + 2],	bl
	mov	byte [rax + 3],	byte 255
	add	qword [rbp - 56],	4	
;done 
ELSE_BLOCK_END:
;++x
	add	dword [rbp - 72],	1
;done

;while (x < WINDOW_WIDTH)
	cmp	dword [rbp - 72],	800
	jl	LOOP_BEGIN
;done

;x = 0;
;++y;
	mov	dword [rbp - 72],	dword 0
	add	dword [rbp - 76],	1
;done

;while (y < WINDOW_HEIGHT);
	cmp	dword [rbp - 76],	640
	jl	LOOP_BEGIN
;done
	epilogue


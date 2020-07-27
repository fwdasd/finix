org 0400h

jmp start

;---------------------------------------------------------------------------------------------------------------
;GDT
;								段基址				段界限		属性
GDT:		Descriptor 			  0,					0,		0									;空白描述符
CODESEG		Descriptor 			  0,              0fffffh,	 	DA_CR  | DA_32 | DA_LIMIT_4K		; 0 ~ 4G
DATASEG		Descriptor 		      0,              0fffffh, 		DA_DRW | DA_32 | DA_LIMIT_4K		; 0 ~ 4G
VIDIOSEG	Descriptor		0B8000h,               0ffffh, 		DA_DRW         | DA_DPL3			; 显存首地址


GDT_LEN		equ 	$-GDT
GDTR		dw		GDT_LEN   - 1			;段界限
			dd		SetupBase + GDT 		;段基址

;--------------------------------------------------
;选择子
SelectorCode	equ 	CODESEG	 - GDT
SelectorData	equ 	DATASEG	 - GDT
SelectorVidio	equ 	VIDIOSEG - GDT + SA_RPL3
;---------------------------------------------------------------------------------------------------------------		
	
start:

	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, StackBase

;清屏
	mov ax, 0600h
	mov bx, 0700h
	mov cx, 0
	mov dx, 0184fh
	int 10h

;------------------------------
;重新放置内核


;------------------------------

;跳入保护模式


;------------------------------

StackBase			equ		0x400

SetupBase			equ		0x9000
SetupOff			equ		0x400
KernalBase			equ		0x1000
KernalOff			equ 	0


;----------------------------------------------------------------------------
DA_32		EQU	4000h	; 32 位段
DA_LIMIT_4K	EQU	8000h	; 段界限粒度为 4K 字节

DA_DPL0		EQU	  00h	; DPL = 0
DA_DPL1		EQU	  20h	; DPL = 1
DA_DPL2		EQU	  40h	; DPL = 2
DA_DPL3		EQU	  60h	; DPL = 3
;----------------------------------------------------------------------------
; 存储段描述符类型值说明
;----------------------------------------------------------------------------
DA_DR		EQU	90h	; 存在的只读数据段类型值
DA_DRW		EQU	92h	; 存在的可读写数据段属性值
DA_DRWA		EQU	93h	; 存在的已访问可读写数据段类型值
DA_C		EQU	98h	; 存在的只执行代码段属性值
DA_CR		EQU	9Ah	; 存在的可执行可读代码段属性值
DA_CCO		EQU	9Ch	; 存在的只执行一致代码段属性值
DA_CCOR		EQU	9Eh	; 存在的可执行可读一致代码段属性值
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; 选择子类型值说明
; 其中:
;       SA_  : Selector Attribute

SA_RPL0		EQU	0	; ┓
SA_RPL1		EQU	1	; ┣ RPL
SA_RPL2		EQU	2	; ┃
SA_RPL3		EQU	3	; ┛

SA_TIG		EQU	0	; ┓TI	GDT
SA_TIL		EQU	4	; ┛		LDT
;----------------------------------------------------------------------------

%macro Descriptor 3
		dw	%2 & 0FFFFh							; 段界限 1				(2 字节)
		dw	%1 & 0FFFFh							; 段基址 1				(2 字节)
		db	(%1 >> 16) & 0FFh					; 段基址 2				(1 字节)
		dw	((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)	; 属性 1 + 段界限 2 + 属性 2		(2 字节)
		db	(%1 >> 24) & 0FFh					; 段基址 3				(1 字节)		
%endmacro
;GDT end
;----------------------------------------------------------------------------------------------
org 0400h

jmp start

%include 	"setup.h"
%include 	"pm.h"
;---------------------------------------------------------------------------------------------------------------
;GDT
;								段基址				段界限		属性
GDT:		Descriptor 			  0,					0,		0									;空白描述符
CODESEG		Descriptor 			  0,              0fffffh,	 	DA_CR  | DA_32 | DA_LIMIT_4K		; 0 ~ 4G
DATASEG		Descriptor 		      0,              0fffffh, 		DA_DRW | DA_32 | DA_LIMIT_4K		; 0 ~ 4G
VIDEOSEG	Descriptor		0B8000h,               0ffffh, 		DA_DRW         | DA_DPL3			; 显存首地址


GDT_LEN			equ 	$-GDT
GdtPtr			dw		GDT_LEN   - 1			;段界限
				dd		SetupBase + GDT 		;段基址

;--------------------------------------------------
;选择子
SelectorCode	equ 	CODESEG	 - GDT
SelectorData	equ 	DATASEEG - GDT + SA_RPL3
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
; 加载 GDTR
	lgdt	[GdtPtr]

; 关中断
	cli

; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax		;已进入保护模式

	jmp dword SelectorCode:(SetupBasePhyAdd + PMstart)
;------------------------------



;------------------------------
[SECTION .s32]
align 32
[BITS 32]

PMstart:
	mov ax, SelectorData
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov ss, ax
	mov sp, stackTop

	mov ax, SelectorVideos
	mov gs, ax




;---------------------------
[SECTION .data]
ALIGN 	32


stackTop:

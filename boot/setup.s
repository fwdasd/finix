org 0400h

jmp start

; SetupBasephy	= 0x90000

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

;获取内存大小


;------------------------------
;函数用的数据
buffSeg		equ		 9100h

;------------------------------
;int 15h 功能号 E820h	地址结构数据放入地址91000h处
findMem:	
	;输入
	mov ebx, 0
	mov ax, buffSeg	
	mov es, ax
	mov di, 0
	
find:
	mov eax, 0000e820h
	mov ecx, 20
	mov edx, 0534D4150h
	int 15h
	jc FindFail
	add di, 20
	inc dword [_mBlocNum]
	cmp ebx, 0
	jne find
	jmp findOk
FindFail:
	mov dword [_mBlockNum], 0

findOk:
	ret


;------------------------------
;计算内存大小
memSize:

	xor bp, bp
	mov ax, buffSeg
	mov es, ax
	mov ecx, [_mBlockNum]
count:
	cmp [es:bp+16], 1
	jne next
	mov eax, [es:bp]
	add eax, [es:bp+8]
	cmp eax, [_memSize]
	jna next
	mov [_memSize], eax
next:
	add bp,	20
	loop count

	ret

;------------------------------

;跳入保护模式
; 加载 GDTR
	lgdt	[GdtPtr]

; 关中断				//保护模式下的中断机制与实模式下的不同，不关中断会发生错误
	cli

; 打开地址线A20		//方法不唯一，此方法简单但有极小的几率发生错误
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

;启动分页
;

;重新放置内核



;---------------------------
[SECTION .data]
ALIGN 	32

_memSize		dd		0
_mBlockNum		dd 		0

stackTop:	resb 1024

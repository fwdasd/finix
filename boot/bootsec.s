org 0x7c00

	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, StackOff

;清屏
	mov ax, 0600h
	mov bx, 0700h
	mov cx, 0
	mov dx, 0184fh
	int 10h

	mov cl, 0
	call display

;复位软驱
	xor ah, ah		; mov ah, 0
	xor dl, dl		; mov dl, 0
	int 13h

;读setup模块
	mov cl, 1
	call display


	mov bx, SetupOff 
	mov ax, SetupBase 
	mov es, ax
	mov ax, 1
	mov cl, 1
	call readSector 
;		^
;		|
;----------------------------
;错误代码， ax被覆盖了
	; mov ax, 1
	; mov cl, 1
	; mov bx, SetupOff 
	; push es
	; mov ax, SetupBase
	; mov es, ax
	; call	readSector
	; pop es
;----------------------------


;读kernal
	mov cl, 2
	call display



;关闭软驱马达
	call KillMotor

	jmp SetupBase:SetupOff
	; jmp $


;-------------------------------------------------------
;读软盘    						int 13h
;扇区号 / 18 = Q ... R 			ah=02h, 	al=要读扇区数
;柱面号 = Q >> 1					ch=柱面号,	cl=起始扇区号
;磁头号 = Q & 1					dh=磁头号,	dl=0
;起始扇区号 = R + 1				es:bx -> 数据缓冲区
;-------------------------------------------------------
readSector:		;从扇区号ax开始读cl个扇区到es:bx中
	; push cx
	mov si, cx
	mov cl, 18
	div cl			;ax / cl = Q ... R 	 Q->al	R->ah
	mov cl, ah
	inc cl			;起始扇区号
	mov ah, al		 
	shr al, 1		;
	mov ch, al		;柱面号
	and ah, 1		
	mov dh, ah		;磁头号
	mov dl, 0
	; pop si
StartRead:
	mov ax, si
	; mov al ,1
	mov ah, 2
	int 13h
	jc StartRead

	ret

;-----------------------------------------------------
;清屏：		ah=06h, al=0

;显示字符串：	ah=13h, 		al=01 显示方式
;			bl=07h 显示属性， cx=字符串长度
;			dh,dl = 行，列
;			es:bp = 字符串地址
;
;-----------------------------------------------------
display:	;cl=字符串序号
	mov ax, 20
	mul cl
	add ax, Message
	mov bp, ax
	mov ax, ds
	mov es, ax
	mov ax, 01301h
	mov bx, 0007h
	mov dh, cl
	mov dl, 0
	mov cx, 20
	int 10h
	ret
;-----------------------------------------------------

;----------------------------------------------------------------------------
; 关闭软驱马达
KillMotor:
	push	dx
	mov	dx, 03F2h
	mov	al, 0
	out	dx, al
	pop	dx
	ret
;----------------------------------------------------------------------------


StackOff			equ 	0x7c00

SetupBase			equ		0x9000
SetupOff			equ		0x400
KernalBase			equ		0x1000
KernalOff			equ 	0

Message:
BootMessage:		db		"Hello, OS world!    "	;序号0
ReadSetup:			db		"reading setup...    "	;	1
ReadKernal:			db 		"reading kernal...   "	;	2

times 	510-($-$$)	db		0

dw 		0xaa55

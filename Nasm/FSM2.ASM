jmp word 0x2e
int3
int3
int3
rep movsw
int3
int3
int3
int 0x86
int 0x86
rep movsw
cld
mov di,cs
push es
pop ds
mov es,di
mov ss,di
jmp sp
nop
nop
nop
nop
nop
mov bx,0x1000
mov ss,bx
mov es,bx
mov ds,bx
call word 0x2d
pop si
xchg ax,bp
mov dx,0x2c2d
mov ax,dx
mov di,0x2
int 0x86
int 0x86
std
lea si,[bp+0xae]
mov di,0x3ce
mov cx,0x1a
rep movsw
cld
mov di,cs
push es
pop ds
mov es,di
mov ss,di
mov si,[bx]
and bp,0xf800
add si,bp
lea di,[si-0x7e4]
lea sp,[si-0x3fc]
mov si,0xa5f3
push sp
push si
push sp
pop sp
mov bx,0xf400
mov dx,0xf802
mov bp,0xfc04
mov ax,0x815e
mov si,0x4
mov cx,0x1fe
jmp sp
nop
nop
nop
nop
nop
cld
mov bp,cs
mov cl,0x4
shl bp,cl
mov cl,0xb
shl ax,cl
xchg ax,di
mov sp,di
mov cx,0x1d
loop 0x92
mov bx,0x1000
mov ss,bx
mov es,bx
mov ds,bx
call word 0xa0
pop si
lea si,[bp+si+0x7]
push bx
push si
retf
lea sp,[si+0x39]
mov bx,di
mov cx,0x1fe
pop ax
and ah,0x3
dec ax
pop sp
pop bp
mov dx,bp
sub bp,0x3fe
mov si,sp
add si,0xfc1c
xor di,si
jmp sp
lodsw
fdivrp st3
movsw
stosw
add sp,dx
push word [si-0x18]
push dx
xchg ax,sp
stosw
xchg ax,sp
pop dx
add di,bx
add si,bp
mov cx,0x1fe
dec ax
jnz 0xde
in al,0x1f
int3
int3
int3
rep movsw
int3
int3
int3
int 0x86
int 0x86
rep movsw
cld
mov di,cs
push es
pop ds
mov es,di
mov ss,di
jmp sp
nop
nop
nop
nop
nop
mov bx,0x1000
mov ss,bx
mov es,bx
mov ds,bx
call word 0x10b
pop si
int3
int3
int3
xchg ax,bx
mov ah,[0x4743]
mov al,0xbd
mul bx
mov [0xed0d],ax
jmp short 0x110

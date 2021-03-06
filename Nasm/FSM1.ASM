mov [0x4743],bx
jmp word 0x32
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
call word 0x31
pop si
add ax,0xc7
stosw
xchg ax,bp
mov dx,0x2c2d
mov ax,dx
mov di,0x1fe
int 0x86
int 0x86
std
lea si,[bp+0x16]
mov cx,0x18
rep movsw
cld
mov di,cs
push es
pop ds
mov es,di
mov ss,di
mov si,bp
lea di,[si-0xbe4]
lea sp,[si-0x7fc]
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
loop 0x91
mov bx,0x1000
mov ss,bx
mov es,bx
mov ds,bx
call word 0x9f
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
jnz 0xdd
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

start_of_code_to_be_copy:
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
nop
mov bx,0x1000
mov ss,bx
mov es,bx
mov ds,bx
call word 0x10a
pop si
int3
int3
int3
xchg ax,bx
mov ah,[0x4743]
mov al,0xbd
mul bx
mov [0xed0d],ax
jmp short 0x10f

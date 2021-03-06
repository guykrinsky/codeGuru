push ss
pop es
xor di,di
mov si,ax
add si,0x50
mov cl,0x15
rep movsw
mov ax,0x6789
push ss
pop ds
mov bx,0x2e
mov word [bx],0x2a54
mov [bx+0x2],cs
mov bp,[bx]
or bp,0xff
and bp,byte -0x5d
mov dx,0x200
mov cl,0x5
mov si,0x20
mov di,[bx]
push cs
pop es
dec di
rep movsw
sub bp,0x100
push cs
pop ds
mov cl,0xf
push cs
push ss
push cs
pop es
pop ds
pop ss
xor si,si
mov [bp+si],ax
sub di,byte +0x7
mov sp,0x5da3
call word far [bx]
inc bp
rep movsw
mov cl,0x5
mov di,[bp+0x0]
stosw
mov si,0x20
add [bx],dx
add bp,dx
mov di,[bx]
dec di
stack_code_minus_byte:
rep movsw ; stack_code starting in the middle of this opcode.
sub di,byte +0x7
xor si,si
mov [bp+si],ax
mov cl,0xf
call word far [bx]
inc bp
movsw
cmp [bp+si],ax
jnz 0x70
call word far [bx]
call word far [bx]

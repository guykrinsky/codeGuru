
push cs
pop es 
push cs
pop ss

mov sp, ax
sub sp, 100h
mov di, ax
add di, 100h
int 86h

xchg di, sp
std
int 86h

cld 
xchg di,sp
mov bx, 0cccch
mov ax, 053abh
mov cx, di
stosw
jmp cx


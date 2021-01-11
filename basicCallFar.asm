push es
pop ds
push cs
pop es 
push cs
pop ss

mov sp, ax
sub sp, 100h
mov di, ax
add di, 100h
int 86h ;bomb infront

xchg di, sp
std
int 86h ;bomb backward

cld 
xchg di,sp

add ax, bomb
mov [si], ax
mov [si+2], ax
bomb:
call far [si]

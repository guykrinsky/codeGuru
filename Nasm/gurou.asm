;IDEAL
;model tiny
;CODESEG
;org 100h
;start:
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

mov bx, di ;pointer to address of start of far calling
xchg cx, ax
lea ax, [bomb]
add ax, cx ;Point to the address of bombing
stosw
mov ax, cs
stosw
bomb:
call far [bx]
;END start
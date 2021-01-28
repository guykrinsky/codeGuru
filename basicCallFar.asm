push es
pop ds
push cs
pop es 
push cs
pop ss

mov sp, ax
sub sp, 100h

add ax, bomb
mov [si], ax
mov [si+2], cs
bomb:
call far [si]

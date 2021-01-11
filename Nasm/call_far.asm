;copy code to es
mov dx, ax
add dx, end
mov si, start
add si, ax
copy:
movsw
cmp si, dx
jl copy

push cs
pop ss

start:
mov bx, ax
add bx, 200h
mov word [bx], 10h

mov cx, ax
sub cx, 200h
mov si, cx
mov word[si], 10h

push es
pop ds

mov sp, cx
add ax, call_far_here
mov [di+2], cs
mov [di], ax

call_far_here:
push cs
pop ds
cmp word[si], 10h
jnz copy_code
cmp word[bx], 10h
jnz copy_code

push es
pop ds
call far [di]

copy_code:

end:
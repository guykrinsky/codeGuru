;; My code here
mov dx, ax
add dx, end
mov si, ax
add si, start
copy:
mov cx, (end-start)/2
rep movsw

push cs
pop ss

add ax, start
start:
mov di, ax
add di, 300h
mov word [di], 10h

mov si, ax
sub si, 300h
mov sp, si
mov word[si], 10h


mov bx, ax
add bx, (end-start)
add ax, (call_far_to-start)
mov [bx+2], cs
mov [bx], ax

main:
mov cx, 10
call_far_here:
call far [bx]
call_far_to:
loop call_far_here

push cs
pop ds
cmp word[si], 10h ;check down
jnz paste_down
cmp word[di], 10h ;check up
jnz paste_up
jmp main

paste_up:
add di, 200h
jmp paste_code

paste_down:
sub si, 200h
mov di, si


paste_code:
push di ;push the start of the code
push es
pop ds
push cs
pop es

xor si, si
paste:
mov cx, (end-start)/2
rep movsw

push ds
pop es
push cs
pop ds

pop ax
jmp ax
end:

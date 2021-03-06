FAR_FROM_TRAPS equ 300h
;; My code here
mov dx, ax
add dx, end
mov si, ax
add si, start
copy:
mov cx, ((end-start)+1)/2
rep movsw
push cs
pop ss
add ax, start

start:
push cs
pop ds


mov bx, ax
mov si, ax
mov dx, ax
mov di, ax


add di, FAR_FROM_TRAPS
mov word [di], 10h

sub si, FAR_FROM_TRAPS
mov sp, si
mov word[si], 10h


add bx, (end-start)
add dx, (call_far_to-start)
mov [bx+2], cs
mov [bx], dx

main:
add cx, 10
call_far_here:
call far [bx]
call_far_to:
loop call_far_here

cmp word[si], 10h ;check baackwards
jnz paste_down
cmp word[di], 10h ;check towars
jnz paste_up
jmp main

paste_up:
mov bx, di
mov ax, di
add ax, FAR_FROM_TRAPS 
jmp anti_call_far

paste_down:
mov bx, si
sub si, FAR_FROM_TRAPS 
mov ax, si

anti_call_far:
mov di, 3
bomb_anti_call_far:
mov si, [bx+di]
sub si, 2
mov word[si], 0cccch
dec di
cmp di, 0
jge bomb_anti_call_far
end_anti_call_far:

paste_code:
push ax ;push the start of the code
push es
pop ds
push cs
pop es

mov di, ax
xor si, si
paste:
mov cx, ((end-start)+1)/2
rep movsw

push ds
pop es

pop ax
jmp ax
end:
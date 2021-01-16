DISTANCE_FROM_TRAPS equ 400h
;; My code here
mov dx, ax
add dx, end
mov si, start
add si, ax
copy:
mov cx, (end-start)
rep movsw

add ax, start
start:

mov bx, ax
add bx, DISTANCE_FROM_TRAPS 
mov di, 10h
mov dx, ax
sub dx, DISTANCE_FROM_TRAPS 
place_traps:
mov word [bx + di], 10h
push bx
mov bx, dx
mov word[bx + di], 10h
pop bx
sub di, 2
test di, di
jnz place_traps


mov si, ax
add si, (end-start)
add ax, (call_far_to-start)
mov [si+2], cs
mov [si], ax

push cs
pop ss
mov sp, dx
sub sp, 100h

reset_di:
mov cx, 5
mov di, 010h
bomb:
	call far [si]
	call_far_to:
	loop bomb
check:
xchg bx, dx
cmp word[bx + di], 10h ;check down
jnz paste_down

xchg bx, dx
cmp word[bx+di], 10h ;check up
jnz paste_up

sub di, 2
test di, di
jnz check

jmp reset_di

paste_up:
lea di, [bx+di]
add di, DISTANCE_FROM_TRAPS+100 
jmp paste_code

paste_down:
lea di, [bx+di]
sub di, DISTANCE_FROM_TRAPS+100

paste_code:
push di ;push the start of the code
push es
pop ds
push cs
pop es

xor si, si
paste:
mov cx, (end-start)
rep movsw

push ds
pop es
push cs
pop ds
pop ax
jmp ax
end:

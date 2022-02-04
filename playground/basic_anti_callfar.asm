push ds
pop es
mov al, 0xcc
dec cx
std
dec di
@check_loop:
repe scasb
mov cl, 4
mov bx, [di]
shl bx, cl
add bx, [di - 2]
sub bx, 2
mov word [bx], 0xcccc
sub di, 0xFF
jmp @check_loop
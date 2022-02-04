%define CHALLENGE_WRITE_LOC 0x1234
%define XOR_KEY 0xBEEF

mov bx, (@challenge_code_size_end - @challenge_code_size)
nop
nop
nop
mov ax, [CHALLENGE_WRITE_LOC]
xor ax, XOR_KEY
add bx, ax
@bomb:
mov word[bx], 0xcccc
jmp @bomb

@challenge_code_size:
mov bx,ax
add bx, 0
xor ax, 0 
mov [0000],ax
nop
nop
nop
nop
nop
jmp bx
@challenge_code_size_end:
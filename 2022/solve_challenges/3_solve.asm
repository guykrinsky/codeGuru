%define CHALLENGE_WRITE_LOC 0x1234

nop
mov bx, [CHALLENGE_WRITE_LOC]
add bx, (@challenge_code_size_end - @challenge_code_size)
@bomb:
mov word[bx], 0xcccc
jmp @bomb

@challenge_code_size:
mov [0000],ax
add ax,0
nop
nop
nop
nop
nop
@challenge_code_size_end:
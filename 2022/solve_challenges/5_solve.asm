%define CHALLENGE_WRITE_LOC 0x1234
%define XOR_ANSWER 0x6042

%define CHALLENGE_READ_LOC (CHALLENGE_WRITE_LOC+0x10)

mov word[CHALLENGE_READ_LOC], XOR_ANSWER
mov cx, 15
@wait:
loop @wait
mov bx, [CHALLENGE_WRITE_LOC]
@bomb:
mov word[bx], 0xcccc
jmp @bomb
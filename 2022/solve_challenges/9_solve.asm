%define CHALLENGE_READ 0x1234
%define CHALLENGE_NEW_CODE_SEG 0x1001
%define NEW_CHALLENGE_IP 0x1000

; wait for challenge
nop
nop
nop
mov word [CHALLENGE_READ], NEW_CHALLENGE_IP
mov word [CHALLENGE_READ + 2], CHALLENGE_NEW_CODE_SEG
mov bx, NEW_CHALLENGE_IP
add bx, 0x10
@bomb:
mov word[bx], 0xcccc
jmp @bomb

%define BL_ANSWER 0x54
%define DL_ANSWER 0x41
%define WAIT_COUNT 46

%define CHALLENGE_READ 0x1234
%define CHALLENGE_WRITE 0xBEEF

mov byte [CHALLENGE_READ], BL_ANSWER
mov byte [CHALLENGE_READ + 1], DL_ANSWER

mov cx, WAIT_COUNT
add bx, @end_challenge_code - @start_challenge_code
@wait:
loop @wait
add bx, word [CHALLENGE_WRITE]
@bomb:
mov word [bx], 0xcccc
jmp @bomb

@start_challenge_code:
nop
mov bl,[0]
mov dl,[0x1]

mov cl, 0


mov si,bx
add bx,dx
mov dx,si

loop 0

cmp bx, 0
jnz @start_challenge_code

mov [0],ax
@end_challenge_code:
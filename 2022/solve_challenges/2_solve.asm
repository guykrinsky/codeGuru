%define CHALLENGE_WRITE_LOC 0x1234

nop
mov bx, [CHALLENGE_WRITE_LOC]
mov word[bx], 0xcccc
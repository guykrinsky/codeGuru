%define R_LOC_SEED 0x1234

%define JMP_BP_SI_OPCODE 0x2AFF
%define MIN_SEG 0xFF6
%define LOC ((R_LOC_SEED % (0xFFB0-0xA0)) + 0xA0)
%define WAIT 7
%define MIN_SEG_DIF 0xa0

add bx, LOC
sub bx, MIN_SEG_DIF
mov cx, WAIT

@wait:
loop @wait

@bomb:
add bx, 10000b
mov word[bx], 0xcccc
jmp @bomb
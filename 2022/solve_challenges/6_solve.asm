%define START_SP_VALUE 0x800
%define CALL_OPCODES_COUNT 3

nop
nop
nop
mov word bx, [START_SP_VALUE - 2]
sub bx, CALL_OPCODES_COUNT
@bomb:
mov word[bx], 0xcccc
jmp @bomb
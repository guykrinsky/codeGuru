%define R_LOC 0x1234

%define RET_OPCODE 0xC3

push cs
pop es

mov ax, 0xcccc
mov dx, ax
mov di, R_LOC

int 0x86
int 0x86

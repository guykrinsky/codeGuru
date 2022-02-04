%define CHALLANGE_LOC 0x1234

bomb:
mov word[CHALLANGE_LOC], 0xcccc
jmp bomb
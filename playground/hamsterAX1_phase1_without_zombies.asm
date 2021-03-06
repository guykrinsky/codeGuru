%define ZOMBIE_OUTPUT_ADDRESS 0x8400      ; 0x8100 for ZOMA, 0x8200 for ZOMB...

; the first word int 0x87 will look for, it's the same in every zombie
%define OPCODE_IN_EVERY_ZOMBIE 0x8089

; the second word int 0x87 will look for
%define ZOMBIE_IDENTIFIER_FOR_INT87 0x200 ; 0x100 for ZOMA, 0x200 for ZOMB...

; NOTE: it can't be every number and it must be different from this number in the other survivor
%define SECRET_BYTE_FOR_ZOMBIE 0x78   

%define SECRET_ADDRESS_FOR_ZOMBIE (0xE200 + SECRET_BYTE_FOR_ZOMBIE) ; NOTE: 0xE200 can't be changed!
%define OFFSET_IN_ZOMBIE_CODE 0x70 ; where in the zombie code we write the opcodes that take over it

%define DIFF_OF_ZOMBIE_BOMBING_FROM_SURVIVOR 0x800 ; the difference between our code and the zombie bombing starting point
%define ITERATIONS_OF_WAITING_LOOP 9
 
; this address is used to exchange the address of mapped_nums with the other survivor
%define EXCHANGE_INFO_ADDRESS 0xBEEF ; random number



; because the next command is at position XXA5 (the opcode of call far takes 2 bytes) and it must writes on itself the opcode 0xA5 (movsw).
%define CALL_FAR_COLUMN_NUM   0xA3                    ; 0xA3 + 2 = 0xA5

; the real column number of the command "call far [bx]" in the arena, after the calculation of (NEW_CODE_SEGMENT*16)+ip
%define NEW_CODE_SEGMENT 0xFFF

; the address in the private stack where the segment and offset for call far will be stored
%define CALL_FAR_PRIVATE_ADDRESS 0x528

; how many bytes to jump to the next position
%define JUMP_DISTANCE 0x4800

; how many bytes to bomb before changing position
; NOTE: call far writes 4 bytes, thus (BOMBING_SIZE % 4) must be zero!!!
%define BOMBING_SIZE 0x200 ; 512 = 2 rows in the arena

; the number of iterations of the loop that copies the opcodes to the stack
; if the number of copied opcodes is odd, adds one more opcode (that's why the +1)
; because in each iteration 2 opcodes are copied 
%define ITERATIONS_NUM_OF_COPY_LOOP (end_copied_opcodes-start_copied_opcodes+1)/2 ; integer division 

%define ZOMBIE_TIMER 0x500
; the address in the zombie's stack where the timer will be stored
%define ZOMBIE_TIMER_ADDRESS (ITERATIONS_NUM_OF_COPY_LOOP*2 + 2) 

; --------------------------------------------------- opcodes in little endian
%define JMP_MEMO_OPCODE    0x26FF ; the beginning of the opcode "jmp [address]"
%define JMP_MEMO_DI_OPCODE 0x25FF ; the opcode of "jmp [di]"
%define MOV_DI_OPCODE      0xBF   ; the beginning of the opcode "mov di, <X>"
%define JMP_LABEL_OPCODE   0xEB   ; the beginning of the opcode "jmp <label>"
%define CALL_FAR_BX_OPCODE 0x1FFF ; the opcode of "call far [bx]" 
; ----------------------------------------------------------------------------




start:
call survivor_attack_preparations
junk_start:
; place junk here
nop
nop
nop
nop
nop
nop
nop
nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; int 0x87 that the survivor runs
push ss
pop es ; es -> ss

pop si ; si points to junk_start
add si, start_copied_opcodes - junk_start ; si points to start_copied_opcodes

copy_opcodes_to_stack:
; copies the opcodes to the beginning of the stack
; preparations that have already been done:
; es -> ss
; si -> start_copied_opcodes
mov cx, ITERATIONS_NUM_OF_COPY_LOOP
rep movsw 

; save the start address in the register si, because it can be used to access memory
mov si, ax
sub ax, JUMP_DISTANCE ; ax points to the new position 
mov al, CALL_FAR_COLUMN_NUM

mov di, CALL_FAR_PRIVATE_ADDRESS
stosw ; writes the offset for call far in the stack
mov ax, NEW_CODE_SEGMENT
stosw ; writes the segment for call far in the stack


push cs
pop es ; es -> cs

mov bp, JUMP_DISTANCE + BOMBING_SIZE ; preparation for the bombing


final_preparations:
push ss
pop ds ; ds -> ss
push cs
pop ss ; ss -> cs

mov dx, JUMP_DISTANCE
mov sp, [bx]
add sp, BOMBING_SIZE

xor ch, ch ; only needed if it was changed before bombing using int 0x87
mov ax, CALL_FAR_BX_OPCODE
jmp start_attack




start_copied_opcodes:
; ------------------------------------------------------------------------
; these opcodes will be copied to the beginning of the stack
rep movsw

dec word [si] ; timer for zombies
jz end_copied_opcodes ; kill itself

add [bx], dx 
add sp, bp
start_attack:
mov cl, ITERATIONS_NUM_OF_COPY_LOOP
les di, [bx] ; di = [bx], es = [bx+2]
stosw
xor si, si
dec di
call word far [bx]
; ------------------------------------------------------------------------
end_copied_opcodes:
tail:
%define ZOMBIE_OUTPUT_ADDRESS 0x8500      ; 0x8100 for ZOMA, 0x8200 for ZOMB...

; the first word int 0x87 will look for, it's the same in every zombie
%define OPCODE_IN_EVERY_ZOMBIE 0x8089

; the second word int 0x87 will look for
%define ZOMBIE_IDENTIFIER_FOR_INT87 0x200 ; 0x100 for ZOMA, 0x200 for ZOMB...

; NOTE: it can't be every number and it must be different from this number in the other survivor
%define SECRET_BYTE_FOR_ZOMBIE 0x49   

%define SECRET_ADDRESS_FOR_ZOMBIE (0xE200 + SECRET_BYTE_FOR_ZOMBIE) ; NOTE: 0xE200 can't be changed!
%define OFFSET_IN_ZOMBIE_CODE 0x70 ; where in the zombie code we write the opcodes that take over it

%define DIFF_OF_ZOMBIE_BOMBING_FROM_SURVIVOR 0x800 ; the difference between our code and the zombie bombing starting point
%define ITERATIONS_OF_WAITING_LOOP 11

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


code_for_zombie:
call next_line
next_line:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; int 0x87 that the zombie runs
; the zombie has already done the setup: es -> ds
xor di, di ; start the search from the beginning of the arena
mov ax, OPCODE_IN_EVERY_ZOMBIE  ; search for ax:dx
mov dx, ZOMBIE_IDENTIFIER_FOR_INT87          
mov bx, JMP_MEMO_OPCODE         ; replace with bx:cx = "jmp [SECRET_ADDRESS_FOR_ZOMBIE]"
mov cx, SECRET_ADDRESS_FOR_ZOMBIE 
int 0x87
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

push ss
pop es ; es -> ss

mov ax, ZOMBIE_TIMER
mov di, ZOMBIE_TIMER_ADDRESS
stosw ; write the timer in the stack

pop si ; si -> next_line
add si, start_copied_opcodes - next_line

; change the last byte at the line calc_diff_for_zombie
sub byte [si-start_copied_opcodes+calc_diff_for_zombie+3], 10
calc_diff_for_zombie:
lea ax, [si - DIFF_OF_ZOMBIE_BOMBING_FROM_SURVIVOR] ; opcode is 4 bytes long
jmp copy_opcodes_to_stack








survivor_attack_preparations:
; these instructions are here in order to wait some turns 
; until the first survivor writes the address of mapped_nums to the arena
pop si ; si points to junk_start
add si, start_copied_opcodes - junk_start ; si points to start_copied_opcodes

push ax ; save the original ax
; read the address of mapped_nums from the arena
mov bp, word [EXCHANGE_INFO_ADDRESS]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; int 0x87
push cs
pop es ; es -> cs

; here di is already 0 - start the search from the beginning of the arena
mov ax, OPCODE_IN_EVERY_ZOMBIE  ; search for ax:dx
mov dx, ZOMBIE_IDENTIFIER_FOR_INT87          
; replace with bx:cx, their values don't matter, just replace the opcodes ax:dx
int 0x87
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

push ss
pop es ; es -> ss

pop ax ; restore the original ax




copy_opcodes_to_stack:
; copies the opcodes to the beginning of the stack
; preparations that have already been done:
; es -> ss
; si -> start_copied_opcodes
xor di, di 
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; attacks using int 0x86 
lea di, [si - JUMP_DISTANCE - 0x250] ; bombs a row before the new position
mov ax, 0xCCCC
mov dx, ax
int 0x86 ; writes dx:ax (0xCCCC CCCC) to es:di 256 times, and updates di
lea di, [di + BOMBING_SIZE + 0x200] ; bombs a row after the new position
int 0x86
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; preparations for spend time
start_line_to_be_modified: 
; this line will be modified to "jmp final_preparations"
lea di, [si+tail] ; di points to tail
end_line_to_be_modified:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; modify start_line_to_be_modified
; writes the opcode of "jmp final_preparations" at start_line_to_be_modified

lea bx, [si + start_line_to_be_modified] ; bx points to start_line_to_be_modified
; the "+2" is there because the line to be modified is 4 bytes long, 
; and the new line ("jmp final_preparations") is 2 bytes long, thus we have to jump 2 more bytes
mov word [bx], (final_preparations-end_line_to_be_modified+2)*0x100 + JMP_LABEL_OPCODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov cx, ITERATIONS_OF_WAITING_LOOP
rep stosw ; spend time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; write the jump address for the zombie in the arena
lea bx, [si + code_for_zombie] ; bx points to code_for_zombie 
mov word [SECRET_ADDRESS_FOR_ZOMBIE], bx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



mov bx, bp ; bx -> mapped_nums 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; calc the start address of the zombie
mov dx, word [ZOMBIE_OUTPUT_ADDRESS] ; read the zombie output from the arena

mov ax, dx
and ax, 0x7F7F ; 0x7F =127: al=al%128, ah=ah%128
xlatb       ; al = ds:[bx + al]
xor al, dl

xchg al, ah
xlatb       ; al = ds:[bx + al]
xor al, dh

xor ah, al
; here ax contains the start address of the zombie 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; take over the zombie
mov bx, ax
; writes the opcode of "mov di, SECRET_BYTE_FOR_ZOMBIE" in little endian
mov word [bx+OFFSET_IN_ZOMBIE_CODE], SECRET_BYTE_FOR_ZOMBIE*0x100 + MOV_DI_OPCODE  
mov word [bx+OFFSET_IN_ZOMBIE_CODE+3], JMP_MEMO_DI_OPCODE ; +3 because we skip one byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


final_preparations:
push ss
pop ds ; ds -> ss
mov bx, CALL_FAR_PRIVATE_ADDRESS
push cs
pop ss ; ss -> cs

; In the other survivor, this line was earlier to save time,
; but this survivor uses bp to save the address of mapped_nums until it reaches here.
mov bp, JUMP_DISTANCE + BOMBING_SIZE ; preparation for the bombing

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




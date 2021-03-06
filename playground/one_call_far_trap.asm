;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; good fixed addressed for testing this code at shooshx
; myCoreDump: 0xEE00
; this code : 0xA000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define DISTANCE_FROM_TRAPS 0x800
%define JMPING_DISTANCE 0x3200
%define TARGET_BYTE 0xF
%define CALL_FAR_COLUMN_NUM 0xA3
%define NEW_CODE_SEGMENT 0x1000 ; 0xFFF
%define CALL_FAR_PRIVATE_ADDRESS 0x123

; NOTE: SIZE_OF_TRAPS must be divisble by 4, because call far bombs 4 bytes
%define SIZE_OF_TRAPS 0x200                          
; NOTE: if ITERATIONS_NUM_SCAN_LOOP is greater than 0xFF, "xor ch, ch" is needed
%define ITERATIONS_NUM_SCAN_LOOP 0xF6
%define RUINED_TRAPS end_preparations_for_scan_traps - start_preparations_for_scan_traps
%define WSIZE_TOTAL_STACK_CODE (end_stack_code-start_stack_code+1)/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; all of these sizes must be even
%define WSIZE_FIRST_CALLFAR (end_first_callfar-start_first_callfar)/2
%define WSIZE_PREPARATIONS_FOR_COPY_TRAPS (end_preparations_for_scan_traps-start_preparations_for_scan_traps)/2
%define WSIZE_COPY_TRAPS_CODE (end_copy_traps-start_copy_traps)/2
%define WSIZE_SCAN_CODE (end_scan-start_scan)/2
%define WSIZE_CODE_FOR_SLAVE (end_code_for_slave-start_code_for_slave)/2
%define WSIZE_CODE_FOR_SCAN_AND_SLAVE (end_code_for_slave-start_scan)/2
%define WSIZE_TAKE_OVER_CODE (end_code_for_take_over-start_code_for_take_over)/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define SLAVE_JUMPING_BETWEEN_BOMBING 0x10
%define SLAVE_TIMER 0x100 ; TODO: check what this number should be

; --------------------------------------------------- opcodes in little endian
%define SUB_MEMO_BX_OPCODE 0x2F81 ; the beginning of the opcode "sub [bx], ..."
; ----------------------------------------------------------------------------

start:
add ax, start_stack_code
mov si, ax

push ss
pop es ; es -> ss
copy:
mov cl, WSIZE_TOTAL_STACK_CODE
rep movsw

push ss 
push cs
pop es ; es -> cs
pop ds ; ds -> ss

; save ss in dx and not in bp, because bp can be used 
; to access memory [ss:bp] and that might be very useful
mov dx, ss  
push cs
pop ss ; ss -> cs

add ah, 0x8
mov al, CALL_FAR_COLUMN_NUM
mov bx, CALL_FAR_PRIVATE_ADDRESS
mov word [bx], ax
mov word [bx+2], NEW_CODE_SEGMENT
mov al, TARGET_BYTE 
mov si, (end_first_callfar - start_stack_code)
jmp start_first_callfar


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start_stack_code:
; values when arriving here:
; es -> cs
; ds -> ss
; ss -> cs
rep movsw ; pasted by the last movsw
start_first_callfar:
les di, [bx]
lea sp, [di + SIZE_OF_TRAPS]
mov cl, WSIZE_PREPARATIONS_FOR_COPY_TRAPS
movsw ; writes the first call far
dec di
call far [bx]
end_first_callfar:
call far [bx] ; pasted by the first movsw



rep movsw
start_preparations_for_scan_traps:
sub di, (DISTANCE_FROM_TRAPS + RUINED_TRAPS)
mov bp, di
;TODO: check what is si now, should write rep movsw
movsw

mov cx, WSIZE_CODE_FOR_SCAN_AND_SLAVE
call bp
end_preparations_for_scan_traps:


rep movsw ; pasted by the movsw
start_scan:
; here ds -> ss
lds cx, [si] ; cx = ITERATIONS_NUM_SCAN_LOOP, ds = 0x1000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; change slave_call_far code 
; here ds -> cs
; bp -> end_copy_traps

lea di, [bp + JMPING_DISTANCE + line_to_be_modified - end_preparations_for_scan_traps] 
mov word [di], SUB_MEMO_BX_OPCODE

;; lea di, [bp + JMPING_DISTANCE + slave_call_far - end_copy_traps] 
;; ; di -> address of slave_call_far in the arena in our ***previous position***
;; ;writes on the line slave_call_far the line now is:
;; ;-> sub word [bx], (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
;; mov word [di], SUB_MEMO_BX_OPCODE 
;; mov word [di+2], (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;mov si and di to their place in the traps
;at the begging they are have to point to bytes with the same value! not every byte will work.
pop si ;si -> start of the traps
lea di, [si + (SIZE_OF_TRAPS)/2] ;di->middle of the traps
cmpsw_loop:
repe cmpsw

scasb ; ES:[DI] - AL, updates di
je start_attack_opcodes
scasb ; ES:[DI] - AL, updates di
je start_attack_opcodes

mov di, si

scasb ; ES:[DI] - AL, updates di
je start_attack_opcodes
scasb ; ES:[DI] - AL, updates di
jne end_attack_opcodes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; take over code!!!!!!
start_attack_opcodes: 
les di, [di-4] ; -4 because di points to the end of the call far bombing
; here di points to the byte after the call far code
add di, (-4 + WSIZE_TAKE_OVER_CODE*2) 
mov ds, dx ; ds -> ss

; prepare the placeholder value at code_for_take_over in the stack
; +2 is the offset of the placeholder from the beginning of it's line
mov si, (start_code_for_take_over - start_stack_code + 2) 
mov word [si], bp ; bp -> address of end_preparations_for_scan_traps in the arena
add word [si], (start_code_for_slave - end_preparations_for_scan_traps)

 ; -2 because the movsw read 2 bytes ahead when the direction flag is on
mov si, (end_code_for_take_over - start_stack_code - 2)
mov cl, WSIZE_TAKE_OVER_CODE
std ; write in the opposite direction
rep movsw ; paste take_over_code
cld
end_attack_opcodes:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mov ds, dx ; ds -> ss
mov cl, WSIZE_FIRST_CALLFAR
sub word [bx], JMPING_DISTANCE
xor si, si
les di, [bx]
movsw
jmp word [bx]
end_scan:


start_code_for_slave:
;;; db 0xCC
; we take over call far survivors, thus they have:
; ss -> cs
; ds -> ss (probably)
mov sp, [bx]
sub sp, DISTANCE_FROM_TRAPS + SIZE_OF_TRAPS + 0x200 ; add padding above our code
add word [bx], (slave_call_far-start_code_for_slave)

dec dx 
jz end_code_for_slave

slave_call_far:
sub sp, SLAVE_JUMPING_BETWEEN_BOMBING
line_to_be_modified:
call far [bx] ; will be modified to nop nop to break out of the call far loop
dw (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
;; sub word [bx], (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
call far [bx]
;db 0xCC ; make the code length even
end_code_for_slave:


start_bytes_for_lds: ; for the command lds...
dw ITERATIONS_NUM_SCAN_LOOP
dw 0x1000 ; code segment
end_bytes_for_lds:


start_code_for_take_over:
mov word [bx], 0xABCD ; placeholder value (will be overwritten)
mov word [bx+2], ss ; ss -> original cs
mov dx, SLAVE_TIMER
call far [bx]
end_code_for_take_over:


end_stack_code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tail:
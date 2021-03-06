;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; good fixed addressed for testing this code at shooshx
; myCoreDump: 0xF100
; this code : 0xA000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define DISTANCE_FROM_TRAPS 0x900
%define JMPING_DISTANCE 0x3200
%define TARGET_BYTE 0xF
%define CALL_FAR_COLUMN_NUM 0xA3
%define NEW_CODE_SEGMENT 0x1000 ; 0xFFF
%define CALL_FAR_PRIVATE_ADDRESS 0x123

; NOTE: SIZE_OF_TRAPS must be divisble by 4, because call far bombs 4 bytes
%define SIZE_OF_TRAPS 0x200                          
; NOTE: if ITERATIONS_NUM_SCAN_LOOP is greater than 0xFF, "xor ch, ch" is needed
%define ITERATIONS_NUM_SCAN_LOOP 0xFF

%define WSIZE_TOTAL_STACK_CODE (end_stack_code-start_stack_code+1)/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; all of these sizes must be even
%define WSIZE_FIRST_CALLFAR (end_first_callfar-start_first_callfar)/2
%define WSIZE_PREPARATIONS_FOR_COPY_TRAPS (end_preparations_for_copy_traps-start_preparations_for_copy_traps)/2
%define WSIZE_COPY_TRAPS_CODE (end_copy_traps-start_copy_traps)/2
%define WSIZE_MIDDLE_CODE (end_middle_code-start_middle_code)/2
%define WSIZE_SCAN_CODE (end_scan-start_scan)/2
%define WSIZE_TAKE_OVER_CODE (end_code_for_take_over-start_code_for_take_over)/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%define WSIZE_CODE_FOR_SLAVE (end_code_for_slave-start_code_for_slave+1)/2


start:
add ax, start_stack_code
mov si, ax

push ss
pop es ; es -> ss
copy:
mov cl, WSIZE_TOTAL_STACK_CODE
rep movsw

; prepare the placeholder value at code_for_take_over
mov di, (start_code_for_take_over-start_stack_code+2)
add ax, (start_code_for_slave-start_stack_code)
stosw

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
start_preparations_for_copy_traps:
sub di, (DISTANCE_FROM_TRAPS * 2 + SIZE_OF_TRAPS + WSIZE_COPY_TRAPS_CODE*2)
mov bp, di
mov cl, WSIZE_COPY_TRAPS_CODE
rep movsw ; paste the code that copies the traps

; cx = ITERATIONS_NUM_SCAN_LOOP, ds = 0x1000
lds cx, [start_bytes_for_lds-start_stack_code] 
call bp
end_preparations_for_copy_traps:


start_copy_traps:
pop si
rep movsw ; copy the traps
mov si, end_copy_traps - start_stack_code
mov ds, dx ; ds -> ss
mov cl, WSIZE_MIDDLE_CODE 
mov bp, di
rep movsw ; paste the middle_code
jmp bp
end_copy_traps:

start_middle_code:
; this code is pasted right after the code that copies the traps
add di, (DISTANCE_FROM_TRAPS - WSIZE_MIDDLE_CODE*2 + 2)
mov cl, WSIZE_SCAN_CODE
mov bp, di
movsw
jmp bp
db 0xCC ; make the code length even
end_middle_code:


rep movsw ; pasted by the movsw
start_scan:
lds cx, [si] ; cx = ITERATIONS_NUM_SCAN_LOOP, ds = 0x1000
lea si, [bp - DISTANCE_FROM_TRAPS - SIZE_OF_TRAPS]
lea di, [bp + DISTANCE_FROM_TRAPS]
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
mov si, (end_code_for_take_over-start_stack_code-2)

mov ds, dx ; ds -> ss
mov cl, WSIZE_TAKE_OVER_CODE
std ; write in the opposite direction
rep movsw
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


start_bytes_for_lds: ; for the command lds...
dw ITERATIONS_NUM_SCAN_LOOP
dw 0x1000 ; code segment
end_bytes_for_lds:


start_code_for_take_over:
; mov bp, 0xABCD ; placeholder value (will be overwritten)
; jmp bp
; db 0xCC ; make the code length even

mov word [bx], 0xABCD ; placeholder value (will be overwritten)
mov word [bx+2], ss ; ss -> original cs
call far [bx]
db 0xCC ; make the code length even
end_code_for_take_over:

start_code_for_slave:
;;; db 0xCC
; we take over call far survivors, thus they have:
; ss -> cs
; ds -> ss (probably)
mov sp, di
add word [bx], (slave_call_far-start_code_for_slave)
slave_call_far:
call far [bx]

end_code_for_slave:


end_stack_code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tail:
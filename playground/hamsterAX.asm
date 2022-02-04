;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; good fixed addressed for testing this code at shooshx
; myCoreDump: 0xEE00
; this code : 0xA000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define ZOMBIE_OUTPUT_ADDRESS 0x8100      ; 0x8100 for ZOMA, 0x8200 for ZOMB...

; the first word int 0x87 will look for, it's the same in every zombie
%define OPCODE_IN_EVERY_ZOMBIE 0x8089

; the second word int 0x87 will look for
%define ZOMBIE_IDENTIFIER_FOR_INT87 0x200 ; 0x100 for ZOMA, 0x200 for ZOMB...

; NOTE: it can't be every number and it must be different from this number in the other survivor
%define SECRET_BYTE_FOR_ZOMBIE 0x78   

; NOTE: it must be different from this number in the other survivor
%define RANDOM_PLACE_FOR_ZOMBIE 0x3333

%define SECRET_ADDRESS_FOR_ZOMBIE (0xE200 + SECRET_BYTE_FOR_ZOMBIE) ; NOTE: 0xE200 can't be changed!
%define OFFSET_IN_ZOMBIE_CODE 0x70 ; where in the zombie code we write the opcodes that take over it



%define DISTANCE_FROM_TRAPS 0x800
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
%define WSIZE_SCAN_CODE (end_scan-start_scan)/2
%define WSIZE_CODE_FOR_SLAVE (end_code_for_slave-start_code_for_slave)/2
%define WSIZE_TAKE_OVER_CODE (end_code_for_take_over-start_code_for_take_over)/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define SLAVE_JUMPING_BETWEEN_BOMBING 0x100
%define SLAVE_TIMER 0x10 ; TODO: check what this number should be

%define ITERATIONS_NUM_WAITING 50
; --------------------------------------------------- opcodes in little endian
%define JMP_MEMO_OPCODE    0x26FF ; the beginning of the opcode "jmp [address]"
%define JMP_MEMO_DI_OPCODE 0x25FF ; the opcode of "jmp [di]"
%define MOV_DI_OPCODE      0xBF   ; the beginning of the opcode "mov di, <X>"
%define SUB_MEMO_BX_OPCODE 0x2F81 ; the beginning of the opcode "sub [bx], ..."
; ----------------------------------------------------------------------------

call start
; place junk here
start_junk:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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






start:
pop si
; prepare the placeholder value at code_for_take_over in the stack (for the zombies!)
; +2 is the offset of the placeholder from the beginning of it's line
add si, (start_code_for_take_over - start_junk + 2) 
add word [si], ax

add si, (start_stack_code - start_junk) - (start_code_for_take_over - start_junk + 2)
push ss
pop es ; es -> ss
copy:
mov cl, ITERATIONS_NUM_WAITING
rep movsw
push ax ; save ax



mov bx, ax
add bx, mapped_nums ; bx -> mapped_nums
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; write the jump address for the zombie in the arena
lea bx, [bx - mapped_nums + code_for_zombie] ; bx -> code_for_zombie 
mov word [SECRET_ADDRESS_FOR_ZOMBIE], bx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; take over the zombie
mov bx, ax
; writes the opcode of "mov di, SECRET_BYTE_FOR_ZOMBIE" in little endian
mov word [bx+OFFSET_IN_ZOMBIE_CODE], SECRET_BYTE_FOR_ZOMBIE*0x100 + MOV_DI_OPCODE  
mov word [bx+OFFSET_IN_ZOMBIE_CODE+3], JMP_MEMO_DI_OPCODE ; +3 because we skip one byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; continue copying
mov cl, WSIZE_TOTAL_STACK_CODE - ITERATIONS_NUM_WAITING
rep movsw

;;; ; si -> end_stack_code in the arena
;;; ; update the placeholder at code_for_zombie
;;; add al, - CALL_FAR_COLUMN_NUM - 82 + 95 - 181
;;; mov byte [si+zombie_placeholder-end_stack_code+1], al ; +1 is the offset of the placeholder




pop ax ; restore ax
push ss 
push cs
pop es ; es -> cs
pop ds ; ds -> ss

; save ss in dx and not in bp, because bp can be used 
; to access memory [ss:bp] and that might be very useful
push cs
mov dx, ss  
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
add di, (DISTANCE_FROM_TRAPS + (SIZE_OF_TRAPS - ITERATIONS_NUM_SCAN_LOOP*2))
mov ds, dx ; ds -> ss
mov cl, WSIZE_SCAN_CODE + WSIZE_CODE_FOR_SLAVE
mov bp, di
movsw
jmp bp
db 0xCC ; make the code length even
end_copy_traps:

rep movsw ; pasted by the movsw
start_scan:
; here ds -> ss
lds cx, [si] ; cx = ITERATIONS_NUM_SCAN_LOOP, ds = 0x1000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; change slave_call_far code 
; here ds -> cs
; bp -> end_copy_traps

lea di, [bp - end_copy_traps + start_code_for_slave]
mov word [RANDOM_PLACE_FOR_ZOMBIE], di

lea di, [bp + JMPING_DISTANCE + line_to_be_modified - end_copy_traps] 
mov word [di], SUB_MEMO_BX_OPCODE

;; lea di, [bp + JMPING_DISTANCE + slave_call_far - end_copy_traps] 
;; ; di -> address of slave_call_far in the arena in our ***previous position***
;; ;writes on the line slave_call_far the line now is:
;; ;-> sub word [bx], (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
;; mov word [di], SUB_MEMO_BX_OPCODE 
;; mov word [di+2], (JMPING_DISTANCE + slave_call_far - start_code_for_slave)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
mov ds, dx ; ds -> ss

; prepare the placeholder value at code_for_take_over in the stack
; +2 is the offset of the placeholder from the beginning of it's line
mov si, (start_code_for_take_over - start_stack_code + 2) 
mov word [si], bp ; bp -> address of end_copy_traps in the arena
add word [si], (start_code_for_slave - end_copy_traps)

; +10 is important!!! and depends on the start_code_for_take_over
add word [si+10], 2


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
db 0xCC ; make the code length even
end_scan:


start_code_for_slave:
;;; db 0xCC
; we take over call far survivors, thus they have:
; ss -> cs
; ds -> ss (probably)
mov sp, [bx]
sub sp, DISTANCE_FROM_TRAPS + SIZE_OF_TRAPS + 0x200 ; add padding above our code
sub sp, bp
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
db 0xCC ; make the code length even
end_code_for_slave:


start_bytes_for_lds: ; for the command lds...
dw ITERATIONS_NUM_SCAN_LOOP
dw 0x1000 ; code segment
end_bytes_for_lds:


start_code_for_take_over:
mov word [bx], start_code_for_slave ; placeholder value (will be overwritten)
set_slave_segment:
mov word [bx+2], ss ; ss -> original cs
mov dx, SLAVE_TIMER
mov bp, 0 ; this value will be updated
call far [bx]
db 0xCC ; make the code length even
end_code_for_take_over:

end_stack_code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; code_for_zombie:
;; push ds
;; push ss
;; pop ds ; ds -> ss
;; pop ss ; ss -> ds
;; xor bx, bx
;; jmp start_code_for_take_over
;; mov cx, 550
;; wait_loop:
;; loop wait_loop
;; zombie_placeholder:
;; jmp 0xAA ; placeholder

code_for_zombie:
mov cx, 550
wait_loop:
loop wait_loop

mov ax, [RANDOM_PLACE_FOR_ZOMBIE]
push ds
push ss
pop ds ; ds -> ss
pop ss ; ss -> ds
xor bx, bx
mov [bx], ax
jmp set_slave_segment


mapped_nums:
db 0x0
db 0x2f
db 0x8a
db 0xa5
db 0x2f
db 0x0
db 0xa5
db 0x8a
db 0x9b
db 0xb4
db 0x11
db 0x3e
db 0xb4
db 0x9b
db 0x3e
db 0x11
db 0x5e
db 0x71
db 0xd4
db 0xfb
db 0x71
db 0x5e
db 0xfb
db 0xd4
db 0xc5
db 0xea
db 0x4f
db 0x60
db 0xea
db 0xc5
db 0x60
db 0x4f
db 0xda
db 0xf5
db 0x50
db 0x7f
db 0xf5
db 0xda
db 0x7f
db 0x50
db 0x41
db 0x6e
db 0xcb
db 0xe4
db 0x6e
db 0x41
db 0xe4
db 0xcb
db 0x84
db 0xab
db 0xe
db 0x21
db 0xab
db 0x84
db 0x21
db 0xe
db 0x1f
db 0x30
db 0x95
db 0xba
db 0x30
db 0x1f
db 0xba
db 0x95
db 0x2a
db 0x5
db 0xa0
db 0x8f
db 0x5
db 0x2a
db 0x8f
db 0xa0
db 0xb1
db 0x9e
db 0x3b
db 0x14
db 0x9e
db 0xb1
db 0x14
db 0x3b
db 0x74
db 0x5b
db 0xfe
db 0xd1
db 0x5b
db 0x74
db 0xd1
db 0xfe
db 0xef
db 0xc0
db 0x65
db 0x4a
db 0xc0
db 0xef
db 0x4a
db 0x65
db 0xf0
db 0xdf
db 0x7a
db 0x55
db 0xdf
db 0xf0
db 0x55
db 0x7a
db 0x6b
db 0x44
db 0xe1
db 0xce
db 0x44
db 0x6b
db 0xce
db 0xe1
db 0xae
db 0x81
db 0x24
db 0xb
db 0x81
db 0xae
db 0xb
db 0x24
db 0x35
db 0x1a
db 0xbf
db 0x90
db 0x1a
db 0x35
db 0x90
db 0xbf
tail:
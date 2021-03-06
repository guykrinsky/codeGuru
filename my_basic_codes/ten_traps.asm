DISTANCE_FROM_TRAPS equ 400h
TIMER_TO_COPY_PASTE_STACK_CODE equ  (end_stack_code-start_stack_code+1)/2
NUMBER_OF_TRAPS equ 60
JMPING_DISTANCE equ 1200h

;; My code here
mov dx, ax
add dx, call_far_to
add ax, start_stack_code
mov si, ax


push ss
pop es

copy:
mov cx, TIMER_TO_COPY_PASTE_STACK_CODE
rep movsw




push es 
push ds
pop es
pop ds

xchg di, si
add si, 2
mov [si], dx ;call far and trap id
mov [si + 2], cs
mov bp, ss ;Save ss
jmp first_time_skip


start_stack_code:
;values when arriving here:
;es = ds
;ds = cs
;si = end_stack_code-start_stack_code
rep movsw
mov [si], ax
add word[si], (call_far_to - start_stack_code)
first_time_skip:
;praperations for placing traps
mov bx, ax
les ax, [si] ; ax = TRAPS_IDEFNTY = call_far_to , es = cs.
lea di, [bx + DISTANCE_FROM_TRAPS]
lea si, [bx - DISTANCE_FROM_TRAPS]

mov cl, NUMBER_OF_TRAPS/2
place_traps:
rep stosw
mov cl, NUMBER_OF_TRAPS/2
xchg di, si
rep stosw


push cs
push cs
pop ds
pop ss

lea sp, [bx - DISTANCE_FROM_TRAPS - 2]
lea bx, [bx + tail - start_stack_code]
mov [bx], ax
mov [bx + 2], cs
 
call_far_to:
mov cl, NUMBER_OF_TRAPS/2
sub di, NUMBER_OF_TRAPS
sub si, NUMBER_OF_TRAPS
repe cmpsw
test cl, cl ;check if cx is zero
jnz check
call far [bx]

check:
push ax
mov ax, 0xf
scasb ;ES:[DI], updates si, di
je start_attack_opcodes
; if the previous byte wan't 0x0F, check the following byte
scasb ; DS:[SI] - ES:[DI], updates si, di
je start_attack_opcodes

xchg si, di

scasb ; DS:[SI] - ES:[DI], updates si, di
je start_attack_opcodes

scasb ; DS:[SI] - ES:[DI], updates si, di
jne end_attack_opcodes

start_attack_opcodes:
les di, [di-4] ; -4 because di points to the end of the call far bombing
sub di, 2 ; call far opcode is 2 bytes long
stosw

push cs
pop es ; es -> cs (resore es) 
end_attack_opcodes:

paste:
pop ax
add word [bx], JMPING_DISTANCE
mov ax, [bx]
mov ds, bp ; ds -> ss
xor si, si
mov cx, TIMER_TO_COPY_PASTE_STACK_CODE
mov di, ax
movsw 
jmp ax
end_stack_code:
tail:

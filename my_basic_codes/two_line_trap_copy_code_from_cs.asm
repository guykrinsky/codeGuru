DISTANCE_FROM_TRAPS equ 400h
TIMER_TO_COPY_PASTE_STACK_CODE equ  (end_stack_code-start_stack_code+5)/2
NUMBER_OF_TRAPS equ 100H
JMPING_DISTANCE equ 3200h
JUMPING_BETWEEN_BOMBING equ 0x2b

;; My code here

push cs
pop ss
push cs
pop es

add ax, tail
mov bx, ax
sub ax, (tail-call_far_to)
mov [bx],ax
mov [bx + 2], cs
mov bp, JUMPING_BETWEEN_BOMBING 
lea sp, [bx + DISTANCE_FROM_TRAPS + NUMBER_OF_TRAPS + 2]


start_stack_code:
;praperations for placing traps
lea di, [bx - tail - DISTANCE_FROM_TRAPS]
lea si, [bx - tail + DISTANCE_FROM_TRAPS - 2]

mov cl, NUMBER_OF_TRAPS/2 - 1
place_traps:
rep stosw
mov cl, NUMBER_OF_TRAPS/2 
xchg di, si
rep stosw

std

call_far_to:
cmpsw
jnz paste
add sp, bp
call far [bx]

paste:
cld
lea si, [bx - tail + start_stack_code]
sub word [bx], JMPING_DISTANCE
sub bx, JMPING_DISTANCE  
lea di, [bx - tail + start_stack_code]
mov cl, TIMER_TO_COPY_PASTE_STACK_CODE 
rep movsw
sub di, (tail-start_stack_code + 4)
jmp di
end_stack_code:
tail:

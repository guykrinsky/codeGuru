
  %define SS_PLACE_IN_STACK 0x7f8
  %define COPY_CODE_TIMER (end_stack_code-stack_code+1)/2
  %define PASTE_CODE_TIMER (end_paste_code-start_paste_code+1)/2
  %define CALL_FAR_LOWBYTE_ADRESS 0xA1
  %define CALL_FAR_ADRESS_IN_STACK 0x40
  %define NEW_CS 0xfff
  %define JUMPING_BETWEEN_BOMBING 0x2b
  %define FAR_FROM_NEW_ADDRES 0x2000
  %define FAR_FROM_NEW_BOMBING_ADDRES_STARTING_POINT 0xfaea
  %define FAR_FROM_FIRST_BOMBING 0x24da
  %define SI_AFTER_PASTE_CODE (end_paste_code-start_paste_code)+2 ;Note: if this conts have to be even
  %define OLD_CS 0x1000
  ; +2 is because the first movsw doesn't count in paste code, but it increase si by two.
  call word end_decoy
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  decoy
  start_decoy:
  
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;end decoy
  
  ;start taking zombies
  ;bomb zombies or something
  end_decoy:
  
  pop si ; si = start_decoy
  add si, (stack_code - start_decoy); si = stack_code
  
  push cs 
  push dx
  
  ;-------------------------------------------------------- int 87
  les ax,[si+(for_int87-stack_code)] ;ax = 
  mov dx,0x61e
  int 0x87 
  ;--------------------------------------------------------
  
  ;;;;;;;;;;;copy code to the stack
  ;si = stack_code
  lea ax,[si+(end_stack_code-stack_code)] ;mov ax end_stack_code
  mov cx, COPY_CODE_TIMER ; (number of opcodes in stack)/2
  push ss
  les di,[bp+SS_PLACE_IN_STACK] ;es = ss, di = 0
  rep movsw
  ;;;;;;;;;;;

  ;Set the new call far addres.
  sub ah,0x40
  mov bl, CALL_FAR_ADRESS_IN_STACK
  pop ds ; ds = ss
  mov al, CALL_FAR_LOWBYTE_ADRESS;
  pop dx ;dx is timer for the zombies
  pop ss ;ss = cs
  
  ;store the new call far addres in the stack
  mov [bx],ax
  mov word [bx+0x2], NEW_CS
  les di,[bx] ;es = NEW_CS, di = ax(call far addres)
  
  ;preperations.
  mov bp, JUMPING_BETWEEN_BOMBING 
  mov ax, FAR_FROM_NEW_ADDRES
  mov cl,PASTE_CODE_TIMER
  
  ;We store the FAR_FROM_NEW_BOMBING_ADDRES_STARTING_POINT in the stack
  ;When overriding myself that will happen: sub bp, FAR_FROM_NEW_BOMBING_ADDRES_STARTING_POINT.
  mov si, SI_AFTER_PASTE_CODE 
  mov word [bx+si], FAR_FROM_NEW_BOMBING_ADDRES_STARTING_POINT ; adding two because using this after one movsw for somereson

  ;write call far in new addres
  movsw
  movsw
  
  dec di ;di point to the correct point that movsw should write one
  
  ;di = call_far addres.
  ;sp = the first bombing place.
  lea sp,[di+FAR_FROM_FIRST_BOMBING]
  xor si,si
  ;end preperations
  ;start bombing
  call word far [bx+si] ;si - 0 probably for int 87
  
  stack_code:
  rep movsw
  start_paste_code: ;paste this code when override yourself.
  sub [bx],ax ;change call_far to new addres
  les di,[bx] ;es = cs, di = new call_far addres
  sub sp,[bx+si] 
  movsw	;write call far in new addres
  movsw ;write sub sp,bp in new addres
  dec di ;di point to the correct point that movsw should write one
  xor si,si
  mov cl,PASTE_CODE_TIMER
  
  
  ;this is very confusing. but it is nice trick.
  ;when runnig it will be like this:
  ;timer for zombies
  dec dx 
  db 0x75 ;0x75ff = jnz timer_not_over - this opcodes it is for cheking zombies's timer.
  ;timer_not_over:
  db 0xff ; 0xFF18 call word far [bx+si]
  db 0x18
  db 0xcc ;this opcode make stack_code even.
  end_paste_code:
  
  ;main loop
  sub sp,bp
  call word far [bx+si]
  end_stack_code:
  
  decoy_end_start:
  
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  
  for_int87:
  rep movsw
  dw OLD_CS

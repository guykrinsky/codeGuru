push cs
pop es
push cs
pop ss
mov sp, ax
mov di, ax
add di, end
mov bx, 0cccch
mov ax, 0ab53h
stosw
end:
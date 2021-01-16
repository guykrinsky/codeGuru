RANDOM_PLACE equ 1234
DELAY_TIME equ 55
mov dx, ax ;dx will point to the start of the program


mov dx, ax
add ax, zombe_code
mov [RANDOM_PLACE], ax
mov cx, DELAY_TIME
delay:
loop delay


%macro get_zombe_foot_print 1
mov ax, [8000h + %1]
stosw
%endmacro

get_zombe_foot_print 100h
get_zombe_foot_print 200h
get_zombe_foot_print 300h
get_zombe_foot_print 400h
get_zombe_foot_print 500h
get_zombe_foot_print 600h
get_zombe_foot_print 700h
get_zombe_foot_print 800h

mov cx, 8
mov di, 0
take_zombe:
push cx
push es
pop ds
push cs
pop es

mov ax, [di]
xchg ah, al 
mov bx, dx
add bx, table
push ds
pop es
push cs
pop ds
xlat
mov cl, al 

xchg ah, al 
xlat 
xor al, cl
xchg al, ah 

; make the zombe jump to our code
add ax, 0x67 
mov bx, ax
mov word[bx] , 26ffh
mov word[bx+2] , 04d2h
add di, 2
pop cx
loop take_zombe

zombe_code:
push cs
pop ss
mov di, ax
mov sp, di
mov ax, 0ab53h
mov bx, 0cccch
mov cx, di
stosw
jmp cx


table:
db 0 ;00
db 46 ;01
db 136 ;02
db 166 ;03
db 43 ;04
db 5 ;05
db 163 ;06
db 141 ;07
db 147 ;08
db 189 ;09
db 27 ;0A
db 53 ;0B
db 184 ;0C
db 150 ;0D
db 48 ;0E
db 30 ;0F
db 78 ;10
db 96 ;11
db 198 ;12
db 232 ;13
db 101 ;14
db 75 ;15
db 237 ;16
db 195 ;17
db 221 ;18
db 243 ;19
db 85 ;1A
db 123 ;1B
db 246 ;1C
db 216 ;1D
db 126 ;1E
db 80 ;1F
db 250 ;20
db 212 ;21
db 114 ;22
db 92 ;23
db 209 ;24
db 255 ;25
db 89 ;26
db 119 ;27
db 105 ;28
db 71 ;29
db 225 ;2A
db 207 ;2B
db 66 ;2C
db 108 ;2D
db 202 ;2E
db 228 ;2F
db 180 ;30
db 154 ;31
db 60 ;32
db 18 ;33
db 159 ;34
db 177 ;35
db 23 ;36
db 57 ;37
db 39 ;38
db 9 ;39
db 175 ;3A
db 129 ;3B
db 12 ;3C
db 34 ;3D
db 132 ;3E
db 170 ;3F
db 106 ;40
db 68 ;41
db 226 ;42
db 204 ;43
db 65 ;44
db 111 ;45
db 201 ;46
db 231 ;47
db 249 ;48
db 215 ;49
db 113 ;4A
db 95 ;4B
db 210 ;4C
db 252 ;4D
db 90 ;4E
db 116 ;4F
db 36 ;50
db 10 ;51
db 172 ;52
db 130 ;53
db 15 ;54
db 33 ;55
db 135 ;56
db 169 ;57
db 183 ;58
db 153 ;59
db 63 ;5A
db 17 ;5B
db 156 ;5C
db 178 ;5D
db 20 ;5E
db 58 ;5F
db 144 ;60
db 190 ;61
db 24 ;62
db 54 ;63
db 187 ;64
db 149 ;65
db 51 ;66
db 29 ;67
db 3 ;68
db 45 ;69
db 139 ;6A
db 165 ;6B
db 40 ;6C
db 6 ;6D
db 160 ;6E
db 142 ;6F
db 222 ;70
db 240 ;71
db 86 ;72
db 120 ;73
db 245 ;74
db 219 ;75
db 125 ;76
db 83 ;77
db 77 ;78
db 99 ;79
db 197 ;7A
db 235 ;7B
db 102 ;7C
db 72 ;7D
db 238 ;7E
db 192 ;7F
db 128 ;80
db 174 ;81
db 8 ;82
db 38 ;83
db 171 ;84
db 133 ;85
db 35 ;86
db 13 ;87
db 19 ;88
db 61 ;89
db 155 ;8A
db 181 ;8B
db 56 ;8C
db 22 ;8D
db 176 ;8E
db 158 ;8F
db 206 ;90
db 224 ;91
db 70 ;92
db 104 ;93
db 229 ;94
db 203 ;95
db 109 ;96
db 67 ;97
db 93 ;98
db 115 ;99
db 213 ;9A
db 251 ;9B
db 118 ;9C
db 88 ;9D
db 254 ;9E
db 208 ;9F
db 122 ;A0
db 84 ;A1
db 242 ;A2
db 220 ;A3
db 81 ;A4
db 127 ;A5
db 217 ;A6
db 247 ;A7
db 233 ;A8
db 199 ;A9
db 97 ;AA
db 79 ;AB
db 194 ;AC
db 236 ;AD
db 74 ;AE
db 100 ;AF
db 52 ;B0
db 26 ;B1
db 188 ;B2
db 146 ;B3
db 31 ;B4
db 49 ;B5
db 151 ;B6
db 185 ;B7
db 167 ;B8
db 137 ;B9
db 47 ;BA
db 1 ;BB
db 140 ;BC
db 162 ;BD
db 4 ;BE
db 42 ;BF
db 234 ;C0
db 196 ;C1
db 98 ;C2
db 76 ;C3
db 193 ;C4
db 239 ;C5
db 73 ;C6
db 103 ;C7
db 121 ;C8
db 87 ;C9
db 241 ;CA
db 223 ;CB
db 82 ;CC
db 124 ;CD
db 218 ;CE
db 244 ;CF
db 164 ;D0
db 138 ;D1
db 44 ;D2
db 2 ;D3
db 143 ;D4
db 161 ;D5
db 7 ;D6
db 41 ;D7
db 55 ;D8
db 25 ;D9
db 191 ;DA
db 145 ;DB
db 28 ;DC
db 50 ;DD
db 148 ;DE
db 186 ;DF
db 16 ;E0
db 62 ;E1
db 152 ;E2
db 182 ;E3
db 59 ;E4
db 21 ;E5
db 179 ;E6
db 157 ;E7
db 131 ;E8
db 173 ;E9
db 11 ;EA
db 37 ;EB
db 168 ;EC
db 134 ;ED
db 32 ;EE
db 14 ;EF
db 94 ;F0
db 112 ;F1
db 214 ;F2
db 248 ;F3
db 117 ;F4
db 91 ;F5
db 253 ;F6
db 211 ;F7
db 205 ;F8
db 227 ;F9
db 69 ;FA
db 107 ;FB
db 230 ;FC
db 200 ;FD
db 110 ;FE
db 64 ;FF
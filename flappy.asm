pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees  
include GFX.inc

extrn imageBird:byte
extrn imageSky:byte
extrn imagePress:byte

xBirdCoordo DW 50
yBirdCoordo DW 50
speed DW 1

donnees ends

code    segment public    ; Segment de code


assume  cs:code,ds:donnees,es:code,ss:pile

myprog:                       ; Début du programme
    mov ax, donnees ; Pointe vers le segment de données
    mov ds, ax

    call Video13h

screen_start:     

    ; press space to play
    mov hY,0
    mov hX,0
    mov BX, offset imageSky
    call drawIcon

    mov hY,40
    mov hX,80
    mov BX, offset imagePress
    call drawIcon

    mov hY,50
    mov hX,50
    mov BX, offset imageBird
    call drawIcon

    call WaitKey
    cmp userinput, 32
    jne screen_start
    call ClearScreen

start_game:

    mov BX, offset imageSky
    mov hX, 0
    mov hY, 0
    call drawIcon

    mov BX, offset imageBird
    mov CX, xBirdCoordo
    mov DX, yBirdCoordo
    mov hX, CX
    mov hY, DX
    mov tempo, 5
    call drawIcon

action_loop:
    cmp speed , 7
    jge limit_place
    add speed, 1; if positive you go down

limit_place:    
    cmp yBirdCoordo, 5 ; if at top of the screen dont go up
    jle change_pos_if_speed_pos
    cmp yBirdCoordo, 145 ; if at bottom of the screen dont go down
    jge change_neg_pos
    jmp draw_loop

change_neg_pos:
    mov speed, -1
    jmp draw_loop          

change_pos_if_speed_pos:
    mov speed, 1
    jmp draw_loop

draw_loop:    
    mov CX, speed
    add yBirdCoordo, CX

    mov BX, offset imageBird
    mov CX, xBirdCoordo
    mov DX, yBirdCoordo
    mov hX, CX
    mov hY, DX
    call drawIcon
    call sleep

    sub DX,30

    mov rX, CX
    mov rY, DX
    mov rW, 30
    mov rH, 30
    mov col, 102

    call fillRect

    
jump:
    call PeekKey
    cmp userinput, 97
    je fin
    cmp userinput, 32
    jne goto_draw_loop
    cmp speed, -8
    jl goto_draw_loop
    sub speed, 8 ; if negative you go up 
goto_draw_loop:  ; pour éviter jne is too far to jump
    jmp action_loop

fin:
    
    mov AH,4Ch  ; 4Ch = fonction exit DOS
    mov AL,00h  ; code de sortie 0 (OK)
    int 21h

code ends
end myprog

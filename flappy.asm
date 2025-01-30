pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees  
include GFX.inc

extrn imageBird:byte

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

    mov BX, offset imageBird
    mov CX, xBirdCoordo
    mov DX, yBirdCoordo
    mov hX, CX
    mov hY, DX
    mov tempo, 3
    call drawIcon

action_loop:
    call sleep

    cmp speed , 7
    jge draw_loop
    add speed, 1; if positive you go down

draw_loop:    
    mov CX, speed
    add yBirdCoordo, CX
    
    call ClearScreen

    mov BX, offset imageBird
    mov CX, xBirdCoordo
    mov DX, yBirdCoordo
    mov hX, CX
    mov hY, DX
    call drawIcon
    
jump:
    call PeekKey
    cmp userinput, 97
    je fin
    cmp userinput, 32
    jne action_loop
    cmp speed, -8
    jl action_loop
    sub speed, 11 ; if negative you go up 
    jmp action_loop

delete_speed:
    mov speed, 0
    sub speed, 16
    jmp action_loop


fin:
    mov AH,4Ch  ; 4Ch = fonction exit DOS
    mov AL,00h  ; code de sortie 0 (OK)
    int 21h

code ends
end myprog

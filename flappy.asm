pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees  
include GFX.inc

extrn imageBird:byte
extrn imagePress:byte

extrn imageQuit:byte

xBirdCoordo DW 50
yBirdCoordo DW 50
oldYBirdCoordo DW 50
speed DW 1

donnees ends

code    segment public    ; Segment de code


assume  cs:code,ds:donnees,es:code,ss:pile

;background color = 102

myprog:                       ; Début du programme
    mov ax, donnees ; Pointe vers le segment de données
    mov ds, ax

    call Video13h

screen_start:     

    ; press space to play
    ;replace that by a big rectangle
    mov rX,0
    mov rY,0
    mov rH,175 
    mov rW,300
    mov col,102
    call fillRect

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
    mov rX,0
    mov rY,0
    mov rH,168
    mov rW,300
    mov col,102
    call fillRect

    mov BX, offset imageBird
    mov yBirdCoordo, 50
    mov hX, 50
    mov hY, 50
    mov tempo, 5
    call drawIcon

action_loop:
    cmp speed , 4
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
    cmp speed,0
    je goto_action    ; no need to draw in this case
    jmp next_draw_loop

goto_action:
    jmp jump

next_draw_loop:
    mov DX, yBirdCoordo
    mov oldYBirdCoordo, DX
    mov CX, speed
    add yBirdCoordo, CX ; new Y position of the bird based on speed ; best solution to store old position

    mov BX, offset imageBird
    mov CX, xBirdCoordo
    mov DX, yBirdCoordo
    mov hX, CX
    mov hY, DX
    call drawIcon  ; draw new bird
    call sleep

    ;delete old bird based on old position
    cmp speed,0
    je jump
    jl redraw_for_neg_speed  ; we go up
    jg redraw_for_pos_speed  ; we go down

redraw_for_neg_speed:   ; monte donc old > new
    mov DX, oldYBirdCoordo 
    mov CX, yBirdCoordo
    sub DX,CX ; taille to draw the rectangle
    add CX,22 ; offset the y coordo at the bottom
    mov BX, xBirdCoordo
    mov rX, BX
    mov rY, CX
    mov rW, 30
    mov rH, DX
    mov col, 102

    call fillRect ; delete old bird
    jmp jump

redraw_for_pos_speed: ; descend donc old < new
    mov CX, oldYBirdCoordo 
    mov DX, yBirdCoordo
    sub DX,CX
    mov BX, xBirdCoordo 
    mov rX, BX
    mov rY, CX
    mov rW, 30
    mov rH, DX
    mov col, 102

    call fillRect ; delete old bird
    jmp jump

jump:
    call PeekKey
    cmp userinput, 97
    je play_again_draw_choice
    cmp userinput, 32
    jne goto_draw_loop
    cmp speed, -8
    jl goto_draw_loop
    sub speed, 8 ; if negative you go up 
goto_draw_loop:  ; pour éviter jne is too far to jump
    jmp action_loop

play_again_draw_choice:
    mov BX, offset imageQuit
    mov hX, 50
    mov hY, 185
    call drawIcon
play_again:
    call WaitKey
    cmp userinput, 114 ; r
    je jump_to_restart
    cmp userinput, 113 ; q
    je fin
    jmp play_again
jump_to_restart:
    call ClearScreen
    jmp start_game    

fin:
    mov AH,4Ch  ; 4Ch = fonction exit DOS
    mov AL,00h  ; code de sortie 0 (OK)
    int 21h

code ends
end myprog

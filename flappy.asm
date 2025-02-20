pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees  
include GFX.inc

extrn imageBird:byte
extrn imagePress:byte

extrn imageQuit:byte
extrn imageGameOver:byte
extrn imageGround:byte
extrn imagePipe:byte
extrn imagePipeL:byte
extrn imagePipeM:byte
extrn imagePipeS:byte
extrn imagePipeLReverse:byte
extrn imagePipeMReverse:byte
extrn imagePipeSReverse:byte
extrn imageScore:byte

xBirdCoordo DW 25
yBirdCoordo DW 50
oldYBirdCoordo DW 50
speed DW 1

xPipeCoordo DW 230
heighReversePipe DW 58
heighPipe DW 58

widthPipe DW 20
speedPipe DW 3

xScore DW 260
yScore DW 30

; color 8

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
    mov rH,160
    mov rW,250
    mov col,102
    call fillRect

    mov hY,40
    mov hX,80
    mov BX, offset imagePress
    call drawIcon

    mov hY,50
    mov hX,40
    mov BX, offset imageBird
    call drawIcon

    call WaitKey
    cmp userinput, 32
    jne screen_start
    call ClearScreen    

start_game:
    mov rX,0
    mov rY,0
    mov rH,160
    mov rW,250
    mov col,102
    call fillRect

    mov BX, offset imageGround
    mov hX,1
    mov hY,160
    call drawIcon

    mov BX, offset imageBird
    mov yBirdCoordo, 50
    mov hX, 25
    mov hY, 50
    mov tempo, 5
    call drawIcon

    mov xPipeCoordo, 230
    mov heighPipe, 58
    mov heighReversePipe, 58
    mov BX, offset imagePipeMReverse
    mov hX, 230
    mov hY, 0
    call drawIcon

    mov BX, offset imagePipeM
    mov CX,160
    sub CX, heighPipe
    mov hX, 230
    mov hY, CX
    call drawIcon

    mov xScore, 260
    mov yScore, 30
    mov BX, offset imageScore
    mov hX, 260
    mov hY, 10
    call drawIcon

action_loop:
    cmp speed , 3
    jge make_pipe_move
    add speed, 1; if positive you go down
    jmp make_pipe_move

make_pipe_move:
    mov CX, speedPipe
    sub xPipeCoordo, CX ; new X for both pipes
    
    mov BX, offset imagePipeMReverse
    mov CX, xPipeCoordo
    mov hX, CX
    mov hY, 0
    call drawIcon

    ; delete old reverse pipe
    mov BX, xPipeCoordo
    add BX, widthPipe
    mov CX,speedPipe
    sub CX,1
    mov DX, heighReversePipe
    sub DX,1
    mov rX, BX
    mov rY, 0
    mov rW, CX
    mov rH, DX
    mov col, 102
    call fillRect

    ; draw new pipe
    mov CX, xPipeCoordo
    mov BX, offset imagePipeM
    mov DX,160
    sub DX, heighPipe
    mov hX, CX
    mov hY, DX ; decal the Y to size of the pipe, no problem for reverse its always 0
    call drawIcon

    ;delete old pipe we know that pipe is always at the bottom : 160 - height
    mov CX,speedPipe
    sub CX,1
    mov rW, CX

    mov BX, xPipeCoordo
    add BX, widthPipe
    mov DX, heighPipe
    sub DX,1
    mov CX,160
    sub CX, heighPipe

    mov rX, BX
    mov rY, CX
    mov rH, DX
    mov col, 102
    call fillRect

    cmp xPipeCoordo, 2
    jle restart_pipe
    jmp hitbox_pipe

restart_pipe:
    mov rX, 2 ; delete the pipe who reach end screen
    mov rY, 0
    mov rH, 160
    mov rw, 20
    mov col, 102
    call fillRect
    mov xPipeCoordo, 230

    ;score gestion

    mov CX, xScore ; draw score
    mov DX, yScore
    mov cCX, CX
    mov cDx, DX
    mov col, 102
    call BigPixl

    add xScore,2
    cmp xScore, 305
    jge redirect_score  
    cmp xScore, 280
    jne hitbox_pipe ; add 4 only if x is not equal to 261
    add xScore,6
    jmp hitbox_pipe

redirect_score:
    mov xScore, 260
    add yScore, 5
    jmp hitbox_pipe

hitbox_pipe:
    mov CX, xBirdCoordo ; + 18 to get the right side of the bird
    add CX, 18
    cmp xPipeCoordo, CX ; check if x collide
    jge limit_place ; if not go to the next check
    
    mov DX, yBirdCoordo ; + 14 to get the bottom of the bird
    cmp DX, heighReversePipe
    jl go_to_restart
    add DX, 14
    mov CX, 160
    sub CX, heighPipe
    cmp DX, CX
    jg go_to_restart
    jmp limit_place

go_to_restart:
    jmp play_again_draw_choice
limit_place:
    cmp yBirdCoordo, 5 ; if at top of the screen dont go up
    jle change_pos_if_speed_pos ; is at the top
    cmp yBirdCoordo, 145 ; 160 - heigt if at bottom of the screen dont go down
    jge change_neg_pos ; is at the bottom
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
    add CX,14 ; offset the y coordo at the bottom
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
    sub DX,1
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
    sub speed, 8 ; if negative you go up ; jump force
goto_draw_loop:  ; pour éviter jne is too far to jump
    jmp action_loop

play_again_draw_choice:

    mov BX, offset imageGameOver
    mov hX, 70
    mov hY, 140
    call drawIcon

    mov BX, offset imageQuit
    mov hX, 60
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

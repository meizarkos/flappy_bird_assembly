pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees
; vos variables
include GFX.inc

donnees ends

code    segment public    ; Segment de code

speed dw 1

yBirdCoord dw 50
xBirdCoord dw 50

assume  cs:code,ds:donnees,es:code,ss:pile

myprog:                       ; Début du programme
    mov ax, donnees ; Pointe vers le segment de données
    mov ds, ax
    call Video13h

start_game:
    call PeekKey

    mov DX, xBirdCoord ; problème en passant par variable
    mov CX, yBirdCoord ; si valeur en clair c'est ok

    mov Rx, DX
    mov Ry, CX
    mov Rw, 10
    mov Rh, 5
    mov col, 4

    call Rectangle

    mov Rx, 50
    mov Ry, 60  
    mov Rw, 10
    mov Rh, 5
    mov col, 2

    call Rectangle

    jmp fin




jump:

    

    cmp userinput, 32 ; value of espace
    jne start_game  


    ; Vérifier si une touche est pressée pour faire sauter l'oiseau
    ;call PeekKey
    ;cmp userinput, 0
    ;je no_jump
    ;sub ax, [jump]
    ;mov [birdY], ax
    ;call WaitKey

;no_jump:
    ; Vérifier les collisions et mettre à jour le score
    ; (à implémenter)

    ; Attendre un court instant
    ;mov tempo, 5
    ;call sleep

    ; Répéter le jeu
    ;jmp start_game

fin:
    mov AH,4Ch  ; 4Ch = fonction exit DOS
    mov AL,00h  ; code de sortie 0 (OK)
    int 21h

code ends
end myprog

pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees
; vos variables
include GFX.inc

donnees ends

code    segment public    ; Segment de code
assume  cs:code,ds:donnees,es:code,ss:pile

myprog:                       ; Début du programme
    MOV ax, donnees ; Pointe vers le segment de données
    MOV ds, ax

    call Video13h

    MOV cCX, 0
    MOV cDX, 50
    MOV col, 255

    call BigPixl  ; Début du jeu




;start_game:
    ;call ClearScreen

    ; Dessiner l'oiseau
    ;mov ax, 14
    ;mov [col], ax
    ;mov cx, 50
    ;mov [cCX], cx
    ;mov ax, [birdY]
    ;mov [cDX], ax
    ;call BigPixl

    ; Appliquer la gravité
    ;add ax, [gravity]
    ;mov [birdY], ax

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

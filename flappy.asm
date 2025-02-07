pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees  
include GFX.inc           ; Inclure le fichier GFX.inc

extrn imageBird:byte      ; Déclaration externe de l'image de l'oiseau
extrn imagePress:byte     ; Déclaration externe de l'image "Press"
extrn imageQuit:byte      ; Déclaration externe de l'image "Quit"
extrn imagePipe:byte      ; Déclaration externe de l'image du tuyau

xBirdCoordo DW 40         ; Coordonnée X de l'oiseau
yBirdCoordo DW 50         ; Coordonnée Y de l'oiseau
oldYBirdCoordo DW 50      ; Ancienne coordonnée Y de l'oiseau
speed DW 1                ; Vitesse de l'oiseau

xPipeCoordo DW 150        ; Coordonnée X du tuyau
yPipeCoordo DW 100        ; Coordonnée Y du tuyau

donnees ends

code    segment public    ; Segment de code

assume  cs:code,ds:donnees,es:code,ss:pile  ; Assumer les segments

;background color = 102

myprog:                       ; Début du programme
    mov ax, donnees          ; Pointe vers le segment de données
    mov ds, ax               ; Charger le segment de données dans DS

    call Video13h            ; Appeler la fonction Video13h

screen_start:                ; Début de l'écran de démarrage

    ; press space to play
    ;replace that by a big rectangle
    mov rX,0                 ; Position X du rectangle
    mov rY,0                 ; Position Y du rectangle
    mov rH,175               ; Hauteur du rectangle
    mov rW,300               ; Largeur du rectangle
    mov col,102              ; Couleur du rectangle
    call fillRect            ; Appeler la fonction pour remplir le rectangle

    mov hY,40                ; Position Y de l'image "Press"
    mov hX,80                ; Position X de l'image "Press"
    mov BX, offset imagePress; Offset de l'image "Press"
    call drawIcon            ; Appeler la fonction pour dessiner l'icône

    mov hY,50                ; Position Y de l'image de l'oiseau
    mov hX,40                ; Position X de l'image de l'oiseau
    mov BX, offset imageBird ; Offset de l'image de l'oiseau
    call drawIcon            ; Appeler la fonction pour dessiner l'icône

    call WaitKey             ; Attendre une touche
    cmp userinput, 32        ; Comparer l'entrée utilisateur avec l'espace
    jne screen_start         ; Si ce n'est pas l'espace, revenir à l'écran de démarrage
    call ClearScreen         ; Effacer l'écran

start_game:                  ; Début du jeu
    mov rX,0                 ; Position X du rectangle
    mov rY,0                 ; Position Y du rectangle
    mov rH,168               ; Hauteur du rectangle
    mov rW,300               ; Largeur du rectangle
    mov col,102              ; Couleur du rectangle
    call fillRect            ; Appeler la fonction pour remplir le rectangle

    mov BX, offset imageBird ; Offset de l'image de l'oiseau
    mov yBirdCoordo, 50      ; Initialiser la coordonnée Y de l'oiseau
    mov hX, 40               ; Position X de l'oiseau
    mov hY, 50               ; Position Y de l'oiseau
    mov tempo, 5             ; Initialiser le tempo
    call drawIcon            ; Appeler la fonction pour dessiner l'icône

    ; Afficher le tuyau agrandi
    mov BX, offset imagePipe ; Offset de l'image du tuyau
    mov yPipeCoordo, 100     ; Initialiser la coordonnée Y du tuyau
    mov hY, yPipeCoordo      ; Position Y du tuyau
    mov hX, xPipeCoordo      ; Position X du tuyau
    call drawIcon            ; Appeler la fonction pour dessiner l'icône

action_loop:                 ; Boucle d'action
    cmp speed , 3            ; Comparer la vitesse avec 3
    jge limit_place          ; Si la vitesse est supérieure ou égale à 3, aller à limit_place
    add speed, 1             ; Si positive, descendre

limit_place:                 ; Limite de position
    cmp yBirdCoordo, 5       ; Comparer la coordonnée Y de l'oiseau avec 5
    jle change_pos_if_speed_pos ; Si au sommet de l'écran, aller à change_pos_if_speed_pos
    cmp yBirdCoordo, 145     ; Comparer la coordonnée Y de l'oiseau avec 145
    jge change_neg_pos       ; Si au bas de l'écran, aller à change_neg_pos
    jmp draw_loop            ; Aller à draw_loop

change_neg_pos:              ; Changer la position si la vitesse est négative
    mov speed, -1            ; Définir la vitesse à -1
    jmp draw_loop            ; Aller à draw_loop

change_pos_if_speed_pos:     ; Changer la position si la vitesse est positive
    mov speed, 1             ; Définir la vitesse à 1
    jmp draw_loop            ; Aller à draw_loop

draw_loop:                   ; Boucle de dessin
    cmp speed,0              ; Comparer la vitesse avec 0
    je goto_action           ; Si égale à 0, aller à goto_action
    jmp next_draw_loop       ; Aller à next_draw_loop

goto_action:                 ; Aller à l'action
    jmp jump                 ; Aller à jump

next_draw_loop:              ; Prochaine boucle de dessin
    mov DX, yBirdCoordo      ; Charger la coordonnée Y de l'oiseau dans DX
    mov oldYBirdCoordo, DX   ; Stocker l'ancienne coordonnée Y de l'oiseau
    mov CX, speed            ; Charger la vitesse dans CX
    add yBirdCoordo, CX      ; Ajouter la vitesse à la coordonnée Y de l'oiseau

    mov BX, offset imageBird ; Offset de l'image de l'oiseau
    mov CX, xBirdCoordo      ; Charger la coordonnée X de l'oiseau dans CX
    mov DX, yBirdCoordo      ; Charger la nouvelle coordonnée Y de l'oiseau dans DX
    mov hX, CX               ; Définir la position X de l'oiseau
    mov hY, DX               ; Définir la position Y de l'oiseau
    call drawIcon            ; Appeler la fonction pour dessiner l'icône
    call sleep               ; Appeler la fonction sleep

    ; Supprimer l'ancien oiseau basé sur l'ancienne position
    cmp speed,0              ; Comparer la vitesse avec 0
    je jump                  ; Si égale à 0, aller à jump
    jl redraw_for_neg_speed  ; Si négative, aller à redraw_for_neg_speed
    jg redraw_for_pos_speed  ; Si positive, aller à redraw_for_pos_speed

redraw_for_neg_speed:        ; Redessiner pour une vitesse négative
    mov DX, oldYBirdCoordo   ; Charger l'ancienne coordonnée Y de l'oiseau dans DX
    mov CX, yBirdCoordo      ; Charger la nouvelle coordonnée Y de l'oiseau dans CX
    sub DX,CX                ; Calculer la taille du rectangle
    add CX,22                ; Décaler la coordonnée Y en bas
    mov BX, xBirdCoordo      ; Charger la coordonnée X de l'oiseau dans BX
    mov rX, BX               ; Définir la position X du rectangle
    mov rY, CX               ; Définir la position Y du rectangle
    mov rW, 30               ; Définir la largeur du rectangle
    mov rH, DX               ; Définir la hauteur du rectangle
    mov col, 102             ; Définir la couleur du rectangle

    call fillRect            ; Appeler la fonction pour remplir le rectangle
    jmp jump                 ; Aller à jump

redraw_for_pos_speed:        ; Redessiner pour une vitesse positive
    mov CX, oldYBirdCoordo   ; Charger l'ancienne coordonnée Y de l'oiseau dans CX
    mov DX, yBirdCoordo      ; Charger la nouvelle coordonnée Y de l'oiseau dans DX
    sub DX,CX                ; Calculer la taille du rectangle
    sub DX,1                 ; Décrémenter DX de 1
    mov BX, xBirdCoordo      ; Charger la coordonnée X de l'oiseau dans BX
    mov rX, BX               ; Définir la position X du rectangle
    mov rY, CX               ; Définir la position Y du rectangle
    mov rW, 30               ; Définir la largeur du rectangle
    mov rH, DX               ; Définir la hauteur du rectangle
    mov col, 102             ; Définir la couleur du rectangle

    call fillRect            ; Appeler la fonction pour remplir le rectangle
    jmp jump                 ; Aller à jump

jump:                        ; Sauter
    call PeekKey             ; Appeler la fonction PeekKey
    cmp userinput, 97        ; Comparer l'entrée utilisateur avec 'a'
    je play_again_draw_choice; Si égale à 'a', aller à play_again_draw_choice
    cmp userinput, 32        ; Comparer l'entrée utilisateur avec l'espace
    jne goto_draw_loop       ; Si ce n'est pas l'espace, aller à goto_draw_loop
    cmp speed, -8            ; Comparer la vitesse avec -8
    jl goto_draw_loop        ; Si inférieure à -8, aller à goto_draw_loop
    sub speed, 8             ; Si négative, monter
goto_draw_loop:              ; Aller à la boucle de dessin
    jmp action_loop          ; Aller à la boucle d'action

play_again_draw_choice:      ; Choix de rejouer
    mov BX, offset imageQuit ; Offset de l'image "Quit"
    mov hX, 50               ; Position X de l'image "Quit"
    mov hY, 185              ; Position Y de l'image "Quit"
    call drawIcon            ; Appeler la fonction pour dessiner l'icône
play_again:                  ; Rejouer
    call WaitKey             ; Attendre une touche
    cmp userinput, 114       ; Comparer l'entrée utilisateur avec 'r'
    je jump_to_restart       ; Si égale à 'r', aller à jump_to_restart
    cmp userinput, 113       ; Comparer l'entrée utilisateur avec 'q'
    je fin                   ; Si égale à 'q', aller à fin
    jmp play_again           ; Revenir à play_again
jump_to_restart:             ; Recommencer
    call ClearScreen         ; Effacer l'écran
    jmp start_game           ; Revenir au début du jeu

fin:                         ; Fin du programme
    mov AH,4Ch               ; 4Ch = fonction exit DOS
    mov AL,00h               ; Code de sortie 0 (OK)
    int 21h                  ; Interruption DOS

code ends
end myprog                  ; Fin du programme

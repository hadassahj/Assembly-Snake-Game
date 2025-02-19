include emu8086.inc
org     100h
    
    mov ah, 0 ;setam modul text, 80x25
    mov al, 3
    int 10h
    
    ; print mesaj cu instructiuni: 
    mov dx, offset msg0
    mov ah, 9 
    int 21h  
    
    ; las mesajul afisat pana cand primesc in buffer orice tasta
    mov ah, 00h
    int 16h   
    
    call CLEAR_SCREEN ;sterg mesajul cu instructiuni de pe ecran cu macro
    
 
    ; afisez mesajul care va fi "mancat" 
    mov dx, offset msg1
    mov ah, 9 
    int 21h 

    call border ; desenez marginile cu care sarpele va face coliziune

    ; astept sa inceapa jocul cand primesc orice tasta in buffer
    mov ah, 00h
    int 16h
    
    ; ascund cursorul:
    CURSOROFF         
    
    ; initializez capul sarpelui in mijlocul ecranului
    mov dh, 12  ; row 12
    mov dl, 40  ; column 40
    mov [snake], dx

game_loop:
    
    mov al, 0  ; selectez pagina 0
    mov ah, 05h
    int 10h
    
    ; afisez capul sarpelui
    mov dx, [snake]
    
    ; setam cursorul in pozitia dl, dh
    mov ah, 02h
    int 10h
    
    ; printam '*' in pozitia dl, dh, capul sarpelui:
    mov al, '*'
    mov ah, 09h
    mov bl, 0ah ; attribute.
    mov cx, 1   ; single char.
    int 10h
    
    ; coada:
    mov ax, [snake + s_size * 2 - 2]
    mov [tail], ax
    
    call move_snake
    
    ; stergem vechiul segment de coada:
    mov dx, [tail]
    
    ; setam cursoul la dl,dh
    mov ah, 02h
    int 10h
    
    ; printam ' ' in locatie, iluzie pentru "a mancat":
    mov al, ' '
    mov ah, 09h
    mov bl, 0ah ; attribute.
    mov cx, 1   ; single char.
    int 10h
    
    check_for_key:
    ; verificam input in keyboard buffer :
    mov ah, 01h
    int 16h
    jz no_key    ; daca nicio tasta nu a fost apasata
    
    mov ah, 00h   ; interrupt: in ah avem codul tastei si in al codul ascii
    int 16h
    
    cmp al, 1bh    ; verificam daca este apasat esc?
    je fail  ; oprim jocul si afisam scorul
    
    mov [cur_dir], ah     ; tinem minte codul scan pt viitoare directie
    
    no_key:
    ; mini bucla de asteptare input
    mov ah, 00h
    int 1ah
    cmp dx, [wait_time]
    jb check_for_key     ;daca nu a trecut timpul stabilit, verificam input 
    add dx, 4
    mov [wait_time], dx
    
    ; eternal game loop:
jmp game_loop
 
 
fail:
    mov dx, offset msgover  ; afisam mesajul "Game Over"
    mov ah, 9
    int 21h
    
    mov ax, [score]
    
    call print_num ;printeaza ce e in ax, adica scorul
    
    ; iesire din program
    mov ah, 4Ch
    mov al, 0
    int 21h 
 
stop_game:
    ; afisez din nou cursoul
    CURSORON
 
ret

; ------ functions ------   
; ------ functions ------
; ------ functions ------



border proc ; build borders function
    ; Setam modul text.
    mov ah, 0
    mov al, 3
    int 10h

    ; Desenam marginea de sus.
    mov cx, 80
    mov dl, 0
    mov dh, 0
draw_top:
    mov ah, 02h
    int 10h
    mov ah, 09h
    mov al, '#'
    mov bl, 0Eh
    mov cx, 80
    int 10h

    ; Desenam marginea de jos.
    mov cx, 80
    mov dl, 0
    mov dh, 24
draw_bottom:
    mov ah, 02h
    int 10h
    mov ah, 09h
    mov al, '#'
    mov bl, 0Eh
    mov cx, 80
    int 10h

    ; Desenam marginea din stanga.
    mov dh, 1
    mov dl, 0  
draw_left:
    cmp dh, 24
    jge cont1
    mov ah, 02h
    int 10h
    mov ah, 09h
    mov al, '#'
    mov bl, 0Eh
    mov cx, 1
    int 10h
    inc dh
    jmp draw_left
    
    cont1:            
    ; Desenam marginea din dreapta.
    mov dh, 1        ; randul      
    mov dl, 79       ; coloana   
draw_right:
    cmp dh, 24
    jge cont2
    mov ah, 02h
    int 10h
    mov ah, 09h
    mov al, '#'     
    mov bl, 0Eh      
    mov cx, 1        
    int 10h
    inc dh 
    jmp draw_right
    
    cont2:    
    ret
border endp

move_snake proc

      mov   di, s_size * 2 - 2    ;di indica coada, prima care va fi mutata
      mov   cx, s_size-1    ; facem un contor pentru cate segmente are sarpele
                            ; excludem capul 
      ;capul este mutat in functie de directie, ultimul
      
      move_array:
      mov   ax, [snake + di - 2]
      mov   [snake + di], ax
      sub   di, 2   ; fiecare segm din sarpe are nev de 2 bytes, x and y, col and row coords
      loop  move_array 
      
    
    cmp [cur_dir], left
      je move_left
    cmp [cur_dir], right
      je move_right
    cmp [cur_dir], up
      je move_up
    cmp [cur_dir], down
      je move_down
    
    jmp stop_move       ; daca a fost afisata alta tasta, jocul are freeze si apare cursorul 
                        ; pana cand se apasa o tasta de directie sau esc
    
    move_left:
      mov   ax, [snake]
      dec   al ;scadem coloana
      mov   [snake], ax 
      call check_next_character ; procedura de verificare coliziune/mancare
      jmp   stop_move
    
    move_right:
      mov   ax, [snake]
      inc   al  ;crestem coloana
      mov   [snake], ax 
      call check_next_character
      jmp   stop_move
    
    move_up:
      mov   ax, [snake]
      dec   ah  ;scadem randul
      mov   [snake], ax 
      call check_next_character
      jmp   stop_move
    
    move_down:
      mov   ax, [snake]
      inc   ah   ;crestem randul
      mov   [snake], ax 
      call check_next_character
      jmp   stop_move
    
    stop_move:
      ret
move_snake endp

;-----------------------------------------
 
check_next_character proc 
    mov ax, [snake]      ; scoatem coordonatele capului sarpelui
    mov dh, ah           ; punem randul in dh
    mov dl, al           ; tinem coloana in dl
    mov bh, 0            ; pagina 0
    mov ah, 02h          ; setam cursorul cu int
    int 10h

    mov ah, 08h          ; citim caracterul de la pozitia capului
    int 10h              ; folosim int si el este stocat in al

    cmp al, ' '          ; verificam daca este spatiu
    je move_ok           ; continuam, iesim din proc

    cmp al, '#'          ; verificam daca este zid
    je collision         ; daca da, fail

    cmp al, '*'          ; verificam daca este corpul sarpelui
    je collision         ; daca da, fail
    
    cmp al, '@'          ; verificam daca este mancare
    jne move_ok                 
    inc word ptr [score] ; incrementam scorul 
    

move_ok:
    ret

collision:
    call fail
    ret
check_next_character endp



; ------ data section ------
; ------ data section ------
; ------ data section ------

    s_size  equ     7    ;lungimea corpului sarpelui (7 segmente)
    snake dw s_size dup(0) ;rezerva memorie pentru 7 elemente word 
                           ;(14 bytes, cate 2 pentru fiecare element, pt coord de rand si coloana)
    tail dw ? 
    score dw 0
    ; (bios key codes):
    left    equ     4bh
    right   equ     4dh
    up      equ     48h
    down    equ     50h
    cur_dir db      right ;by default prima directie de mers va fi dreapta
    wait_time dw    0 
    
    msg1 db "                                                                  ", 0dh, 0ah
      db "             @         #     @             @         #                ", 0dh, 0ah
      db "                   @                   @                   @       ", 0dh, 0ah
      db "      @     @                 @                                    ", 0dh, 0ah
      db "   @                                         @       @              ", 0dh, 0ah
      db "                @          @                                       ", 0dh, 0ah
      db "                                      @                         ", 0dh, 0ah
      db "         @                        @           @                  ", 0dh, 0ah
      db "      @                  #                                  @      ", 0dh, 0ah
      db "                                                              ", 0dh, 0ah
      db "       #        @                           @      #     @         ", 0dh, 0ah
      db "                         @                                     ", 0dh, 0ah
      db "   @                              @                             ", 0dh, 0ah
      db "             #                                          @       ", 0dh, 0ah
      db "                                           @                   ", 0dh, 0ah
      db "         @             @          @                            ", 0dh, 0ah
      db "    @                        @                        @         ", 0dh, 0ah
      db "                @                       #         @              ", 0dh, 0ah
      db "                                                              ", 0dh, 0ah
      db "         @             @         @                     @        @   ", 0dh, 0ah
      db "   @             @                       @                   @   ", 0dh, 0ah
      db "            #                                #                 ", 0dh, 0ah
      db "       @                                  @          @         @  ", 0dh, 0ah
      db "   @             @       @          @                              ", 0dh, 0ah
      db "                                                                   $"

         
     msgover db "Game Over! Your score is: $" 
     
     msg0 db "                                                         ", 0dh,0ah    
        db "  ================== @GAME CONTROLS ====================   ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  Use the arrow keys to control the snake's direction.     ", 0dh,0ah
        db "  @UP    - Move the snake upwards                          ", 0dh,0ah
        db "  @DOWN  - Move the snake downwards                        ", 0dh,0ah
        db "  @LEFT  - Move the snake to the left                      ", 0dh,0ah
        db "  @RIGHT - Move the snake to the right                     ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  @Press ESC at any time to exit the game.                 ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  ================== @HOW TO WIN ======================    ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  Your goal is to collect as much food as possible.        ", 0dh,0ah
        db "  Each food item is represented by '@'.                    ", 0dh,0ah
        db "  Each '@' is 1 point for the final score.                 ", 0dh,0ah
        db "  DO NOT crash into the obstacles marked with '#'          ", 0dh,0ah
        db "  Be careful not to crash into the walls or yourself!      ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  =================== @START NOW =====================     ", 0dh,0ah
        db "                                                           ", 0dh,0ah
        db "  Press @ANY KEY to begin your Snake adventure...          ", 0dh,0ah
        db "  After the border are drawed, press any key to start      ", 0dh,0ah
        db "  =====================================================    $"

     
     DEFINE_PRINT_NUM 
     DEFINE_PRINT_NUM_UNS   
     DEFINE_CLEAR_SCREEN
     
     end  
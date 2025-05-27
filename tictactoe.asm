name "Tic Tac Toe AI"
org 100h

.DATA
    BOARD DB '1','2','3','4','5','6','7','8','9'
    CURRENT_PLAYER DB ?
    GAME_MODE DB ?     ; 0 = PvP, 1 = PvE
    X_SCORE DB 0
    O_SCORE DB 0
    DUPLICATE_MSG DB 'Invalid move! Position already taken.$'
    WELCOME_MSG DB 'Welcome to Tic Tac Toe!$'
    INPUT_MSG DB 'Enter Position (1-9), Current Player: $'
    INVALID_INPUT_MSG DB 'Invalid input! Please enter a number from 1 to 9!$'
    DRAW_MSG DB 'Game ended in DRAW!$'
    WIN_MSG DB 'Player $'
    WIN_MSG2 DB ' wins!$'
    RESET_MSG DB 'Play again? (1=Yes, 0=No): $'
    SCORE_MSG DB 'Score - X: $'
    SCORE_O_MSG DB ' O: $'
    MODE_MSG DB 'Select mode (0=PvP, 1=PvE): $'
    RETRY_MODE_MSG DB 'Please Enter 1 or 0!$'

.CODE
main:
    call CLEAR_SCREEN
    call SHOW_WELCOME
    call NEW_LINE
    
    ; Select game mode
    call SELECT_MODE

    ; Initialize game
    mov cx, 9          ; 9 moves total
    call RESET_BOARD

game_loop:
    call CLEAR_SCREEN
    call SHOW_WELCOME
    call DISPLAY_BOARD
    call SHOW_SCORE

    ; Determine current player
    mov bx, cx
    and bx, 1          ; odd=1 (X), even=0 (O)
    jnz PLAYER_X_TURN
    mov CURRENT_PLAYER, 'o'
    jmp CHECK_GAME_MODE
PLAYER_X_TURN:
    mov CURRENT_PLAYER, 'x'

CHECK_GAME_MODE:
    cmp GAME_MODE, 1   ; PvE mode?
    jne HUMAN_TURN
    cmp CURRENT_PLAYER, 'o' ; AI is O
    jne HUMAN_TURN
    call AI_MOVE
    jmp AFTER_MOVE

HUMAN_TURN:
    call NEW_LINE
    call SHOW_INPUT_PROMPT
GET_INPUT:
    call GET_PLAYER_INPUT
    push cx
    mov cx, 9
    mov bx, 0
FIND_POSITION:
    cmp BOARD[bx], al
    je VALID_MOVE
    inc bx
    loop FIND_POSITION
    pop cx
    call NEW_LINE
    lea dx, DUPLICATE_MSG
    mov ah, 9
    int 21h
    call NEW_LINE
    jmp GET_INPUT

VALID_MOVE:
    pop cx
    mov dl, CURRENT_PLAYER
    mov BOARD[bx], dl

AFTER_MOVE:
    call CHECK_WINNER
    loop game_loop

    call SHOW_DRAW
    call RESET_GAME
    jmp main

exit_program:
    mov ah, 4Ch
    int 21h

; ================= SUBROUTINES =================

SHOW_WELCOME:
    lea dx, WELCOME_MSG
    mov ah, 9
    int 21h
    ret 
           
SELECT_MODE:
    lea dx, MODE_MSG
    mov ah, 9
    int 21h

    mov ah, 1
    int 21h

    cmp al, '0'
    je SET_MODE
    cmp al, '1'
    je SET_MODE

    ; Neu khong phai 1 0 thi nhap lai
    call NEW_LINE
    lea dx, RETRY_MODE_MSG
    mov ah, 9
    int 21h
    call NEW_LINE
    jmp SELECT_MODE  
    ret
    
SET_MODE:
    sub al, '0'
    mov GAME_MODE, al
    ret

SHOW_INPUT_PROMPT:
    lea dx, INPUT_MSG
    mov ah, 9
    int 21h
    mov dl, CURRENT_PLAYER
    mov ah, 2
    int 21h
    call PRINT_SPACE
    ret

GET_PLAYER_INPUT:
    mov ah, 1
    int 21h
    cmp al, '1'
    jb INVALID_INPUT ; below '1'
    cmp al, '9'
    ja INVALID_INPUT ; above '9'
    ret
                      
INVALID_INPUT:
    call NEW_LINE
    lea dx, INVALID_INPUT_MSG
    mov ah, 9
    int 21h
    call NEW_LINE
    jmp GET_PLAYER_INPUT                      
                      
DISPLAY_BOARD:
    push cx
    mov bx, 0
    mov cx, 3
PRINT_ROWS:
    call NEW_LINE
    push cx
    mov cx, 3
PRINT_COLS:
    mov dl, BOARD[bx]
    mov ah, 2
    int 21h
    call PRINT_SPACE
    inc bx
    loop PRINT_COLS
    pop cx
    loop PRINT_ROWS
    pop cx
    call NEW_LINE
    ret

NEW_LINE:
    mov dl, 0Ah
    mov ah, 2
    int 21h
    mov dl, 0Dh
    int 21h
    ret

PRINT_SPACE:
    mov dl, ' '
    mov ah, 2
    int 21h
    ret

CHECK_WINNER:
    ; Check rows
    mov bl, BOARD[0]
    cmp bl, BOARD[1]
    jne row2
    cmp bl, BOARD[2]
    je SHOW_WINNER
    
row2:
    mov bl, BOARD[3]
    cmp bl, BOARD[4]
    jne row3
    cmp bl, BOARD[5]
    je SHOW_WINNER
    
row3:
    mov bl, BOARD[6]
    cmp bl, BOARD[7]
    jne col1
    cmp bl, BOARD[8]
    je SHOW_WINNER
    
col1:
    ; Check columns
    mov bl, BOARD[0]
    cmp bl, BOARD[3]
    jne col2
    cmp bl, BOARD[6]
    je SHOW_WINNER
    
col2:
    mov bl, BOARD[1]
    cmp bl, BOARD[4]
    jne col3
    cmp bl, BOARD[7]
    je SHOW_WINNER
    
col3:
    mov bl, BOARD[2]
    cmp bl, BOARD[5]
    jne diag1
    cmp bl, BOARD[8]
    je SHOW_WINNER
    
diag1:
    ; Check diagonals
    mov bl, BOARD[0]
    cmp bl, BOARD[4]
    jne diag2
    cmp bl, BOARD[8]
    je SHOW_WINNER
    
diag2:
    mov bl, BOARD[2]
    cmp bl, BOARD[4]
    jne no_winner
    cmp bl, BOARD[6]
    jne no_winner
    
SHOW_WINNER:
    call NEW_LINE
    call DISPLAY_BOARD
    lea dx, WIN_MSG
    mov ah, 9
    int 21h
    mov dl, CURRENT_PLAYER
    mov ah, 2
    int 21h
    lea dx, WIN_MSG2
    mov ah, 9
    int 21h
    call UPDATE_SCORE
    call SHOW_SCORE
    call RESET_GAME
    jmp main
    
no_winner:
    ret

SHOW_DRAW:
    call NEW_LINE
    lea dx, DRAW_MSG
    mov ah, 9
    int 21h
    call SHOW_SCORE
    ret

UPDATE_SCORE:
    cmp CURRENT_PLAYER, 'x'
    jne o_wins
    inc X_SCORE
    ret
o_wins:
    inc O_SCORE
    ret

SHOW_SCORE:
    call NEW_LINE
    lea dx, SCORE_MSG
    mov ah, 9
    int 21h
    mov dl, X_SCORE
    add dl, '0'
    mov ah, 2
    int 21h
    lea dx, SCORE_O_MSG
    mov ah, 9
    int 21h
    mov dl, O_SCORE
    add dl, '0'
    mov ah, 2
    int 21h
    call NEW_LINE
    ret

RESET_GAME:
    call NEW_LINE
    lea dx, RESET_MSG
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    cmp al, '1'
    je RESET_BOARD
    jmp exit_program

RESET_BOARD:
    mov BOARD[0], '1'
    mov BOARD[1], '2'
    mov BOARD[2], '3'
    mov BOARD[3], '4'
    mov BOARD[4], '5'
    mov BOARD[5], '6'
    mov BOARD[6], '7'
    mov BOARD[7], '8'
    mov BOARD[8], '9'
    mov cx, 9
    ret

CLEAR_SCREEN:
    mov ax, 3
    int 10h
    ret

; =========== SMART AI ===========
AI_MOVE:
    push ax
    push dx
    
    ; 1. First check if AI can win immediately
    mov al, CURRENT_PLAYER
    call FIND_WINNING_MOVE
    cmp bx, 9
    jb AI_MOVE_FOUND
    
    ; 2. Check if player can win and block
    mov al, CURRENT_PLAYER
    xor al, 'x' ^ 'o' ; switch to opponent
    call FIND_WINNING_MOVE
    cmp bx, 9
    jb AI_MOVE_FOUND
    
    ; 3. Take center if available
    cmp BOARD[4], '5'
    jne CHECK_CORNERS
    mov bx, 4
    jmp AI_MOVE_FOUND
    
CHECK_CORNERS:
    ; 4. Take any empty corner
    mov bx, 0
    cmp BOARD[bx], '1'
    je AI_MOVE_FOUND
    mov bx, 2
    cmp BOARD[bx], '3'
    je AI_MOVE_FOUND
    mov bx, 6
    cmp BOARD[bx], '7'
    je AI_MOVE_FOUND
    mov bx, 8
    cmp BOARD[bx], '9'
    je AI_MOVE_FOUND
    
    ; 5. Take any empty side
    mov bx, 1
    cmp BOARD[bx], '2'
    je AI_MOVE_FOUND
    mov bx, 3
    cmp BOARD[bx], '4'
    je AI_MOVE_FOUND
    mov bx, 5
    cmp BOARD[bx], '6'
    je AI_MOVE_FOUND
    mov bx, 7
    cmp BOARD[bx], '8'
    je AI_MOVE_FOUND
    
    ; 6. Fallback (shouldn't reach here)
    mov bx, 0
    
AI_MOVE_FOUND:
    mov dl, CURRENT_PLAYER
    mov BOARD[bx], dl
    pop dx
    pop ax
    ret

FIND_WINNING_MOVE:
    ; al = player to check
    mov bx, 0
CHECK_CELL:
    cmp bx, 9
    jae NO_WINNING_MOVE
    
    ; Skip if cell not empty
    mov dl, BOARD[bx]
    cmp dl, 'x'
    je NEXT_CELL
    cmp dl, 'o'
    je NEXT_CELL
    
    ; Save original value
    mov dh, BOARD[bx]
    
    ; Try the move
    mov BOARD[bx], al
    
    ; Check if this move wins
    push ax
    push bx
    call CHECK_WIN
    cmp al, 1

    pop bx
    pop ax
    
    ; Undo the move
    mov BOARD[bx], dh
    
    jz FOUND_WINNING_MOVE
    
NEXT_CELL:
    inc bx
    jmp CHECK_CELL
    
FOUND_WINNING_MOVE:
    ret
    
NO_WINNING_MOVE:
    mov bx, 9  ; return invalid position
    ret

CHECK_WIN:
    ; Check rows
    mov bl, BOARD[0]
    cmp bl, BOARD[1]
    jne c_row2
    cmp bl, BOARD[2]
    jne c_row2
    mov al, 1
    ret
    
c_row2:
    mov bl, BOARD[3]
    cmp bl, BOARD[4]
    jne c_row3
    cmp bl, BOARD[5]
    jne c_row3
    mov al, 1
    ret
    
c_row3:
    mov bl, BOARD[6]
    cmp bl, BOARD[7]
    jne c_col1
    cmp bl, BOARD[8]
    jne c_col1
    mov al, 1
    ret
    
c_col1:
    mov bl, BOARD[0]
    cmp bl, BOARD[3]
    jne c_col2
    cmp bl, BOARD[6]
    jne c_col2
    mov al, 1
    ret
    
c_col2:
    mov bl, BOARD[1]
    cmp bl, BOARD[4]
    jne c_col3
    cmp bl, BOARD[7]
    jne c_col3
    mov al, 1
    ret
    
c_col3:
    mov bl, BOARD[2]
    cmp bl, BOARD[5]
    jne c_diag1
    cmp bl, BOARD[8]
    jne c_diag1
    mov al, 1
    ret
    
c_diag1:
    mov bl, BOARD[0]
    cmp bl, BOARD[4]
    jne c_diag2
    cmp bl, BOARD[8]
    jne c_diag2
    mov al, 1
    ret
    
c_diag2:
    mov bl, BOARD[2]
    cmp bl, BOARD[4]
    jne c_no_win
    cmp bl, BOARD[6]
    jne c_no_win
    mov al, 1
    ret
    
c_no_win:
    mov al, 0
    ret


END main


.model small
.stack 100h
.data
    press_to_start_msg db "Press space to start$"
    game_over_msg db "Game over!", 0Ah,  0Ah,  5 DUP(' '), "Press escape to quit or", 0Ah, 10 DUP(' '), "space to retry.$"

    blue equ 0BFh
    white equ 0F1h
    green equ 0AFh
    brown equ 0CFh
    yellow equ 0EFh

    space_code equ 32
    esc_code equ 27

    score db 0, '$'

    score_box db ' ', 60h, ' ', 60h

    score_box_size equ 4
    score_box_pos_x equ 0
    score_box_pos_y equ 0
    score_box_start_pos  dw  0

    player_size equ 2
    player_pos_x db 20
    player_pos_y db 14

    screen_width equ 40
    screen_height equ 25


    block_color equ 0EFh

    counter db 10
    block_height             equ     2
    block_spacing equ 15
    block_space             equ     5
    block_position          db      0
    space_start             db      0

.code

paint macro
    push cx
    mov ah, 02h
    int 10h
    mov al, ' '
    mov cx, 1
    mov ah, 09h
    int 10h
    pop cx
endm

set_cursor_position macro x, y
    push ax
    push bx
    push dx
    mov ah, 02h
    mov dh, x
    mov dl, y
    xor bh, bh
    int 10h
    pop  dx
    pop  bx
    pop  ax
endm

print proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
print endp

set_color macro color
    mov bl, color
endm

welcome_screen proc
    call draw_background
    lea dx, press_to_start_msg
    set_cursor_position 8,10
    call print
    ret
welcome_screen endp

draw_background proc
    mov dl, 0
    mov dh, 0
    set_color blue
    jmp next_pixel
    next_row:
        inc dh
        cmp dh, 15
        jne skip_color
        set_color brown
    skip_color:
        cmp dh, 25
        je finish
        mov dl, 0
    next_pixel:
        paint
        inc dl
        cmp dl, screen_width
        je next_row
        jmp next_pixel
    finish:
        ret
draw_background endp

draw_model proc
    push ax
    push bx
    push cx

    mov ah, 02h
    int 10h

    mov bl, green
    mov al, ' '

    mov cx, 1
    mov ah, 09h
    int 10h

    pop cx
    pop bx
    pop ax
    ret
draw_model endp

draw_score_box proc
    push ax
    push bx
    push cx
    push dx
    push es

    push 0B800h
    pop es
    mov cx, score_box_size

    mov di, word ptr score_box_start_pos
    mov si, offset score_box
    cld
    rep movsb
    mov dh, score_box_pos_y
    mov dl, score_box_pos_x

    xor ax, ax
    mov al, score

    cmp al, 9
    jg multiDigit_number

    inc dl

multiDigit_number:
    set_cursor_position dh, dl
    call print_number

    pop es
    pop dx
    pop cx
    pop bx
    pop ax

    ret
draw_score_box endp

print_number proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    di

        mov     cx, 10          ; cx - base number
        xor     di, di          ; di - digits in number

        cmp     ah, 0
@convert:
        xor     dx, dx
        div     cx
        add     dl, '0'
        inc     di
        push    dx
        or      ax, ax
        jnz     @convert

@display:
        ;output
        pop     dx              ; dl = symbol
        mov     ah, 02h
        int     21h
        dec     di              ; repeat while di<>0
        jnz     @display

        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        ret

print_number endp

delay proc
    push ax
    push cx
    push dx

    mov cx, 0001h
    mov dx, 0000h
    mov ah, 86h
    int 15h

    pop dx
    pop cx
    pop ax

    ret
delay endp

clear_keyboard_buffer proc near
	push ax
	mov ah, 08h
	int 21h
	pop ax
	ret
clear_keyboard_buffer endp

erase_bird proc
    push ax
    push bx
    push cx

    mov ah, 02h
    int 10h

    mov bl, blue
    mov al, ' '

    mov cx, 1
    mov ah, 09h
    int 10h

    pop cx
    pop bx
    pop ax
    ret
erase_bird endp

erase_score_box proc
    push ax
    push bx
    push cx

    set_cursor_position 1, 0

    mov bl, blue
    mov al, ' '

    mov cx, 2
    mov ah, 09h
    int 10h

    pop cx
    pop bx
    pop ax
    ret
erase_score_box endp

draw_gamefield proc
    mov ah, 7               ; scroll down
    mov al, 1               ; number of lines to scroll
    mov bh, 0               ; attribute
    mov ch, 0               ; row top
    mov cl, 0               ; col left
    mov dh, 25              ; row bottom
    mov dl, 40              ; col right
    int 10h

    xor dx,dx
    mov bl, blue

    @next_pixel:
        paint
        inc dl
        cmp dl, screen_width
        je @finish
        jmp @next_pixel
    @finish:
        call erase_score_box
        call draw_score_box
        ret
draw_gamefield endp

check_color proc
    push ax
    set_cursor_position player_pos_y, player_pos_x
    mov ah, 08h     ;output: ah - symbol attribute
    int 10h
    cmp ah, block_color
    jne end_check_color
    call game_over
end_check_color:
    pop ax
    ret
check_color endp


random proc
    ; this proc gets the current time
    ; and retains only the last 4 bits
    ; output: ax - pseudo random value
    push cx
    push dx

    mov ah, 2Ch     ;access time
    int 21h
    mov ax, dx
    and al, 0Fh     ;clear high-order bits to zero

	pop dx
	pop cx
	ret

random endp

draw_block proc
    push ax
    push bx
    push cx
    push dx

    xor dx,dx
    mov bl, yellow
    get_new_space_pos:
        call random
        mov space_start, al
        add space_start, 10 ; shift space start to the center
        cmp space_start, 25
        jge get_new_space_pos
        jmp draw_next_pixel
    add_space:
        add dl, block_space
    draw_next_pixel:
        paint
        inc dl
        cmp dl, space_start
        je add_space
        cmp dl, screen_width
        jge finish_drawing_block
        jmp draw_next_pixel
   finish_drawing_block:
        call erase_score_box
        call draw_score_box
        pop dx
        pop cx
        pop bx
        pop ax
        ret
draw_block endp

new_block proc
    mov counter, 0
    inc score
    call draw_score_box
    mov block_position, screen_width
    mov space_start, 0
    call draw_block
    ret
new_block endp

game_start proc
   call draw_background
   mov score, 0

   mov dh, player_pos_y
   mov dl, player_pos_x
   call draw_model

     check_buffer:
            call draw_score_box
            call erase_score_box
            mov ah, 00h
            mov al, 00h
            int 16h
            cmp al, space_code
            je fly_right
            jmp check_buffer
     fly_right:
            call erase_score_box
            call delay
            call erase_bird
            call draw_gamefield

            cmp counter, block_spacing
            jne skip1
            call new_block
      skip1:
            inc counter

            cmp player_pos_x, 2 ; scorebox space
            je game_over
            cmp player_pos_x, screen_width - 1
            je game_over

            call check_color

            ; move right
            inc player_pos_x

            mov dh, player_pos_y
            mov dl, player_pos_x
            call draw_model

            ; redraw bird and game field
            mov ah, 01h     ; check buffer
            int 16h
            jz fly_right         ; buffer is empty

            cmp al, space_code
            call clear_keyboard_buffer
            jne fly_right
            jmp fly_left
       fly_left:
            call erase_score_box
            call delay
            call erase_bird
            call draw_gamefield

            cmp counter, block_spacing
            jne skip2
            call new_block
         skip2:
            inc counter ; block offset counter

            cmp player_pos_x, 0
            je game_over
            cmp player_pos_x, screen_width - 1
            je game_over

            call check_color ; check current player position

            ; move left
            dec player_pos_x

            mov dh, player_pos_y
            mov dl, player_pos_x
            call draw_model

            mov ah, 01h     ; check buffer
            int 16h
            jz fly_left         ; buffer is empty
            cmp al, space_code
            call clear_keyboard_buffer
            jne fly_left
            jmp fly_right
     game_over:
        call end_game
        ret
game_start endp

end_game proc
    call draw_background
    lea dx, game_over_msg
    set_cursor_position 8,10
    call print
    call wait_for_input
end_game endp

wait_for_input proc
    xor ax, ax
    xor bx,bx
    xor cx,cx
    xor dx,dx

    mov player_pos_x, 20
    mov player_pos_y, 14

    wait_input:
        mov ah, 00h
        int 16h
        cmp al, space_code
        je @game_start
        cmp al, esc_code
        je @end_game
     jmp wait_input
     @game_start:
        call game_start
     @end_game:
        mov ax,0003h
        int 10h
        mov ax, 4C00h
         int 21h
        ret
wait_for_input endp


start proc near
   mov ax, @data
   mov ds, ax
   mov es, ax
   mov ax, 01h
   int 10h

   mov ax, 1003h
   xor bx, bx
   int 10h

   mov ah, 01h
   mov ch, 2bh
   mov cl, 0bh
   int 10h

   call welcome_screen
   call wait_for_input

   mov ax, 4C00h
   int 21h
start endp
end start

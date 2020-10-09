.model small
.stack 100h
.data

power_up        equ 3904h
wall            equ 4EB1h
coin            equ 0BEF8h
enemy           equ 3C02h
frozen_enemy    equ 3102h
empty           equ 3020h
player          equ 3005h
finish          equ 3AB0h
spike           equ 3CD8h
bg              equ 30h
jump_height     equ 3
float_frames    equ 3
zero            equ 0730h
to_red          equ 7000h
cx_delay        equ 1
dx_delay        equ 4585h
gmem_offset     equ 0A0h
score_offset    equ 14
a_offset        equ 90h
w_offset        equ 94h
s_offset        equ 98h
d_offset        equ 9Ch
freeze_offset   equ 16h
max_enemies     equ 16
max_y           equ 23
dir_duration    equ 3
freez_duration  equ 50



file_name       db "c:\map.txt", 0h
score_line      db 'S', 07h, 'c', 07h, 'o', 07h, 'r', 07h, 'e', 07h, ':', 07h, ' ', 07h
m_width         db ?
player_x        dw ?
player_y        dw ?
max_x           dw ?
player_exists   db ?
can_freeze      db ?
a_state         dw ?
w_state         dw ?
d_state         dw ?
q_state         dw ?
s_state         dw ?
r_state         dw ?
f_state         dw ?
dir             dw ?
real_dir        dw ?
dir_count       dw ?
max_offs        dw ?
screen_offs     dw ?
buf             dw ?
before_player   dw ?
score           db ?
block_action    db ?
fall_frame      db ?
last_chance     db ?
time_mask       dw 1
score_str       dw 3 dup (?)
read_buf        db 257 dup (?)
screen          dw 6120 dup (?)
enemies_x       dw max_enemies dup (?)
enemies_y       dw max_enemies dup (?)
enemies_dir     dw max_enemies dup (?)
enemies_state   dw max_enemies dup (?)
enemies_before  dw max_enemies dup (?)
enemies_count   dw ?


.code
    jmp start

delay macro
        push dx
        push cx
        mov cx, cx_delay
        mov dx, dx_delay
        mov ah, 86h
        int 15h
        pop cx
        pop dx
endm

get_data proc; cx - error code
    push ax
    push bx
    push dx
    push di
    push si

    mov player_exists, 0
    mov can_freeze, 0
    mov a_state, 0
    mov w_state, 0
    mov d_state, 0
    mov q_state, 0
    mov r_state, 0
    mov f_state, 0
    mov last_chance, 0
    mov dir, 1
    mov real_dir, 1
    mov dir_count, 0
    mov screen_offs, 0
    mov before_player, empty
    mov score, 0
    mov block_action, 0
    mov fall_frame, 0
    mov enemies_count, 0

    push es
    mov ax, 0B800h
    mov es, ax
    mov di, 0
    mov si, offset score_line
    mov cx, 7
    rep movsw
    pop es

    mov ah, 3Dh
    mov al, 0
    mov dx, offset file_name
    int 21h
    pushf
    pop bx
    and bx, 0001h
    jz get_data_no_fail
    jmp get_data_fail

    get_data_no_fail:
    push ax
    mov bx, ax
    mov ah, 3Fh
    mov dx, offset read_buf
    mov cx, 3
    int 21h
    pop ax

    mov bl, read_buf
    mov m_width, bl
    xor bh, bh
    dec bx
    mov max_x, bx

    mov cx, 24
    mov di, offset screen
    get_data_succes:
        mov buf, cx
        push cx
        push ax
        mov bx, ax
        mov ah, 3Fh
        mov dx, offset read_buf
        xor ch, ch
        mov cl, m_width
        add cx, 2
        int 21h
        cmp ax, cx
        je get_data_succes_cont
        jmp get_data_read_fail
        get_data_succes_cont:
        mov si, offset read_buf
        xor ch, ch
        mov cl, m_width

        push di
        get_data_parce:
            lodsb
            cmp al, ' '
            je get_data_free
            cmp al, '0'
            je get_data_free
            cmp al, '1'
            je get_data_wall
            cmp al, 'P'
            je get_data_player
            cmp al, 'C'
            je get_data_coin
            cmp al, 'S'
            je get_data_spike
            cmp al, 'A'
            je get_data_power_up
            cmp al, 'F'
            je get_data_finish
            cmp al, 'E'
            je get_data_enemy
            jmp get_data_other
            get_data_in_parce:
        loop get_data_parce
        pop di
        add di, 0FFh
        add di, 0FFh
        pop ax
        pop cx
    loop get_data_succes
    jmp get_data_fine

    get_data_free:
        mov ax, empty
        stosw
        jmp get_data_in_parce

    get_data_wall:
        mov ax, wall
        stosw
        jmp get_data_in_parce

    get_data_spike:
        mov ax, spike
        stosw
        jmp get_data_in_parce

    get_data_coin:
        mov ax, coin
        stosw
        jmp get_data_in_parce

    get_data_power_up:
        push cx
        push dx

        push ax
        mov ah, 0
        int 1Ah
        pop ax
        and dx, time_mask
        rol time_mask, 1
        jz get_data_power_up_yes
        mov ax, empty
        jmp get_data_power_up_continue
        get_data_power_up_yes:
        mov ax, power_up

        get_data_power_up_continue:

        pop dx
        pop cx

        stosw
        jmp get_data_in_parce

    get_data_player:
        cmp player_exists, 1
        je get_data_extra_player
        mov ax, player
        stosw
        mov player_exists, 1
        mov player_x, 255
        sub player_x, cx
        mov player_y, 24
        push bx
        mov bx, buf
        sub player_y, bx
        pop bx
        jmp get_data_in_parce

    get_data_finish:
        mov ax, finish
        stosw
        jmp get_data_in_parce

    get_data_enemy:
        cmp enemies_count, max_enemies
        jae get_data_enemies_cap_reached

        push di
        mov di, enemies_count
        add di, di
        inc enemies_count
        mov enemies_dir[di], 0
        mov enemies_state[di], 1
        mov enemies_before[di], empty
        mov ax, 255
        sub ax, cx
        mov enemies_x[di], ax
        mov ax, 24
        push bx
        mov bx, buf
        sub ax, bx
        mov enemies_y[di], ax
        pop bx
        pop di
        mov ax, enemy
        stosw
        jmp get_data_in_parce

        get_data_enemies_cap_reached:
        mov ax, empty
        stosw
        jmp get_data_in_parce



    get_data_other:
        mov ah, bg
        stosw
        jmp get_data_in_parce

    get_data_extra_player:
    pop ax
    get_data_read_fail:
    pop ax
    pop ax
    pop ax
    mov cx, 1
    jmp get_data_end

    get_data_fail:
    mov cx, 1
    jmp get_data_end

    get_data_fine:
    mov cx, 0
    mov bx, ax
    mov ah, 3Eh; close file
    int 21h

    get_data_end:
    pop si
    pop di
    pop dx
    pop bx
    pop ax
    ret
endp

to_gmem proc; dx - origin
    push ax
    push es
    push si
    push di
    push cx
    push dx

    mov ax, 0B800h
    mov es, ax
    mov di, 14
    mov si, offset score_str
    call score_to_str
    mov cx, 3
    rep movsw
    mov dx, screen_offs
    mov si, offset screen
    add si, dx
    mov di, gmem_offset
    mov cx, 24
    to_gmem_loop:
        push cx
        mov cx, 80
        push si
        rep movsw
        pop si
        add si, 0FFh
        add si, 0FFh
        pop cx
    loop to_gmem_loop

    pop dx
    pop cx
    pop di
    pop si
    pop es
    pop ax
    ret
endp

input_check proc
    push ax
    push es
    push di

    mov a_state, 0
    mov w_state, 0
    mov d_state, 0
    mov s_state, 0
    mov f_state, 0

    input_check_loop:
        mov ah, 1
        int 16h
        jz input_check_disp

        mov ah, 0
        int 16h
        cmp al, 'w'
        je input_check_w
        cmp al, 'a'
        je input_check_a
        cmp al, 'd'
        je input_check_d
        cmp al, 'q'
        je input_check_q
        cmp al, 'W'
        je input_check_w
        cmp al, 'A'
        je input_check_a
        cmp al, 'D'
        je input_check_d
        cmp al, 'Q'
        je input_check_q
        cmp al, 'r'
        je input_check_r
        cmp al, 'R'
        je input_check_r
        cmp al, 's'
        je input_check_s
        cmp al, 'S'
        je input_check_s
        cmp al, 'f'
        je input_check_f
        cmp al, 'F'
        je input_check_f
        jmp input_check_loop

    input_check_r:
        mov r_state, 1
        jmp input_check_loop
    input_check_w:
        mov w_state, 1
        jmp input_check_loop
    input_check_a:
        mov a_state, 1
        jmp input_check_loop
    input_check_d:
        mov d_state, 1
        jmp input_check_loop
    input_check_q:
        mov q_state, 1
        jmp input_check_loop
    input_check_s:
        mov s_state, 1
        jmp input_check_loop
    input_check_f:
        mov f_state, 1
        jmp input_check_loop


    input_check_disp:
        mov ax, 0B800h
        mov es, ax
    input_check_disp_a:
        mov di, a_offset
        cmp a_state, 1
        jne input_check_a_0
        input_check_a_1:
        mov ah, 00000100b
        mov al, 11h
        stosw
        jmp input_check_disp_w
        input_check_a_0:
        mov ah, 00000111b
        mov al, 11h
        stosw

    input_check_disp_w:
        mov di, w_offset
        cmp w_state, 1
        jne input_check_w_0
        input_check_w_1:
        mov ah, 00000100b
        mov al, 1Eh
        stosw
        jmp input_check_disp_s
        input_check_w_0:
        mov ah, 00000111b
        mov al, 1Eh
        stosw

    input_check_disp_s:
        mov di, s_offset
        cmp s_state, 1
        jne input_check_s_0
        input_check_s_1:
        mov ah, 00000100b
        mov al, 1Fh
        stosw
        jmp input_check_disp_d
        input_check_s_0:
        mov ah, 00000111b
        mov al, 1Fh
        stosw

    input_check_disp_d:
        mov di, d_offset
        cmp d_state, 1
        jne input_check_d_0
        input_check_d_1:
        mov ah, 00000100b
        mov al, 10h
        stosw
        jmp input_check_end
        input_check_d_0:
        mov ah, 00000111b
        mov al, 10h
        stosw

    input_check_end:

    pop di
    pop es
    pop ax
    ret
endp

game_loop proc

    xor ch, ch
    mov cl, m_width
    sub cx, 80
    add cx, cx
    mov max_offs, cx
    jmp game_loop_loop

    load_data:
    call get_data

    game_loop_loop:
        cmp block_action, 1
        je game_loop_skip_render
        call to_gmem
        call display_can_freez
        game_loop_skip_render:
        delay
        call input_check
        cmp q_state, 1
        je game_loop_end
        cmp r_state, 1
        je load_data
        cmp f_state, 1
        jne game_loop_continue

        cmp can_freeze, 1
        jne game_loop_continue
        mov can_freeze, 0
        call freeze_enemies



        game_loop_continue:
        cmp block_action, 1
    je game_loop_loop
        call determ_dir
        call update_player
        call enemies_update
    jmp game_loop_loop

    game_loop_end:
    ret
endp

determ_dir proc
    push ax

    game_loop_horizontal_control_start:
    mov ax, a_state
    add ax, d_state
    cmp ax, 2
    je game_loop_horizontal_control_last_check
    cmp ax, 0
    je game_loop_horizontal_control_last_check
    cmp a_state, 1
    jne game_loop_horizontal_control_right

    game_loop_horizontal_control_left:
    mov dir, 0
    mov real_dir, 0
    mov dir_count, 0
    jmp game_loop_horizontal_control_last_check

    game_loop_horizontal_control_right:
    mov dir, 2
    mov real_dir, 2
    mov dir_count, 0

    game_loop_horizontal_control_last_check:
    cmp s_state, 1
    jne game_loop_horizontal_control_end
    mov dir, 1
    mov real_dir, 1
    mov dir_count, 0
    game_loop_horizontal_control_end:
    pop ax
    ret
endp

update_player proc
    push ax
    push di
    push bx
    cmp player_exists, 1
    je update_player_exists
    pop bx
    pop di
    pop ax
    ret
    update_player_exists:
    mov ax, player_y
    mov bx, 0FFh
    mul bx
    mov bx, 2
    mul bx
    add ax, player_x
    add ax, player_x
    add ax, offset screen
    mov di, ax; di - current player offset

    call vertical
    call horizontal

    pop bx
    pop di
    pop ax
    ret
endp

horizontal proc
    cmp dir, 1
    jne update_player_fine
    jmp update_player_end

    update_player_fine:
    cmp dir, 0
    je update_player_left
    jmp update_player_right

    update_player_left:
    cmp player_x, 0
    jne update_player_continue
    jmp update_player_stopped
    mov real_dir, 0

    update_player_continue:
    mov bx, before_player
    mov [di], bx
    dec player_x
    sub di, 2
    mov bx, [di]
    cmp bx, wall
    je update_player_continue_continue
    cmp bx, frozen_enemy
    je update_player_continue_continue
    jmp update_player_collision
    update_player_continue_continue:
    add di, 2
    inc player_x
    mov bx, [di]
    call det_dir_change
    jmp update_player_after_checks

    update_player_right:
    mov bx, max_x
    cmp player_x, bx
    je update_player_stopped
    mov real_dir, 2
    mov bx, before_player
    mov [di], bx
    inc player_x
    add di, 2
    mov bx, [di]
    cmp bx, wall
    je update_player_right_continue
    cmp bx, frozen_enemy
    je update_player_right_continue
    jmp update_player_collision
    update_player_right_continue:
    sub di, 2
    dec player_x
    mov bx, [di]
    call det_dir_change
    jmp update_player_after_checks

    update_player_collision:
    call handle_collision
    update_player_after_checks:
    mov before_player, bx
    mov ax, player
    mov [di], ax
    jmp update_player_end

    update_player_stopped:
    mov dir, 1
    mov real_dir, 1
    mov dir_count, 0

    update_player_end:
    cmp player_x, 40
    jb update_player_last
    mov dx, player_x
    sub dx, 40
    add dx, dx
    cmp dx, max_offs
    jbe update_player_last
    mov dx, max_offs

    update_player_last:
    mov screen_offs, dx
    ret
endp

det_dir_change proc
    mov real_dir, 1
    cmp dir_count, dir_duration
    je det_dir_change_change
    jmp det_dir_change_stay
    det_dir_change_change:
    mov dir, 1
    mov dir_count, 0
    jmp det_dir_change_end
    det_dir_change_stay:
    inc dir_count
    jmp det_dir_change_end
    det_dir_change_end:
    ret
endp

vertical proc
    cmp player_y, max_y
    jb vertical_not_bottom
    jmp vertical_at_the_bottom
    vertical_not_bottom:
    add di, 1FEh; di - below
    mov bx, [di]
    cmp bx, wall
    je vertical_prep_jump
    cmp bx, frozen_enemy
    je vertical_prep_jump
    cmp last_chance, 1
    jne vertical_no_last_chance
    cmp w_state, 1
    je vertical_last_chance

    vertical_no_last_chance:
    mov last_chance, 0
    sub di, 1FEh; di - player
    cmp fall_frame, 0
    je vertical_cont
    jmp switch_fall_frame
    vertical_cont:
    mov bx, before_player
    mov [di], bx; overwrote player
    add di, 1FEh; di - below, now is player
    mov bx, [di]
    call handle_collision
    vertical_handled:
    mov before_player, bx
    mov ax, player
    mov [di], ax;
    inc player_y
    jmp vertical_end

    vertical_at_the_bottom:
    mov ax, before_player
    mov [di], ax
    call enemy_handle
    jmp vertical_handled

    vertical_prep_jump:
    mov last_chance, 1
    jmp vertical_prep_jump_continue
    vertical_last_chance:
    mov last_chance, 0
    vertical_prep_jump_continue:
    sub di, 1FEh; di - player
    mov fall_frame, 0
    cmp w_state, 1
    jne vertical_end
    mov last_chance, 0
    mov cx, jump_height
    checker:
        sub di, 1FEh; di - above
        mov bx, [di]
        cmp bx, wall
    je vertical_above_end
        cmp bx, frozen_enemy
    je vertical_above_end
        push bx
        push di
        add di, 1FEh
        mov bx, before_player
        mov [di], bx
        pop di
        pop bx
        call handle_collision
        checker_handled:
        push bx
        mov fall_frame, float_frames
        dec player_y
        add di, 1FEh; di - player
        mov bx, before_player
        mov [di], bx; overwrote player
        sub di, 1FEh; di - above, now player

        mov bx, player
        cmp block_action, 1
        je checker_do_not_draw
        mov [di], bx
        checker_do_not_draw:
        pop bx
        mov before_player, bx
    loop checker
        mov ax, player
        mov [di], ax
    jmp vertical_end

    checker_coin:
    call coin_handle
    jmp checker_handled

    checker_enemy:
    call enemy_handle
    jmp checker_handled

    checker_finish:
    call finish_handle
    jmp checker_handled

    switch_fall_frame:
    dec fall_frame
    jmp vertical_end

    vertical_above_end:
    add di, 1FEh
    jmp vertical_end

    vertical_end:
    ret
endp

enemy_handle proc
    mov block_action, 1
    call to_gmem
    call screen_to_red
    ret
endp

coin_handle proc
    mov bx, empty
    inc score
    ret
endp

finish_handle proc
    mov block_action, 1
    call to_gmem
    call screen_to_green
    ret
endp

handle_collision proc
    cmp bx, coin
    je handle_collision_coin
    cmp bx, enemy
    je handle_collision_enemy
    cmp bx, finish
    je handle_collision_finish
    cmp bx, spike
    je handle_collision_enemy
    cmp bx, power_up
    je handle_collision_powerup
    handle_collision_end:
    ret
    handle_collision_coin:
    call coin_handle
    jmp handle_collision_end
    handle_collision_enemy:
    call enemy_handle
    jmp handle_collision_end
    handle_collision_finish:
    call finish_handle
    jmp handle_collision_end
    handle_collision_powerup:
    mov can_freeze, 1
    mov bx, empty
    jmp handle_collision_end

endp

screen_to_red proc
    push ax
    push es
    push cx
    push di
    mov ax, 0B800h
    mov es, ax
    mov cx, 1920
    mov di, 0A0h
    screen_to_red_loop:
        mov ax, es:[di]
        and ax, 0FFFh
        or  ax, 4000h
        mov es:[di], ax
        add di, 2
    loop screen_to_red_loop
    pop di
    pop cx
    pop es
    pop ax
    ret
endp

screen_to_green proc
    push ax
    push es
    push cx
    push di
    mov ax, 0B800h
    mov es, ax
    mov cx, 1920
    mov di, 0A0h
    screen_to_green_loop:
        mov ax, es:[di]
        and ax, 0FFFh
        or  ax, 2000h
        mov es:[di], ax
        add di, 2
    loop screen_to_green_loop
    pop di
    pop cx
    pop es
    pop ax
    ret
endp

score_to_str proc
    push ax
    push di
    push es
    mov ax, @data
    mov es, ax
    mov ax, zero
    mov cx, 3
    mov di, offset score_str
    rep stosw
    mov di, offset score_str
    add di, 4
    xor ah, ah
    mov al, score
    mov cx, 10
    score_to_str_loop:
        cmp ax, 0
        je score_to_str_end;
        xor dx, dx
        div cx
        add dx, '0'
        mov [di], dl
        sub di, 2
        jmp score_to_str_loop

    score_to_str_end:
    pop es
    pop di
    pop ax
    ret
endp

enemies_update proc
    mov cx, enemies_count
    mov di, 0
    enemies_update_loop:
        call enemy_update
        add di, 2
    loop enemies_update_loop
    ret
endp

enemy_update proc; di - index of enemy
    push di
    push bx
    push ax
    push si

    mov si, di

    mov ax, enemies_y[si]
    mov bx, 0FFh
    mul bx
    mov bx, 2
    mul bx
    add ax, enemies_x[si]
    add ax, enemies_x[si]
    add ax, offset screen
    mov di, ax; di - current enemy offset in screen

    cmp enemies_state[si], 1
    je enemy_update_active
    ja enemy_update_frozen
    jmp enemy_update_end
    enemy_update_frozen:
    dec enemies_state[si]
    jmp enemy_update_end
    enemy_update_active:

    mov bx, enemies_before[si]
    mov [di], bx

    cmp enemies_y[si], max_y
    jne enemy_update_legal_height
    jmp enemy_update_disable
    enemy_update_legal_height:

    ;first look down
    add di, 1FEh
    mov bx, [di]
    sub di, 1FEh
    cmp bx, wall
    je enemy_update_check_horizontal
    cmp bx, spike
    je enemy_update_check_horizontal
    cmp bx, enemy
    je enemy_update_check_horizontal
    cmp bx, frozen_enemy
    je enemy_update_check_horizontal
    cmp bx, player
    jne enemy_update_vertical_fine
    jmp enemy_update_encountered_player
    enemy_update_vertical_fine:

    mov bx, enemies_before[si]
    mov [di], bx
    add di, 1FEh
    mov bx, [di]
    mov enemies_before[si], bx
    mov bx, enemy
    mov [di], bx
    inc enemies_y[si]
    jmp enemy_update_end


    enemy_update_check_horizontal:
    cmp enemies_dir[si], 2
    je enemy_update_right
    jmp enemy_update_left
    enemy_update_right:
    mov bx, max_x
    cmp enemies_x[si], bx
    jae enemy_update_right_unable_to_move
    add di, 2
    mov bx, [di]
    sub di, 2
    cmp bx, wall
    je enemy_update_right_unable_to_move
    cmp bx, spike
    je enemy_update_right_unable_to_move
    cmp bx, enemy
    je enemy_update_right_unable_to_move
    cmp bx, frozen_enemy
    je enemy_update_right_unable_to_move
    cmp bx, player
    jne enemy_update_right_fine
    jmp enemy_update_encountered_player


    enemy_update_right_fine:
    add di, 2
    mov bx, [di]
    mov enemies_before[si], bx
    mov bx, enemy
    mov [di], bx
    inc enemies_x[si]
    jmp enemy_update_end

    enemy_update_right_unable_to_move:
    mov bx, enemy
    mov [di], bx
    mov enemies_dir[si], 0
    jmp enemy_update_end

    enemy_update_left:
    cmp enemies_x[si], 0
    je enemy_update_left_unable_to_move
    sub di, 2
    mov bx, [di]
    add di, 2
    cmp bx, wall
    je enemy_update_left_unable_to_move
    cmp bx, spike
    je enemy_update_left_unable_to_move
    cmp bx, enemy
    je enemy_update_left_unable_to_move
    cmp bx, frozen_enemy
    je enemy_update_left_unable_to_move
    cmp bx, player
    je enemy_update_encountered_player

    sub di, 2
    mov bx, [di]
    mov enemies_before[si], bx
    mov bx, enemy
    mov [di], bx
    dec enemies_x[si]
    jmp enemy_update_end

    enemy_update_left_unable_to_move:
    mov bx, enemy
    mov [di], bx
    mov enemies_dir[si], 2
    jmp enemy_update_end

    jmp enemy_update_end
    enemy_update_encountered_player:
    call enemy_handle
    jmp enemy_update_end
    enemy_update_disable:
    mov enemies_state[si], 0
    enemy_update_end:
    pop si
    pop ax
    pop bx
    pop di
    ret
endp

freeze_enemies proc
    push cx
    push di
    push ax
    push bx
    push si

    mov cx, enemies_count
    cmp cx, 0
    mov si, 0
    je freeze_enemies_end
    mov di, offset enemies_state
    freeze_enemies_loop:
        cmp word ptr [di], 0
        je freeze_enemies_loop_continue
        mov word ptr [di], freez_duration

        push di
        mov ax, enemies_y[si]
        mov bx, 0FFh
        mul bx
        mov bx, 2
        mul bx
        add ax, enemies_x[si]
        add ax, enemies_x[si]
        add ax, offset screen
        mov di, ax; di - current enemy offset in screen

        mov ax, frozen_enemy
        mov [di], ax
        pop di

        freeze_enemies_loop_continue:
        add si, 2
        add di, 2
    loop freeze_enemies_loop


    freeze_enemies_end:
    pop si
    pop bx
    pop ax
    pop di
    pop cx
    ret
endp

display_can_freez proc
    push ax
    push es
    push di

    mov ax, 0B800h
    mov es, ax
    mov di, freeze_offset
    cmp can_freeze, 1
    je display_can_freez_can
    mov ax, 0704h
    jmp display_can_freez_continue

    display_can_freez_can:
    mov ax, 0904h

    display_can_freez_continue:
    stosw

    display_can_freez_end:
    pop di
    pop es
    pop ax
    ret
endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov ah, 00h
    mov al, 03h
    int 10h

    mov ah, 02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    call get_data
    cmp cx, 1
    je finished

    call game_loop

    mov ah, 00h
    mov al, 03h
    int 10h

    finished:
    mov ax, 4C00h
    int 21h

end start

;Игра гонки

.286
.model small
.stack 100h
.data
    ;start_message db 'P', 05h, 'R', 05h, 'E', 05h, 'S', 05h, 'S', 05h
	;db ' ', 05h, 'K', 05h, 'E', 05h, 'Y', 05h, ' '
	;db 05h, 'T', 05h, 'O', 05h, ' ', 05h, 'S', 05h, 'T', 05h, 'A', 05h, 'R', 05h, 'T', 05h
    title_message db "PRESS ANY KEY TO START", 0
	empty_title db "                       ", 0
	gameover_message db "GAME OVER", 0
	empty_gameover db "         ", 0
	score_message db "SCORE", 0
	score db "00000", 0
	buffer db 2000 dup(?)
	car_pos_x dw 0
	car_pos_y dw 0
	car_pos_abs dw 1716
	prev_car_pos_x dw 0
	prev_car_pos_y dw 0
	prev_car_pos_abs dw 1716
	car_left_max_pos_abs dw 1711
	car_right_max_pos_abs dw 1721
	random_number dw 0
	old_handler dd 0
	object_pos_abs  dw 0
	object_prev_pos_abs dw 0
	current_time db 0
	prev_time db 0
	time_interval db 50
	object_collision_flag db 0
	end_game_flag db 0
	object_counter db 0
	dec_speed_flag db 0
	screen_attribute equ 0010000b
	TRUE equ 1
	FALSE equ 0
	border_upper_side equ 110
	border_bottom_side equ 1950
	border_left_side equ 110
	border_right_side equ 126
	horizontal_border_symbol equ 196
	vertical_border_symbol equ 179
	upper_left_border_corner equ 110
	upper_right_border_corner equ 126
	bottom_left_border_corner equ 1950
	bottom_right_border_corner equ 1966
	upper_left_border_corner_symbol equ 218
	upper_right_border_corner_symbol equ 191
	bottom_left_border_corner_symbol equ 192
	bottom_right_border_corner_symbol equ 217
.code

init_screen_mode proc
	pusha
	xor ax, ax
	mov ah,0h
	mov al,03h
	int 10h
	popa
	ret
init_screen_mode endp

sleep proc
	pusha
	mov ah, 0
	int 1ah
	mov bx, dx
	_wait:
		mov ah, 0
		int 1ah
		sub dx, bx
		cmp dx, si
		jb _wait
	popa
	ret
sleep endp

buffer_clear proc
    pusha
    mov bx, 0
	next_clear:
	    mov byte ptr[buffer + bx], ' '
	    inc bx
	    cmp bx, 2000
	    jne next_clear
    popa
    ret
buffer_clear endp

buffer_write proc
	pusha
	mov di, offset buffer
	mov al, 80
	mul dl
	add ax, cx
	add di, ax
	mov byte ptr [di], bl
	popa
	ret
buffer_write endp

;input si - source address
;      di - buffer offset
buffer_write_string proc
	pusha
	write_string_loop:
		xor ax, ax
		mov al, byte ptr[si]
		cmp al, 0
		je _exit_buffer_write_string
		mov byte ptr[buffer + di], al
		inc si
		inc di
		jmp write_string_loop
	_exit_buffer_write_string:
		popa
		ret
buffer_write_string endp

buffer_render proc
    pusha
    mov ax, 0b800h
	mov es, ax
	mov di, offset buffer
	xor si, si
	next_render:
		xor bx, bx
		mov bl, byte ptr[di]
		mov bh, screen_attribute
		jmp write_render
	write_render:
		mov word ptr es:[si], bx
		inc di
		add si, 2
		cmp si, 4000
		jne next_render
    popa
	ret
buffer_render endp

hide_cursor proc
	pusha
	mov ah, 02h
	mov bh, 0
	mov dh, 26
	mov dl, 0
	int 10h
	popa
	ret
hide_cursor endp

random proc
	pusha
	mov ah, 00h  ; interrupts to get system time
	int 1ah      ; CX:DX now hold number of clock ticks since midnight
	mov  ax, dx
	xor  dx, dx
	mov  cx, 10
	div  cx       ; here dx contains the remainder of the division - from 0 to 9
	mov word ptr[random_number], dx
	popa
	ret
random endp

check_key_pressed proc
	pusha
	xor ax, ax
	mov ah, 01h
	int 16h
	jnz key_pressed
	jmp key_not_pressed
	key_pressed:
		popa
		mov dx, TRUE
		jmp _exit_check_key_pressed
	key_not_pressed:
		popa
		mov dx, FALSE
		jmp _exit_check_key_pressed
	_exit_check_key_pressed:
		ret
check_key_pressed endp

show_title proc
	pusha
	call buffer_clear
	call buffer_render
	xor si, si
	xor di, di
	mov si, offset title_message
	mov di, 988
	call buffer_write_string
	call buffer_render
	_wait_for_key:
		mov si, 5
		call sleep
		mov si, offset empty_title
		mov di, 988
		call buffer_write_string
		call buffer_render
		call check_key_pressed
		cmp dx, TRUE
		je _exit_show_title
		jmp _continue_wait_for_key
		_continue_wait_for_key:
			mov si, 5
			call sleep
			mov si, offset title_message
			mov di, 988
			call buffer_write_string
			call buffer_render
			jmp _wait_for_key
	_exit_show_title:
		popa
		ret
show_title endp

show_gameover proc
	pusha
	call buffer_clear
	call buffer_render
	xor si, si
	xor di, di
	mov si, offset gameover_message
	mov di, 996
	call buffer_write_string
	call buffer_render
	_wait_for_key_gameover:
		mov si, 5
		call sleep
		mov si, offset empty_gameover
		mov di, 996
		call buffer_write_string
		call buffer_render
		call check_key_pressed
		cmp dx, TRUE
		je _exit_show_gameover
		jmp _continue_wait_for_key_gameover
		_continue_wait_for_key_gameover:
			mov si, 5
			call sleep
			mov si, offset gameover_message
			mov di, 996
			call buffer_write_string
			call buffer_render
			jmp _wait_for_key_gameover
	_exit_show_gameover:
		popa
		ret
show_gameover endp

draw_border proc
	pusha
	mov di, 0
	next_x:
		mov byte ptr[buffer + di], 255
		mov byte ptr[buffer + border_upper_side + di], horizontal_border_symbol
		mov byte ptr[buffer + border_bottom_side + di], horizontal_border_symbol
		inc di
		cmp di, 16
		jnz next_x
		mov di, 0
	next_y:
		mov byte ptr[buffer + border_left_side + di], vertical_border_symbol
		mov byte ptr[buffer + border_right_side + di], vertical_border_symbol
		add di,80
		cmp di, 2000
		jnz next_y
	corners:
		mov byte ptr[buffer + upper_left_border_corner], upper_left_border_corner_symbol
		mov byte ptr[buffer + upper_right_border_corner], upper_right_border_corner_symbol
		mov byte ptr[buffer + bottom_left_border_corner], bottom_left_border_corner_symbol
		mov byte ptr[buffer + bottom_right_border_corner], bottom_right_border_corner_symbol
	popa
	ret
draw_border endp

draw_car proc
	pusha
		mov di, word ptr[car_pos_abs]
		mov si, word ptr[prev_car_pos_abs]
		xor bx, bx
		init_car_draw:
			mov byte ptr[buffer + si + bx], 20h
			mov byte ptr[buffer + di + bx], 23h
			inc bx
			cmp bx, 5
			jb init_car_draw
			xor bx, bx
			add di, 80
			add si, 80
			mov ax, word ptr[car_pos_abs]
			add ax, 80*3
			cmp di, ax
			jb init_car_draw
	popa
	ret
draw_car endp

update_car_pos proc
	pusha
	mov ah, 01h
	int 16h
	jz end_car
	mov ah, 0h ; retrieve key from buffer
	int 16h
	cmp al, 27 ; ESC
	je _exit_func
	cmp ah, 48h ; up
	je up_car
	cmp ah, 50h ; down
	je down_car
	cmp ah, 4bh; left
	je left_car
	cmp ah, 4dh; right
	je right_car
	jmp end_car
	up_car:
		jmp end_car
	down_car:
		jmp end_car
	left_car:
		xor ax, ax
		xor bx, bx
		mov ax, word ptr[car_pos_abs]
		mov bx, word ptr[car_left_max_pos_abs]
		cmp ax, bx
		je end_car
		mov word ptr[prev_car_pos_abs], ax
		sub word ptr[car_pos_abs], 5
		jmp end_car
	right_car:
		xor ax, ax
		xor bx, bx
		mov ax, word ptr[car_pos_abs]
		mov bx, word ptr[car_right_max_pos_abs]
		cmp ax, bx
		je end_car
		mov word ptr[prev_car_pos_abs], ax
		add word ptr[car_pos_abs], 5
		jmp end_car
	_exit_func:
		jmp far ptr _exit
	end_car:
		popa
		ret
update_car_pos endp

;keyboard_handler proc far
;	pushf                                ; Сохраняем регистры флагов
;    call cs:old_handler                  ; Вызываем старый обработчик
;
;    pusha                                ; Сохраняем регистры
;    push ds
;    push es
;    push cs
;    pop ds
;
;	call  cs:update_car_pos
;	call  cs:draw_car
;
;    pop es
;    pop ds
;    popa
;	popf
;    iret
;keyboard_handler endp
;
;install_handler proc
;	pusha
;	push es
;    cli
;    mov ah, 35h                       ; Функция получения адреса обработчика прерывания
;	mov al, 09h                       ; прерывание, обработчик которого необходимо получить (09 - прерывание от клавиатуры)
;	int 21h
;
;	                                 ; Сохраняем старый обработчик
;	mov word ptr old_handler, bx     ; смещение
;	mov word ptr old_handler + 2, es ; сегмент
;
;	push ds
;	pop es
;
;	mov ah, 25h                       ; Функция замены обработчика прерывания
;	mov al, 09h                       ; Прерывание, обработчк которого будет заменен
;	mov dx, offset keyboard_handler        ; Загружаем в dx смещение нового обработчика прерывания, который будет установлен на место старого обработчика
;	int 21h
;    sti
;	pop es
;	popa
;	ret
;install_handler endp

create_pivot proc
	pusha
	call random
	mov ax, word ptr[random_number]
	xor bx, bx
	mov bl, 3
	div bl
	cmp ah, 0
	je first_line_obj
	cmp ah, 1
	je second_line_obj
	cmp ah, 2
	je third_line_obj

	first_line_obj:
		mov word ptr[object_pos_abs], 111+80
		jmp end_pivot
	second_line_obj:
		mov word ptr[object_pos_abs], 116+80
		jmp end_pivot
	third_line_obj:
		mov word ptr[object_pos_abs], 121+80
		jmp end_pivot
	end_pivot:
		popa
		ret
create_pivot endp

draw_object proc
	pusha
		xor di, di
		xor bx, bx
		mov bx, word ptr[object_prev_pos_abs]
		delete_prev_object_loop:
			mov byte ptr[buffer + bx + di], ' '
			inc di
			cmp di, 5
			jne delete_prev_object_loop
		xor ax, ax
		mov al, byte ptr[object_collision_flag]
		cmp al, TRUE
		je _exit_draw_object
		xor di, di
		xor bx, bx
		mov bx, word ptr[object_pos_abs]
		draw_object_loop:
			mov byte ptr[buffer + bx + di], '#'
			inc di
			cmp di, 5
			jne draw_object_loop
	_exit_draw_object:
		popa
		ret
draw_object endp

get_counters_value proc
	pusha
	xor ax, ax
	xor cx, cx
	xor dx, dx
	mov ah, 2ch
	int 21h
	mov byte ptr[current_time], dl
	popa
	ret
get_counters_value endp

drop_counter proc
	pusha
	xor cx, cx
	xor dx, dx
	mov ah, 01h
	int 1ah
	popa
	ret
drop_counter endp

check_time_left proc
	pusha
	call get_counters_value
	xor ax, ax
	xor bx, bx
	xor dx, dx
	mov al, byte ptr[prev_time]
	mov bl, byte ptr[current_time]
	cmp bx, ax
	jae _sub_from_bx
	jb _sub_from_ax
	_sub_from_ax:
		mov cx, 99
		sub cx, ax
		add bx, cx
		jmp compare_with_time_interval
	_sub_from_bx:
		sub bx, ax
		jmp compare_with_time_interval
	compare_with_time_interval:
		mov dl, byte ptr[time_interval]
		jmp compare_time
	compare_time:
		cmp bx, dx
		jae _true
		jmp _false
	_true:
		xor dx, dx
		mov dl, byte ptr[current_time]
		mov byte ptr[prev_time], dl
		popa
		mov ax, 1
		jmp _exit_check_time_left
	_false:
		popa
		mov ax, 0
		jmp _exit_check_time_left
	_exit_check_time_left:
		ret
check_time_left endp


update_object_pos proc
	pusha
	call check_time_left
	cmp ax, 1
	je move_object_down
	jmp _exit_update_object_pos
	move_object_down:
		xor ax, ax
		mov ax, word ptr[object_pos_abs]
		mov word ptr[object_prev_pos_abs], ax
		add ax, 80
		jmp check_boreder_collision
		check_boreder_collision:
			cmp ax, border_bottom_side
			jg object_border_collision
			jmp continue_move_object_down
			object_border_collision:
				xor bx, bx
				mov bl, 1
				mov byte ptr[object_collision_flag], bl
				mov ax, word ptr[object_prev_pos_abs]
				mov word ptr[object_pos_abs], ax
				jmp _exit_update_object_pos
		continue_move_object_down:
			mov word ptr[object_pos_abs], ax
	_exit_update_object_pos:
		popa
		ret
update_object_pos endp

recreate_object proc
	pusha
	xor ax, ax
	mov al, byte ptr[object_collision_flag]
	cmp al, TRUE
	je _recreate_object
	jmp _exit_recreate_object
	_recreate_object:
		xor ax, ax
		mov al, byte ptr[object_counter]
		inc al
		mov byte ptr[object_counter], al
		call create_pivot
		mov byte ptr[object_collision_flag], 0
		call draw_object
	_exit_recreate_object:
		popa
		ret
recreate_object endp

check_car_collision proc
	pusha
	xor ax, ax
	xor bx, bx
	mov ax, word ptr[car_pos_abs]
	mov bx, word ptr[object_pos_abs]
	cmp ax, bx
	je collision_detected
	add ax, 80
	cmp ax, bx
	je collision_detected
	add ax, 80
	cmp ax, bx
	je collision_detected
	jmp _exit_check_car_collision
	collision_detected:
		mov byte ptr[end_game_flag], TRUE
	_exit_check_car_collision:
		popa
		ret
check_car_collision endp

increase_speed proc
	pusha
	xor ax, ax
	mov al, byte ptr[object_counter]
	xor bx, bx
	mov bl, 3
	div bl
	cmp ah, 0
	je decrease_time_interval
	jne _reset_speed_flag
	decrease_time_interval:
		mov bl, byte ptr[dec_speed_flag]
		cmp bl, TRUE
		je _exit_increase_speed
		mov al, byte ptr[time_interval]
		cmp al, 5
		jle _sub_one
		jmp _sub_five
		_sub_one:
			sub al, 1
			jmp check_to_zero
		_sub_five:
			sub al, 5
			jmp check_to_zero
		check_to_zero:
			cmp al, 0
			je add_one
			jmp continue_decrease_speed
		add_one:
			add al, 1
			jmp continue_decrease_speed
		continue_decrease_speed:
			mov byte ptr[time_interval], al
			mov byte ptr[dec_speed_flag], 1
			jmp _exit_increase_speed
	_reset_speed_flag:
		mov byte ptr[dec_speed_flag], 0
		jmp _exit_increase_speed
	_exit_increase_speed:
		popa
		ret
increase_speed endp

itoa proc
    pusha
    xor di, di
    xor si, si
	xor ax, ax
	xor bx, bx
    mov di, offset score
    add di, 4
    mov al, byte ptr[object_counter]
    _outer_loop_:
       mov bx, 10
	   xor dx, dx
       div bx
       add dx, '0'
       mov byte ptr[di], dl
       dec di
       cmp ax, 0
       je _ret_itoa
       jmp _outer_loop_
    _ret_itoa:
    	popa
    	ret
itoa endp

print_score proc
	pusha
	xor si, si
	xor di, di
	call itoa
	mov si, offset score_message
	mov di, 128
	call buffer_write_string
	mov si, offset score
	mov di, 134
	call buffer_write_string
	call buffer_render
	popa
	ret
print_score endp

_start:
    mov ax, @data
    mov ds, ax
	call init_screen_mode
	call hide_cursor
	call show_title
    call buffer_clear
    call buffer_render
	call draw_border
	call buffer_render
	call draw_car
	call buffer_render
	call create_pivot
	call draw_object
	call buffer_render
	call get_counters_value
	main_loop:
		call print_score
		call update_object_pos
		call recreate_object
		call update_car_pos
		call draw_car
		call draw_object
		call check_car_collision
		xor ax, ax
		mov al, byte ptr[end_game_flag]
		cmp ax, TRUE
		je _exit
		call buffer_render
		call increase_speed
		jmp main_loop
_exit:
call buffer_clear
call buffer_render
call show_gameover
mov ah, 4ch
int 21h
end _start

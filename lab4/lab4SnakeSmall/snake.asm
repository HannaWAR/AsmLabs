.model	small

.data					;Сегмент данных. Храним координаты тела змейки

snake	dw 0101h
		dw 0102h
		dw 0103h
		dw 0104h
		dw 0105h
		dw 7CCh dup('?')

delay_time dw  0FFFFh
score      db  0
score_      db  0
lvl        db  0
UpSpeed    equ 48h	         ; Up key
DownSpeed  equ 50h	         ; Down key
MoveUp     equ 11h	         ; W key
MoveDown   equ 1Fh	         ; S key
MoveLeft   equ 1Eh	         ; A key
MoveRight  equ 20h	         ; D key
Exit       equ 01h          ; ESC key
start_position dw 0  		; позиция символа на экране
							; строка " 00:00 " с атрибутом символа 1Fh (белый на синем фоне)
output_line db ' ',1Fh

output_line_size equ 14

.stack 100h

.code
;В начале сегмента кода будем размещать процедуры
delay proc

    push cx
	mov cx, 0
	mov dx, delay_time        ; пауза в микросекундач
    mov ah, 86h
	int 15h     			; функция задержки
	mov cx, 0
	mov dx, delay_time        ; пауза в микросекундач
    mov ah, 86h
	int 15h
	mov cx, 0
	mov dx, delay_time       ; пауза в микросекундач
    mov ah, 86h
	int 15h
	pop cx
	ret
delay endp

check_board proc
	cmp dl,15h
	jne check_left
	mov dl, 01h
	jmp check_cur
check_left:
	cmp dl,0
	jne check_up
	mov dl, 14h
	jmp check_cur
check_up:
	cmp dh, 0
	jne check_down
	mov dh, 10h
	jmp check_cur
check_down:
	cmp dh, 11h
	jne check_ret
	mov dh, 01h
	jmp check_cur
check_cur:
	mov ax,0200h
	mov [snake+si], dx
	int 10h
check_ret:
	ret
endp

game_over proc

	cmp al,2Ah ;Проверяем символ *
	je the_end
	jmp good

the_end:

    mov ax,4c00h
    int 21h

good:
	ret
game_over endp

key_press proc
	mov ax, 0100h
	int 16h						;проверка наличия символа в буфере
	jz buff_en 					;Без нажатия выходим
	xor ah, ah
	int 16h
	cmp ah, MoveDown
	jne up
	cmp cx,0FF00h		   		;Сравниваем чтобы не пойти на себя
	je buff_en
	mov cx,0100h
	jmp en
up:
	cmp ah, MoveUp
	jne left
	cmp cx,0100h
	je en
	mov cx,0FF00h
	jmp en
buff_en:
	jmp en
left:
	cmp ah, MoveLeft
	jne right
	cmp cx,0001h
	je en
	mov cx,0FFFFh
	jmp en
right:
	cmp ah, MoveRight
	jne up_speed
	cmp cx, 0FFFFh
	je en
	mov cx,0001h
    jmp en
up_speed:
	cmp ah, UpSpeed
	jne down_speed
	cmp lvl, 05h
	je en

	add lvl, 1
	sub delay_time, 1500h
	jmp pen
down_speed:
	cmp ah, DownSpeed
	jne escb
	cmp lvl, 00h
	je en

	sub lvl, 1
	add delay_time, 1500h
	jmp pen
pen:
	mov ax,0200h
	mov dx,1115h
	int 10h

	mov ah,02h
	mov dl, lvl
	add dl, '0'
	int 21h
escb:
	cmp ah, Exit
	jne en
	mov ax,4c00h
    int 21h
en:
	ret
key_press endp

add_food proc
	push ax
	push bx
	push cx
	push dx

sc:
	mov ah, 2Ch
	int 21h

	xor ax, ax
	mov al, dl
	;push ax
	mov dl, 13h
	div dl

	mov bl, ah         ;Запись координаты
sc2:

	mov ah, 2Ch
	int 21h

	xor ax, ax
	mov al, dl

	mov dl, 0Fh
	div dl

	mov dl, bl
	mov dh, ah           ;Запись координаты
	add dx, 0101h

	xor bx, bx
	xor cx, cx

	mov ax,0200h		;установить положение курсора
	int 10h				;dh -  номер строки, dl - номер столбца

	mov ax,0800h		;считать символ и атрибут символа в текущей позиции курсора
	int 10h				;Вывод: АН = атрибут символа, AL = ASCII-код символа.

	cmp al,2Ah          ;Проверяем пустое ли место
	je sc

    cmp al,40h
    je sc               ;Если нет повторяем

	push cx
	mov cx, 1
	mov bl, 01000001b
	mov ax,0924h
	int 10h
	pop cx

	pop dx
	pop cx
	pop bx
	pop ax

	ret
add_food endp

start:
	mov ax,@data
	mov ds,ax
	mov es,ax


	mov ax,0003h
	int	10h 			;Очищаем игровое поле


	;рисуем поле вверх
	xor bx, bx
	mov ax, 0B800h
	mov es, ax

	mov dh, 00100000b
	mov dl, 0B2h

	mov cx, 16h
up_:
	mov word ptr es:[bx],dx
	add bx, 2
	loop up_

	mov cx, 10h
draw:

	add bx, 116                            ;рисуем левый борт
	mov word ptr es:[bx],dx

	push cx								 	;запоминаем сколько еще нпдо рисовать

	mov dh, 01000100b						;устонавливаем маску на цветной фон
	mov dl, 020h
	mov cx, 14h

color:

	add bx, 2
	mov word ptr es:[bx],dx

	loop color


	pop cx

	mov dh, 00100000b
	mov dl, 0B2h

	add bx, 2
	mov word ptr es:[bx],dx

	add bx, 2
	loop draw

	add bx, 116

	mov dl, score
	add dl, '0'

	mov word ptr es:[bx],dx
	add bx, 2
	mov word ptr es:[bx],dx
	add bx, 2

	mov dl, 0B2h
	mov cx, 13h

down_:
	mov word ptr es:[bx],dx
	add bx, 2
	loop down_

	mov dl, lvl
	add dl, '0'

	mov word ptr es:[bx],dx
	add bx, 2



	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx

	mov ax,0200h
	mov dx,0101h
	int 10h

	mov cx,5
	mov bl, 01000010b
	mov ax,092Ah
	int 10h 			;Выводим змейку из 5 символов "*"



	mov si,8			;Индекс координаты символа головы
	xor di,di			;Индекс координаты символа хвоста
	mov cx,0001h		;Регистр cx используем для управления головой. При сложении от значения cx будет изменяться координата x или y

	mov bl,7h
    call add_food
main:					;Основной цикл
	call delay
	call key_press

    xor bh,bh
	mov ax,[snake+si]		;Берем координату головы из памяти
	add ax,cx		        ;Изменяем координату x
	inc si
	inc si
	mov [snake+si],ax		;Заносим в память новую координату головы змеи
	mov dx,ax
	mov ax,0200h
	int 10h 			;Вызываем прерывание. Перемещаем курсор

	mov ax,0800h
    int 10h                     ;Читает символ
	call check_board
    call game_over
	mov ax, 0800h
    int 10h
    cmp al, 24h
	jne next
	call add_food
	add score, 1
	cmp score, 10
	je next_score
back:
	mov ax,0200h		;счет
	mov dx,1101h
	int 10h

	mov ah,02h
	mov dl, score
	add dl, '0'
	int 21h
	jmp main
    mov dh,al

next_score:

	add score_, 1
	mov ax,0200h		;счет
	mov dx,1100h
	int 10h

	mov ah,02h
	mov dl, score_
	add dl, '0'
	int 21h

	mov score, 0

	jmp back

next_:

		mov cx, output_line_size        ; число байт в строке - в СХ
        push 0B800h
        pop es                          ; адрес в видеопамяти
        mov di, word ptr start_position  ; в ES:DI
        mov si,offset output_line       ; адрес строки в DS:SI
        cld
        rep movsb


next:

	push cx

	mov cx, 1
	mov bl, 01000010b
	mov ax, 092Ah
	int 10h

	pop cx	;Прерывание выводит символ '*'

	mov ax,0200h
	mov dx,[snake+di]
	int 10h
	mov ax,0200h
	mov dl,0020h
	int 21h			;Выводим пробел, тем самым удаляя хвост
	inc di
	inc di
jmp main
end	start

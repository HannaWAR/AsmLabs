.model small
.stack 100h

.data
enemies_count               equ 3
screen_size                 equ 80 * 25
screen_width                equ 80
screen_heigth               equ 25
green_space                 equ 2020h
red_space                   equ 4020h
bullet                      equ 0E04h
wall                        equ 6620h
ground                      equ 0620h
empty                       equ 0720h ;07-атрибут, 20h-символ пробела
enemy_tank_up               equ 041Eh
enemy_tank_down             equ 041Fh
enemy_tank_left             equ 0411h
enemy_tank_right            equ 0410h
player_tank_up              equ 021Eh
player_tank_down            equ 021Fh
player_tank_left            equ 0211h
player_tank_right           equ 0210h
enemy_base                  equ 04B1h
tank_status_dead            equ 0
tank_status_dead_has_bullet equ 1
tank_status_can_shoot       equ 2
tank_status_can_not_shoot   equ 3
direction_up                equ 0
direction_down              equ 1
direction_left              equ 2
direction_right             equ 3
direction_none              equ 4
shoot_bullet                equ 5
exit                        equ 6
min_x                       equ 0
max_x                       equ 79
min_y                       equ 1
max_y                       equ 24
bullet_destroyed            equ 0
bullet_fine                 equ 1
bullet_out_of_bound         equ 2
cx_delay                    equ 2
dx_delay                    equ 4585h
long_cx_delay               equ 50
victory_word_size           equ 7
fail_word_size              equ 9

gbbl                        equ 00100000b
rbbl                        equ 01000000b

screen                      dw screen_size dup (?)
enemies_positions           dw enemies_count dup (?)
enemies_status              db enemies_count dup (?)
enemies_directions          db enemies_count dup (?)
enemies_bullets_position    dw enemies_count dup (?)
enemies_bullets_direction   db enemies_count dup (?)
player_position             dw ?
player_direction            db ?
player_status               db ?
player_bullet_position      dw ?
player_bullet_direction     db ?
desired_action              db ?
player_killed               db ?
destroyed_base              db ?

victory_word                db 'Y', gbbl, 'o', gbbl, 'u', gbbl, ' ', gbbl, 'w', gbbl, 'i', gbbl, 'n', gbbl
fail_word                   db 'G', rbbl, 'a', rbbl, 'm', rbbl, 'e', rbbl, ' ', rbbl, 'o', rbbl, 'v', rbbl, 'e', rbbl, 'r', rbbl

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

long_delay macro
    push dx
    push cx
    mov cx, long_cx_delay
    mov dx, dx_delay
    mov ah, 86h
    int 15h
    pop cx
    pop dx
endm

set_video_mode proc ;установка видеорежима
    push ax ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov ah, 0 ;установка видеорежима
    mov al, 03h ;номер режима (03-80х25 стандартный 16-цветный текстовый режим)
    int 10h ;номер прерывания

    set_video_mode_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

update_screen proc
    push ax
    push es
    push si
    push di
    push cx

    mov ax, 0B800h
    mov es, ax
    mov di, 0
    mov cx, screen_size
    mov si, offset screen
    rep movsw

    update_screen_end:
    pop cx
    pop di
    pop si
    pop es
    pop ax
    ret
endp

load_map proc ;загрузка(отрисовка карты)
    push ax ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push cx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push es ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov ax, ds ;в ds лежит адрес начала сегмента данных
    mov es, ax ;перемещаем в регистр es(через регистр ax, тк напрямую нельзя)
    mov di, offset screen ;в регистр di помещаем значение смещения выражения(screen) в байтах относительно начала того сегмента, в котором выражение определено(в нашем случае data)
    mov cx, screen_width ;в сх заносим значение ширины экрана
    mov ax, empty ;в ah заносим атрибут, в al-символ
    rep stosw ;выводим пробелы столько раз, сколько указано в cx
    mov cx, screen_width ;в сх заносим значение ширины экрана
    mov ax, wall ;в ah заносим атрибут, в al-символ
    rep stosw ;выводим пробелы столько раз, сколько указано в cx

    mov cx, 11
    load_map_loop:
        push cx ;запоминаем cx в стек 11
        mov ax, wall ;в ah заносим атрибут, в al-символ
        stosw ;выводим пробелы столько раз, сколько указано в cx

        mov cx, (screen_width - 2) / 6 ;от ширины поля (80-2)/6=13.Это значит, что делим поле на 13 равных участков по 6 символов
        load_map_loop1:
            push cx ;запоминаем 13
            mov ax, ground ;в ah заносим атрибут, в al-символ
            mov cx, 3 ;виртуально делим наши кусочки по 6 символов на кусочки по 3 символа
            rep stosw ; 3 раза чертим землю
            mov ax, wall ;в ah заносим атрибут, в al-символ
            mov cx, 3 ;виртуально делим наши кусочки по 6 символов на кусочки по 3 символа
            rep stosw ; 3 раза чертим стену
            pop cx ;достаём 13
        loop load_map_loop1 ;выполнякм 13 таких подходов(зо один подход отчерчивается 3 символа земли и 3 символа стены)
        mov ax, wall ;в ah заносим атрибут, в al-символ
        stosw ; 1 раз чертим стену(это самая боковая, её надо прочертить отдельно)

        ;переходим на новую строку и чертим вначале 1 стену(она боковая и её надо прочертить отдельно)
        mov ax, wall ;в ah заносим атрибут, в al-символ
        stosw ; 1 раз чертим стену(это самая боковая, её надо прочертить отдельно)

        mov cx, screen_width - 2 ;отнимаем от ширины 2 символа(это наших 2 стены)
        mov ax, ground ;в ah заносим атрибут, в al-символ
        rep stosw ;прочерчиваем землю 78 символов

        mov ax, wall ;в ah заносим атрибут, в al-символ
        stosw ;1 прочерчиваем боковую правую стену

        pop cx ;достаём из стека 11(тк 24-1(верхняя(информационная) строка или земля)-1(земля-стена)=22 и 22/2=11(тк за цикл заполняется 2 дорожки:только земля и земля-стена))
    loop load_map_loop ;пока cx!=0
    mov cx, screen_width ;дорисовываем последнюю  строку стен(в cx помещаем ширину)
    mov ax, wall ;в ah заносим атрибут, в al-символ
    rep stosw ;прочерчиваем землю 80 символов(сколько указано в cx)

    mov di, offset screen ;в di помещаем смещение screen
    mov ah, screen_heigth / 2 ;середина высоты
    mov al, (screen_width / 2) + 1 ;середина длины +1
    call get_offset_on_screen
    add di, ax ;добавляем место, где отрисуем базу
    mov [di], enemy_base ;устанавливаем символ и атрибуты

    load_map_end:
    pop es ;достаём из стека то, что положили вначале опроцедуры
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    pop di ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_enemy_pos proc; al - x, ah - y, cx - enemy_index
    push cx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    add cx, cx
    mov di, offset enemies_positions
    add di, cx ;добавляем к di индекс врага
    mov [di], ax ;заносим координаты врага в di(таким образом, в enemies_positions лежат координаты врагов)

    store_enemy_pos_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_pos proc; cx - enemy_index; output: al - x, ah - y
    push cx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    add cx, cx ;превращаем из байтов в слова, тк они отображаются на выводе
    mov di, offset enemies_positions ;в di помещаем смещение enemies_positions
    add di, cx ;добавляем индекс врага для движения по массиву врагов
    mov ax, [di] ;помещаем в ax значение di

    get_enemy_pos_end:
    pop di ;достаём из стека то, что положили в начале процедуры
    pop cx ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_enemy_direction proc; cx - enemy_index, al - enemy_direction
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_directions ;в di заносим смещение на направление врага
    add di, cx ;прибвляем индекс врага
    mov [di], al ;в di по значению заносим команду танка

    store_enemy_direction_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_direction proc; cx - enemy_index; output: al - enemy_direction
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_directions ;в di заносим смещение на направление врага
    add di, cx ;прибвляем индекс врага(чтобы двигаться по массиву врагов)
    mov al, [di] ;заносим значение di в al

    get_enemy_direction_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_enemy_status proc; cx - enemy_index, al - enemy status
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_status ;в di заносим смещение на статус врага
    add di, cx ;к di прибавляем cx(индекс врага)
    mov [di], al ;записываем в di по значению cтатус врага

    store_enemy_status_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_status proc; cx - enemy_index; output: al - enemy status
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_status ;в di заносим смещение на enemies_status(статус врага)
    add di, cx ;добавляем индекс элемента(для перехода к следующему врагу)
    mov al, [di] ;заносим значение di в al

    get_enemy_status_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    ret  ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_offset_on_screen proc; al - x, ah - y; output: ax - offset_on_screen ;преобразуем двумерный массив в одномерный
    push cx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push bx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push dx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov cx, ax; cx - stores pos(в ах-текущая позикия, причём в ah по у, в al по х) сохраняем в сх, чтобы не потерять
    mov al, ah; al - y
    xor ah, ah; ax - y
    mov bx, screen_width ;в bx кладём ширину экрана
    mul bx ;умножаем bx на ax и заносит в ax
    xor ch, ch; cx - x
    add ax, cx; ax - index on screen
    add ax, ax; ax - offset on screen(было в байтах, станет в словах, тк на экране всё в словах)

    get_offset_on_screen_end:
    pop dx ;достаём из стека то, что положили вначале опроцедуры
    pop bx ;достаём из стека то, что положили вначале опроцедуры
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

draw_enemy proc; cx - enemy_index
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push ax ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push dx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    call get_enemy_status ;вызываем функцию получения статуса врага
    cmp al, tank_status_dead ; сравниваем полученный статус со статусом смерти танка
    je draw_enemy_end ;если враг умер, то прыгает на метку draw_enemy_end
    cmp al, tank_status_dead_has_bullet ; сравниваем полученный статус со статусом смерти танка от пули
    je draw_enemy_end ;если враг умер от пули, то прыгает на метку draw_enemy_end

    call get_enemy_tank_sprite ;функция получения графики танка
    mov dx, ax; dx - sprite to draw (в dx заносим графику танка)

    call get_enemy_pos ;получение позиции врага
    call get_offset_on_screen ;получаем смещение на экране
    mov di, offset screen ;в di помещаем смещение screen
    add di, ax; di - enemy offset on screen (добавляем к di ax, в котором мы получили смещение врага на экране)
    mov [di], dx ;отрисовываем новое положение танка с атрибутами(если быть точнее, то в di(наша новая позиция танка) по значению помещаем символ отрисовки и атрибуты)

    draw_enemy_end:
    pop dx ;достаём из стека то, что положили в начале процедуры
    pop ax ;достаём из стека то, что положили в начале процедуры
    pop di ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_tank_sprite proc; cx - enemy_index; output: ax - enemy_tank_sprite

    call get_enemy_direction ;получить направление врага
    cmp al, direction_up ;cравниваем с движением вверх
    je get_tank_sprite_up ;если мы движемся вверх, то переходим на метку get_tank_sprite_up
    cmp al, direction_down ;cравниваем с движением вниз
    je get_tank_sprite_down ;если мы движемся вниз, то переходим на метку get_tank_sprite_down
    cmp al, direction_left ;cравниваем с движением влево
    je get_tank_sprite_left ;если мы движемся влево, то переходим на метку get_tank_sprite_left
    jmp get_tank_sprite_right ;если это не движение вверх, вниз, влево, то вправо. Безусловный переход на метку get_tank_sprite_right

    get_tank_sprite_up:
    mov ax, enemy_tank_up ;в ax переносим значение enemy_tank_up
    jmp get_tank_sprite_end ;Безусловный переход на завершение процедуры
    get_tank_sprite_down:
    mov ax, enemy_tank_down ;в ax переносим значение enemy_tank_down
    jmp get_tank_sprite_end ;Безусловный переход на завершение процедуры
    get_tank_sprite_left:
    mov ax, enemy_tank_left ;в ax переносим значение enemy_tank_left
    jmp get_tank_sprite_end ;Безусловный переход на завершение процедуры
    get_tank_sprite_right:
    mov ax, enemy_tank_right ;в ax переносим значение enemy_tank_right
    jmp get_tank_sprite_end ;Безусловный переход на завершение процедуры

    get_tank_sprite_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_bullet_pos proc; cx - enemy_index; output: al - x, ah - y
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_bullets_position ;в di помещаем смещение enemies_bullets_position(позиция пули врага)
    add di, cx ;добавляем индекс к di
    add di, cx ;для перехода на следующее слово надо сдвинуться на 2, x лежит число перемещений к следующему слову
    mov ax, [di] ;заносим значение, которое лежит в di в ax

    get_enemy_bullet_pos_end:
    pop di ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_enemy_bullet_pos proc; cx - enemy_index, al - x, ah - y
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_bullets_position ;в di помещаем смещение enemies_bullets_position(позиция пули врага)
    add di, cx ;добавляем индекс к di
    add di, cx ;преобразование к слову
    mov [di], ax ;заносим значение, которое лежит в ax в di

    set_enemy_bullet_pos_end:
    pop di ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_enemy_bullet_direction proc; cx - enemy_index; output: bl - direction
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_bullets_direction ;в di помещаем смещение enemies_bullets_direction(направление пули врага)
    add di, cx ;добавляем индекс к di
    mov bl, [di] ;заносим значение, которое лежит в di в bl(тут 2 раза не прибавляем, тк нам размерность слово не нужно)

    get_enemy_bullet_direction_end:
    pop di ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_enemy_bullet_direction proc; cx - enemy_index, bl - direction
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    mov di, offset enemies_bullets_direction ;в di помещаем смещение enemies_bullets_direction(направление пули врага)
    add di, cx ;добавляем индекс к di
    mov [di], bl ;заносим значение, которое лежит в bl в di(тут 2 раза не прибавляем, тк нам размерность слово не нужно)

    set_enemy_bullet_direction_end:
    pop di ;достаём из стека то, что положили в начале процедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_pos proc; output: al - x, ah - y
    mov ax, player_position ;помещаем позицию игрока в ax
    get_player_pos_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_player_pos proc; al - x, ah - y
    mov player_position, ax ;сохраняем позицию врага в player_position
    store_player_pos_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_direction proc; output: al - player direction

    mov al, player_direction ;заносим направление игрока в al

    get_player_direction_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_player_direction proc; al - player direction

    mov player_direction, al ;заносим направление игрока в player_direction(по умолчанию вверх)

    store_player_direction_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_status proc; output: al - player status

    mov al, player_status ;заносим статус игрока в al

    get_player_status_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_player_status proc; al - player status

    mov player_status, al ;заносим статус игрока в player_status(по умолчанию вверх)

    store_player_status_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

draw_player proc; no input, no output
    push ax ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push dx ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их
    push di ;в начале каждой функции проделываем операцию сохранения в стек, чтобы если вдруг в регистрах лежат данные, не потерять их

    cmp player_killed, 1 ;сравниваем player_killed флаг с 1(убит ли игрок)
    je draw_player_end ;если игрок убит, то переходим на метку draw_player_end

    call get_player_tank_sprite ;получаем графику игрока
    mov dx, ax; dx - sprite to draw(графика для отрисовки)

    call get_player_pos ;получаем позицию игрока
    call get_offset_on_screen ;получаем смещение на экране
    mov di, offset screen ;в di помещаем смещение экрана
    add di, ax ;становимся в нашу позицию (где надо отрисовать)
    mov [di], dx ;помещаем графику для отрисовки(атрибуты цвета и символ) в di

    draw_player_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    pop dx ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_tank_sprite proc; output: ax - player_tank_sprite

    call get_player_direction ;получаем направление игрока

    cmp al, direction_up ;сравниваем, совпадат ли направление с движением вверх
    je get_player_direction_up ;если совпадает, то переходим на метку get_player_direction_up
    cmp al, direction_down ;если это не движение вверх, то сравниваем с движением вниз
    je get_player_direction_down ;если это движение вниз, то переходим на метку get_player_direction_down
    cmp al, direction_left ;если это не движение вниз, то сравниваем на движение влево
    je get_player_direction_left ;если это движение влево, то переходим по метке get_player_direction_left
    jmp get_player_direction_right ;если это не движение вверх, вниз, влево, то это движение вправо, выполняем безусловный переход на метку get_player_direction_right

    get_player_direction_up:
    mov ax, player_tank_up ;в ax переносим значение player_tank_up (символ и атрибуты для отрисовки)
    jmp get_player_direction_end ;Безусловный переход на завершение процедуры
    get_player_direction_down:
    mov ax, player_tank_down ;в ax переносим значение player_tank_down (символ и атрибуты для отрисовки)
    jmp get_player_direction_end ;Безусловный переход на завершение процедуры
    get_player_direction_left:
    mov ax, player_tank_left ;в ax переносим значение player_tank_left (символ и атрибуты для отрисовки)
    jmp get_player_direction_end ;Безусловный переход на завершение процедуры
    get_player_direction_right:
    mov ax, player_tank_right ;в ax переносим значение player_tank_right (символ и атрибуты для отрисовки)
    jmp get_player_direction_end ;Безусловный переход на завершение процедуры

    get_player_tank_sprite_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_bullet_pos proc; output: al - x, ah - y

    mov ax, player_bullet_position ;заносим в ax позицию пули игрока

    get_player_bullet_pos_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_player_bullet_direction proc; output: bl - direction

    mov bl, player_bullet_direction ;заносим в bl направление пули игрока

    get_player_bullet_direction_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_player_bullet_pos proc; al - x, ah - y

    mov player_bullet_position, ax ;помещаем позицию(координаты) пули игрока в player_bullet_position

    set_player_bullet_pos_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_player_bullet_direction proc; al - direction

    mov player_bullet_direction, al ;помещаем направление пули игрока в player_bullet_direction

    set_player_bullet_direction_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

init proc
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push cx ;сохраняем в стек регистр сx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call load_map ;загрузка(отрисовка карты)

    mov player_killed, 0 ;в переменную убитый игрок заносим 0
    mov destroyed_base, 0 ;в переменную разрушенная база заносим 0

    ;таким образом, у нас 3 врага(1 двигается с верхнего левого угла, второй с середины ширины самой первой строки, третий- с середины высоты (самой краёней левой))
    mov al, min_x + 1 ;init enemies pos (инициализируем позицию врага), заносим её в al (по х)
    mov ah, min_y + 1 ;init enemies pos (инициализируем позицию врага), заносим её в ah (по y)
    mov cx, 0 ;заносим в cx 0 (индекс врага)
    call store_enemy_pos ;функция хранения позиции врага
    mov al, screen_width / 2 ;init enemies pos (инициализируем позицию врага), заносим её в al (по х)
    mov ah, min_y + 1 ;init enemies pos (инициализируем позицию врага), заносим её в ah (по y)
    inc cx ;заносим в cx 1 (индекс врага)
    call store_enemy_pos ;функция хранения позиции врага
    mov al, min_x + 1 ;init enemies pos (инициализируем позицию врага), заносим её в al (по х)
    mov ah, screen_heigth / 2 ;init enemies pos (инициализируем позицию врага), заносим её в ah (по y)
    inc cx ;заносим в cx 2 (индекс врага)
    call store_enemy_pos ;функция хранения позиции врага

    ;init enemies status(инициализация статуса врага)
    mov cx, 0 ;индекс танка
    mov al, tank_status_can_shoot ;в al помещаем 2, что свидетельствует о том, что танк может стрелять
    call store_enemy_status ;хранение статуса врага
    inc cx ;индекс танка
    call store_enemy_status ;хранение статуса врага
    inc cx ;индекс танка
    call store_enemy_status ;хранение статуса врага

    ;init enemies directions(инициализация направления врага)
    mov cx, 0 ;заносим 0(как индекс врага)
    mov al, direction_up ;заносим 0(это вверх)
    call store_enemy_direction ;храним направление врага
    inc cx ;заносим 1(как индекс врага)
    call store_enemy_direction ;храним направление врага
    inc cx ;заносим 2(как индекс врага)
    call store_enemy_direction ;храним направление врага

    ;draw enemies (отрисовка врагов)
    mov cx, 0 ;заносим 0(как индекс врага)
    call draw_enemy ;отрисовываем первого врага
    inc cx ;увеличиваем cx(до 1)
    call draw_enemy ;отрисовываем первого врага
    inc cx ;увеличиваем cx(до 2)
    call draw_enemy ;отрисовываем третьего врага

    mov al, max_x - 1 ;переносим в al 78
    mov ah, max_y - 1 ;переносим в al 23
    call store_player_pos ;начальное положение нашего танка(правый нижний угол)

    mov al, direction_up ;заносим 0(это вверх) по умолчанию вверх
    call store_player_direction ;храним направление движения игрока

    mov al, tank_status_can_shoot ;в al помещаем 2, что свидетельствует о том, что танк может стрелять
    call store_player_status ;храним статус игрока

    call draw_player ;отрисовываем игрока

    init_end:
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

choose_desired_action proc; al - ASCII, ah - scan_code; output: desired_action changed if legal
    cmp ah, 01h; Esc key сравнение с кодом Esc
    je choose_desired_action_exit ;если совпадает с Esc, то переходим на метку choose_desired_action_exit
    cmp ah, 11h; W key Если не Esc, то проверяем, W ли это
    je choose_desired_action_up ;если совпадает с W, то переходим на метку choose_desired_action_up
    cmp ah, 1Eh; A key Если не W, то проверяем, A ли это
    je choose_desired_action_left ;если совпадает с A, то переходим на метку choose_desired_action_left
    cmp ah, 1Fh; S key Если не A, то проверяем, S ли это
    je choose_desired_action_down ;если совпадает с S, то переходим на метку choose_desired_action_down
    cmp ah, 20h; D key Если не S, то проверяем, D ли это
    je choose_desired_action_right ;если совпадает с D, то переходим на метку choose_desired_action_right
    cmp ah, 39h; SpaceBar Если не D, то проверяем, SpaceBar ли это
    je choose_desired_action_shoot ;если совпадает с SpaceBar, то переходим на метку choose_desired_action_shoot
    jmp choose_desired_action_end ;если ни одна из вышеперечисленных клавиш, то безусловный переход на конец процедуры на метку choose_desired_action_end

    choose_desired_action_exit:
    mov desired_action, exit ;переносим в desired_action 6(наш код выхода)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end
    choose_desired_action_up:
    mov desired_action, direction_up ;переносим в desired_action 0(наш код движения вверх)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end
    choose_desired_action_down:
    mov desired_action, direction_down ;переносим в desired_action 1(наш код движения вниз)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end
    choose_desired_action_left:
    mov desired_action, direction_left ;переносим в desired_action 2(наш код движения влево)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end
    choose_desired_action_right:
    mov desired_action, direction_right ;переносим в desired_action 3(наш код движения вправо)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end
    choose_desired_action_shoot:
    mov desired_action, shoot_bullet ;переносим в desired_action 5(наш код пробела)
    jmp choose_desired_action_end ;безусловный переход на метку choose_desired_action_end

    choose_desired_action_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_desired_action proc; output: desired_action
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    mov desired_action, direction_none ;по умолчанию заносим отсутствие действия в ожидаемое значение
    get_desired_action_loop:
        mov ah, 11h ;101/102 клавиши
        int 16h ;проверка на наличие символа в буффере
        jz get_desired_action_end ;если в буффере нет ничего, то переходим на метку get_desired_action_end
        mov ah, 10h ;101/102 клавиши
        int 16h ;если в буффере имеется символ, то мы его читаем с ожиданием
        call choose_desired_action ;функция выбора действия
    jmp get_desired_action_loop ;зацикливаемся

    get_desired_action_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

erase proc; al - x, ah - y
    push di ;сохраняем в стек регистр di(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_offset_on_screen ;получаем смещение пули на экране
    mov di, offset screen ;записываем в di смещение экрана
    add di, ax ;переходим к позиции пули на экране
    mov [di], ground ;говорим, что теперь это земля(записываем в di по значению атрибуты земли)

    erase_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    pop di ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

check_boundaries proc; al - x, ah - y; output: al - checked x, ah - checked y

    cmp ah, min_y ;сравниваем у с минимальным возможным у=1 (1, потому что по краям стена)
    jb check_boundaries_ah_too_small ;если ah меньше минимального, то переходим по метке check_boundaries_ah_too_small
    cmp ah, max_y ;сравниваем у с максимально возможным у=24 (24, потому что по краю стена)
    ja check_boundaries_ah_too_big ;если ah больше максимального, то переходим по метке check_boundaries_ah_too_big
    jmp check_boundaries_ah_fine

    check_boundaries_ah_too_big:
    mov ah, max_y ;присваиваем y его возможное максимальное значение
    jmp check_boundaries_ah_fine ;безусловный переход на метку check_boundaries_ah_fine
    check_boundaries_ah_too_small:
    mov ah, min_y ;присваиваем y его возможное минимальное значение
    jmp check_boundaries_ah_fine ;безусловный переход на метку check_boundaries_ah_fine

    check_boundaries_ah_fine: ;на данной ветке мы оказываемся, если у располагается в нужных нам пределах

    cmp al, min_x ;сравниваем х с минимальным возможным х=0
    jb check_boundaries_al_too_small ;если al меньше минимального, то переходим по метке check_boundaries_al_too_small
    cmp al, max_x ;сравниваем x с максимально возможным x=79
    ja check_boundaries_al_too_big ;если al больше максимального, то переходим по метке check_boundaries_al_too_big
    jmp check_boundaries_end ;безусловный переход на метку check_boundaries_end

    check_boundaries_al_too_small:
    mov al, min_x ;присваиваем x его возможное минимальное значение
    jmp check_boundaries_end ;безусловный переход на метку check_boundaries_end
    check_boundaries_al_too_big:
    mov al, max_x ;присваиваем х его возможное минимальное значение
    jmp check_boundaries_end ;безусловный переход на метку check_boundaries_end

    check_boundaries_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_new_pos proc; al - x, ah - y, bl - direction; al - new x, ah - new y (checked)

    cmp bl, direction_right ;сравниваем направление пули с правым направлением
    je get_new_pos_right ;если направление совпадает с правым, то перходим по метке get_new_pos_right
    cmp bl, direction_left ;сравниваем направление пули с левым направлением
    je get_new_pos_left ;если направление совпадает с левым, то перходим по метке get_new_pos_left
    cmp bl, direction_up ;сравниваем направление пули с направлением вверх
    je get_new_pos_up ;если направление совпадает направлением вверх, то перходим по метке get_new_pos_up
    cmp bl, direction_down ;сравниваем направление пули с направлением вниз
    je get_new_pos_down ;если направление совпадает направлением вниз, то перходим по метке get_new_pos_down
    jmp get_new_pos_end ;если это не право, лево, верх, низ, то выходим из процедуры, переходя на метку get_new_pos_end

    get_new_pos_up:
    cmp ah, 0 ;сравниваем, является ли y=0(т е существует ли возможность движения вверх)
    je get_new_pos_end ;безусловный переход на метку get_new_pos_end и завершение процедуры, если некуда двигаться
    dec ah ;уменьшаем координату y, если есть возможность движения вверх
    jmp get_new_pos_end ;безусловный переход на метку get_new_pos_end
    get_new_pos_down:
    inc ah ;уведичиваем у
    jmp get_new_pos_end ;безусловный переход на метку get_new_pos_end
    get_new_pos_left:
    cmp al, 0 ;сравниваем, является ли х=0(т е существует ли возможность движения влево)
    je get_new_pos_end ;безусловный переход на метку get_new_pos_end и завершение процедуры, если некуда двигаться
    dec al ;уменьшаем х
    jmp get_new_pos_end ;безусловный переход на метку get_new_pos_end
    get_new_pos_right:
    inc al ;увеличиваем координату х(это движение вправо)
    jmp get_new_pos_end ;безусловный переход на метку get_new_pos_end

    get_new_pos_end:
    call check_boundaries ;проверяем границы
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

get_element_on_screen proc; al - x, ah - y; output: dx - element
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push di ;сохраняем в стек регистр di(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_offset_on_screen ;получаем смещение на экране в ax
    mov di, offset screen ;заносим в di смещение screen
    add di, ax ;добавляем к di смещение пули относительно начала
    mov dx, [di] ;заносим в dx значение di(цвет и атрибуты ячейки на экране)

    get_element_on_screen_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

draw_bullet proc; al - x, ah - y
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push di ;сохраняем в стек регистр di(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_offset_on_screen ;получаем смещение на экране в ax
    mov di, offset screen ;заносим в di смещение экрана
    add di, ax ;прибавляем к смещению на экране положение нашей пули отностительно начала(становимся в точку, где надо отрисовать пулю)
    mov word ptr [di], bullet ;передаём по смещению di атрибуты и символ пули для вывода на экран

    draw_bullet_end:
    pop di ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

deside_if_bullet_destroyed proc; al - new x, ah - new y; output: bl - bullet_state
    push dx ;сохраняем в стек регистр dx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_element_on_screen ;получаем описание символа на экране по новым координатам пули
    cmp dx, bullet ;является ли данная ячейка пулей
    je deside_if_bullet_destroyed_out_of_bound ;если да, то разрешить уничтожить пулю за пределами поля
    cmp dx, ground ;сравниваем, является ли данная ячейка землёй
    je deside_if_bullet_destroyed_fine ;переходим по метке, что всё ок
    jmp deside_if_bullet_destroyed_destroyed

    deside_if_bullet_destroyed_out_of_bound:
    mov bl, bullet_out_of_bound ;устанавливаем состояние пули:она вылетела за пределы поля
    jmp deside_if_bullet_destroyed_end ;безусловный переход на окончание процедуры
    deside_if_bullet_destroyed_fine:
    mov bl, bullet_fine ;устанавливаем статус, что пуля в порядке
    jmp deside_if_bullet_destroyed_end ;безусловный переход на окончание процедуры
    deside_if_bullet_destroyed_destroyed:
    mov bl, bullet_destroyed ;устанавливаем статус: пуля уничтожена
    cmp dx, enemy_base ;сравниваем dx с базой противника(цвет и символ)
    je deside_if_bullet_destroyed_destroyed_base ;если да, то мы уничтожили  базу противника
    cmp dx, player_tank_down ;сравниваем,повёрнутый ли вниз это танк игрока
    je deside_if_bullet_destroyed_player_killed ;если да, то игрок убит, переходим по метке deside_if_bullet_destroyed_player_killed
    cmp dx, player_tank_up ;сравниваем,повёрнутый ли вверх это танк игрока
    je deside_if_bullet_destroyed_player_killed ;если да, то игрок убит, переходим по метке deside_if_bullet_destroyed_player_killed
    cmp dx, player_tank_left ;сравниваем,повёрнутый ли влево это танк игрока
    je deside_if_bullet_destroyed_player_killed ;если да, то игрок убит, переходим по метке deside_if_bullet_destroyed_player_killed
    cmp dx, player_tank_right ;сравниваем,повёрнутый ли вправо это танк игрока
    je deside_if_bullet_destroyed_player_killed ;если да, то игрок убит, переходим по метке deside_if_bullet_destroyed_player_killed
    jmp deside_if_bullet_destroyed_end ;безусловный переход на окончание процедуры (состояние не меняется)

    deside_if_bullet_destroyed_destroyed_base:
    mov destroyed_base, 1 ;устанавливаем, что база уничтожена
    jmp deside_if_bullet_destroyed_end ;безусловный переход на окончание процедуры

    deside_if_bullet_destroyed_player_killed:
    mov player_killed, 1 ;устанавливаем, что игрок уничтожен
    jmp deside_if_bullet_destroyed_end ;безусловный переход на окончание процедуры

    deside_if_bullet_destroyed_end:
    pop dx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

draw_bullet_result proc; al - x, ah - y, bl - bullet_state

    cmp bl, bullet_out_of_bound ;если статус у пули, что она вылетела за пределы поля(сравнение тут)
    je draw_bullet_result_end ;переходим на конец процедуры
    cmp bl, bullet_fine ;если у пули статус, что с ней всё хорошо, то вызываем отрисовку пули
    jne draw_bullet_result_empty ;если у пули не всё хорошо, то переходим по метке draw_bullet_result_empty
    call draw_bullet ;отрисовка пули
    jmp draw_bullet_result_end ;безусловный переход на конец процедуры

    draw_bullet_result_empty:
    call erase ;стираем пулю
    jmp draw_bullet_result_end ;безусловный переход на конец процедуры

    draw_bullet_result_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

update_bullet proc; al - x, ah - y, bl - direction; output: al - new x, ah - new y, bl - bullet state
    push dx ;сохраняем в стек регистр dx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    push ax ;сохраняем в стек ax
    mov dx, ax ;помещаем ax в dx
    call get_new_pos ;функция получения новой позиции пули
    cmp dx, ax ;сравниваем новую и старую позиции пуль
    jne update_bullet_no_out_of_bound ;если они не равны, то пуля не улетела
    call draw_bullet ;отрисовка пули
    update_bullet_no_out_of_bound:
    call deside_if_bullet_destroyed ;проверяем, уничтожена ли пуля
    call draw_bullet_result ;отрисовываем результат

    mov dx, ax ;переносим координаты пули в dx
    pop ax ;достаём ax-позиция пули врага
    call erase ;удаляем пули
    mov ax, dx ; переносим координаты удалённых пуль(уже земли) в ах

    update_bullet_end:
    pop dx  ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_enemy_bullet_status_active proc; cx - enemy_index
    push ax ;сохраняем в стек регистр аx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_enemy_status ;получаем статус врага
    cmp al, tank_status_dead ;сравниваем статус врага со смертью
    je set_enemy_bullet_status_active_dead ;если статус=смерти, то переходим по метке set_enemy_bullet_status_active_dead
    cmp al, tank_status_dead_has_bullet ;сравниваем статус врага со смертью, но пуля его ещё летит
    je set_enemy_bullet_status_active_dead ;если статус=смерти но пуля его ещё летит, то переходим по метке set_enemy_bullet_status_active_dead
    jmp set_enemy_bullet_status_active_alive ;безусловный переход на метку set_enemy_bullet_status_active_alive

    set_enemy_bullet_status_active_dead:
    mov al, tank_status_dead_has_bullet ;устанавливаем статус врага со смертью, но пуля его ещё летит
    call store_enemy_status ;сохраняем статус врага
    jmp set_enemy_bullet_status_active_end ;безусловный переход на метку set_enemy_bullet_status_active_end

    set_enemy_bullet_status_active_alive:
    mov al, tank_status_can_not_shoot ;устанавливаем статус врага , что он не может стрелять
    call store_enemy_status ;сохраняем статус врага
    jmp set_enemy_bullet_status_active_end ;безусловный переход на метку set_enemy_bullet_status_active_end

    set_enemy_bullet_status_active_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

set_enemy_bullet_status_inactive proc; cx - enemy_index
    push ax ;сохраняем в стек регистр аx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_enemy_status ;получаем статус врага
    cmp al, tank_status_dead ;сравниваем статус врага со смертью
    je set_enemy_bullet_status_inactive_dead ;если статус=смерти, то переходим по метке set_enemy_bullet_status_inactive_dead
    cmp al, tank_status_dead_has_bullet ;сравниваем статус врага со смертью, но пуля его ещё летит
    je set_enemy_bullet_status_inactive_dead ;если статус=смерти но пуля его ещё летит, то переходим по метке set_enemy_bullet_status_inactive_dead
    jmp set_enemy_bullet_status_inactive_alive ;безусловный переход на метку set_enemy_bullet_status_inactive_alive

    set_enemy_bullet_status_inactive_dead:
    mov al, tank_status_dead ;заносим в al статус смерти
    call store_enemy_status ;сохраняем статус врага
    jmp set_enemy_bullet_status_inactive_end ;безусловный переход на метку set_enemy_bullet_status_inactive_end

    set_enemy_bullet_status_inactive_alive:
    mov al, tank_status_can_shoot ;заносим в al статус, что он может стрелять
    call store_enemy_status ;сохраняем статус врага
    jmp set_enemy_bullet_status_inactive_end ;безусловный переход на метку set_enemy_bullet_status_inactive_end

    set_enemy_bullet_status_inactive_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

save_enemy_bullet_state proc; cx - enemy_index, bl - bullet_state

    cmp bl, bullet_fine ;сравниваем, является ли состояние пули, что всё с ней ок
    je save_enemy_bullet_state_fine ;если да, то переходим по метке сохранения состояния save_enemy_bullet_state_fine
    call set_enemy_bullet_status_inactive ;если нет, то вызываем set_enemy_bullet_status_inactive
    jmp save_enemy_bullet_state_end ;безусловный переход на конец процедуры

    save_enemy_bullet_state_fine:
    call set_enemy_bullet_status_active ;установка статуса врага
    jmp save_enemy_bullet_state_end ;безусловный переход на конец процедуры

    save_enemy_bullet_state_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

update_enemy_bullet proc; cx - number of enemy
    push cx ;сохраняем в стек регистр cx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push bx ;сохраняем в стек регистр bx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    dec cx; turn cx to index(уменьшаем cx, чтобы он указывал не на количество, а на индекс)
    call get_enemy_status ;получаем статус врага

    cmp al, tank_status_dead ;если статус врага установлен в то, что он умер
    je update_enemy_bullet_end ;то переходим по метке update_enemy_bullet_end
    cmp al, tank_status_can_shoot ;если статус врага установлен в то, что он может стрелять
    je update_enemy_bullet_end ;то переходим по метке update_enemy_bullet_end

    call get_enemy_bullet_pos ;из массива позиций пуль получаем позицию пули конкретного врага(задаётся сх)
    call get_enemy_bullet_direction ;получаем направление пули конкркетного врага
    call update_bullet ;обновляем положение пули
    call save_enemy_bullet_state ;сохранение состояние пули врага
    call set_enemy_bullet_pos ;установка позиции пули

    update_enemy_bullet_end:
    pop bx ;достаём из стека то, что положили вначале опроцедуры
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

save_player_bullet_status_active proc;
    push ax ;сохраняем в стек регистр аx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_player_status ;получение статуса игрока
    cmp al, tank_status_dead ;если статус, что игрок умер
    je save_player_bullet_status_active_dead ;переходим по метке save_player_bullet_status_active_dead
    cmp al, tank_status_dead_has_bullet  ;если статус, что игрок умер, но его пуля ещё летит
    je save_player_bullet_status_active_dead ;переходим по метке save_player_bullet_status_active_dead

    mov al, tank_status_can_not_shoot ;устанавливаем статус, что игрок не может стрелять
    call store_player_status ;cохраняем статус игрока
    jmp save_player_bullet_status_active_end ;безусловный переход на окончание процедуры

    save_player_bullet_status_active_dead:
    mov al, tank_status_dead_has_bullet ;устанавливаем статус, что игрок умер, но его пуля ещё летит
    call store_player_status ;cохраняем статус игрока

    save_player_bullet_status_active_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

save_player_bullet_status_inactive proc;
    push ax ;сохраняем в стек регистр аx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_player_status ;получение статуса игрока
    cmp al, tank_status_dead ;если статус, что игрок умер
    je save_player_bullet_status_inactive_dead ;переходим по метке save_player_bullet_status_inactive_dead
    cmp al, tank_status_dead_has_bullet ;если статус, что игрок умер, но его пуля ещё летит
    je save_player_bullet_status_inactive_dead ;переходим по метке save_player_bullet_status_inactive_dead

    mov al, tank_status_can_shoot ;устанавливаем статус, что игрок может стрелять
    call store_player_status ;cохраняем статус игрока
    jmp save_player_bullet_status_inactive_end ;безусловный переход на окончание процедуры

    save_player_bullet_status_inactive_dead:
    mov al, tank_status_dead ;устанавливаем статус, что игрок умер
    call store_player_status ;cохраняем статус игрока

    save_player_bullet_status_inactive_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

save_player_bullet_state proc; bl - bullet_state

    cmp bl, bullet_fine ;сравниваем состояние пули с состоянием, что всё хорошо
    je save_player_bullet_state_active ;если с пулей всё ок, то переходим по метке save_player_bullet_state_active
    call save_player_bullet_status_inactive ;сохраняем статус пули
    jmp save_player_bullet_state_end ;безусловный переход на конец процедуры

    save_player_bullet_state_active:
    call save_player_bullet_status_active ;сохраняем статус пули
    jmp save_player_bullet_state_end ;безусловный переход на конец процедуры

    save_player_bullet_state_end:
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

update_player_bullet proc;
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    call get_player_status ;функция получения статуса игрока

    cmp al, tank_status_can_shoot ;сравниваем со статусом, что можно стрелять
    je update_player_bullet_end ;если да, то безусловный переход на метку update_player_bullet_end
    cmp al, tank_status_dead ;сравниваем со статусом, что танк умер
    je update_player_bullet_end ;если да, то безусловный переход на метку update_player_bullet_end

    call get_player_bullet_pos ;получить позицию пули игрока
    call get_player_bullet_direction ;получить направление пули игрока
    call update_bullet ;обновление пули
    call save_player_bullet_state ;сохранение состояния пули игрока
    call set_player_bullet_pos ;установка позиции пули

    update_player_bullet_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

update_bullets proc
    push cx ;сохраняем в стек регистр cx(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    mov cx, enemies_count ;помещаем количество врагов в cx
    update_bullets_enemies_loop:
        call update_enemy_bullet ;функция обновления пуль врагов
    loop update_bullets_enemies_loop ;крутим для 3 врагов

    call update_player_bullet ;обновляем пулю игрока

    update_bullets_end:
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

player_shoot proc
    push ax

    call get_player_status
    cmp al, tank_status_can_not_shoot
    je player_shoot_end

    call get_player_pos
    call set_player_bullet_pos
    call get_player_direction
    call set_player_bullet_direction
    mov al, tank_status_can_not_shoot
    call store_player_status
    call update_player_bullet

    player_shoot_end:
    pop ax
    ret
endp

player_move proc

    call get_player_pos
    call erase
    mov bl, desired_action
    push ax
    mov al, desired_action
    call store_player_direction
    pop ax
    call get_new_pos
    call get_element_on_screen
    cmp dx, ground
    je player_move_can_move
    cmp dx, bullet
    je player_move_bullet
    jmp player_move_end

    player_move_bullet:
    mov player_killed, 1
    jmp player_move_end

    player_move_can_move:
    call store_player_pos
    jmp player_move_end

    player_move_end:
    ret
endp

update_player proc

    cmp player_killed, 1
    je update_player_end

    cmp desired_action, direction_none
    je update_player_finished_action

    cmp desired_action, shoot_bullet
    je update_player_shoot

    jmp update_player_move

    update_player_shoot:
    call player_shoot
    jmp update_player_finished_action

    update_player_move:
    call player_move
    jmp update_player_finished_action


    update_player_finished_action:

    call draw_player

    update_player_end:
    ret
endp

get_difference proc; ch - a, cl - b; output: ch - difference

    cmp ch, cl
    ja get_difference_ah_greater
    sub cl, ch
    mov ch, cl

    get_difference_ah_greater:
    sub ch, cl
    jmp get_differenc_end

    get_differenc_end:
    ret
endp

get_distance_to_player proc; cx - enemy_index; output: ah - y differenc, al - x difference
    push cx
    push bx

    call get_player_pos
    mov bx, ax
    call get_enemy_pos

    mov ch, bl
    mov cl, al
    call get_difference
    mov al, ch

    mov ch, bh
    mov cl, ah
    call get_difference
    mov ah, ch

    get_distance_to_player_end:
    pop bx
    pop cx
    ret
endp

update_enemy_vertical_action proc; cx - enemy_index, al - final_flag
    push ax
    push bx
    push ax

    call get_player_pos
    mov bx, ax
    call get_enemy_pos

    cmp ah, bh; bh - player, ah - enemy
    je update_enemy_vertical_action_to_shoot
    ja update_enemy_vertical_action_up
    jmp update_enemy_vertical_action_down

    update_enemy_vertical_action_up:
    call update_enemy_move_up
    cmp bl, 1
    je update_enemy_vertical_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_vertical_action_end
    mov al, 1
    call update_enemy_horizontal_action
    jmp update_enemy_vertical_action_end

    update_enemy_vertical_action_down:
    call update_enemy_move_down
    cmp bl, 1
    je update_enemy_vertical_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_vertical_action_end
    mov al, 1
    call update_enemy_horizontal_action
    jmp update_enemy_vertical_action_end

    update_enemy_vertical_action_to_shoot:
    call update_enemy_shoot_horizontal
    cmp bl, 1
    je update_enemy_vertical_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_vertical_action_end
    mov al, 1
    call update_enemy_horizontal_action
    jmp update_enemy_vertical_action_end

    update_enemy_vertical_action_end_pop:
    pop ax
    update_enemy_vertical_action_end:
    pop bx
    pop ax
    ret
endp

check_if_enemy_alive proc; cx - enemy_index, bx - result
    push ax
    push dx
    push cx

    call get_enemy_pos
    mov bx, ax

    mov dx, cx
    inc dx
    mov cx, enemies_count
    check_if_enemy_alive_loop:
        cmp cx, dx
        je check_if_enemy_alive_skip
        push cx
        dec cx
        call get_enemy_pos
        cmp ax, bx
        je check_if_enemy_alive_loop_matched
        jmp check_if_enemy_alive_loop_did_not_match

        check_if_enemy_alive_loop_matched:
        call get_enemy_status
        pop cx
        cmp al, tank_status_dead
        je check_if_enemy_alive_skip
        cmp al, tank_status_dead_has_bullet
        je check_if_enemy_alive_skip
        jmp check_if_enemy_alive_dead

        check_if_enemy_alive_loop_did_not_match:
        pop cx
        check_if_enemy_alive_skip:
    loop check_if_enemy_alive_loop

    dec dx
    mov cx, dx; cx - index
    call get_enemy_tank_sprite
    mov cx, ax; cx - desired sprite

    mov ax, bx; ax - pos
    call get_element_on_screen
    cmp cx, dx
    jne check_if_enemy_alive_dead
    mov bx, 1
    jmp check_if_enemy_alive_end

    check_if_enemy_alive_dead:
    mov bx, 0
    jmp check_if_enemy_alive_end

    check_if_enemy_alive_end:
    pop cx
    pop dx
    pop ax
    ret
endp

update_enemy_move_up proc; cx - enemy_index; output: bl - success flag
    push cx
    push di
    push ax
    push dx

    mov di, cx
    call get_enemy_pos
    mov dx, ax; dx - old pos
    mov bl, direction_up
    call get_new_pos
    mov cx, dx; cx - old pos, ax - new_pos
    call get_element_on_screen
    cmp dx, ground
    je update_enemy_move_up_fine
    cmp dx, wall
    je update_enemy_move_up_shoot
    mov bl, 0
    jmp update_enemy_move_up_end

    update_enemy_move_up_shoot:
    mov cx, di
    call update_enemy_shoot_up
    jmp update_enemy_move_up_end

    update_enemy_move_up_fine:
    push ax
    mov ax, cx
    call erase
    pop ax; ax - new_pos
    mov cx, di; cx - enemy_index
    call store_enemy_pos
    mov al, direction_up
    call store_enemy_direction
    mov bl, 1
    jmp update_enemy_move_up_end

    update_enemy_move_up_end:
    pop dx
    pop ax
    pop di
    pop cx
    ret
endp

update_enemy_move_down proc; cx - enemy_index; output: bl - success flag
    push cx
    push di
    push ax
    push dx

    mov di, cx
    call get_enemy_pos
    mov dx, ax; dx - old pos
    mov bl, direction_down
    call get_new_pos
    mov cx, dx; cx - old pos, ax - new_pos
    call get_element_on_screen
    cmp dx, ground
    je update_enemy_move_down_fine
    cmp dx, wall
    je update_enemy_move_down_shoot
    mov bl, 0
    jmp update_enemy_move_down_end

    update_enemy_move_down_shoot:
    mov cx, di
    call update_enemy_shoot_down
    jmp update_enemy_move_down_end

    update_enemy_move_down_fine:
    push ax
    mov ax, cx
    call erase
    pop ax; ax - new_pos
    mov cx, di; cx - enemy_index
    call store_enemy_pos
    mov al, direction_down
    call store_enemy_direction
    mov bl, 1
    jmp update_enemy_move_down_end

    update_enemy_move_down_end:
    pop dx
    pop ax
    pop di
    pop cx
    ret
endp

update_enemy_move_left proc; cx - enemy_index; output: bl - success flag
    push cx
    push di
    push ax
    push dx

    mov di, cx
    call get_enemy_pos
    mov dx, ax; dx - old pos
    mov bl, direction_left
    call get_new_pos
    mov cx, dx; cx - old pos, ax - new_pos
    call get_element_on_screen
    cmp dx, ground
    je update_enemy_move_left_fine
    cmp dx, wall
    je update_enemy_move_left_shoot
    mov bl, 0
    jmp update_enemy_move_left_end

    update_enemy_move_left_shoot:
    mov cx, di
    call update_enemy_shoot_left
    jmp update_enemy_move_left_end

    update_enemy_move_left_fine:
    push ax
    mov ax, cx
    call erase
    pop ax; ax - new_pos
    mov cx, di; cx - enemy_index
    call store_enemy_pos
    mov al, direction_left
    call store_enemy_direction
    mov bl, 1
    jmp update_enemy_move_left_end

    update_enemy_move_left_end:
    pop dx
    pop ax
    pop di
    pop cx
    ret
endp

update_enemy_move_right proc; cx - enemy_index; output: bl - success flag
    push cx
    push di
    push ax
    push dx

    mov di, cx; di - enemy index
    call get_enemy_pos
    mov dx, ax; dx - old enemy pos
    mov bl, direction_right
    call get_new_pos
    mov cx, dx; cx - old pos, ax - new_pos
    call get_element_on_screen
    cmp dx, ground
    je update_enemy_move_right_fine
    cmp dx, wall
    je update_enemy_move_right_shoot
    mov bl, 0
    jmp update_enemy_move_right_end

    update_enemy_move_right_shoot:
    mov cx, di
    call update_enemy_shoot_right
    jmp update_enemy_move_right_end

    update_enemy_move_right_fine:
    push ax
    mov ax, cx
    call erase
    pop ax; ax - new_pos
    mov cx, di; cx - enemy_index
    call store_enemy_pos
    mov al, direction_right
    call store_enemy_direction
    mov bl, 1
    jmp update_enemy_move_right_end

    update_enemy_move_right_end:
    pop dx
    pop ax
    pop di
    pop cx
    ret
endp

update_enemy_shoot_up proc; cx - enemy_index; output: bl - success flag
    push ax

    call get_enemy_status
    cmp al, tank_status_can_shoot
    jne update_enemy_shoot_up_fail

    call get_enemy_pos
    call erase
    call set_enemy_bullet_pos
    mov bl, direction_up
    call set_enemy_bullet_direction
    mov al, tank_status_can_not_shoot
    call store_enemy_status
    mov al, direction_up
    call store_enemy_direction

    inc cx
    call update_enemy_bullet
    dec cx

    mov bl, 1
    jmp update_enemy_shoot_up_end

    update_enemy_shoot_up_fail:
    mov bl, 0
    jmp update_enemy_shoot_up_end

    update_enemy_shoot_up_end:
    pop ax
    ret
endp

update_enemy_shoot_down proc; cx - enemy_index; output: bl - success flag
    push ax

    call get_enemy_status
    cmp al, tank_status_can_shoot
    jne update_enemy_shoot_down_fail

    call get_enemy_pos
    call erase
    call set_enemy_bullet_pos
    mov bl, direction_down
    call set_enemy_bullet_direction
    mov al, tank_status_can_not_shoot
    call store_enemy_status
    mov al, direction_down
    call store_enemy_direction

    inc cx
    call update_enemy_bullet
    dec cx

    mov bl, 1
    jmp update_enemy_shoot_down_end

    update_enemy_shoot_down_fail:
    mov bl, 0
    jmp update_enemy_shoot_down_end

    update_enemy_shoot_down_end:
    pop ax
    ret
endp

update_enemy_shoot_left proc; cx - enemy_index; output: bl - success flag
    push ax

    call get_enemy_status
    cmp al, tank_status_can_shoot
    jne update_enemy_shoot_left_fail

    call get_enemy_pos
    call erase
    call set_enemy_bullet_pos
    mov bl, direction_left
    call set_enemy_bullet_direction
    mov al, tank_status_can_not_shoot
    call store_enemy_status
    mov al, direction_left
    call store_enemy_direction

    inc cx
    call update_enemy_bullet
    dec cx

    mov bl, 1
    jmp update_enemy_shoot_left_end

    update_enemy_shoot_left_fail:
    mov bl, 0
    jmp update_enemy_shoot_left_end

    update_enemy_shoot_left_end:
    pop ax
    ret
endp

update_enemy_shoot_right proc; cx - enemy_index; output: bl - success flag
    push ax

    call get_enemy_status
    cmp al, tank_status_can_shoot
    jne update_enemy_shoot_right_fail

    call get_enemy_pos
    call erase
    call set_enemy_bullet_pos
    mov bl, direction_right
    call set_enemy_bullet_direction
    mov al, tank_status_can_not_shoot
    call store_enemy_status
    mov al, direction_right
    call store_enemy_direction

    inc cx
    call update_enemy_bullet
    dec cx

    mov bl, 1
    jmp update_enemy_shoot_right_end

    update_enemy_shoot_right_fail:
    mov bl, 0
    jmp update_enemy_shoot_right_end

    update_enemy_shoot_right_end:
    pop ax
    ret
endp

update_enemy_shoot_horizontal proc;cx - enemy_index; output: bl - success flag
    push ax

    call get_player_pos
    mov bx, ax
    call get_enemy_pos
    cmp al, bl;al - enemy_x, bl - player_x
    jb update_enemy_shoot_horizontal_right

    call update_enemy_shoot_left
    jmp update_enemy_shoot_horizontal_end

    update_enemy_shoot_horizontal_right:
    call update_enemy_shoot_right
    jmp update_enemy_shoot_horizontal_end

    update_enemy_shoot_horizontal_end:
    pop ax
    ret
endp

update_enemy_shoot_vertical proc;cx - enemy_index; output: bl - success flag
    push ax
    call get_player_pos
    mov bx, ax
    call get_enemy_pos
    cmp ah, bh;ah - enemy_x, bh - player_x
    jb update_enemy_shoot_vertical_down

    call update_enemy_shoot_up
    jmp update_enemy_shoot_vertical_end

    update_enemy_shoot_vertical_down:
    call update_enemy_shoot_down
    jmp update_enemy_shoot_vertical_end

    update_enemy_shoot_vertical_end:
    pop ax
    ret
endp

update_enemy_horizontal_action proc; cx - enemy_index, al - final_flag
    push ax
    push bx
    push ax

    call get_player_pos
    mov bx, ax
    call get_enemy_pos

    cmp al, bl; bl - player, al - enemy
    je update_enemy_horizontal_action_to_shoot
    ja update_enemy_horizontal_action_left
    jmp update_enemy_horizontal_action_right

    update_enemy_horizontal_action_left:
    call update_enemy_move_left
    cmp bl, 1
    je update_enemy_horizontal_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_horizontal_action_end
    mov al, 1
    call update_enemy_vertical_action
    jmp update_enemy_horizontal_action_end

    update_enemy_horizontal_action_right:
    call update_enemy_move_right
    cmp bl, 1
    je update_enemy_horizontal_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_horizontal_action_end
    mov al, 1
    call update_enemy_vertical_action
    jmp update_enemy_horizontal_action_end

    update_enemy_horizontal_action_to_shoot:
    call update_enemy_shoot_vertical
    cmp bl, 1
    je update_enemy_horizontal_action_end_pop
    pop ax
    cmp al, 1
    je update_enemy_horizontal_action_end
    mov al, 1
    call update_enemy_vertical_action
    jmp update_enemy_horizontal_action_end

    update_enemy_horizontal_action_end_pop:
    pop ax
    update_enemy_horizontal_action_end:
    pop bx
    pop ax
    ret
endp

update_enemy_status_dead proc; cx - enemy_index
    push ax

    call get_enemy_status
    cmp al, tank_status_can_shoot
    je update_enemy_status_dead_has_no_bullet
    cmp al, tank_status_can_not_shoot
    je update_enemy_status_dead_has_bullet
    jmp update_enemy_status_dead_end

    update_enemy_status_dead_has_bullet:
    mov al, tank_status_dead_has_bullet
    call store_enemy_status
    jmp update_enemy_status_dead_end

    update_enemy_status_dead_has_no_bullet:
    mov al, tank_status_dead
    call store_enemy_status
    jmp update_enemy_status_dead_end

    update_enemy_status_dead_end:
    call get_enemy_pos
    call erase
    pop ax
    ret
endp

update_enemy proc; cx - enemy number
    push cx
    push ax
    push bx

    dec cx; turn number to index

    call get_enemy_status
    cmp al, tank_status_dead
    je update_enemy_dead_end
    cmp al, tank_status_dead_has_bullet
    je update_enemy_dead_end

    call check_if_enemy_alive
    cmp bx, 1
    je update_enemy_alive
    call update_enemy_status_dead
    jmp update_enemy_dead_end

    update_enemy_alive:

    call get_distance_to_player
    cmp ah, al
    ja update_enemy_horizontal
    jmp update_enemy_vertical

    update_enemy_vertical:
    mov al, 0
    call update_enemy_vertical_action
    jmp update_enemy_end

    update_enemy_horizontal:
    mov al, 0
    call update_enemy_horizontal_action
    jmp update_enemy_end


    update_enemy_end:
    call draw_enemy
    update_enemy_dead_end:
    pop bx
    pop ax
    pop cx
    ret
endp

update_enemies proc
    push cx

    mov cx, enemies_count
    update_enemies_loop:
        call update_enemy
    loop update_enemies_loop

    update_enemies_end:
    pop cx
    ret
endp

get_time_elapsed_since_start proc; cx:dx - result
    push ax
    push es

    mov ax, 0
    mov es, ax

    mov cx, es:[46Ch]
    mov dx, es:[46Eh]

    get_time_elapsed_since_start_end:
    pop es
    pop ax
    ret
endp

reset_counter proc
    push cx ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push dx ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)
    push ax ;сохраняем в стек регистр ax(всегда это делаем с регистрами, с которыми будем работать, тк в них могут быть нужные нам значения)

    mov ax, 0 ;заносим в ax 0
    mov es, ax ;заносим в es ax

    mov word ptr es:[46Eh], 0 ;сбрасываем счётчики времени перед началом игры в 0
    mov word ptr es:[46Ch], 0 ;сбрасываем счётчики времени перед началом игры в 0

    reset_counter_end:
    pop ax ;достаём из стека то, что положили вначале опроцедуры
    pop dx ;достаём из стека то, что положили вначале опроцедуры
    pop cx ;достаём из стека то, что положили вначале опроцедуры
    ret ;завершаем процедуру(команда выполняет корректный выход из процедуры)
endp ;завершаем процедуру

store_int proc; dx - value, di - pointer; output: di - new pointer
    push ax
    push dx
    push bx

    mov ax, dx
    store_int_loop:
        mov dx, 0
        mov bx, 10
        div bx
        add dx, '0'
        push ax
        mov ax, dx
        mov ah, 07h
        stosw
        pop ax
        cmp ax, 0
    ja store_int_loop


    store_int_end:
    pop bx
    pop dx
    pop ax
    ret
endp

log_current_time proc
    push cx
    push dx
    push ax
    push di
    push es
    push bx

    mov ax, ds
    mov es, ax

    call get_time_elapsed_since_start; cx:dx
    mov ax, cx
    mov bx, 40
    mul bx
    mov bx, 12
    div bx
    mov bx, 60
    mov dx, 0
    div bx; ax - minutes, dx - seconds
    mov dx, 0
    div bx

    std

    mov di, offset screen
    add di, max_x * 2
    push ax
    mov ah, 07h
    mov al, 's'
    stosw

    call store_int

    mov ah, 07h
    mov al, ' '
    stosw
    mov al, 'm'
    stosw

    pop ax
    mov dx, ax
    call store_int

    mov ax, empty
    mov cx, 5
    rep stosw

    cld

    log_current_time_end:
    pop bx
    pop es
    pop di
    pop ax
    pop dx
    pop cx
    ret
endp

victory proc
    push ax
    push es
    push ds
    push cx
    push di
    push si

    mov ax, ds
    mov es, ax
    mov cx, screen_size
    mov ax, green_space
    mov di, offset screen
    rep stosw

    mov cx, victory_word_size
    mov ah, screen_heigth / 2
    mov al, screen_width / 2
    sub al, (victory_word_size / 2) + 1
    call get_offset_on_screen
    mov di, offset screen
    add di, ax
    mov si, offset victory_word
    rep movsw

    call update_screen
    victory_end:
    pop si
    pop di
    pop cx
    pop ds
    pop es
    pop ax
    ret
endp

fail proc
    push ax
    push es
    push ds
    push cx
    push di
    push si

    mov ax, ds
    mov es, ax
    mov cx, screen_size
    mov ax, red_space
    mov di, offset screen
    rep stosw

    mov cx, fail_word_size
    mov ah, screen_heigth / 2
    mov al, screen_width / 2
    sub al, (fail_word_size / 2) + 1
    call get_offset_on_screen
    mov di, offset screen
    add di, ax
    mov si, offset fail_word
    rep movsw

    call update_screen
    fail_end:
    pop si
    pop di
    pop cx
    pop ds
    pop es
    pop ax
    ret
endp

game_loop proc
    call reset_counter ;процедура сброса счётчиков

    game_loop_loop:
        call get_desired_action ;функция получения желаемого действия
        cmp desired_action, exit ;сравниваем desired_action, которое установилось в процедуре get_desired_action с нашим кодом exit
        je game_loop_end ;если совпадает, то переходим к метке game_loop_end и выходим из процедуры

        call update_bullets ;обновление пуль врагов и игрока

        call update_player
        call update_enemies

        call log_current_time

        call update_screen

        cmp destroyed_base, 1
        je game_loop_victory

        cmp player_killed, 1
        je game_loop_fail

        delay

    jmp game_loop_loop

    game_loop_victory:
    call victory
    long_delay
    jmp game_loop_end

    game_loop_fail:
    call fail
    long_delay
    jmp game_loop_end

    game_loop_end:
    ret
endp

start:
    mov ax, @data
    mov ds, ax
    mov es, ax

    call set_video_mode ;установить видеорежим

    call init ;инициализация врагов и игрока

    call game_loop

    call set_video_mode

start_end:
    mov ax, 4C00h
    int 21h
end start

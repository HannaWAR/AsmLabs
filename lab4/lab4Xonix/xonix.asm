.model small
.stack 400h
.386
.data
    field db 2000 dup(0)
    land db 00100000B
    road db 00110000B
    sea db 00010000B
    whiteText db 00010111B
    w db 80
    wWord dw 80
    wm db 79
    h db 25
    hWord dw 25
    hm db 24
    levelFileName db 'XONIXL.TXT' , 0
    readBuffer db 9 dup(' ')
    readSize db 9
    convertRes db ?
    timeout dw 86A0h
    moveDirection db 4Dh
    currentPos dw 0000h
    enemiesCount dw 4
    enemiesDirections dw 257 , 511
    enemiesPos dw 0D14h , 0D3Bh
    minutes db 0
    seconds db 0
    timeCounter dw 0
    ten db 10
    pointsLimit dw 1400
    points dw 0
    pointsShift dw 404
    enemiesMaps dw 0 , 0
    numbersMask db 2000 dup(0)
    maxNumber db 0
    shieldPart db '            '
    gameoverMessage db ' GAME  OVER '
    gameoverText db 10001100B
    winMessage db '  YOU  WON  '
    winText db 10001010B
.code

proc hideCursor near;сокрытие курсора
    pusha
    mov ah , 02
    mov bh , 00
    mov dh , 25
    int 10h
    popa
    ret
endp

proc coordsToAddress near;получаем смещение для элемента с координатами (dl , dh)
;   dh - y
;   dl - x
;   si - res

    push ax
    push cx

    mov al , dh;заносим y
    cbw
    mul w
    xor ch , ch
    mov cl , dl ;заносим х
    add ax , cx ;добавляем к значению y, умноженного на длину строки, элемент в данной строке
    mov si , ax

    pop cx
    pop ax
    ret
endp

proc printFromField near
;   dh - y
;   dl - x
;
    pusha

    mov ah , 02;установить плоложение курсора
    xor bh , bh;bh-стр dh-строка
    int 10h

    call coordsToAddress

    mov ah , 09             ; писать символ в текущей позиции курсора
    mov al , ' '            ; записываемый символ
    mov bl , [field + si]   ;видео атрибут (текст) или цвет (графика)
    mov cx , 1              ; счетчик (сколько экземпляров символа записать)
    int 10h

    call hideCursor

    popa
    ret
endp

proc setToField near
;   dh - y
;   dl - x
;   al - value
    pusha

    mov ah , 02
    xor bh , bh
    int 10h

    call coordsToAddress

    mov [si] , al

    popa
    ret
endp

proc clearKeyboardBuffer near   ;очистить буффер клавиатуры

    push ax
    push es
    push bx
    mov bx , 041eh
    mov	ax, 0000h
    mov	es, ax
    mov	es:[041ah], bx  ;хранится адрес начала
    mov	es:[041ch], bx  ;хранится адрес конца
    pop bx
    pop	es
    pop	ax

    ret
endp

proc printTime near ; вывести время
    pusha

    mov cx , 10

    mov ax , [timeCounter]
    xor dx , dx

    div cx

    mov dl , 60
    div dl

    mov [minutes] , al
    mov [seconds] , ah

    xor bh , bh
    mov bl , [whiteText]
    mov cx , 1

    xor ah , ah
    mov al , [minutes]
    div [ten]

    mov dx , ax
    add dx , '00'

    pusha
    xor dh , dh
    mov dl , 75
    mov ah , 02
    xor bh , bh
    int 10h
    popa
    mov ah , 09h
;   старший р. минуты
    mov al , dl
    int 10h

    pusha
    xor dh , dh
    mov dl , 76
    mov ah , 02
    xor bh , bh
    int 10h
    popa
;   младший р. минуты
    mov al , dh
    int 10h

    pusha
    xor dh , dh
    mov dl , 77
    mov ah , 02
    xor bh , bh
    int 10h
    popa

    mov al , ':'
    int 10h

    xor ah , ah
    mov al , [seconds]
    div [ten]

    mov dx , ax
    add dx , '00'

    pusha
    xor dh , dh
    mov dl , 78
    mov ah , 02
    xor bh , bh
    int 10h
    popa
    mov ah , 09h
;   старший р. секунды
    mov al , dl
    int 10h

    pusha
    xor dh , dh
    mov dl , 79
    mov ah , 02
    xor bh , bh
    int 10h
    popa
;   младший р. секунды
    mov al , dh
    int 10h

    call hideCursor

    popa
    ret
endp


proc numberFromBuffer near ; конвертация файловых строк в числа
    pusha                  ; поместить в стек значения всех 16-битных регистров общего назначения

    xor si , si
    xor ax , ax
    xor bh , bh

    convertLoop:

    mov bl , [readBuffer + si]
    sub bl , '0'                ;преобразуем в число
    shl al , 1                  ;Инструкция SHL (сдвиг влево, синоним - SAL) перемещает  каждый бит операнда-приемника на один разряд влево, по направлению к самому  значащему  биту.
    add al , bl                 ;;100101101 , bl=1 , al=0*2=0 , al+=dl

    inc si

    cmp si , 8
    jb convertLoop

    mov [convertRes] , al

    popa
    ret
endp


proc printField near    ; печатает поле на экран
    pusha

    xor dx , dx
    fieldPrintRows:
        fieldPrintColumns:

        call printFromField

        inc dl      ;х
        cmp dl , w
        jb fieldPrintColumns

    xor dl , dl
    inc dh
    cmp dh , h
    jne fieldPrintRows

    popa
    ret
endp

proc loadLevel near ; загрузка уровня из файла
    pusha

    mov ah , 3dh            ; функция открытия файла
    xor al , al             ; читать
    xor cl , cl             ;
    lea dx , levelFileName  ;
    int 21h

    mov bx , ax
    xor ch , ch
    mov cl , [readSize]
    lea dx , [readBuffer]

    xor si , si
    fileReadLoop:

    mov ah , 3fh            ; функция чтения файла
    int 21h

    call numberFromBuffer

    mov ah , [convertRes]
    mov [field + si] , ah

    inc si
    cmp si , 2000
    jb fileReadLoop


    popa
    ret
endp

proc printXonix near    ; отрисовывает xonix в текущей позиции
    pusha

    mov ah , 02         ; установка позиции курсора
    xor bh , bh
    int 10h

    mov ah , 09         ; писать символ в текущей позиции курсора
    mov al , ' '        ; записываемый символ
    mov bl , 01110000B  ; атрибуты символа
    mov cx , 1          ; 1 символ
    int 10h

    call hideCursor

    popa
    ret
endp

proc printEnemy near    ;отрисовка врага
    pusha

    mov ah , 02         ;перемещение курсора
    xor bh , bh         ;
    int 10h             ;

    mov ah , 09         ;вывод красного пробела
    mov al , ' '        ;
    mov bl , 01000000B  ;
    mov cx , 1          ;
    int 10h             ;

    call hideCursor

    popa
    ret
endp

proc calcScore near ;считаем очки
    pusha

    xor dx , dx

    xor si , si
    calcScoreLoop:

    mov ah , [field + si]
    cmp ah , [sea]
    jne notSea

    inc dx

    notSea:
    inc si
    cmp si , 2000
    jb calcScoreLoop

    sub dx , [pointsShift]

    mov [points] , dx

    popa
    ret
endp

proc printScore near    ; подсчет и вывод кол-ва очков через стэк
    pusha

    call calcScore

    mov bx , 10
    mov ax , [pointsLimit]

    mov cx , 4

    divLimitLoop:

    xor dx , dx
    div bx
    add dl , '0'
    push dx

    loop divLimitLoop

    xor dh , dh
    mov dl , '\'
    push dx

    mov ax , [points]
    mov cx , 4

    divPointsLoop:

    xor dx , dx
    div bx
    add dl , '0'
    push dx

    loop divPointsLoop

    xor di , di

    mov bl , [whiteText]    ; белый текст на синем фоне
    xor bh , bh             ; страница 0

    mov cx , 1              ; 1 символ

    printScoreLoop:

    pusha
    mov dx , di
    mov ah , 02
    xor bh , bh
    int 10h
    popa

    pop dx
    mov ah , 09h
    mov al , dl
    int 10h

    inc di
    cmp di , 9
    jb printScoreLoop

    call hideCursor

    popa
    ret
endp

proc remap near
;   заменить все символы с номером сh на номер bh в numbersMask
    pusha

    xor si , si
    remapLoop:

    mov cl , [numbersMask + si]
    cmp cl , ch
    jne remapFinished

    mov [numbersMask + si] , bh

    remapFinished:

    inc si
    cmp si , 2000
    jb remapLoop

    popa
    ret
endp

proc initMask near  ; заполнение массива-маски
    pusha

    mov dx , 0101h
    maskInitRows:
        maskInitColumns:

        call coordsToAddress

        mov al , [field + si]
        cmp al , [land]
        jne maskItemFinish

        mov ah , [numbersMask + si]     ; A
        mov bh , [numbersMask + si - 1] ; B

        sub si , [wWord]                ; Смещаемся вверх
        mov ch , [numbersMask + si]     ; C
        add si , [wWord]                ; смещаемся обратно

        cmp ch , 0
        jne notCase2
        cmp bh , 0
        jne notCase2

        mov ah , [maxNumber]        ; записать в ah максимальный номер участка
        inc ah
        mov [maxNumber] , ah
        mov [numbersMask + si] , ah

        jmp maskItemFinish
        notCase2:

        cmp ch , 0
        jne notCase4
        cmp bh , 0
        je notCase4

        mov [numbersMask + si] , bh

        jmp maskItemFinish
        notCase4:

        cmp bh , 0
        jne notCase3
        cmp ch , 0
        je notCase3

        mov [numbersMask + si] , ch

        jmp maskItemFinish
        notCase3:

        cmp bh , 0
        je notCase5
        cmp ch , 0
        je notCase5
        cmp ch , bh
        je equals

        call remap

        equals:

        mov [numbersMask + si] , bh

        notCase5:
        maskItemFinish:

        inc dl
        cmp dl , [w]
        jb maskInitColumns

    mov dl , 1
    inc dh
    cmp dh , [h]
    jne maskInitRows

    popa
    ret
endp

proc initEnemiesNumbers near    ;запомнить номера областей с врагами
    pusha

    xor di , di
    enemiesNumbers:

    mov dx , [enemiesPos + di]
    call coordsToAddress

    mov al , [numbersMask + si]
    xor ah , ah

    mov [enemiesMaps + di] , ax
    add di , 2
    cmp di , [enemiesCount]
    jb enemiesNumbers

    popa
    ret
endp

proc autofill near  ;заполнение синим
    pusha

    mov dx , 0101h
    fillRows:
        fillColumns:

        call coordsToAddress

        mov bl , [numbersMask + si]

        cmp bl , 0
        je notFilling

        xor di , di

        enemiesFill:

            mov ax , [enemiesMaps + di]

            cmp bl , al
            je fillFinished

            add di , 2
            cmp di , [enemiesCount]
            jb enemiesFill
        ; если в этой области нету врагов
        mov bh , [sea]
        mov [field + si] , bh

        fillFinished:

        xor al , al                     ; обнуляем маску на текущем элементе
        mov [numbersMask + si ] , al    ;

        notFilling:

        inc dl
        cmp dl , w
        jb fillColumns

    mov dl , 1
    inc dh
    cmp dh , h
    jne fillRows

    popa
    ret
endp

proc fill near  ; заполнение дороги и свободных областей
    pusha

    mov dx , [currentPos]
    mov ch , [road]

    inc dh

    call coordsToAddress
    cmp ch , [si]
    je fillPermited

    sub dh , 2

    call coordsToAddress
    cmp ch , [si]
    je fillPermited

    inc dh
    dec dl

    call coordsToAddress
    cmp ch , [si]
    je fillPermited

    add dl , 2

    call coordsToAddress
    cmp ch , [si]
    je fillPermited

    jmp fillEnd
    fillPermited:

    xor si , si
    fillLoop:

    mov cl , [field + si]
    mov ch , [sea]
    cmp cl , [road]
    jne fillNotRoad
    mov [field + si] , ch

    fillNotRoad:
    inc si
    cmp si , 2000
    jb fillLoop

    call initMask
    call initEnemiesNumbers
    call autofill
    call printField

    fillEnd:
    popa
    ret
endp

proc moveXonix near;движение xonixа по спец алгоритму
    push ax
    push dx

    mov ah , [moveDirection]
    mov dx , [currentPos]
;     Up
    cmp ah , 48h
    jne moveNotUp
        cmp dh , 0
        je endXonixMove
        dec dh
        jmp endXonixMove

    moveNotUp:
;     Left
    cmp ah , 4Bh
    jne moveNotLeft
        cmp dl , 0
        je endXonixMove
        dec dl
        jmp endXonixMove

    moveNotLeft:
;     Right
    cmp ah , 4Dh
    jne moveNotRight
        cmp dl , wm
        je endXonixMove
        inc dl
       jmp endXonixMove

    moveNotRight:
;     Down
    cmp ah , 50h
    jne moveNotDown
        cmp dh , hm
        je endXonixMove
        inc dh
        jmp endXonixMove

    moveNotDown:
    endXonixMove:

    mov [currentPos] , dx

    call printXonix

    pop dx
    pop ax

    ret
endp

proc moveEnemies near   ;движение врага по спец алгоритму
;   dh - y
;   dl - x
;   bh - y
;   bl - x
    pusha

    xor di , di

    enemyLoopMain:

    mov dx , [enemiesPos + di]

    mov bx , [enemiesDirections + di]
;     Horizontal
    add dl , bl
;   Можно ли продолжать двигаться дальше
    call coordsToAddress
    mov cl , [field + si]
    cmp cl , [sea]
    jne moveHorizontalGood
;   Пытаемся отразить
    neg bl      ;отражение

    add dl , bl
    add dl , bl

    call coordsToAddress
    mov cl , [field + si]
    cmp cl , [sea]
    jne moveHorizontalGood
;   По этой оси больше двигаться нельзя
    sub dl , bl
    xor bl , bl

    moveHorizontalGood:
;     Vertical
    add dh , bh
;   Можно ли продолжать двигаться дальше
    call coordsToAddress
    mov cl , [field + si]
    cmp cl , [sea]
    jne moveVerticalGood
;   Пытаемся отразить
    neg bh

    add dh , bh
    add dh , bh

    call coordsToAddress
    mov cl , [field + si]
    cmp cl , [sea]
    jne moveVerticalGood
;   По этой оси больше двигаться нельзя
    sub dh , bh
    xor bh , bh

    moveVerticalGood:

    mov [enemiesDirections + di] , bx
    mov [enemiesPos + di] , dx

    call printEnemy

    add di , 2

    cmp di , enemiesCount
    jb enemyLoopMain

    popa
    ret
endp

proc move near  ;функции. отвечающие за движение
    call moveXonix
    call moveEnemies
    ret
endp

proc level near
    pusha

    mainLevelLoop:

    mov ah , 01             ; проверка наличия символа в буффере
    int 16h                 ;

    call clearKeyboardBuffer

;     Esc to exit
    cmp al , 1Bh
    je gameOver

    mov dx , [currentPos]

    call coordsToAddress

    mov bl , [field + si]

    cmp bl , land
    jne levelNotLand
    mov bl , road
    mov [field + si] , bl
    levelNotLand:

    call printField


;     Up
    cmp ah , 48h
    jne levelNotUp
        mov [moveDirection] , ah

    levelNotUp:
;     Left
    cmp ah , 4Bh
    jne levelNotLeft
        mov [moveDirection] , ah

    levelNotLeft:
;     Right
    cmp ah , 4Dh
    jne levelNotRight
       mov [moveDirection] , ah

    levelNotRight:
;     Down
    cmp ah , 50h
    jne levelNotDown
        mov [moveDirection] , ah

    levelNotDown:

    call move

    call printScore

    mov ax , [points]
    cmp ax , [pointsLimit]
    jae win

    mov ax , [timeCounter]
    inc ax
    cmp ax , 36000
    jb timeOk
    xor ax , ax

    timeOk:
    mov [timeCounter] , ax

    call printTime

    xor di , di
    checkEnemiesLoop:

    mov dx , [enemiesPos + di]

    cmp dx , currentPos
    je gameOver

    call coordsToAddress
    mov bl , [field + si]
    cmp bl , road
    je gameOver

    add di , 2
    cmp di , enemiesCount
    jb checkEnemiesLoop
    ;если мы на море то превратить дорогу в море
    mov dx , [currentPos]
    call coordsToAddress
    mov bl , [field + si]
    cmp bl , sea
    jne mainLevelLoopWait

    call fill

    mainLevelLoopWait:

    mov ah , 86h
    mov cx , 0
    mov dx , 45000
    int 15h
    nop
    nop
    nop
    nop
    ;mov ah , 86h
    ;mov cx , 0
    ;mov dx , 45000
    ;int 15h

    jmp mainLevelLoop
    gameOver:

    mov ax , @data
    mov es , ax

    mov ah , 13h
    xor al , al
    xor bh , bh
    mov bl , [gameoverText]
    mov cx , 12
    mov dl , 34

    lea bp , shieldPart
    mov dh , 0Ch
    int 10h

    lea bp , gameoverMessage
    mov dh , 0Dh
    int 10h

    lea bp , shieldPart
    mov dh , 0Eh
    int 10h

    xor ah , ah
    int 16h

    jmp levelEnd
    win:

    mov ax , @data
    mov es , ax

    mov ah , 13h
    xor al , al
    xor bh , bh
    mov bl , [winText]
    mov cx , 12
    mov dl , 34

    lea bp , shieldPart
    mov dh , 0Ch
    int 10h

    lea bp , winMessage
    mov dh , 0Dh
    int 10h

    lea bp , shieldPart
    mov dh , 0Eh
    int 10h

    xor ah , ah
    int 16h

    jmp levelEnd
    levelEnd:
    popa
    ret
endp

start:
    mov ax , @data
    mov ds , ax

    call loadLevel

;   Set 16-color text mode ( 25 x 80 )
    mov ah , 00
    mov al , 03
    int 10h

    mov dx , 0a30h
    call printField

    call level

    mov    ah,4ch
    int    21h
end start

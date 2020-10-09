;Игра "Змейка"


;macro HELP
endd MACRO
	mov ah, 4ch
	int 21h
ENDM

clearScreen MACRO
	push ax
	mov ax, 0003h
	int 10h
	pop ax
ENDM
;end macro help

.model small

.stack 100h

.data

;key bindings (configuration)
KUpSpeed equ 48h		;Up key
KDownSpeed equ 50h	;Down key
KMoveUp equ 11h		;W key
KMoveDown equ 1Fh	;S key
KMoveLeft equ 1Eh	;A key
KMoveRight equ 20h	;D key
KExit equ 01h 		;ESC key

xSize equ 80
ySize equ 25
xField equ 50
yField equ 21
oneMemoBlock equ 2
scoreSize equ 4

videoStart dw 0B800h
dataStart dw 0000h
timeStart dw 0040h
timePosition dw 006Ch

space equ 0020h
snakeBodySymbol equ 0A40h
appleSymbol equ 0B0Fh
VWallSymbol equ 0FBAh
HWallSymbol equ 0FCDh
VWallSpecialSymbol equ 0FCCh

fieldSpacingBad equ space, VWallSymbol, xField dup(space)
fieldSpacing equ fieldSpacingBad, VWallSymbol
rbSym equ 0CFDCh	;white block with red background
rbSpc equ 0CF20h	;space with red background
ylSym equ 06FDCh	;white block with yellow background
ylSpc equ 06F20h	;space with yellow background
grSym equ 02FDBh	;white block with green background
grSpc equ 02F20h	;space with green background

screen	dw xSize dup(space)
		dw space, 0FC9h, xField dup(HWallSymbol), 0FCBh, xSize - xField - 5 dup(HWallSymbol), 0FBBh, space
firstBl	dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), 15 dup(rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, rbSpc, rbSym, 5 dup(rbSpc), 3 dup(rbSym), 2 dup(rbSpc), 3 dup(rbSym), rbSpc, rbSym, 3 dup(rbSpc), rbSym, 2 dup(rbSpc), rbSym, rbSpc, VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, 4 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, 4 dup(rbSym), rbSpc, 2 dup(rbSym), 2 dup(rbSpc), rbSym, 4 dup(rbSpc), VWallSymbol, space
		dw fieldSpacing, rbSpc, 4 dup(rbSym), rbSpc, rbSym, 2 dup(rbSpc), rbSym, rbSpc, rbSym, 2 dup(rbSpc), 3 dup(rbSym, rbSpc), 4 dup(rbSym), rbSpc, VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(rbSpc), VWallSymbol, space
delim1	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(HWallSymbol), 0FB9h, space
secondF	dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, ylSpc, 06F53h, 06F63h, 06F6Fh, 06F72h, 06F65h, 06F3Ah, ylSpc
	score	dw scoreSize dup(06F30h), xSize - xField - scoreSize - 13 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, ylSpc, 06F53h, 06F70h, 2 dup(06F65h), 06F64h, 06F3Ah, ylSpc
	speed	dw 06F31h, 16 dup(ylSpc), VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(ylSpc), VWallSymbol, space
delim2	dw fieldSpacingBad, 0FCCh, xSize - xField - 5 dup(HWallSymbol), 0FB9h, space
thirdF	dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space
		dw fieldSpacing, grSpc, 02F4Dh, 02F61h, 02F64h, 02F65h, grSpc, 02F62h, 02F79h, 02F3Ah, 10 dup(grSpc), 02FDCh, 3 dup(grSym), 02FDCh, grSpc, VWallSymbol, space
		dw fieldSpacing, 19 dup(grSpc), grSym, 02FDDh, grSym, 02FDEh, grSym, grSpc, VWallSymbol, space
		dw fieldSpacing, 2 dup(grSpc), 02FDCh, 02FDFh, grSym, 2 dup(grSpc), 2 dup(grSym, grSpc), 02FDEh, 2 dup(grSym), grSpc, grSym, 02FDFh, 02FDDh, grSpc, 5 dup(grSym), grSpc, VWallSymbol, space
		dw fieldSpacing, 2 dup(grSpc), grSym, 02FDCh, grSym, 2 dup(grSpc), 4 dup(grSym, grSpc), grSym, 02FDFh, 02FDCh, grSpc, grSym, grSpc, 02FDFh, grSpc, grSym, grSpc, VWallSymbol, space
		dw fieldSpacing, grSpc, 2 dup(02FDCh, 2 dup(grSym, grSpc)), 2 dup(grSym), 02FDDh, grSpc, grSym, 02FDCh, grSym, grSpc, 02FDFh, grSym, 02FDCh, grSym, 02FDFh, grSpc, VWallSymbol, space
		dw fieldSpacing, xSize - xField - 5 dup(grSpc), VWallSymbol, space
		dw space, 0FC8h, xField dup(HWallSymbol), 0FCAh, xSize - xField - 5 dup(HWallSymbol), 0FBCh, space
		dw xSize dup(space)

snakeMaxSize equ 20
snakeSize db 2
PointSize equ 2

; XYh coordinates
; first position - head
snakeBody dw 1C0Ch, 1B0Ch, snakeMaxSize-1 dup(0000h)

stopVal equ 00h
forwardVal equ 01h
backwardVal equ 0FFh

Bmoveright db 01h
Bmovedown db 00h

minWaitTime equ 1
maxWaitTime equ 9
waitTime dw maxWaitTime
deltaTime equ 2

.code

main:
	mov ax, @data	;init
	mov ds, ax
	mov dataStart, ax
	mov ax, videoStart
	mov es, ax
	xor ax, ax

	clearScreen

	call initAllScreen

	call mainGame

to_close:
	;clearScreen

	endd

;more macro help

;ZF = 1 - buffer is free
;AH = scan-code
CheckBuffer MACRO
	mov ah, 01h
	int 16h
ENDM

ReadFromBuffer MACRO
	mov ah, 00h
	int 16h
ENDM

;result in cx:dx
GetTimerValue MACRO
	push ax

	mov ax, 00h
	int 1Ah

	pop ax
ENDM

;end macro help

;procedure help

initAllScreen PROC
	mov si, offset screen
	xor di, di

	mov cx, xSize*ySize
	rep movsw

	;load base snake

	xor ch, ch
	mov cl, snakeSize
	mov si, offset snakeBody

loopInitSnake:
	mov bx, [si]
	add si, PointSize

	;get pos as (bh + (bl * xSize))*oneMemoBlock
	call CalcOffsetByPoint

	mov di, bx

	mov ax, snakeBodySymbol
	stosw
	loop loopInitSnake

	call GenerateRandomApple

	ret
ENDP

;get pos as (bh + (bl * xSize))*oneMemoBlock
;input: point (x,y) in bx
;output: offser in bx
CalcOffsetByPoint PROC
	push ax dx

	xor ah, ah
	mov al, bl
	mov dl, xSize
	mul dl
	mov dl, bh
	xor dh, dh
	add ax, dx
	mov dx, oneMemoBlock	;длину каждого блока
	mul dx
	mov bx, ax

	pop dx ax
	ret
ENDP

;change snake body in array
;old last element is always saved
;delete old last element from screen
MoveSnake PROC
	push ax bx cx si di es

	mov al, snakeSize
	xor ah, ah 		;в ah - длина массива
	mov cx, ax 		;cx - счетчик кол-ва сдвигов
	mov bx, PointSize
	mul bx			;теперь получим в ax реальную позицию в памяти относительно начала массива
	mov di, offset snakeBody
	add di, ax 		;di - адрес следующего после последнего элемента массива
	mov si, di
	sub si, PointSize 			;si - адрес последнего элемента массива

	push di
	;удалить конец змейки с экрана
	mov es, videoStart
	mov bx, ds:[si]
	call CalcOffsetByPoint
	mov di, bx			;установили память, куда будем писать пробел
	mov ax, space
	stosw

	pop di

	mov es, dataStart	;для работы с данными
	std				;идем от конца к началу
	rep movsw

	mov bx, snakeBody 	;текущая позиция головы

	add bh, Bmoveright
	add bl, Bmovedown	;новая позиция головы
	mov snakeBody, bx	;сохраняем новую позицию головы
	;все тело в памяти сдвинуто

	pop es di si cx bx ax
	ret
ENDP

mainGame PROC
	push ax bx cx dx ds es

checkAndMoveLoop:

	CheckBuffer
	jnz skipJmp2
	jmp far ptr noSymbolInBuff

skipJmp2:
	ReadFromBuffer

	cmp ah, KExit		;exit key is pressed
	jne skipJmp

	jmp far ptr endLoop

skipJmp:
	cmp ah, KMoveLeft	;move left key is pressed
	je setMoveLeft

	cmp ah, KMoveRight	;move right key is pressed
	je setMoveRight

	cmp ah, KMoveUp		;move up key is pressed
	je setMoveUp

	cmp ah, KMoveDown	;move down key is pressed
	je setMoveDown

	cmp ah, KUpSpeed		;move up key is pressed
	je setSpeedUp

	cmp ah, KDownSpeed	;move down key is pressed
	je setSpeedDown

	jmp noSymbolInBuff

setMoveLeft:
	mov Bmoveright, backwardVal
	mov Bmovedown, stopVal
	jmp noSymbolInBuff

setMoveRight:
	mov Bmoveright, forwardVal
	mov Bmovedown, stopVal
	jmp noSymbolInBuff

setMoveUp:
	mov Bmoveright, stopVal
	mov Bmovedown, backwardVal
	jmp noSymbolInBuff

setMoveDown:
	mov Bmoveright, stopVal
	mov Bmovedown, forwardVal
	jmp noSymbolInBuff

setSpeedUp:
	mov ax, waitTime
	cmp ax, minWaitTime
	je noSymbolInBuff			;нельзя больше уменьшать время задержки

	sub ax, deltaTime
	mov waitTime, ax 			;записали новое значение скорости

	mov es, videoStart
	mov di, offset speed - offset screen	;получаем смещение символа скорости
	mov ax, es:[di]
	inc ax
	mov es:[di], ax

	jmp noSymbolInBuff

setSpeedDown:
	mov ax, waitTime
	cmp ax, maxWaitTime
	je noSymbolInBuff			;нельзя больше увеличивать время задержки

	add ax, deltaTime
	mov waitTime, ax 			;записали новое значение скорости

	mov es, videoStart
	mov di, offset speed - offset screen	;получаем смещение символа скорости
	mov ax, es:[di]
	dec ax
	mov es:[di], ax

	jmp noSymbolInBuff

noSymbolInBuff:
	;сдвигаем все тело
	call MoveSnake

	mov bx, snakeBody 		;в bx точка головы змеи
checkSymbolAgain:
	call CalcOffsetByPoint	;в bx смещение в памяти, соответствующее точке

	mov es, videoStart
	mov ax, es:[bx]		;в ax текущий символ в памяти es:bx (куда должна стать змейка)

	cmp ax, appleSymbol
	je AppleIsNext

	cmp ax, snakeBodySymbol
	je SnakeIsNext

	cmp ax, HWallSymbol
	je PortalUpDown

	cmp ax, VWallSymbol
	je PortalLeftRight

	cmp ax, VWallSpecialSymbol
	je PortalLeftRight

	jmp GoNextIteration

AppleIsNext:
	call incSnake
	call GenerateRandomApple
	call incScore
	jmp GoNextIteration
SnakeIsNext:
	call incSnake
	jmp endLoop
PortalUpDown:
	mov bx, snakeBody
	sub bl, yField
	cmp bl, 0		;верхняя или нижняя граница
	jg writeNewHeadPos

	;елси мы тут, следовательно это была верхняя стена
	add bl, yField*2

writeNewHeadPos:
	mov snakeBody, bx		;записываем новое значение головы
	jmp checkSymbolAgain	;и отправляем его заново на сравнение

PortalLeftRight:
	mov bx, snakeBody
	sub bh, xField
	cmp bh, 0		;левая или правая граница
	jg writeNewHeadPos

	;елси мы тут, следовательно это была верхняя стена
	add bh, xField*2
	jmp writeNewHeadPos

GoNextIteration:
	mov bx, snakeBody		;вывести новое начало змейки
	call CalcOffsetByPoint
	mov di, bx
	mov ax, snakeBodySymbol
	stosw

	call Sleep

	jmp checkAndMoveLoop

endLoop:
	;todo: end logo
	pop es ds dx cx bx ax
	ret
ENDP

Sleep PROC
	push ax bx cx dx

	GetTimerValue

	add dx, waitTime
	mov bx, dx

checkTimeLoop:
	GetTimerValue
	cmp dx, bx			;ax - current value, bx - needed value
	jl checkTimeLoop

	pop dx cx bx ax
	ret
ENDP

GenerateRandomApple PROC
	push ax bx cx dx es

loop_random:
	;считываем текущее время
	;ch - час, cl - минута, dh - секунда, dl - сотая доля секунды
	mov ah, 2Ch
	int 21h

	mov al, dl
	mul dh 				;в ax теперь число для рандома

	xor dx, dx			;чтобы не словить переполнение и получить хороший результат
	mov cx, xField
	div cx				;в dx - результат (позиция по x); в ax - еще число
	add dx, 2			;добавляем смещение от начала оси
	mov bh, dl 			;сохранили координату x

	xor dx, dx
	mov cx, yField
	div cx
	add dx, 2			;позиция по y

	mov bl, dl 			;сохранили координату y. Теперь в bx координата яблока

	call CalcOffsetByPoint
	mov es, videoStart
	mov ax, es:[bx]

	cmp ax, space
	jne loop_random		;если там всё-таки не пробел - попытаем счастье еще разок

	mov ax, appleSymbol
	mov es:[bx], ax

	pop es dx cx bx ax
	ret
ENDP

;save tail of snake if no overloading
incSnake PROC
	push ax bx di es

	mov al, snakeSize
	cmp al, snakeMaxSize
	je return

	;увеличиваем длину змейки в массиве
	inc al
	mov snakeSize, al
	dec al 				;нам для дальнейшей работы удобнее старая длина змейки

	;восстанасливаем конец
	mov bl, PointSize
	mul bl 				; получили в ax нужное для восстановления смещение в массиве

	mov di, offset snakeBody
	add di, ax 			;di указывает на точку для "восстановления"

	mov es, dataStart
	mov bx, es:[di]
	call CalcOffsetByPoint		;получили реальное смещение для восстановления

	mov es, videoStart
	mov es:[bx], snakeBodySymbol

return:
	pop es di bx ax
	ret
ENDP

incScore PROC
	push ax es si di
	mov es, videoStart
	mov cx, scoreSize 					;max pos value
	mov di, offset score + (scoreSize - 1)*oneMemoBlock - offset screen	;получаем смещение последнего символа счета

loop_score:
	mov ax, es:[di]
	cmp al, 39h			;'9' symbol
	jne nineNotNow

	sub al, 9			;ставим '0'
	mov es:[di], ax

	sub di, oneMemoBlock	;return to symbol back

	loop loop_score
	jmp return_incScore

nineNotNow:
	inc ax
	mov es:[di], ax
return_incScore:
	pop di si es ax
	ret
ENDP

;end procedure help

end main

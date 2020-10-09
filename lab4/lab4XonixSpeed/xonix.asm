.model small
.stack 100h
.386
.data

	sWidth   equ 80
	sHeight  equ 25

	maxX     equ 79
	maxY     equ 24

	alertX   equ 30
	alertY   equ 11

	alertWidth equ 18

	typeLand equ 00100000B
	typeSea  equ 00010000B
	typeRoad equ 01110000B

	typePlayer equ 01110000b
	typeEnemy  equ 01000111b

	enemiesCount equ 2

	score       dw 0
	winScore    dw 1500
	scoreOffset dw 252

	map db 2000 dup (0)

	fluidMap  db 2000 dup (0)
	nextFluid db 0

	enemyFluids dw enemiesCount dup (0)

	enemyPos     dw 0a0ah, 0d0dh
	enemyVel     dw 100000001b, 111111111b

	playerPos    dw 00000000h
	playerMovement db 1001011b

	messageGameOver db '     GAME OVER    '
	messageWin      db ' CONGRATULATIONS! '
	messagePause    db '       PAUSE      '

	messagePauseTip    db ' Esc to exit. Enter to continue '
	messagePauseColors db 07h
	                   db 03 dup (0ch)
	                   db 10 dup (07h)
					   db 05 dup (0ah)
					   db 12 dup (07h)
					   db 07h
	messagePauseTipLen dw 32
	pauseTipX          db 24
	pauseTipY          db 15

.code

generateIter macro count, data
	mov cx, count
	mov al, data
	mov ah, 00h
	rep stos byte ptr es:[di]
endm

generateMap:
	push es
	push ds
	pop es

	lea di, map
	generateIter 82, typeSea
	generateIter 76, typeLand

	mov bx, 22
	generateLoop:
		generateIter 4, typeSea
		generateIter 76, typeLand
		dec bx
		cmp bx, 00h
	jg generateLoop

	generateIter 82, typeSea

	pop es
	ret

translateOffset:
	push ax
	push cx
	push bx

	mov bl, sWidth
	mov al, dh
	mov ah, 00h
	mul bl
	mov ch, 00h
	mov cl, dl
	add ax, cx
	mov si, ax

	pop bx
	pop cx
	pop ax
	ret

drawMap:
	push ax
	mov si, 00h
	mov cx, 2000
	drawMapLoop:
		mov di, si
		shl di, 1
		mov al, ' '
		mov ah, byte ptr ds:[map + si]
		mov word ptr es:[di], ax
		inc si
	loop drawMapLoop
	pop ax
	ret

drawPlayer:
	call translateOffset
	shl si, 1
	mov ah, typePlayer
	mov al, 02h
	mov word ptr es:[si], ax
	ret

drawEnemy:
	call translateOffset
	shl si, 1

	mov ah, typeEnemy
	mov al, 00h
	mov word ptr es:[si], ax
	ret

handleMove:
	push ax
	push dx

	mov ah, playerMovement
	mov dx, playerPos

	cmp ah, 48h
	je handleMoveUp

	cmp ah, 4bh
	je handleMoveLeft

	cmp ah, 4dh
	je handleMoveRight

	cmp ah, 50h
	je handleMoveDown

	jmp handleMoveDone

	handleMoveUp:
		cmp dh, 00h
		je handleMoveDone

		dec dh
		jmp handleMoveDone

	handleMoveLeft:
		cmp dl, 00h
		je handleMoveDone

		dec dl
		jmp handleMoveDone

	handleMoveRight:
		cmp dl, maxX
		je handleMoveDone

		inc dl
		jmp handleMoveDone

	handleMoveDown:
		cmp dh, maxY
		je handleMoveDone

		inc dh
		jmp handleMoveDone

	handleMoveDone:
		mov playerPos, dx
		call drawPlayer
	pop dx
	pop ax
	ret

updateEnemy:
	push di

	add dl, bl
	call translateOffset
	mov cl, [map + si]

	cmp cl, typeSea
	jne updateEnemyVertical

	neg bl
	add dl, bl
	add dl, bl
	call translateOffset
	mov cl, [map + si]
	cmp cl, typeSea
	jne updateEnemyVertical

	sub dl, bl
	mov bl, 00h

	updateEnemyVertical:
		add dh, bh
		call translateOffset
		mov cl, [map + si]
		cmp cl, typeSea
		jne updateEnemyDone

		neg bh
		add dh, bh
		add dh, bh
		call translateOffset
		mov cl, [map + si]
		cmp cl, typeSea
		jne updateEnemyDone

		sub dh, bh
		mov bh, 00h
	updateEnemyDone:
	pop di
	ret

updateEnemies:
	mov di, 00h
	updateEnemiesLoop:
		shl di, 1

		mov dx, [enemyPos + di]
		mov bx, [enemyVel + di]

		call updateEnemy
		mov [enemyPos + di], dx
		mov [enemyVel + di], bx

		call drawEnemy

		shr di, 1
		inc di
		cmp di, enemiesCount
	jl updateEnemiesLoop
	ret

replaceFluid:
	push si
	push cx
	push bx

	mov si, 00h
	replaceFluidLoop:
		mov cl, [fluidMap + si]
		cmp cl, ch
		jne replaceFluidContinue
		mov [fluidMap + si], bh

	replaceFluidContinue:
		inc si
		cmp si, 2000
	jb replaceFluidLoop

	pop bx
	pop cx
	pop si
	ret

initFluids:
	mov dx, 0101h
	initFluidsOuter:
		initFluidsInner:
			call translateOffset
			mov al, [map + si]
			cmp al, typeLand
			jne initFluidsInnerContinue

			mov ah, [fluidMap + si]
			mov bh, [fluidMap + si - 1]
			sub si, sWidth
			mov ch, [fluidMap + si]
			add si, sWidth

			cmp ch, 00h
			jne hasFluid
			cmp bh, 00h
			jne hasFluid

			mov ah, nextFluid
			inc ah
			mov nextFluid, ah
			mov [fluidMap + si], ah
			jmp initFluidsInnerContinue

			hasFluid:
				cmp ch, 00h
				jne floodUp
				cmp bh, 00h
				je floodUp

				mov [fluidMap + si], bh
				jmp initFluidsInnerContinue

			floodUp:
				cmp bh, 00h
				jne mergeFluids
				cmp ch, 00h
				je mergeFluids

				mov [fluidMap + si], ch
				jmp initFluidsInnerContinue

			mergeFluids:
				cmp bh, 00h
				je initFluidsInnerContinue
				cmp ch, 00h
				je initFluidsInnerContinue
				cmp ch, bh
				je mergeSameFluids

				call replaceFluid

			mergeSameFluids:
				mov [fluidMap + si], bh
				jmp initFluidsInnerContinue

			initFluidsInnerContinue:
			inc dl
			cmp dl, sWidth
		jb initFluidsInner
		mov dl, 01h
		inc dh
		cmp dh, sHeight
	jne initFluidsOuter
	ret

initEnemyFluids:
	mov di, 00h
	initEnemyFluidsLoop:
		shl di, 1

		mov dx, [enemyPos + di]
		call translateOffset
		mov al, [fluidMap + si]
		mov ah, 00h
		mov [enemyFluids + di], ax

		shr di, 1
		inc di
		cmp di, enemiesCount
	jl initEnemyFluidsLoop
	ret

fillFluid:
	mov dx, 0101h
	fillFluidOuterLoop:
		fillFluidInnerLoop:
			call translateOffset
			mov bl, [fluidMap + si]
			cmp bl, 00h
			je fillFluidInnerContinue

			mov di, 00h
			fillFluidCheckEnemy:
				shl di, 1
				mov ax, [enemyFluids + di]
				cmp bl, al
				je fillFluidDone
				shr di, 1
				inc di
				cmp di, enemiesCount
			jl fillFluidCheckEnemy
			mov bh, typeSea
			mov [map + si], bh

			fillFluidDone:
			mov al, 00h
			mov [fluidMap + si], al

			fillFluidInnerContinue:
			inc dl
			cmp dl, sWidth
		jb fillFluidInnerLoop
		mov dl, 01h
		inc dh
		cmp dh, sHeight
	jne fillFluidOuterLoop
	ret

fill:
	mov dx, playerPos
	mov ch, typeRoad

	inc dh
	call translateOffset
	cmp ch, [map + si]
	je handleFill

	sub dh, 2
	call translateOffset
	cmp ch, [map + si]
	je handleFill

	inc dh
	dec dl
	call translateOffset
	cmp ch, [map + si]
	je handleFill

	add dl, 2
	call translateOffset
	cmp ch, [map + si]
	je handleFill

	ret

	handleFill:
		mov si, 00h
		fillLoop:
			mov cl, [map + si]
			mov ch, typeSea
			cmp cl, typeRoad
			jne fillLoopSkip
			mov [map + si], ch
			fillLoopSkip:
			inc si
			cmp si, 2000
		jb fillLoop

		call initFluids
		call initEnemyFluids
		call fillFluid
		call drawMap
		ret


showAlert macro message, color
	local alertMessageLoop

	mov dl, alertX
	mov dh, alertY
	call translateOffset
	mov di, si
	shl di, 1

	mov cx, alertWidth
	mov ax, 00h
	rep stosw

	mov dl, alertX
	mov dh, alertY + 1
	call translateOffset
	mov di, si
	shl di, 1

	mov cx, alertWidth
	lea si, message
	alertMessageLoop:
		mov al, byte ptr ds:[si]
		mov ah, color
		mov word ptr es:[di], ax
		inc si
		add di, 2
	loop alertMessageLoop

	mov dl, alertX
	mov dh, alertY + 2
	call translateOffset
	mov di, si
	shl di, 1

	mov cx, alertWidth
	mov ax, 00h
	rep stosw
endm

showPauseTip macro
	local pauseTipLoop
	mov dl, pauseTipX
	mov dh, pauseTipY
	call translateOffset
	shl si, 1
	mov di, si
	lea si, messagePauseTip
	lea bx, messagePauseColors
	mov cx, messagePauseTipLen
	pauseTipLoop:
		mov al, byte ptr ds:[si]
		mov ah, byte ptr ds:[bx]
		mov word ptr es:[di], ax
		inc si
		inc bx
		add di, 2
	loop pauseTipLoop
endm

drawScore:
	mov si, 16
	mov ax, winScore
	mov bx, 10
	mov cx, 4
	winScoreLoop:
		mov dx, 00h
		div bx
		add dl, '0'
		mov dh, 17h
		mov word ptr es:[si], dx
		sub si, 2
	loop winScoreLoop

	mov dl, '/'
	mov dh, 17h
	mov word ptr es:[si], dx
	sub si, 2

	mov ax, score
	mov bx, 10
	mov cx, 4
	scoreLoop:
		mov dx, 00h
		div bx
		add dl, '0'
		mov dh, 17h
		mov word ptr es:[si], dx
		sub si, 2
	loop scoreLoop
	ret

updateScore:
	mov dx, 00h
  mov si, 00h
  mov al, typeLand
  mov cl, typeSea
	updateScoreLoop:
		mov ah, byte ptr ds:[map + si]
		cmp ah, cl
		jne updateScoreContinue
		inc dx
	updateScoreContinue:
		inc si
		cmp si, 2000
	jb updateScoreLoop

	sub dx, scoreOffset
	mov score, dx

	call drawScore
	ret

game:
	mov ah, 01h
	int 16h

	jz gameHandle

	push ax
	mov ah, 00h
	int 16h
	pop ax

	gameHandle:
	cmp al, 1bh
	je gamePause

	mov dx, playerPos
	call translateOffset
	mov bl, [map + si]

	cmp bl, typeLand
	jne gameHandleEvents

	mov bl, typeRoad
	mov [map + si], bl

	gameHandleEvents:
		call drawMap

		cmp ah, 48h
		je gameSetMovement

		cmp ah, 4bh
		je gameSetMovement

		cmp ah, 4dh
		je gameSetMovement

		cmp ah, 50h
		je gameSetMovement

		jmp gameHandleUpdate

		gameSetMovement:
		mov playerMovement, ah

		gameHandleUpdate:
		call handleMove
		call updateEnemies
		call updateScore

		mov ax, score
		cmp ax, winScore
		jae gameWin

		mov di, 00h
		gameCheckEnemies:
			shl di, 1
			mov dx, [enemyPos + di]
			cmp dx, playerPos
			je gameOver

			call translateOffset
			mov bl, [map + si]
			cmp bl, typeRoad
			je gameOver
			shr di, 1
			inc di
			cmp di, enemiesCount
		jl gameCheckEnemies

		mov dx, playerPos
		call translateOffset
		mov bl, [map + si]

		cmp bl, typeSea
		jne gameHandleDelay

		call fill

	gameHandleDelay:
		mov ah, 86h
		mov cx, 00h
		mov dx, 45000
		int 15h
	jmp game

	gameOver:
		showAlert messageGameOver, 0ch
		mov ah, 00h
		int 16h
		ret

	gameWin:
		showAlert messageWin, 0ah
		mov ah, 00h
		int 16h
		ret
	gamePause:
		showAlert messagePause, 10000111b
		showPauseTip
		gamePauseLoop:
			mov ah, 00h
			int 16h
			cmp al, 1bh
			je gamePauseExit
			cmp ax, 1c0dh
			je game
		jmp gamePauseLoop

	gamePauseExit:
		ret

start:
	mov ax, @data
	mov ds, ax

	; select video mode
	mov ah, 00h
	mov al, 03h
	int 10h

	; hide cursor
	mov ah, 01h
	mov cx, 2607h
	int 10h

	call generateMap
	mov ax, 0b800h
	mov es, ax

	call game
exit:
	; reset cursor
	mov ax, 0100h
	mov cx, 0607h
	int 10h

	; clear screen
	mov ax, 0700h
	mov di, 00h
	mov cx, 2000
	rep stosw

	mov ax, 4c00h
	int 21h
end start

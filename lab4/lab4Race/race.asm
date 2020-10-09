.model small

.stack 100h

.data
    isEndOfGame db 0

    block equ 08FEh

    outSize equ 2
    carPoz dw 3278
    carSize equ 3
    number dw 0700h
    delayTime dw 0A2C3h

    leftBorder db 20
    rightBorder db 20

    ;car dw 22F2h, 01DBh, 01DBh
    deleteStr dw 00DBh, 00DBh, 00DBh
    barrier dw block, block, block, block, block

    scoreMsg dw 0753h, 0763h, 076Fh, 0772h, 0765h, 073Ah
    score dw 0
    exitMsg dw 0750h, 0772h,0765h,0773h,0773h,0720h,0745h,0753h,0743h,0720h,0774h, 076Fh, 0720h, 0765h, 0778h, 0769h, 0774h
    exitSize db 17
    gameOver dw 0747h, 0761h, 076Dh, 0765h,0720h, 074Fh, 0776h, 0765h, 0772h
    i db 10
    gameOverSize db 9
.code


kbHandler proc
    mov ah, 01
    int 16h
    mov dl, al
    mov ah, 0Ch
    int 21h
    mov al, dl
    cmp al, 'a'
    je aPressed
    cmp al, 'd'
    je dPressed
    jne kbHandlerContinue
aPressed:
    sub carPoz, 2
    jmp kbHandlerContinue
dPressed:
    add carPoz, 2
    jmp kbHandlerContinue
kbHandlerContinue:
    ret
kbHandler endp

randomGenerator proc
    push ax
    push bx
    push cx
    xor bx, bx
    mov ah, 2Ch
    int 21h
    mov bl, dl
    mov ah, 00h
    int 1Ah
    mov ax, dx
    mul bx
    mov bx, 10
    mov al, dl
    xor dx, dx
    div bx
    pop cx
    pop bx
    pop ax
    ret
randomGenerator endp

showBorder proc
    push ax
    xor dx, dx
    xor di, di
    call randomGenerator
    cmp dl, 3
    jbe left
    cmp dl, 6
    jae right
showBorderContinue:
    mov di, 0
    mov cl, leftBorder
showBorderLoop:
    add di, 2
    loop showBorderLoop
    mov es:[di], block
    add di, 80
    mov es:[di], block
    mov cl, rightBorder
showBorderLoop2:
    add di, 2
    loop showBorderLoop2
    pop ax
    ret
left:
    cmp leftBorder, 1
    je showBorderContinue
    dec leftBorder
    inc rightBorder
    jmp showBorderContinue
right:
    cmp rightBorder, 1
    je showBorderContinue
    inc leftBorder
    dec rightBorder
    jmp showBorderContinue

showBorder endp

showCar proc
    mov di, carPoz
    mov es:[di],     08FEh
    mov es:[di] + 2, 07FFEh
    mov es:[di] + 4, 08FEh
    ret
showCar endp

moveScreen proc
    mov ah, 07h
    mov al, 1
    xor bh, bh
    xor cx, cx
    mov dh, 24
    mov dl, 79
    int 10h
    ret
moveScreen endp

deleteCar proc
    mov di, carPoz
    mov si, offset deleteStr
    mov cx, carSize
    rep movsw
deleteCar endp


isCrush proc
    mov si, carPoz
    sub si, 160
    mov cx, carSize
isCrushLoop:
    mov ax, es:[si]
    cmp ax, block
    je isCrushContinue
    add si, 2
    loop isCrushLoop
    ret
isCrushContinue:
    mov isEndOfGame, 1
    ret
isCrush endp

nextFrameDelay proc
    mov ah, 86h
    mov dx, delayTime
    sub delayTime, 10
    mov cx, 0
    int 15h
nextFrameDelay endp

showScore proc
    scoreLen dw 20
    inc score
    mov di, 24*160+70
    mov si, offset scoreMsg
    mov cx, 6
    rep movsw
    mov ax, score
    mov cx, 5
    mov di, 24*160+20+70
showScoreLoop:
    mov bx, 10
    xor dx, dx
    div bx
    add dl, '0'
    add number, dx
    mov si, offset number
    movsw
    mov number, 0700h
    sub di, 4
    loop showScoreLoop
    ret
showScore endp

createBarrier proc
    call randomGenerator
    xor bx, bx
    xor ax, ax
    mov al, dl
    mov bx, 8
    mul bx
    mov dl, 0
    mov dl, leftBorder
    mov di, dx
    add di, dx
    add di, ax
    mov si, offset barrier
    mov cx, 5
    rep movsw

createBarrierEnd:
    ret
createBarrier endp

sendGameOver proc
    mov ah, 06h
    xor al, al
    xor bh, bh
    xor cx, cx
    mov dh, 25
    mov dl, 80
    int 10h

    inc score
    mov di, 12*160+70
    mov si, offset scoreMsg
    mov cx, 6
    rep movsw
    mov ax, score
    mov cx, 5
    mov di, 12*160+20+70

    showScoreLoop1:
    mov bx, 10
    xor dx, dx
    div bx
    add dl, '0'
    add number, dx
    mov si, offset number
    movsw
    mov number, 0700h
    sub di, 4
    loop showScoreLoop1

    mov di, 13*160+64
    mov si, offset exitMsg
    mov cl, exitSize
    rep movsw

    mov di, 11*160+72
    mov si, offset gameOver
    mov cl, gameOverSize
    rep movsw
close:
    mov ah, 00
    int 16h
    cmp al, 1bh
    jne close
    mov ax, 0003h
    int 10h

    mov ah, 4Ch
    int 21h
    ret
sendGameOver endp

begin:
    mov ax, @data
    mov ds, ax
    mov ax, 0003
    int 10h
    mov ax, 0B800h
    mov es, ax

            xor bx, bx
    xor cx, cx
    mov cl, 21
    fenceLoop0:
        mov es:[bx], BLOCK
        add bx, 2
    loop fenceLoop0

    add bx, 39 * 2
    mov cx, 80 - 39
    sub cl, 21
    fenceLoop1:
        mov es:[bx], BLOCK
        add bx, 2
    loop fenceLoop1
    call moveScreen

myLoop:
    call nextFrameDelay
    call deleteCar
    call kbHandler
    call showBorder
    call isCrush
    cmp isEndOfGame, 1
    je end
    call moveScreen
    call showCar
    call showScore
    dec i
    cmp i, 0
    jne myLoop
    mov i, 10
    call createBarrier
    jmp myLoop

end:
    call sendGameOver

end begin

model small
.386
.stack 80h

segment over ;сегмент оверлея
over ends

.data
max     db 201
len     db ?
buffer  db 201 dup(?)
lenSmall     db ?
smallBuffer  db 201 dup(?)
lenSpesh     db ?
bufferSpesh  dw 201 dup(?)
lenSmallSmall     db ?
smallBufferSmall  db 201 dup(?)

num db 50 dup(?)

over_pointer1 dw 0
over_pointer2 dw 0
pathMul db 'ArifmMul.exe',0
pathSum db 'ArifmAdd.exe',0
pathSub db 'ArifmSub.exe',0
pathDiv db 'ArifmDiv.exe',0

messageBorders db "Max border:",10,13,'$'
messageDiv0 db "Cannot be divided by 0!!!",10,13,'$'
messageErrorInput db "Wrong input! Enter arithmetic sign count",10,13,'$'
messageErrorInputSmall db "String is small",10,13,'$'
messageInputViewer db "Enter string in this format A1x1A2x2A3x3...ANxN, N-max border:",10,13,'$'
messageErrorSearch db "Error, repeat input string, please:",10,13,'$'
messageNotErrorSearch db "String entered correctly!",10,13,'$'
messageErrorSearchLen db "String is big or small, repeat input, please:",10,13,'$'
overflow db "Overflow",10,13 , '$'
startPos dw 20 dup(?)
startPosPos dw 20 dup(?)
finishPos dw 20 dup(?)
temp dw 50 dup(?)
tempRes dw 20 dup(?)
tempZ db 3 dup(?)

.code

proc inputString
    pusha
    mov ah, 0ah ;ввод строки в буфер
    xor al, al
    lea dx, max
    int 21h
    xor ah, ah
    mov al, len
    mov si, ax
    mov buffer[si], '$'
    dec si
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    popa
    ret
endp

proc errorSearch ;проверка на пустую строку и на соответствие всех вводимых символов, на 1 и последний символы, на повторяющиеся символы и на количество введённых символов
    pusha
    startSearch:
    mov al , [len] ;проверка на пустую строку
    cmp al , 0
    je endSearch

    xor ch,ch
    mov cl , [len]
    xor si , si
    xor bx , bx ;счётчик знаков

   searchStart:
    cmp [buffer + si], '+'
    je searchSymb
    cmp [buffer + si], '-'
    je searchSymb
    cmp [buffer + si], '/'
    je searchSymb
    cmp [buffer + si], '*'
    je searchSymb
    cmp [buffer + si], '0'
    jb endSearch
    cmp [buffer + si], '9'
    ja endSearch
    jmp cycleSearch

    searchSymb:
    inc bl
    dec si
    cmp si , '0'
    je endSearch
    cmp [buffer + si],'0'
    jb endSearch
    cmp [buffer + si], '9'
    ja endSearch
    inc si
    inc si
    cmp [buffer + si] , '$'
    je endSearch
    cmp [buffer + si], '0'
    jb endSearch
    cmp [buffer + si], '9'
    ja endSearch
    dec si

    cycleSearch:
    inc si
    loop searchStart
    jmp endErrorSearchProc


    endSearch:
    mov ah , 9 ;вывод строки, чтобы пользователь вводил строку заново
    mov dx,offset messageErrorSearch
    int 21h
    jmp repeatCycle

    endSearchLen:
    mov ah , 9 ;вывод строки, чтобы пользователь вводил строку заново из-за маленькой или большой длины
    mov dx,offset messageErrorSearchLen
    int 21h

    repeatCycle:

    call inputString

    jmp startSearch

    endErrorSearchProc:
    cmp [buffer + 0], '0'
    jb endSearch
    cmp [buffer + 0], '9'
    ja endSearch
    mov dl , [len]
    xor dh , dh
    dec dx
    mov si , dx
    cmp [buffer + si], '+'
    je endSearch
    cmp [buffer + si], '-'
    je endSearch
    cmp [buffer + si], '/'
    je endSearch
    cmp [buffer + si], '*'
    je endSearch

    xor dh , dh
    mov dl , num
    dec dl
    sub dl, '0'

    cmp bl , dl
    jne endSearchLen


    mov ah , 9 ;вывод строки, что всё хорошо
    mov dx,offset messageNotErrorSearch
    int 21h

    popa
    ret
endp

proc writeToBufferSpesh ;после данной процедуры в BufferSpesh лежит число знак число знак
    pusha
    xor si,si
    xor di,di

    mov ax, [bufferSpesh+0]
    mov [tempRes] ,ax

    xor dx,dx;будет лежать si

    mainWriteToBufferLoop:
    xor cx,cx
    loopConv:
    cmp [buffer+si], '0'
    jb endConv
    cmp [buffer+si], '9'
    ja endConv
    inc si
    inc cx
    jmp loopConv

    endConv:
    mov dx,si
    sub si,cx
    xor di,di
    loopCx:
    mov bl,[buffer+si]
    mov [smallBufferSmall+di],bl
    inc di
    inc si
    loop loopCx
    mov [smallBufferSmall+di],'$'

    mov [lenSmallSmall],2

    call convertNumberA; в ax-результат

   ; jo lastIteration

    mov  si,[tempRes]; куда записывать будем
    mov [bufferSpesh+si] , ax
    add si,2
    mov [tempRes],si

    xor ax,ax
    mov si,dx
    cmp [buffer+si],'$'
    je exitWriteToBufferSpesh
    mov ah, [buffer+si]
    xor al,al
    mov si,[tempRes]
    mov [bufferSpesh+si],ax
    add si,2
    mov [tempRes],si
    mov si,dx
    inc si
    jmp mainWriteToBufferLoop

    exitWriteToBufferSpesh:
    mov si,[tempRes]
    mov [bufferSpesh+si],'$'
    mov ax , si
    xor ah,ah

    mov [lenSpesh],al

    mov ah , 9
    mov dx,offset bufferSpesh
    int 21h

    popa
    ret
endp

convertNumberA proc near
    push si
    push cx
    push bx
    push dx

    checkIsEmpty:

    push ax

    mov al , [lenSmallSmall] ;проверка на пустую строку
    cmp al , 0
    je endFirstConvert

    pop ax

    convertNumberStart:
    mov si, offset smallBufferSmall
    mov al , [ smallBufferSmall]
    xor cx, cx; base
    xor ax, ax; result
    xor bx, bx;
    mov cx, 10
    mov dx , 1
    lodsb ;mov al,[si] inc si
    cmp al , '-'
    jne nonMinus
    mov dx , -1
    push dx
    xor ax , ax
    jmp convertNumberLoop

    nonMinus:
    mov dx , 1
    push dx
    cmp al, '$'
    je endConvert
    cmp al, '0'
    jb endFirstConvert
    cmp al, '9'
    ja endFirstConvert
    sub al, '0' ;преобразование к цифре

    convertNumberLoop:
    push ax
    lodsb
    mov bl, al
    pop ax
    cmp bl, '$'
    je endConvert
    cmp bl, '0'
    jb endFirstConvert
    cmp bl, '9'
    ja endFirstConvert
    sub bl, '0'
    xor dx , dx
    imul cx
    cmp dx , 0
    jne overflowL

    add ax, bx

    jmp convertNumberLoop

    endFirstConvert:
    ;call errorMessage
    ;-----------------------------
    lea bx , smallBufferSmall; копирует адрес буффер
    pop dx
    jmp checkIsEmpty
    ;---------------------------------
    jmp convertNumberLoop
    endConvert:

    test ax , 8000h
    jz nonOverfolw

    overflowL:

    mov ah , 9
    mov dx,offset overflow
    int 21h
    mov ax, 4c00h
    int 21h

    nonOverfolw:

    xor si,si
    mov cx , 201
    cycleClear:
    mov [smallBufferSmall + si] , '$'
    inc si
    loop cycleClear

    pop dx
    mul dx
    pop dx
    pop bx
    pop cx
    pop si
    ret
endp

printNumberTest proc near; ax - number
    push ax; number
    push bx; base
    push cx; counter
    push dx; remainder

    xor cx, cx
    mov bx, 10

    cmp ax , 0
    jge printNumber_parseA
    push ax

    mov ah , 02h
    mov dl , '-'
    int 21h

    pop ax
    neg ax ;cменить знак


    printNumber_parseA:
    xor dx, dx
    idiv bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne printNumber_parseA
    mov ah, 02h

    printNumber_loopA:
    pop dx
    int 21h
    loop printNumber_loopA

    printNumberExitA:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

proc resultOperation
    pusha
    mov es,[temp]

    mainLoopMain:
    xor si,si
    xor bx,bx
    xor di,di
    xor dx,dx;si лежит
    xor cx,cx
    mov [tempZ+0],'0'

    mainLoop:
    xor al,al
    xor ah,ah
    mov ah,'*'
    cmp [bufferSpesh+si] , ax
    je mullOperation
    cmp [bufferSpesh+si] , '$'
    je notMullSymbol
    add si,2
    jmp mainLoop

   notMullSymbol:
    xor si,si
    returnSearchDec:
    xor al,al
    xor ah,ah
    mov ah,'/'
    cmp [bufferSpesh+si] , ax
    je mullOperation
    cmp [bufferSpesh+si] , '$'
    je notDivSymbol
    add si,2
    jmp returnSearchDec

    notDivSymbol:
    xor si,si
    returnSearchSub:
     xor al,al
     xor ah,ah
    mov ah,'-'
    cmp [bufferSpesh+si] , ax
    je mullOperation
    cmp [bufferSpesh+si] , '$'
    je notSubSymbol
    add si,2
    jmp returnSearchSub

    notSubSymbol:
    xor si,si
    returnSearchAdd:
     xor al,al
     xor ah,ah
    mov ah,'+'
    cmp [bufferSpesh+si] , ax
    je mullOperation
    cmp [bufferSpesh+si] , '$'
    je notAddSymbol
    add si,2
    jmp returnSearchAdd

    mullOperation:

    mov dx,si
    xor cx,cx
    add si,2
    repeatSearchMull:
    ;cmp [bufferSpesh + si], '$'
    ;je nextIteration
    ; xor bh,Sbh
    mov bx,[bufferSpesh + si];2
    add si,2
    mov [finishPos],si
    sub si,2
    ;xor bh,bh
    mov si,dx
    sub si,2
    mov ax, [bufferSpesh + si];1
    mov cx,ax
    mov [startPosPos],si
    mov si,dx
    xor al,al
    xor ah,ah
    mov ah,'*'
    cmp [bufferSpesh + si],ax
    je mullO
    xor al,al
    xor ah,ah
    mov ah,'/'
    cmp [bufferSpesh + si],ax
    je decO
    xor al,al
    xor ah,ah
    mov ah,'-'
    cmp [bufferSpesh + si],ax
    je subO
    xor al,al
    xor ah,ah
    mov ah,'+'
    cmp [bufferSpesh + si],ax
    je addO

    mullO:
    mov ax,cx
    cmp [tempZ+0],'*'
    je noWaightMul
    ;-------------------------
    pusha

    mov ax,over ;сегмент оверлея
    mov [over_pointer2],ax ;сегмент оверлея
    lea bx,over_pointer2
    lea dx,pathMul ;путь к файлу оверлея
    mov ax,4B03h ; mov ah,4bh mov al,3 код загрузки оверлея
    int 21h ;выполнение загрузки оверлея
    mov ax,over
    mov [over_pointer1 + 2],ax

    popa
    ;-------------------------
    noWaightMul:
    ; вызов оверлея как далёкой процедуры
    call dword ptr [over_pointer1]

    test ax , 8000h
    jz next1
    cmp dx,0FFFFh
    jne overFlowLoop
    jmp next11
    next1:
    cmp dx,000h
    jne overFlowLoop
    next11:

    mov [tempZ+0],'*'
    jmp nextO
    decO:
    mov ax,cx
    cmp [tempZ+0],'/'
    je noWaightDiv
    ;-------------------------
    pusha

    mov ax,over ;сегмент оверлея
    mov [over_pointer2],ax ;сегмент оверлея
    lea bx,over_pointer2
    lea dx,pathDiv ;путь к файлу оверлея
    mov ax,4B03h
    int 21h

    mov ax,over
    mov [over_pointer1 + 2],ax

    popa
    ;-------------------------
    noWaightDiv:

    cmp bx,0 ;проверка на деление на 0
    jne nextZ
    mov ah , 9
    mov dx,offset messageDiv0
    int 21h
    mov ax, 4c00h
    int 21h
    nextZ:

    call dword ptr [over_pointer1]

    mov [tempZ+0],'/'
    ;div bl

    xor ah,ah

    jmp nextO
    subO:
    mov ax,cx
    cmp [tempZ+0],'-'
    je noWaightSub
    ;-------------------------
    pusha

    mov ax,over
    mov [over_pointer2],ax
    lea bx,over_pointer2
    lea dx,pathSub
    mov ax,4B03h
    int 21h

    mov ax,over
    mov [over_pointer1 + 2],ax

    popa
    ;-------------------------
    noWaightSub:
    call dword ptr [over_pointer1]

    cmp bx,1
    je overFlowLoop

    mov [tempZ+0],'-'
   ; sub ax,bx
    jmp nextO
    addO:
    mov ax,cx
    cmp [tempZ+0],'+'
    je noWaightAdd
    ;-------------------------
    pusha

    mov ax,over
    mov [over_pointer2],ax
    lea bx,over_pointer2
    lea dx,pathSum
    mov ax,4B03h
    int 21h

    mov ax,over
    mov [over_pointer1 + 2],ax

    popa
    ;-------------------------
    noWaightAdd:
    call dword ptr [over_pointer1]

    cmp bx,1
    je overFlowLoop

    mov [tempZ+0],'+'
   ; add ax,bx

    nextO:

    mov di,[startPosPos]
    mov [bufferSpesh+di],ax
    add di,2
    mov [startPosPos],di

    call copy

    call printNumberTest

    mov ah, 2 ;переход на новую строку
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    mov ah , 9
    mov dx,offset bufferSpesh
    int 21h

    xor ax,ax

    jmp mainLoopMain

    overFlowLoop:
    mov ah , 9
    mov dx,offset overflow
    int 21h
    mov ax, 4c00h
    int 21h

    notAddSymbol:
    popa
    ret
endp

proc copy
    pusha
    xor dx,dx
    push si
    ;bx-куда si-откуда
    mov bx ,[startPosPos]

    mov si , [finishPos]
    xor ah,ah
    mov al , [lenSpesh]

    copyLoop:
    cmp si , ax
    je copyEnd

    mov cx , [bufferSpesh + si]
    mov [bufferSpesh + bx] , cx

    add bx,2
    add si,2
    jmp copyLoop
    copyEnd:
    mov al,[lenSpesh]
    sub ax,4
     mov si,ax
    mov [bufferSpesh+si],'$'
 ;   xor ah,ah

    pop si

    popa
    ret
endp

start:
    mov cl,ds:80h

    mov ax, @data
    mov ds, ax
    mov [temp],ax


    cmp cl,0 ; нет параметров
    jne noExit; указать параметры
    mov ah , 9
    mov dx,offset messageErrorInput
    int 21h
    jmp exit
    noExit:
    mov si,81h ; со смещением 81h начинается область параметров
    cld
    xor di,di
    get_parm:

    lods BYTE PTR es:[si]    ; Загружаем в al очередной символ строки параметров (в данном случае то, что лежит по адресу es:[si])
    mov [num + di] , al  ; помещаем его в num
    inc di
    loop get_parm

    xor si,si
    dec di
    mov cx,di

    cycleF:
    mov bl , [num + si + 1] ;смещаем всё на 1 элемент вперёд
    mov [num + si] , bl
    inc si
    loop cycleF

    mov cx,si
    xor si,si
    inc cx
    loopNum: ;проверки на ввод командной строки
    cmp [num + si], '0'
    jb nextNum
    cmp [num + si], '9'
    ja nextNum
    inc si
    loop loopNum
    cmp [num+0],'0'
    je nextNumSmall
    jmp nextLoop

    nextNumSmall:
    mov ah , 9
    mov dx,offset messageErrorInputSmall
    int 21h
    jmp exit

    nextNum:
    mov ah , 9
    mov dx,offset messageErrorInput
    int 21h
    jmp exit

    nextLoop:
    mov ah , 9
    mov dx,offset messageBorders
    int 21h

    mov ah , 9
    mov [num+di],'$'
    mov dx,offset num
    int 21h

    mov ah, 2 ;переход на новую строку
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    mov ah , 9 ;вывод строки, чтобы пользователь вводил строку вида А1х1А2х2...
    mov dx,offset messageInputViewer
    int 21h

    call inputString

    call errorSearch

    call writeToBufferSpesh

    call resultOperation

    exit:
    mov ax, 4c00h
    int 21h
end start

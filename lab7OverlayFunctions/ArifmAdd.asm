overlay segment para public 'code'
    assume cs:overlay
    main:
       add ax,bx

       jno next
       xor bx,bx
       mov bx,1
       jmp exit
       next:
       xor bx,bx
       mov bx,0
       exit:
    retf
overlay ends
end main

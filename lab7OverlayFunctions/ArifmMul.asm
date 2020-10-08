overlay segment para public 'code'
    assume cs:overlay
    main:
       MUL BX
    retf
overlay ends
end main

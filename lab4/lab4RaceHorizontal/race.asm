.model small
.stack 100h
.data
    start_position dw 0
    delay dw 40364
    car_pos dw 2
    en_car_pos dw 0
    prev_car_pos dw 0
    random dw 0
    random_mas db 1,3,1,2,3,1,1,2,1,3,3,1,2,2,1,2,1,2,3,1,1,2,1,3,3,2,2,1,3,2
    line1 db 80 dup(0)
    line2 db 80 dup(0)
    line3 db 80 dup(0)
    score dw 0
    counter dw 0
    tacts dw 0
output_line db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',00Fh,' ',00Fh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',00Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0EFh,' ',0EFh,' ',00Fh,' ',0EFh,' ',0Fh,' ',0Fh,' ',00Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',01Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',01Fh,' ',1Fh,' ',1Fh,' ',01Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',01Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',01Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',01Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0EFh,' ',0EFh,' ',01Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',01Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0EFh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',01Fh,' ',01Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',01Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db '-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h,'-',04h
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
            db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh

    game_over_message db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',4Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',4Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',0EFh,' ',0EFh,' ',1Fh,' ',0EFh,' ',0EFh,' ',0EFh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',3Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
                  db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',4Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',3Fh,' ',4Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh
    output_line_size equ 4000
    game_over_line_size equ 2560
    clear_line_size equ 2560
    game_over_start equ 960
    scoreSTR db ' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh,' ',1Fh

    car1 db ' ',7Fh,' ',7Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',7Fh,' ',7Fh

    car2 db ' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh,' ',0EFh, ' '

    car1clear db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
    car2clear db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
    enemycar1 db ' ',0Fh,' ',7Fh,' ',7Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',7Fh,' ',7Fh
    enemycar2 db ' ',40h,' ',40h,' ',40h,' ',40h,' ',40h,' ',40h,' ',40h,' ',40h
.code
start:
    mov ax, @data
    mov ds, ax
    xor ax,ax
    mov ah,1h
    mov ch,20h
    int 10h

    call paint_field
    call movecar

paint_field proc
    mov cx, output_line_size
    push 0B800h
    pop es
    mov di,word ptr start_position
    lea si,output_line
    cld
    rep movsb
    ret
    endp
game_over proc
    mov cx, game_over_line_size
    mov di,word ptr game_over_start
    lea si,game_over_message
    cld
    rep movsb
    mov ah,10h
    int 16h
    call clrscr
    xor ax,ax
    mov ah, 4ch
    int 21h
    ret
endp

clear_field proc
    push ax
    mov cx, 16
    mov di,prev_car_pos
    lea si,car1clear
    cld
    rep movsb
    mov ax,prev_car_pos
    add ax,160
    mov prev_car_pos,ax
    mov cx, 16
    mov di,prev_car_pos
    lea si,car2clear
    cld
    rep movsb
    mov ax,prev_car_pos
    add ax,160
    mov prev_car_pos,ax
    mov cx, 16
    mov di,prev_car_pos
    lea si,car2clear
    cld
    rep movsb
    mov ax,prev_car_pos
    add ax,160
    mov prev_car_pos,ax
    mov cx, 16
    mov di,prev_car_pos
    lea si,car1clear
    cld
    rep movsb
    pop ax
    rep movsb
    ret
endp

clrscr proc
    mov ax,0003h
    int 10h
    ret
endp

movecar proc
    mov cx, 16
    mov di,2064
    lea si,car1
    cld
    rep movsb
    mov cx, 16
    mov di,2224
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di,2384
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di,2544
    lea si,car1
    cld
    rep movsb
    startmov:
    call drawCars
    xor ax,ax
    mov ah,01h
    int 16h
    jz draw
    xor ax,ax
    mov ah, 00h
    int 16h
    cmp al,'w'
    jne down
    cmp car_pos,1
    je draw
    cmp car_pos,3
    jne  @w2
    mov prev_car_pos, 3024
    call clear_field
    jmp @w
    @w2:
    mov prev_car_pos, 2064
    call clear_field
    @w:
    dec car_pos
    jmp finally
down:
    cmp al,'s'
    jne esc
    cmp car_pos,3
    je draw
    cmp car_pos,1
    jne  @c2
    mov prev_car_pos, 1104
    call clear_field
    jmp @c
@c2:
    mov prev_car_pos, 2064
    call clear_field
@c:
    inc car_pos
esc:
    cmp al,1Bh
    jne finally
    call game_over
    finally:

draw:
    mov bx,car_pos
    cmp bx,1
    je draw1
    cmp bx,2
    je draw2
    cmp bx,3
    je draw3

draw1:
    mov cx, 16
    mov di, 1104
    lea si,car1
    cld
    rep movsb
    mov cx, 16
    mov di, 1264
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di, 1424
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di, 1584
    lea si,car1
    cld
    rep movsb
    jmp doNothing
draw2:
    mov cx, 16
    mov di, 2064
    lea si,car1
    cld
    rep movsb
    mov cx, 16
    mov di, 2224
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di,2384
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di, 2544
    lea si,car1
    cld
    rep movsb
    jmp doNothing
draw3:
    mov cx, 16
    mov di, 3024
    lea si,car1
    cld
    rep movsb
    mov cx, 16
    mov di, 3184
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di, 3344
    lea si,car2
    cld
    rep movsb
    mov cx, 16
    mov di, 3504
    lea si,car1
    cld
    rep movsb
    jmp doNothing
doNothing:
    call checkForLooser
    call displayScore
    inc tacts     ;+1
    call rand
    mov bx, tacts
    cmp bx,25
    jne next
    mov tacts,0
    inc score
    inc counter
    cmp delay,10364
    je justskip
    cmp counter,10
    jne justskip
    mov counter,0
    sub delay,2500
justskip:
    mov bx,random
    cmp bx,2
    jg place3
    cmp bx,2
    je place2
    lea bx,line1
    add bx,72
    mov [bx],1
    jmp next
place2:
    lea bx,line2
    add bx,72
    mov [bx],1
    jmp next
place3:
    lea bx,line3
    add bx,72
    mov [bx],1
next:
    call delaypr
    call movArr
    jmp startmov
    ret
endp

delaypr proc
    xor ax,ax
    mov cx,0
    mov dx,delay
    mov ah,86h
    int 15h
    ret
endp

rand proc
    xor ax,ax
    mov ah,00h
    int 1Ah
    mov ax,dx
    xor dx,dx
    mov cx,30
    div cx
    push bx
    lea bx, random_mas
    add bx,dx
    xor ax, ax
    mov al,[bx]
    mov random,ax
    pop bx
    ret
endp

movArr proc
    xor ax,ax
    lea bx, line1
    movArr1:
    inc bx
    mov dh,[bx]
    dec bx
    mov [bx],dh
    inc bx
    inc dx
    inc ax
    cmp ax,73
    je clearax1
    jmp movArr1
    clearax1:
    xor ax,ax
    lea bx, line2
    movArr2:
    inc bx
    mov dh,[bx]
    dec bx
    mov [bx],dh
    inc bx
    inc ax
    inc dx
    cmp ax,73
    je clearax2
    jmp movArr2
    clearax2:
    xor ax,ax
    lea bx, line3
    movArr3:
    inc bx
    mov dh,[bx]
    dec bx
    mov [bx],dh
    inc bx
    inc ax
    inc dx
    cmp ax,73
    je stopmov
    jmp movArr3
    stopmov:
    ret
endp

drawCars proc
    xor ax,ax
    lea bx, line1
analyzeline1:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,74
    je line1finish
    cmp dh,1
    jne analyzeline1
    xor cx, cx
    xor dx,dx
    push ax
    push bx
    mov bx,2
    dec ax
    mul bx
    add cx,ax
    pop bx
    pop ax

    push ax
    mov ax, 1104
    sub ax, cx
    mov cx, ax
    pop ax
    mov en_car_pos,cx

    call drawEnCar
    jmp analyzeline1
line1finish:
    xor ax,ax
    lea bx, line2
analyzeline2:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,74
    je line2finish
    cmp dh,1
    jne analyzeline2
    xor cx, cx
    xor dx,dx
    push ax
    push bx
    mov bx,2
    dec ax
    mul bx
    add cx,ax
    pop bx
    pop ax

    push ax
    mov ax, 2064
    sub ax, cx
    mov cx, ax
    pop ax
    mov en_car_pos,cx

    call drawEnCar
    jmp analyzeline2
line2finish:
    xor ax,ax
    lea bx, line3
analyzeline3:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,74
    je line3finish
    cmp dh,1
    jne analyzeline3
    xor cx, cx
    xor dx,dx
    push ax
    push bx
    mov bx,2
    dec ax
    mul bx
    add cx,ax
    pop bx
    pop ax

    push ax
    mov ax, 3024
    sub ax, cx
    mov cx, ax
    pop ax
    mov en_car_pos,cx
   ; mov line_ind,0
    call drawEnCar
    jmp analyzeline3
line3finish:
    ret
endp

checkForLooser proc
    mov ax, car_pos
    cmp ax,2
    jg check3
    cmp ax,2
    jl check1
    cmp ax,2
    je check2
check1:
    lea bx, line1
    xor ax,ax
analyzeline1forloose:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,9
    je endcheck
    cmp dh,1
    jne analyzeline1forloose
    call game_over
check2:
    lea bx, line2
    xor ax,ax
analyzeline2forloose:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,9
    je endcheck
    cmp dh,1
    jne analyzeline2forloose
    call game_over
check3:
    lea bx, line3
    xor ax,ax
analyzeline3forloose:
    mov dh,[bx]
    inc ax
    inc bx
    cmp ax,9
    je endcheck
    cmp dh,1
    jne analyzeline3forloose
    call game_over
endcheck:
    ret
endp

drawEnCar proc
    push ax
    mov ax,en_car_pos
    cmp ax, 960
    je skip
    cmp ax, 1920
    je skip
    cmp ax, 2880
    je skip
    sub ax,2
    mov prev_car_pos,ax
    call clear_field
skip:
    cmp en_car_pos,1104
    jne @1920
    mov prev_car_pos, 1104
    call clear_field
    jmp endthis
@1920:
    cmp en_car_pos,2064
    jne @2880
    mov prev_car_pos, 2064
    call clear_field
    jmp endthis
@2880:
    cmp en_car_pos,3024
    jne drawthis
    mov prev_car_pos, 3024
    call clear_field
    jmp endthis
drawthis:

    mov cx, 14
    mov di,en_car_pos
    lea si,enemycar1
    cld
    rep movsb
    mov ax,en_car_pos
    add ax,160
    mov en_car_pos,ax
    mov cx, 16
    mov di,en_car_pos
    lea si,enemycar2
    cld
    rep movsb
    mov ax,en_car_pos
    add ax,160
    mov en_car_pos,ax
    mov cx, 16
    mov di,en_car_pos
    lea si,enemycar2
    cld
    rep movsb
    mov ax,en_car_pos
    add ax,160
    mov en_car_pos,ax
    mov cx, 14
    mov di,en_car_pos
    lea si,enemycar1
    cld
    rep movsb


endthis:
    pop ax
    ret
endp

displayScore proc
    call convertScore
    mov cx, 10
    mov di,3828
    lea si,scoreStr
    cld
    rep movsb
    ret
endp

convertScore proc
    mov ax,score
    mov di,offset scoreStr
w_to_udec_str:
    push ax
    push cx
    push dx
    push bx
    xor cx,cx
    mov bx,10
wtusd_loop1:
    xor dx,dx
    div bx
    add dl,'0'
    push dx
    inc cx
    test ax,ax
jnz wtusd_loop1

wtusd_loop2:
    pop dx
    mov [di],dl
    inc di
    inc di
loop wtusd_loop2
    pop bx
    pop dx
    pop cx
    pop ax
    ret
endp

doFaster proc
    ret
    endp
end start

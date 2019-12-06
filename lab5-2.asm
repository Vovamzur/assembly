include e_mcr.txt

STSEG SEGMENT PARA STACK "STACK"        
  DB 64 DUP("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"  
  str1 DB "Enter your number: $"
  str2 DB 10,13,"Converted number: $"
  buffer DB 7,?,7 DUP(?)
  errormsg db 10,13, "incorrect number$"
  errormsg1 db 10,13, "your number is too big$"
  number dw ?
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"

  print macro string 
    push ax
    lea dx,string
    mov ah, 09h
    int 21h
    pop ax
  endm

  printerror_and_exit macro error_str
    xor dx,dx
    lea dx, error_str
    mov ah,9h
    int 21h
    exit
  endm
        
  MAIN PROC FAR
    ASSUME CS:CSEG, DS:DSEG, SS:STSEG

    mov ax,dseg
    mov ds,ax

    call getArg
    sub number, 99
    call digit
    exit
  MAIN ENDP

  getArg proc  
    lea dx,str1             
    mov ah,09h
    int 21h
    lea dx,buffer
    mov ah,0ah
    int 21h

    lea si,buffer+2
    cmp byte ptr[si], "-"
    jnz proc_1

    xor di, di
    mov di,1
    inc si

    proc_1:
      xor ax,ax
      mov bx,10

    proc_2:
      mov cl,[si]
      cmp cl,0dh
      jz ending
      cmp cl,'0'
      jb error ; cl < '0'
      cmp cl,'9'
      ja error ; cl > '9'
      sub cl,'0'
      mul bx
      jc error1
      add ax,cx
      jc error1
      inc si
      jmp proc_2
      
    ending:
      test ax, 32768
      js error1
      cmp di,1
      jnz return
      neg ax

    return:
      mov number, ax
      ret

    error:
      printerror_and_exit errormsg
    error1:
      printerror_and_exit errormsg1
  getArg endp

  digit proc
    mov bx,number 
    lea dx, str2 
    mov ah, 09h   
    int 21h
    or bx, bx
    jns m1
    mov al, '-'
    int 29h
    neg bx

    m1:
      mov ax, bx
      xor cx, cx
      mov bx, 10

    m2:
      xor dx, dx
      div bx
      add dl, '0'
      push dx
      inc cx
      test ax, ax
      jnz m2

    m3:
      pop ax
      int 29h
      loop m3

    ret
  digit endp

CSEG ENDS

END MAIN
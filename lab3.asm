STSEG SEGMENT PARA STACK "STACK"
  DB 64 DUP("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
  preinpurStr      db 10, 13, "Enter your number:$"
  preoutputStr     db 10, 13, "The result is:$"
  notNumErrorStr   db 10, 13, "Incorrect number!$"
  tooBigNumberStr  db 10, 13, "Your number is too big$"
  divisionErrorStr db 10, 13, "Division by zero!$"
  multiplyErrorStr db 10, 13, "Mutiplied value is too big$"
  buffer db 6, ? , 6 DUP(?)
  x dw ?
  result dw ?
  remainder dw 0
  divider dw 0
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
  MAIN PROC FAR
    ASSUME CS:CSEG, DS:DSEG, SS:STSEG

    mov ax,dseg
    mov ds,ax

    call getX
    call myfunc
    call printResult

    mov ax, 4c00h
    int 21h
    ret
  MAIN ENDP

  getX proc
    lea dx, preinpurStr
    mov ah, 09h
    int 21h
    lea dx, buffer
    mov ah, 0ah
    int 21h
    lea si, buffer+2
    cmp byte ptr [si], "-"
    jnz proc_1

    xor di,di
    mov di,1
    inc si

    proc_1:
      xor ax, ax
      mov bx, 10

    proc_2:
      mov cl,[si]
      cmp cl,0dh
      jz ending
      cmp cl, '0' ; cl < '0'
      jb notNumError
      cmp cl, '9' ; cl > '9'
      ja notNumError
      sub cl, '0'
      mul bx
      js tooBigNumberError
      add ax,cx
      jc tooBigNumberError
      inc si
      jmp proc_2

    ending:
      test ax, 32768
      js tooBigNumberError
      cmp di,1
      jnz return
      neg ax

    return:
      mov x,ax
      xor di,di
      ret

    notNumError:
      xor dx,dx
      lea dx, notNumErrorStr
      mov ah,9h
      int 21h
      mov ah,4ch
      int 21h
      ret

    tooBigNumberError:
      xor dx, dx
      lea dx, tooBigNumberStr
      mov ah, 9h
      int 21h
      mov ah, 4ch
      int 21h
      ret

  getX endp

  myfunc proc
    mov ax,x
    cmp ax, 1
    jle less_x
    cmp ax, 6
    ja bigger_x

    ; 1 < x <= 6
    xor bx,bx
    mov bx, 35
    imul bx
    jo multiplyError
    mov bx, ax
    mov ax, x
    imul ax
    jo multiplyError
    neg ax
    add ax, 1
    cmp ax, 0
    je divisionError
    xchg ax, bx
    cwd
    idiv bx
    jo tooBigNumberError
    mov divider, bx
    mov remainder, dx
    jmp assign

    ; x <= 1
    less_x:
      imul ax
      jo multiplyError
      jmp assign

    ; x > 6
    bigger_x:
      xor bx, bx
      mov bx, x
      imul bx
      jo multiplyError
      imul bx
      jo multiplyError
      sub ax, 75
      jmp assign

    multiplyError:
      xor dx,dx
      lea dx, multiplyErrorStr
      mov ah,9h
      int 21h
      mov ah,4ch
      int 21h
      ret

    divisionError:
      xor dx,dx
      lea dx, divisionErrorStr
      mov ah,9h
      int 21h
      mov ah,4ch
      int 21h
      ret

    assign:
      mov result, ax
      ret
  myfunc endp

  printresult proc
    lea dx, preoutputStr
    mov ah, 09h
    int 21h
    xor bx, bx
    mov bx, result
    call printNum
    cmp remainder, 0
    je printEnd
    mov al, ' '
    int 29h
    xor bx, bx
    mov bx, remainder
    call printNum
    mov al, '/'
    int 29h
    xor bx, bx
    mov bx, divider
    call printNum

    printEnd:
      ret
  printresult endp

  printNum proc
    or bx,bx
    jns pm1

    mov al,'-'
    int 29h
    neg bx

    pm1:
      xor cx, cx
      mov ax, bx
      mov bx, 10

    pm2:
      xor dx, dx
      div bx
      add dl, '0'
      push dx
      inc cx
      test ax, ax
      jnz pm2

    pm3:
      pop ax
      int 29h
      loop pm3

    ret
  printNum endp

CSEG ENDS

END MAIN
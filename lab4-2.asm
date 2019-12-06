include e_mcr.txt

STSEG SEGMENT PARA STACK 'STACK'
  DB 64 DUP ( 'STACK' )
STSEG ENDS

DSEG SEGMENT PARA PUBLIC 'DATA' 
  s_enter_columns_of_array db 10, 13, 'Enter count of columns 2< ... <10: $'
  s_enter_rows_of_array    db 10, 13, 'Enter count of rows 2< ... <10: $'
  s_enter_num              db 10, 13, 'array$'
  s_search_el              db 10, 13, 'Enter number that you want to find: $'
  s_i                      db 10, 13, 'i: $'
  s_j                      db 10, 13, 'j: $'
  s_coord                  db 10, 13, 'Coordinates: $'
  s_space                  db ' $'
  e_array_size             db 10, 13, 'Incorrect length of array!$'
  e_not_founded            db 10, 13, 'Can not find this element!$'
  e_notNumErrorStr         db 10, 13, 'Incorrect number!$'
  e_tooBigNumberStr        db 10, 13, 'Your number is too big$'
  buffer db 6, ?, 6 dup(?)
  column_count dw ?
  row_count dw ?
  quantity dw ?
  number_to_find dw ?
  position_number dw 10000 dup(?)
  x dw 10000 dup(?)
  y dw 10000 dup(?)
  j dw 1 
  i dw 1
 
  array dw 100 dup(?)
  number dw ?
  max dw ?
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"

  print macro string 
    push ax
    lea dx,string
    mov ah, 09h
    int 21h
    pop ax
  endm
     
  MAIN PROC FAR
    ASSUME CS:CSEG, DS:DSEG, SS:STSEG 

    mov ax,dseg
    mov ds,ax

    call enter_array_sizes
    call enter_array
    call searchNumber1
    exit

  MAIN ENDP

  enter_array_sizes proc
    print s_enter_columns_of_array
    call getNumber
    cmp ax, 2
    jb error_size
    cmp ax, 20
    ja error_size
    mov column_count, ax
    print s_enter_rows_of_array
    call getNumber
    cmp ax, 2
    jb error_size
    cmp ax, 20
    ja error_size
    mov row_count, ax
    ret
 
  error_size:
    print e_array_size
    exit
  enter_array_sizes endp

  enter_array proc
    xor ax, ax
    xor bx, bx
    mov cx, row_count
    c_i:
      push cx
      mov cx, column_count
      mov ax, 1
      mov j, ax
      c_j:
        push cx
        push bx
        print s_enter_num
        mov al,'['
        int 29h 
        xor ax,ax
        mov ax, i               
        call printNum
        mov al,']'
        int 29h
        mov al,'['
        int 29h
        xor ax,ax
        mov ax, j
        call printNum
        mov al,']'
        int 29h
        mov al, '='
        int 29h
        call getNumber
        inc j
        pop bx
        mov array[bx],ax    
        add bx,2 
        pop cx           
        loop c_j
        inc i
        pop cx            
    loop c_i
    ret
  enter_array endp

  searchNumber1 proc
    mov i, 1
    mov j, 1
    print s_search_el
    call getNumber
    mov number_to_find, ax
    xor ax, ax
    xor bx, bx
    xor di, di
    xor dx, dx
    mov cx, row_count
    mov dx, number_to_find
    loop_i:
      push cx
      mov cx, column_count
      mov ax, 1
      mov j, ax
      loop_j:
        push cx
        cmp array[bx], dx
        jne next
        inc di
        push ax
        mov ax, i
        mov x, ax
        mov ax, j
        mov y, ax
        jmp printCoord
        pop ax
        next:
        add bx, 2 
        inc j
        pop cx           
        loop loop_j
      inc i
      pop cx            
      loop loop_i
    cmp di, 0
    je not_found
    ret

    printCoord:
      print s_coord
      mov al, '['
      int 29h
      xor ax, ax
      mov ax, i
      call printNum
      mov al, ','
      int 29h
      xor ax, ax
      mov ax, j
      call printNum
      mov al, ']'
      int 29h
      exit

    not_found:
      print e_not_founded
      exit

  searchNumber1 endp

  getNumber proc
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
      xor ax,ax
      mov bx,10

    proc_2:
      mov cl,[si]
      cmp cl,0dh
      jz ending
      cmp cl,'0' ; cl < '0'
      jb notNumError
      cmp cl,'9' ; cl > '9'
      ja notNumError
      sub cl,'0'
      mul bx
      jc tooBigNumberError
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
      xor di,di
      ret

    notNumError:
      print e_notNumErrorStr
      exit

    tooBigNumberError:
      print e_tooBigNumberStr
      exit
  getNumber endp

  printNum proc
    mov bx, ax
    or bx,bx
    jns pm1
    mov al,'-'
    int 29h
    neg bx

    pm1:
      xor cx ,cx
      mov ax, bx
      mov bx, 10

    pm2:
      xor dx, dx
      div bx
      add dl,'0'
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
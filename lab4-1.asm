include e_mcr.txt

STSEG SEGMENT PARA STACK 'STACK'
  DB 64 DUP ( 'STACK' )
STSEG ENDS

DSEG SEGMENT PARA PUBLIC 'DATA' 
  s_enter_length_of_array db 10, 13, 'Enter lenght of array 2< ... <20: $'
  s_enter_num             db 10, 13, 'Enter element: $'
  s_array                 db 10, 13, 'Your array: $'
  s_sum                   db 10, 13, 'Sum of numbers in array: $'
  s_max_number            db 10, 13, 'Max number in array: $'
  s_sorted_array          db 10, 13, 'Your sorted array: $'
  e_notNumErrorStr        db 10, 13, 'Incorrect number!$'
  e_tooBigNumberStr       db 10, 13, 'Your number is too big$'
  e_array_size            db 10, 13, 'Incorrect length of array!$'
  e_sum_calculation       db 10, 13, 'Error during calculation sum of elements!$'
  s_space                 db ' $'
  buffer db 6, ?, 6 dup(?)
  array_length dw ?
  array dw 100 DUP(?)
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

    call enter_array
    print s_array
    call print_array
    call sum_of_array
    call max_of_array
    call sort_array
    print s_sorted_array
    call print_array
    exit
  MAIN ENDP

  enter_array proc
    print s_enter_length_of_array
    call getNumber
    cmp ax, 2
    jb error_size
    cmp ax, 20
    ja error_size
    mov array_length, ax
    mov cx, ax
    xor bx, bx
  
    enter_el_of_array:
      push cx
      push bx
      print s_enter_num
      call getNumber
      pop bx
      mov array[bx], ax
      add bx, 2
      pop cx
      loop enter_el_of_array
    ret
  
    error_size:
      print e_array_size
      exit
  enter_array endp

  sum_of_array proc
    mov cx, array_length
    xor ax, ax
    xor bx, bx
    xor dx, dx

    m_sum:
      mov ax, array[bx]
      add dx, ax
      jo error_overflow
      add bx, 2
      loop m_sum

    push dx
    print s_sum
    pop dx
    mov ax, dx
    call printNum
    ret
  
    error_overflow:
      print e_sum_calculation
      exit
  sum_of_array endp

  max_of_array proc
    mov cx, array_length
    xor ax, ax
    xor bx, bx
    xor dx, dx
    mov dx, array[bx]
    m_max_el:
      mov ax, array[bx]
      cmp dx, ax
      jg skip_assign_new_max
      mov dx, ax
    skip_assign_new_max:
      add bx, 2
      loop m_max_el
      push dx
      print s_max_number
      pop dx
      mov ax, dx
      call printNum
      ret
  max_of_array endp

  sort_array proc
    xor dx, dx
    xor cx, cx
    mov dx, array_length
    dec dx
    oloop:
      mov cx, array_length
      dec cx
      lea si, array
      
      iloop:
      mov ax, [si]
      cmp ax, [si+2]
      jl common
      xchg ax, [si+2]
      mov [si], ax
      
      common:
        add si, 2
        loop iloop
        
      sub dx, 1
      jnz oloop
    ret
  sort_array endp

  print_array proc
    mov cx, array_length
    xor si, si
    display_loop:
      mov ax, array[si]
      push cx
      print s_space
      call printNum
      pop cx
      add si, 2
      loop display_loop
    ret
  print_array endp

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
      xor ax, ax
      mov bx, 10

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
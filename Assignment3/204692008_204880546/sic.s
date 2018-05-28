section .data   

    m1: dq 0x0
    m2: dq 0x0
    m3: dq 0x0
    
    size: dq 4096
    
    scan: db "%ld",0
    output1: db "%d ", 0
    output2: db "%d", 10, 0
    counter: dq 0x0
    index: dq 0x0
   
section .bss

    M: resq 1
   
section .text   ; our code is always in the .text section
        global main
        extern printf                ; tell linker that printf is defined elsewhere        
        extern malloc
        extern calloc
        extern realloc
        extern scanf
        extern free
        
        
; ************************************** main ***********************************************

main:

    push    rbp
    mov     rbp, rsp

    mov rsi, 8
    mov rdi, 4097
    call calloc
    
    mov r15, rax
    mov qword [M], r15
    
    lea rsi,[r15]
    mov r14, 4096

    scan_loop:

        cmp r14, 0x0
        jle continue_main

        mov rdi, scan  
        mov rax, 0x0
        
        push rsi
        push r14
        push r15
        call scanf
        pop r15
        pop r14
        pop rsi
        
        cmp eax, 0
        jle continue_main

        add rsi, 8 
        dec r14
        add qword[counter], 0x1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; realoc
        
        mov r9, qword[counter]
        mov r10, qword[size]
        
        cmp r9, r10
        jne scan_loop
        
        mov rdi, qword[M]
        add r10, r10
        add r10, r10
        add r10, r10
        add r10, r10
        
        mov rsi, r10
        
        push r15
        push r14
        push rsi
        push r10
        call realloc
        pop r10
        pop rsi
        pop r14
        pop r15
        
        mov rsi, rax
        mov r15, rax
        mov qword[M], rax
        
        ;add qword[size], 1
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        add rsi, qword[size]
        mov qword[size], r10
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp scan_loop

    continue_main:
    
    mov r15, qword [M]
    
    
    
  mov r14, 0
    
  while_loop:  
        
        mov r10, r14
        lea r9, [r15 + 8*r10]  ; r9 = adress(!) of m[index]
        mov r8, [r9]
        mov qword[m1], r8   ;; m1 = m[index]
        
        add r9, 8
        mov r8, [r9]
        mov qword[m2], r8    ;; m2 = m[index+1]
        
        add r9, 8
        mov r8, [r9]
        mov qword[m3], r8    ;; m3 = m[index+2]
        
        mov r8, qword[m1]
        cmp r8, 0
        jne continue_loop
        
        mov r8, qword[m2]
        cmp r8, 0
        jne continue_loop
        
        mov r8, qword[m3]
        cmp r8, 0
        je end_while
        
        continue_loop:
        
            mov r11, qword [m1]
            lea r12, [r15 + 8*r11]  ; r12 = adress(!) of M[M[i]]
            
            mov r11, qword [m2]
            lea r13, [r15 + 8*r11]  ; r13 = adress(!) of M[M[i+1]]
        
            mov r9, r12
        
            mov r12, [r12]
            mov r13, [r13]
            sub r12, r13  ; [r12] = M[M[i]] - M[M[i+1]]
            mov [r9], r12
            mov r10, r12
            
            cmp r10, 0
            
            jge else_label
            
            mov r14, qword[m3]
            jmp while_loop
        
            else_label:
            
                add r14, 3
                jmp while_loop
        
    end_while: 
    
    mov r11, 0 
    
    print_loop:
    
        mov r10, qword[counter]
        sub r10, 1
        cmp r11, r10
        je end_main
        
        lea rsi, [r15 + 8*r11]
        mov rsi, [rsi]
        mov rdi, output1
        mov rax, 0
        push r15
        push r11
        call printf
        pop r11
        pop r15
        
        add r11, 1
        jmp print_loop    
    
    end_main:
    
        lea rsi, [r15 + 8*r11]
        mov rsi, [rsi]
        mov rdi, output2
        mov rax, 0
        push r15
        push r11
        call printf
        pop r11
        pop r15
    
        mov rdi, qword [M]
        call free 
        ret
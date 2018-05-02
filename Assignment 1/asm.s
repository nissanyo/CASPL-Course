section .data     ; data section, read-write
        num1: DQ 0x0
        digit1: dq 0x0
        num2: dq 0x0
        digit2: dq 0x0
        temp: dq 0x0
        ans: dq 0x0
        lsb1: dq 0x0
        initialDigit: dq 0x0
        carry: dw 0x0
        ansLen: dq 0x0
        tempMsb: dq 0x0
        tempLsb: dq 0x0
        loopCounter: dq 0x0
        

section .text                    	; our code is always in the .text section
        global calc_add          	    ; makes the function appear in global scope
        global calc_sub          	    ; makes the function appear in global scope        
        global calc_mul          	    ; makes the function appear in global scope        
        extern printf            	; tell linker that printf is defined elsewhere 							; (not used in the program)


calc_add: 
        push    rbp              	; save Base Pointer (bp) original researchvalue
        mov     rbp, rsp         	; use base pointer to access stack contents
        
        mov r10, rdi
        mov r11, rsi
        mov r12, rdx
        mov r13, rcx
        
        
        dec r11 ; decreasing r11 by one
        add r10, r11 ;now we have a pointer to the lsb of num1 
        
        dec r13 ; decreasing r13 by one
        add r12, r13  ;now we have a pointer to the lsb of num2 
        
        inc r11
        inc r13
        mov r8b, 0x0
        
        
        add_loop:
                ; changing the value of the char to the numerical value in both registers
                mov al, [r10]
                sub al, 0X30
                mov [r10], al
                mov al, [r12]
                sub al, 0X30
                mov [r12], al
                
                ; adding both values + optional carry - 10
                mov al, [r10]
                add al, [r12]
                add al, r8b
                sub al, 0xA
                mov [r10], al
                
                mov r8b, 0x0
                
                cmp byte [r10], 0x0
                jl no_carry ; in case there is no carry (add back 10)
                mov al, [r10]
                add al, 0x30
                mov [r10], al
                
                mov al, [r12] 
                add al, 0x30
                mov [r12], al
                
                
                add r8b, 0x1
                
                dec r11
                
                dec r10 
                dec r12 
                cmp r11, 0x0
                jnz add_loop
                
               
                ; last adding, no carry
                inc r10 
                mov rax, r10
                mov     rsp, rbp
                pop     rbp
                ret
                
        no_carry:
        
                mov al, [r10]
                add al, 0xA
                add al, 0x30
                mov [r10], al
                
                mov al, [r12] ;; !!!!!!!!!!!
                add al, 0x30
                mov [r12], al
                
                dec r11
                
                dec r10 
                dec r12 
                cmp r11, 0x0
                jnz add_loop
         
                ; last adding, no carry
                inc r10                    
                mov rax, r10
                mov     rsp, rbp
                pop     rbp
                ret
                

                
calc_sub: 
        push    rbp              	; save Base Pointer (bp) original value
        mov     rbp, rsp         	; use base pointer to access stack contents
        
        mov r10, rdi
        mov r11, rsi
        mov r12, rdx
        mov r13, rcx
        
        
        dec r11 ; decreasing r11 by one
        add r10, r11 ;now we have a pointer to the lsb of num1 
        
        dec r13 ; decreasing r13 by one
        add r12, r13  ;now we have a pointer to the lsb of num2 
        
        inc r11 ; updated number of digits
        inc r13 ; updated number of digits
        mov r8b, 0x0 ; borrow register
        
        sub_loop:
                ; changing the value of the char to the numerical value in both registers
                mov al, [r10]
                sub al, 0X30
                mov [r10], al
                mov al, [r12]
                sub al, 0X30
                mov [r12], al
                
                ; sub both values - optional borrow - 10
                mov al, [r10]
                sub al, [r12]
                sub al, r8b
                mov [r10], al
                mov r8b, 0x0
                cmp byte [r10], 0x0
                jl yes_borrow

                
                
                mov al, [r10]
                add al, 0x30
                mov [r10], al

				mov al, [r12] ; TODO - CHECK if it's Ok here!!!!!!
                add al, 0x30
                mov [r12], al
                
                dec r11
                
                dec r10 
                dec r12 
                cmp r11, 0x0
                jnz sub_loop
                
               
                ; last adding, no borrow
                inc r10 
                mov rax, r10
                mov     rsp, rbp
                pop     rbp
                ret
                
                
        yes_borrow:
                mov al, [r10]
                add al, 0xA
                mov [r10], al
                add r8b, 0x1
                
                mov al, [r10]
                add al, 0x30
                mov [r10], al

				mov al, [r12] ; TODO - CHECK if it's Ok here!!!!!!
                add al, 0x30
                mov [r12], al
                
                dec r11
                
                dec r10 
                dec r12 
                cmp r11, 0x0
                jnz sub_loop
                
               
                ; last adding, no borrow
                inc r10 
                mov rax, r10
                mov     rsp, rbp
                pop     rbp
                ret
                
                
calc_mul: 
        push    rbp              	; save Base Pointer (bp) original value
        mov     rbp, rsp         	; use base pointer to access stack contents
        
        mov r15, r8
        mov qword [tempMsb], r15
        
        dec rsi ; decreasing r11 by one
        add rdi, rsi ;now we have a pointer to the lsb of num1 
        
        dec rcx ; decreasing r13 by one
        add rdx, rcx  ;now we have a pointer to the lsb of num2 
        
        inc rsi
        inc rcx
        add qword [ansLen], rsi
        add qword [ansLen], rsi
        add qword [ansLen], 0x1
        
        
        add r15, qword [ansLen]
        sub r15, 0x1
        
        
        
        
        mov qword [tempLsb], r15
        
        mov word [carry], 0x0 
        mov qword [initialDigit], rcx ; the number of digits of [r13] - the "lower" number
        mov qword [lsb1], rdi
        
        ; in this point - all the pointers are pointing to the lsb
        
        mul_loop:
            
            ; changing the value of the char to the numerical value in both registers

            mov al, [rdi]
            sub al, 0x30
            mov [rdi], al
            mov al, [rdx]
            sub al, 0x30
            mov [rdx], al
                
            ; multi part:
            mov bl, [rdx]
            mov al, [rdi]
            mul bl
            add ax, word [carry] 
            mov word [carry] ,0x0 
            ;mov word [dummyAx], ax !!
            ; now we check if there's carry
            
            mov r14b, [rdi]
            add r14b, 0x30
            mov [rdi], r14b
            
            mov r14b, [rdx]
            add r14b, 0x30
            mov [rdx], r14b
                
            cmp word ax ,0x9   ; was [dummyAx]
            jle inside_label
            
            ; in case it's greater then 9 then we divide by 10, and then mov into dummyAx the remaining and into carry the carry
            
            ;cwd !!
            ;mov cx, 0xA
            ;div cx
            ;mov word [dummyAx], dx
            ;mov word [carry], ax !!
            
            ;;
            mov qword [num2], rdx
            mov qword [digit2], rcx
            cwd
            mov cx, 0xA
            div cx
            add dx, 0x30
            mov [r15], dl
            ;mov dl, [r15]
            ;add dl, 0x30  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            ;mov [r15], dl
            mov word [carry], 0x0
            mov word [carry], ax
            
            mov rdx, qword [num2]
            mov rcx, qword[digit2]
            jmp out_of_lable
            ;;
    
            inside_label:
            
            add word ax, 0x30 ; was [dummyAx]
            ;mov ax, [dummyAx] !!
            mov [r15], al     
                
            out_of_lable:
            
            dec rdi
            dec r15
            dec rsi
            cmp rsi, 0x0
            jnz mul_loop
            
            add qword [loopCounter], 0x1
            mov qword [num1], rdi
            mov qword [num2], rdx
            mov qword [temp], r15
            mov qword [digit1], rsi
            mov qword [digit2], rcx
            
            mov rdi, r9
            mov rsi, qword [ansLen]
            mov rdx, qword [tempMsb]
            mov rcx, qword [ansLen]
      
            call calc_add
            
            mov rdi, qword [num1]
            mov rdx, qword [num2]
            mov r15, qword [tempMsb]
            mov rsi, qword [digit1]
            mov rcx, qword [digit2]
            
            mov r9, rax
            ;need to change temp into being all zeros again and move temp to be pointing to the next place
            mov rdi, qword [lsb1]
            mov rsi, qword [initialDigit]
            dec rdx
            
            zero_loop:
                mov [r15], byte 0x30
                inc r15
                cmp r15, qword [tempLsb]
                jne zero_loop
            mov [r15], byte 0x30
            ;mov r15, tempLsb ---- no needed
            sub r15, qword [loopCounter]
            
            dec rcx
            cmp rcx, 0x0
            jnz mul_loop
            
            mov rax, r9
            jmp cleaner_label
                         
            ; need to put the ans inside rax and initiate all of the data section varibels to 0 again
            ; need to return
                
                
cleaner_label:
        mov qword [num1], 0x0
        mov qword [digit1], 0x0
        mov qword [num2], 0x0
        mov qword [digit2], 0x0
        mov qword [temp], 0x0
        mov qword [ans], 0x0
        mov qword [lsb1], 0x0
        mov qword [initialDigit], 0x0
        mov word [carry], 0x0
        mov qword [ansLen], 0x0
        mov qword [tempMsb], 0x0
        mov qword [tempLsb], 0x0
        mov qword [loopCounter], 0x0
        
        mov     rsp, rbp
        pop     rbp
        ret   
        
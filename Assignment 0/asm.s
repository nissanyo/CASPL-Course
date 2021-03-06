section .data                    	; data section, read-write
        an:    DQ 0              	; this is a temporary var

section .text                    	; our code is always in the .text section
        global do_Str          	    ; makes the function appear in global scope
        extern printf            	; tell linker that printf is defined elsewhere 							; (not used in the program)

do_Str:                        	    ; functions are defined as labels
        push    rbp              	; save Base Pointer (bp) original value
        mov     rbp, rsp         	; use base pointer to access stack contents
        mov rcx, rdi			    ; get function argument

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE STARTS HERE ;;;;;;;;;;;;;;;; 

	mov	qword [an], 0		; initialize answer
	label_here:
   		cmp byte [rcx], '('
   		je input_open

                cmp byte [rcx], ')'
   		je input_close
   		
   		
   		cmp byte [rcx], 0x41
   		jl inc_counter

   		cmp byte [rcx], 0x5A
                jg input_between
                
                jmp continue
   		
        input_between:
                cmp byte [rcx], 0x61
                jl inc_counter
                
                cmp byte [rcx], 0x7A
                jle input_lowChar
                
                jmp inc_counter
                
                
        input_open:
                mov byte [rcx], '<'                             
                jmp inc_counter
                
        input_close:
                mov byte [rcx], '>'
                jmp inc_counter

        input_lowChar:
                sub byte [rcx], 0x20
                jmp continue
            
        inc_counter:
                add qword [an],1
                
        continue:
                inc rcx      	    ; increment pointer
                cmp byte [rcx], 0   ; check if byte pointed to is zero
                jnz label_here      ; keep looping until it is null terminated
		
        


;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE ENDS HERE ;;;;;;;;;;;;;;;; 

         mov     rax,[an]         ; return an (returned values are in rax)
         mov     rsp, rbp
         pop     rbp
         ret 
		 
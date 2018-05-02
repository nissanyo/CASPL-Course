section .data     ; data section, read-write

    add_real: dq 0x0
    add_img: dq 0x0
    sub_real: dq 0x0
    sub_img: dq 0x0
    mul_real: dq 0x0
    mul_img: dq 0x0
    div_real: dq 0x0
    div_img: dq 0x0
    poly_real: dq 0x0
    poly_img: dq 0x0
   
    ; ** taken from here!!!!!!!!!!!!!!!!
    f_calc_counter: dw 0x1
   
    norm_check: dw 0x0
    norm_real: dq 0x0
    norm_img: dq 0x0
    norm_temp: dq 0x0
   
    real1: dq 0x0
    img1: dq 0x0
    real2: dq 0x0
    img2: dq 0x0
    temp_for_mul: dq 0x0
    roof_real_div: dq 0x0
    roof_img_div: dq 0x0
   
    store_temp1_div: dq 0x0
    store_temp2_div: dq 0x0
    store_temp3_div: dq 0x0
    store_temp4_div: dq 0x0
   
    f_tag_temp_arr: dq 0x0
    f_tag_counter: dq 0x1.0
    f_tag_double_size: dw 0x8
;; f_tag_return_arr
    f_tag_deg_minus_one: dw 0x0
    f_tag_temp_number: dq 0x0.0
    f_tag_register_help: dq 0x0.0
    f_tag_one: dq 0x1.0
   
    epsilon_read: db "epsilon = %lf",10,0
    order_read: db "order = %d",10,0
    coeff_read: db "coeff %d = %lf %lf",10,0
    initial_read: db "initial = %lf %lf",0
    main_output: db "root = %.17e %.17e",10,0
   
    n1: dq 0x0
    n2: dq 0x0
    main_deg_minus_i: dw 0x0
    main_temp_real: dq 0x0
    main_temp_img: dq 0x0
    f_real_saver: dq 0x0
    f_img_saver: dq 0x0
    size_to_jmp: dw 0x8
   
   
section .bss
    f_tag_return_arr: resq 1
    f_real: resq 1
    f_img: resq 1
    f_tag_real: resq 1
    f_tag_img: resq 1
    num_i: resw 1
   
    x0_real: resq 1
    x0_img: resq 1
    epsilon: resq 1
    deg: resw 1
   
section .text   ; our code is always in the .text section
        global main
        extern printf                ; tell linker that printf is defined elsewhere        
        extern malloc
        extern calloc
        extern scanf
        extern free

       
; ************************************** main ***********************************************

main:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents
finit

mov rdi, 0x0
mov rdi, epsilon_read
mov rsi, epsilon
mov rax, 0x0
call scanf
mov rax, 0x0


mov rdi, 0x0
mov rdi, order_read
mov rsi, deg
mov rax, 0x0
call scanf
mov rax, 0x0

;creating new array for f_real:

mov r15w, word [deg]


;mov word [f_tag_double_size], 0x8

;add word [deg], 0x1 ; adding 1 to deg  (deg = deg+1)
;mov bx, word [deg]    ; TODO adding exactly 1 or byte (8) ?
;sub word [deg], 0x1 ; returnning to the original deg

;mov ax, word [f_tag_double_size]
;mul bx  ; now: ax = deg*f_tag_double_size

;mov rdi, rax
;mov rax, 0x0
;call malloc
;mov qword [f_real], rax   ; creating new array in size of sizeof(double)*(deg+1)


mov rsi, 0x8
mov rdi, 0x0
mov r9, 0x0
mov r9w, word [deg]
mov rdi, r9
add rdi, 0x1
call calloc
mov qword [f_real], rax




;creating new array for f_img:

mov rax, 0x0
;mov word [f_tag_double_size], 0x8

;add word [deg], 0x1 ; adding 1 to deg  (deg = deg+1)
;mov bx, word [deg]    ; TODO adding exactly 1 or byte (8) ?
;sub word [deg], 0x1 ; returnning to the original deg

;mov ax, word [f_tag_double_size]
;mul bx  ; now: ax = (deg+1)*f_tag_double_size

;mov rdi, rax
;mov rax, 0x0
;call calloc
;mov qword [f_img], rax   ; creating new array in size of sizeof(double)*(deg+1)


mov rsi, 0x8
mov rdi, 0x0
mov r9, 0x0
mov r9w, word [deg]
mov rdi, r9
add rdi, 0x1
call calloc
mov qword [f_img], rax



scan_loop:

cmp r15w, 0x0
jl continue_main

; scanf loop for coeff numbers:

mov rdi, 0x0
mov rdi, coeff_read  
mov rsi, num_i
mov rcx, n2
mov rdx, n1
mov rax, 0x0
call scanf
mov rax, 0x0


mov r9w, word [deg]
mov word [main_deg_minus_i], r9w
mov r9w, word [num_i]
sub word [main_deg_minus_i], r9w


;main_deg_minus_i * size_to_jmp = main_deg_minus_i

mov word [size_to_jmp], 0x8
mov r14, 0x0
mov bx, word [size_to_jmp]
mov rax, 0x0
mov ax, word [main_deg_minus_i]
mul bx  ; now: ax = deg*f_tag_double_size
add r14, rax ; now the pointer is on the LSB of the new array

mov r12, qword [f_real]
mov r13, qword [f_img]
sub r12, r14
sub r13, r14  ; now f_real and f_img pointing to right place as i

mov r9, qword [n1]
mov [r12], r9
mov r9, qword [n2]
mov [r13], r9

dec r15w

jmp scan_loop

continue_main:

mov rdi, 0x0
mov rdi, initial_read  
mov rsi, x0_real
mov rdx, x0_img
mov rax, 0x0
call scanf
mov rax, 0x0


mov r9, qword [f_real]
mov qword [f_tag_temp_arr], r9
call f_tag
mov r9, qword [f_tag_return_arr]
mov qword [f_tag_real], r9

mov r9, qword [f_img]
mov qword [f_tag_temp_arr], r9
call f_tag
mov r9, qword [f_tag_return_arr]
mov qword [f_tag_img], r9

call calc_func

norm_loop:

call norm_check_func

mov r9w, word [norm_check]

cmp r9w, 0x0
jne end_main

call calc_func

mov r9, qword [poly_real]
mov qword [main_temp_real], r9
mov r9, qword [poly_img]
mov qword [main_temp_img], r9



mov r9, qword [f_real]
mov qword [f_real_saver], r9
mov r9, qword [f_img]
mov qword [f_img_saver], r9
mov r9, qword [f_tag_real]
mov qword [f_real], r9
mov r9, qword [f_tag_img]
mov qword [f_img], r9
sub word [deg], 0x1

call calc_func


add word [deg], 0x1

mov r9, qword [f_real]
mov qword [f_tag_real], r9
mov r9, qword [f_img]
mov qword [f_tag_img], r9
mov r9, qword [f_real_saver]
mov qword [f_real], r9
mov r9, qword [f_img_saver]
mov qword [f_img], r9

mov r9, qword [main_temp_real]
mov qword [real1], r9
mov r9, qword [main_temp_img]
mov qword [img1], r9
mov r9, qword [poly_real]
mov qword [real2], r9
mov r9, qword [poly_img]
mov qword [img2], r9



call cmplx_div




mov r9, qword [x0_real]
mov qword [real1], r9
mov r9, qword [x0_img]
mov qword [img1], r9
mov r9, qword [div_real]
mov qword [real2], r9
mov r9, qword [div_img]
mov qword [img2], r9

call cmplx_sub

mov r9, qword [sub_real]
mov qword [x0_real], r9
mov r9, qword [sub_img]
mov qword [x0_img], r9

call calc_func




jmp norm_loop

end_main:

mov rdi, 0x0
movsd xmm0, qword [x0_real]
movsd xmm1, qword [x0_img]
mov rdi, main_output
mov rax, 2
call printf

;mov rdi, qword [f_real_original]
;mov rax, 0x0
;call free

;mov rdi, qword [f_img_original]
;mov rax, 0x0
;call free

;mov rdi, qword [f_tag_img_original]
;mov rax, 0x0
;call free

;mov rdi, qword [f_tag_real_original]
;mov rax, 0x0
;call free



jmp cleaner_label



; ************************************** add ***********************************************
cmplx_add:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov qword [add_real], 0x0
fld qword [add_real]
fld qword [real1]
fadd
fld qword [real2]
fadd ; last 4 lines - adding to add_real real1 and real2
fstp qword [add_real]

mov qword [add_img], 0x0
fld qword [add_img]
fld qword [img1]
fadd
fld qword [img2]
fadd
fstp qword [add_img]

mov     rsp, rbp
pop     rbp
ret

; ************************************** sub ***********************************************

cmplx_sub:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov qword [sub_real], 0x0
fld qword [sub_real]
fld qword [real1] ; real1 stored in st0
fadd  ;sub_real have real1
fld qword [real2]
fsub   ; last 4 lines - sub real2 from real 1 and store in sub_real
fstp qword [sub_real]

mov qword [sub_img], 0x0
fld qword [sub_img]
fld qword [img1] ; real1 stored in st0
fadd ;sub_real have real1
fld qword [img2]
fsub   ; last 4 lines - sub img2 from img1 and store in sub_img
fstp qword [sub_img]

mov     rsp, rbp
pop     rbp
ret

; ************************************** mul ***********************************************

cmplx_mul:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov qword [mul_real], 0x0
fld qword [mul_real]
fld qword [img1]
fadd
fld qword [img2]
fmul ; img1*img2
fstp qword [mul_real]

mov r9, qword [mul_real]
mov qword [temp_for_mul], r9 ; result moved to temp_for_mul   ; now: mul_real = img1*img2

mov qword [mul_real], 0x0
fld qword [mul_real]
fld qword [real1]
fadd
fld qword [real2]
fmul ; real1*real2
fstp qword [mul_real]

fld qword [mul_real]
fld qword [temp_for_mul]
fsub ; real1*real2 - (img1*img2) = mul_real
fstp qword [mul_real]

mov qword [mul_img], 0x0
fld qword [mul_img]
fld qword [real1]
fadd
fld qword [img2]
fmul  ; last 4 lines - mul between real1 and img2 - located in mul_img
fstp qword [mul_img]

mov r9, qword [mul_img]
mov qword [temp_for_mul], r9 ; result moved to temp_for_mul

mov qword [mul_img], 0x0
fld qword [mul_img]
fld qword [img1]
fadd
fld qword [real2]
fmul  ; last 4 lines - mul between img1 and real2 - located in mul_img
fld qword [temp_for_mul]
fadd  ; mul_img = real1*img2 + img2*real1
fstp qword [mul_img]

mov     rsp, rbp
pop     rbp
ret

;mul_real = real1 * real2  + img1 * img2 * (-1) = real1*real2 - (img1*img2)
;mul_img = real1*img2 + img2*real1

; ************************************** div ***********************************************

cmplx_div:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov r9, qword [real2]
mov qword [roof_real_div], r9

mov qword [roof_img_div], 0x0
fld qword [roof_img_div]
fld qword [img2]
fsub
fstp qword [roof_img_div]

mov r9, qword [real2]
mov qword [store_temp1_div], r9
mov r9, qword [img2]
mov qword [store_temp2_div], r9 ; last 4 lines: storing real2 and img2 in temps.

mov r9, qword [roof_real_div]
mov qword [real2], r9
mov r9, qword [roof_img_div]
mov qword [img2], r9 ; last 4 lines: loading roofs into real2 and img2 for using cmplx_mul

call cmplx_mul ; mul_real = real1*roof_real_div - (img1*roof_img_div)    ,    mul_img = real1*roof_img_div + img1*roof_real_div

mov r9, qword [mul_real]
mov qword [store_temp3_div], r9
mov r9, qword [mul_img]
mov qword [store_temp4_div], r9

mov r9, qword [store_temp1_div]
mov qword [real1], r9
mov r9, qword [store_temp2_div]
mov qword [img1], r9

call cmplx_mul ; mul_real = real2*roof_real_div - (img2*roof_img_div)    ,    mul_img = real2*roof_img_div + img2*roof_real_div

mov r9, qword [store_temp3_div]
mov qword [div_real], r9

fld qword [div_real]
fld qword [mul_real]
fdiv
fstp qword [div_real]

mov r9, qword [store_temp4_div]
mov qword [div_img], r9

fld qword [div_img]
fld qword [mul_real]
fdiv
fstp qword [div_img]

mov     rsp, rbp
pop     rbp
ret

; ************************************** norm_check ***********************************************

norm_check_func:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov r9, qword [poly_real]
mov qword [norm_real], r9

fld qword [norm_real]
fld qword [poly_real]
fmul
fstp qword [norm_real]

mov r9, qword [poly_img]
mov qword [norm_img], r9

fld qword [norm_img]
fld qword [poly_img]
fmul
fstp qword [norm_img]

mov r9, qword [norm_real]
mov qword [norm_temp], r9

fld qword [norm_temp]
fld qword [norm_img]
fadd
fsqrt
;fld qword [epsilon]
;fsub
;fstp qword [norm_temp]
;cmp qword [norm_temp], 0x0


fstp qword [norm_temp]
finit
fld qword [epsilon]
fld qword [norm_temp]
fcom st1
fstsw ax
fwait
sahf

jb change_flag
jz change_flag
finit


mov     rsp, rbp
pop     rbp
ret

change_flag:
finit
add word [norm_check], 0x1

mov     rsp, rbp
pop     rbp
ret


; ************************************** calc_func ***********************************************

;exactly by the main.c

calc_func:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents


mov word [f_calc_counter], 0x1
mov r10, qword [f_real]

mov r9, [r10]
mov qword [poly_real], r9

mov r11, qword [f_img]
mov r9, [r11]
mov qword [poly_img], r9

mov r15w, word [f_calc_counter]

calc_loop:

mov r9w, word [deg]

cmp r15w, r9w   
jg return_calc_func

mov r9, qword [poly_real]
mov qword [real1], r9
mov r9, qword [poly_img]
mov qword [img1], r9
mov r9, qword [x0_real]
mov qword [real2], r9
mov r9, qword [x0_img]
mov qword [img2], r9

call cmplx_mul ; sent poly_real, poly_img, x0_real, x0_img


mov r9, qword [mul_real]
mov qword [real1],  r9
mov r9, qword [mul_img]
mov qword [img1], r9

sub r10, 0x8
sub r11, 0x8
inc r15w  ; inc to the next place in the array

mov r9, [r10]
mov qword [real2], r9
mov r9, [r11]
mov qword [img2], r9

call cmplx_add

mov r9, qword [add_real]
mov qword [poly_real], r9
mov r9, qword [add_img]
mov qword [poly_img], r9
jmp calc_loop

return_calc_func:

;mov rdi, 0x0
;movsd xmm0, qword [poly_real]
;movsd xmm1,qword [poly_img]
;mov rdi, main_output
;mov rax, 2
;call printf

mov     rsp, rbp
pop     rbp
ret


; ************************************** f_tag ***********************************************

f_tag:

push    rbp                  ; save Base Pointer (bp) original researchvalue
mov     rbp, rsp             ; use base pointer to access stack contents

mov rax, 0x0
mov bx, word [deg]
mov word [f_tag_double_size], 0x8
mov ax, word [f_tag_double_size]
mul bx  ; now: ax = deg*f_tag_double_size

mov rdi, 0x0
mov rdi, rax
mov rax, 0x0
call malloc
mov qword [f_tag_return_arr], rax   ; creating new array in size of sizeof(double)*deg

mov r9w, word [deg]
dec r9w
mov word [f_tag_deg_minus_one], r9w

mov r12, qword [f_tag_return_arr]
mov bx, word [f_tag_deg_minus_one]
mov rax, 0x0
mov word [f_tag_double_size], 0x8
mov ax, word [f_tag_double_size]
mul bx  ; now: ax = deg*f_tag_double_size
sub r12, rax ; now the pointer is on the LSB of the new array

mov r13, qword [f_tag_temp_arr]
mov bx, word [f_tag_deg_minus_one]
mov rax, 0x0
mov ax, word [f_tag_double_size]
mul bx  ; now: ax = deg*f_tag_double_size
sub r13, rax ; now the pointer is on the LSB of the new array


mov r15, 0x0
mov r15w, word [f_tag_deg_minus_one]

f_tag_loop:

cmp r15w, 0x0
jl f_tag_return

mov r9, [r13]
mov qword [f_tag_register_help], r9

;mov rdi, 0x0
;movsd xmm0, qword [f_tag_register_help]
;movsd xmm1, qword [f_tag_register_help]
;movsd xmm2, qword [f_tag_register_help]
;mov rdi, main_output
;mov rax, 0x3
;call printf


mov qword [f_tag_temp_number], 0x0
fld qword [f_tag_temp_number]
fld qword [f_tag_register_help]
fadd
fstp qword [f_tag_temp_number]

fld qword [f_tag_temp_number]
fld qword [f_tag_counter]
fmul
fstp qword [f_tag_temp_number]
mov r9, qword [f_tag_temp_number]
mov [r12], r9


finit
fld qword [f_tag_counter]
fld qword [f_tag_one]
fadd
fstp qword [f_tag_counter]

dec r15 ; i--
add r12, 0x8
add r13, 0x8

jmp f_tag_loop

f_tag_return:

mov     rsp, rbp
pop     rbp
ret




cleaner_label:

    mov qword [add_real], 0x0
    mov qword [add_img], 0x0
    mov qword [sub_real], 0x0
    mov qword [sub_img], 0x0
    mov qword [mul_real], 0x0
    mov qword [mul_img], 0x0
    mov qword [div_real], 0x0
    mov qword [div_img], 0x0
    mov qword [poly_real], 0x0
    mov qword [poly_img], 0x0
    mov qword [x0_real], 0x0
    mov qword [x0_img], 0x0
    mov qword [epsilon], 0x0
    mov word [deg], 0x0
    mov qword [f_real], 0x0
    mov qword [f_img], 0x0
    mov qword [f_tag_real], 0x0
    mov qword [f_tag_img], 0x0
    mov word [f_calc_counter], 0x0
    mov byte [norm_check], 0x0
    mov qword [norm_real], 0x0
    mov qword [ norm_img], 0x0
    mov qword [norm_temp], 0x0
    mov qword [real1], 0x0
    mov qword [img1], 0x0
    mov qword [real2], 0x0
    mov qword [img2], 0x0
    mov qword [temp_for_mul], 0x0
    mov qword [roof_real_div], 0x0
    mov qword [roof_img_div], 0x0
    mov qword [store_temp1_div], 0x0
    mov qword [store_temp2_div], 0x0
    mov qword [store_temp3_div], 0x0
    mov qword [store_temp4_div], 0x0
    mov qword [f_tag_temp_arr], 0x0
    mov qword [f_tag_counter], 0x0
    mov word [f_tag_double_size], 0x0
    mov qword [f_tag_return_arr], 0x0
    mov word [f_tag_deg_minus_one], 0x0
    mov qword [f_tag_temp_number], 0x0
    mov byte [epsilon_read], 0x0
    mov byte [order_read], 0x0
    mov byte [coeff_read], 0x0
    mov byte [initial_read], 0x0
    mov byte [main_output], 0x0
    mov qword [n1], 0x0
    mov qword [n2], 0x0
    mov word [num_i], 0x0
    mov word [ main_deg_minus_i], 0x0
    mov qword [main_temp_real], 0x0
    mov qword [main_temp_img], 0x0
    mov qword [f_real_saver], 0x0
    mov qword [f_img_saver], 0x0

leave


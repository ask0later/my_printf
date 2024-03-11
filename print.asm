section .text
global my_printf

; rdi  - first  argument
; rsi  - second argument
; rdx  - third  argument
; rcx  - fourth argument
; r8   - fifth  argument
; r9   - sixth  argument



;---------------------------------------------------------------
; function similar to printf on C
; Entry: first arg  - string
;        othet args - arg, which need input ot string 
; Assumes: r8 - counter of stack argument
;          String - ptr of first arg
;       
;       rdi  - first  argument
;       rsi  - second argument
;       rdx  - third  argument
;       rcx  - fourth argument
;       r8   - fifth  argument
;       r9   - sixth  argument
;       next args in stack
; Destr: all
;---------------------------------------------------------------
my_printf:      
                pop r10                 ; return value my_printf

                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rdi                ; saves registers

                push r10                ; at the top of the stack

                push rbp                ; saves rbp
               

                mov rbp, rsp
                add rbp, 16             ; 8 byte * 2 = return value and rbp value

                xor r8, r8              ; r8 - counter of stack argument 
                mov rsi, [rbp + r8]
                add r8, 8

                mov [String], rsi
                

                .loop:
                        mov r10, [String]               ;
                        mov r11b, byte [r10]            ; current symbol
                        cmp r11b, 0x00                  ; '\0'
                        je .end_loop

                        cmp r11b, '%'                   ; function insert
                        jne .not_insert

                        mov r10, [String]               ; next symbol
                        inc r10                         ;
                        mov [String], r10               ; %<this symbol>

                        call insert_arg
                        jmp .insert

                        .not_insert:
                        mov rsi, [String]
                        call my_putchar

                        mov r10, [String]
                        inc r10
                        mov [String], r10

                        .insert:

                        jmp .loop

                .end_loop:

                pop rbp

                pop r10                 ; r10 = return value my_printf
        
                pop rdi
                pop rsi
                pop rdx
                pop rcx
                pop r8
                pop r9                  ; saves registers

                push r10                ; push return value my_printf

                ret


;---------------------------------------------------------------
; prints one character from the buffer to stdin
; Entry: rsi - ptr of buffer
;        
; Assumes: 
; Destr: rax, rdi, rdx
;---------------------------------------------------------------
my_putchar:       
                mov rax, 0x01           ; write64 (rdi, rsi, rdx) (int fd, void* buf, size_t count)
                mov rdi, 1              ; stdout
                mov rdx, 1

                ; rsi = ptr of buffer     
                
                syscall
                ret
            


;---------------------------------------------------------------
; detects the character after % and calls 
; the corresponding functions (using a switch)
; Entry: String - ptr of first arg
;        
; Assumes: r8 - counter of stack argument
; Destr: rsi, rbp, r8, r10, r11, r12
;---------------------------------------------------------------

insert_arg: 
                mov rbp, rsp

                add rbp, 24                     ; 8 byte * 3 = two return value and two rbp value
                                                ; + one return value 

                mov r10, [String]
                mov r11b, byte [r10]            ; %<r11b>
                and r11, 0xff                   ; 

                mov r10, [String]               ; next symbol
                inc r10
                mov [String], r10               ; after %<smth>

                cmp r11b, '%'                   
                je switch_perc


                sub r11b, 'a'                   ; offset of 'a' ASCII code 
                shl r11b, 3                     ; r11b *= 8 byte  
                mov r12, [SwitchChar + r11]
                jmp r12                         ; switch char

                switch_perc:
                        mov rsi, PercentSymbol  ; write twice '%' 
                        call my_putchar
                        call my_putchar

                        jmp switch_exit

                switch_hex:
                        mov rsi, rbp
                        add rsi, r8
                        add r8, 8
        
                        call print_hex
                        jmp switch_exit

                switch_oct:
                        mov rax, [rbp + r8]
                        add r8, 8
                        mov r10, 8              ; r10 - divider
                        call print_num

                        jmp switch_exit

                switch_dec:
                        mov rax, [rbp + r8]
                        add r8, 8
                        mov r10, 10             ; r10 - divider

                        call print_num
                        jmp switch_exit
                
                switch_bin:
                        mov rax, [rbp + r8]     ; rax - member
                        add r8, 8
                        mov r10, 2              ; r10 - divider
                        call print_num

                        jmp switch_exit

                switch_char:
                        mov rsi, rbp
                        add rsi, r8
                        add r8, 8

                        call my_putchar 
                        jmp switch_exit

                switch_str:
                        mov rsi, [rbp + r8]
                        add r8, 8
                        
                        call print_buf
                        jmp switch_exit

                switch_exit:       


                ret

;---------------------------------------------------------------
; converts each digit of the number into the ASCII code 
; of this digit and prints it to stdout
;
; the next number in the argument
;
; converts to octal, decimal and binary
;
; using DIV
; Entry:   rax - number
;        
; Assumes: r8 - counter of stack argument
;          NumberBuffer - ptr of converted number
; Destr: rax, rdi, rdx, rsi, r10, r11
;---------------------------------------------------------------
print_num:               
                                        ; rax = number
                cmp r10, 10
                jne .no_decimal
                test rax, rax
                jns .no_decimal

                push rax
                mov rsi, MinusSymbol
                call print_buf

                pop rax
                neg rax

                .no_decimal:
                xor r11, r11            ; counter
                .loop:
                        xor rdx, rdx
                        div r10         ; rax - quotient (частное)
                                        ; rdx - remainder of the division (остаток)

                        add rdx, '0'
                        mov byte [NumberBuffer + r11], dl
                        inc r11

                        cmp rax, 0
                        je .exit

                        jmp .loop
                .exit:
                
                call write_number

                ret


;---------------------------------------------------------------
; prints the octal, decimal and binary number 
; that appears next in the argument
; Entry: String - ptr of first arg
;        
; Assumes: NumberBuffer - ptr of converted number
; Destr: rax, rdi, rdx, rsi, r10
;---------------------------------------------------------------
write_number:            
                mov r10, r11                    ; r10 - number of digits
                mov rsi, NumberBuffer           ; = ptr of converted number    

                add rsi, r10
                dec rsi

                .loop:
                        call my_putchar
                        dec rsi
                        dec r10
                        
                        cmp r10, 0
                        je .exit

                        jmp .loop

                .exit:


                ret

;---------------------------------------------------------------
; converts each digit of the number into the ASCII code 
; of this digit and prints it to stdout
;
; the next number in the argument
;
; converts to hexical
;
; using shits
; Entry: rsi - ptr of number
;        
; Assumes: PtrHexNumber - ptr of converted number
;          
; Destr: rax, rdi, rcx, rdx, rsi, r9, r10, r11
;---------------------------------------------------------------
print_hex:       
                push rcx
                xor rcx, rcx

                xor r11, r11
                xor r9, r9

                mov rdx, 0xff00000000000000
                mov cl, 56              ; 8 * 7
                
                .loop:
                        mov r10, rdx
                        and r10, [rsi]          ; rsi = ptr of number
                                                ; r10 is some part of number
                        
                        shr r10, cl
                        sub cl, 8

                        shr rdx, 8              ; shift one byte (two hex digit)

                        mov r9b, 0xf0           ; = 11110000 b
                        and r9b, r10b
                        shr r9b, 4
                        call hex_converter      ; r9b converted

                        mov [PtrHexNumber + r11], r9b
                        inc r11

                        mov r9b, 0x0f           ; = 00001111 b
                        and r9b, r10b
                        call hex_converter

                        mov [PtrHexNumber + r11], r9b
                        inc r11

                        cmp r11, 16
                        je .exit

                        jmp .loop
                .exit:

                call write_hex

                pop rcx
                ret


;---------------------------------------------------------------
; prints the hexical number 
; that appears next in the argument
; Entry: 
;        
; Assumes: PtrHexNumber - ptr of converted number
; Destr: rax, rdi, rdx, rsi, r9, r10
;---------------------------------------------------------------
write_hex:
                mov rsi, HexPrefix
                call print_buf
                xor r9, r9
                mov rsi, PtrHexNumber

                .loop:
                        call my_putchar
                        inc rsi 
                        inc r9
                        cmp r9, 16
                        je .exit
                jmp .loop
                .exit:

                ret

;---------------------------------------------------------------
; converts a number to aski number code for hexadecimal
;
; Entry: r9b - digit
;        
; Assumes:
; Destr: r9b
;---------------------------------------------------------------
hex_converter: 	        
                        cmp r9b, 9
                        ja .letter
			add r9b, '0'
			jmp .digit
			.letter:
				sub r9b, 10
				add r9b, 'A'
			.digit:
                        
			ret



;---------------------------------------------------------------
; prints the buffer until it reaches \0
;
; Entry: rsi - ptr of buffer
;        
; Assumes:
; Destr: rax, rdi, rdx, rsi, r11 
;---------------------------------------------------------------
print_buf:    
                .loop:
                        mov r11b, byte [rsi]
                        cmp r11b, 0x00                  ; '\0'
                        je .endloop

                        call my_putchar

                        inc rsi

                        jmp .loop
                .endloop:

                ret




section     .data
String:      dq      0
PtrHexNumber:   db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0,
                db      0

NumberBuffer:   db      65 dup 0

SwitchChar:     dq switch_exit          ; a
                dq switch_bin           ; b
                dq switch_char          ; c
                dq switch_dec           ; d
                dq switch_exit          ; e
                dq switch_exit          ; f
                dq switch_exit          ; g
                dq switch_exit          ; h
                dq switch_exit          ; i
                dq switch_exit          ; g
                dq switch_exit          ; k
                dq switch_exit          ; l
                dq switch_exit          ; m
                dq switch_exit          ; n
                dq switch_oct           ; o
                dq switch_exit          ; p
                dq switch_exit          ; q
                dq switch_exit          ; r
                dq switch_str           ; s
                dq switch_exit          ; t
                dq switch_exit          ; u
                dq switch_exit          ; v
                dq switch_exit          ; w
                dq switch_hex           ; x

PtrWord         dw      0

HexPrefix       dq      "0x" 
PercentSymbol   db      "%"
MinusSymbol     dq      "-"
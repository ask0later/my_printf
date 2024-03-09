section .text
global _PrintString

; rdi - first  argument
; rsi - second argument
; rdx - third  argument
; r10 - fourth argument
; r8 - fifth argument
; r9 - sixth argument

_PrintString:   
                push r9
                push r8
                push r10
                push rdx
                push rsi
                push rdi


                xor r8, r8

                mov rsi, [rsp + r8]

                add r8, 8
                mov [String], rsi
                

                loop_2:
                        mov r10, [String]               ;
                        mov r11b, byte [r10]            ; current symbol
                        cmp r11b, 0x00                  ; '\0'
                        je endloop_2

                        cmp r11b, '%'                   ; function insert
                        jne not_insert

                        mov r10, [String]               ; next symbol
                        inc r10                         ;
                        mov [String], r10               ; %<this symbol>

                        call InsertArgument
                        jmp insert_2

                        not_insert:
                        mov rsi, [String]
                        call _PutChar

                        mov r10, [String]
                        inc r10
                        mov [String], r10

                        insert_2:

                        jmp loop_2

                endloop_2:
        
                pop rdi
                pop rsi
                pop rdx
                pop r10
                pop r8
                pop r9

                ret

_PutChar:       
                mov rax, 0x01           ; write64 (rdi, rsi, rdx) (int fd, void* buf, size_t count)
                mov rdi, 1              ; stdout
                mov rdx, 1
                ; rsi = ptr of buffer     
                syscall
                ret
            


InsertArgument: 
                push rbp
                
                push rsp
                pop rbp
                
                add rbp, 16                     ; 8 byte * 2 = return value and rbp value


                mov r10, [String]
                mov r11b, byte [r10]            ; %<r11b>

                mov r10, [String]               ; next symbol
                inc r10
                mov [String], r10               ; after %<smth>

                cmp r11b, '%'                   
                je label_pers

                cmp r11b, 'd'                   
                je label_dec

                cmp r11b, 'x'                   
                je label_hex

                cmp r11b, 'o'                   
                je label_oct

                cmp r11b, 'b'                   
                je label_bin

                cmp r11b, 'c'                   
                je label_char

                cmp r11b, 's'                   
                je label_str


                label_pers:
                        mov rsi, PercentSymbol            ; write twice '%' 
                        call _PutChar
                        call _PutChar

                        jmp exit_switch

                label_hex:
                        mov rsi, [rsp + r8]
                        add r8, 8
                        ;call PrintHex
                        jmp exit_switch

                label_oct:
                        mov rsi, [rsp + r8]
                        add r8, 8
                        ;call PrintOct

                        jmp exit_switch

                label_dec:
                        add r8, 8
                        mov rsi, [rsp + r8]
                        ;call PrintDec

                        jmp exit_switch

                label_char:
                        mov rsi, rbp
                        
                        add r8, 8

                        call _PutChar 
                        jmp exit_switch

                label_str:
                        mov rsi, [rbp + r8]
                        add r8, 8
                        
                        call PrintArgStr
                        jmp exit_switch

                label_bin:
                        mov rsi, [rsp + r8]
                        add r8, 8
                        ;call PrintBin
                        jmp exit_switch

                exit_switch:       
                
                pop rbp
                ret

; PrintHex:       

;                 ret

; PrintOct:
;                 ret

PrintArgStr:    
                loop_3:
                        mov r11b, byte [rsi]
                        cmp r11b, 0x00                  ; '\0'
                        je endloop_3

                        call _PutChar

                        inc rsi

                        jmp loop_3
                endloop_3:

                ret

; PrintDec:       


;                 ret


; PrintBin:       
                

;                 ret





section     .data
String      db      0
PercentSymbol   db      "%"
section .text

global sum
sum:    add rdi, rsi
        mov rax, rdi

        ret
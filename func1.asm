global _start
extern printf   ;
  
 
section .text
_start:
        lea rdi, message        ; 1-й параметр функции printf - адрес строки
        call printf             ; вызываем функцию printf
        mov rax, 60    
        syscall


section .data 
message: db "Арсений пидорас скотина ублюдина!!!",10, 0
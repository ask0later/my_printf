#include <stdlib.h>
#include <stdio.h>


// nasm -f elf64  print.asm
// g++ -no-pie main.cpp print.o

extern "C" int my_printf(const char x[], ...);

int main()
{

        int       num1 = 32;
        long long num2 = -1111;
        long long num3 = -1;

        const char str1[] = "karina";
        const char str3[] = "love";

        my_printf("number = <%o>, <%s>, <%d>, <%x>, <%b>, %c %%\n %d %s %x %d %% %c %b", num1, str1, num2, num3, 888, 'g', -1, str3, 3802, 100, 33, 31);

        return 0;
}
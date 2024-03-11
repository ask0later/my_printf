#include <stdlib.h>
#include <stdio.h>

//extern "C" int sum(int x, int y);

extern "C" int my_printf(const char x[], ...);

int main()
{

        int       num1 = 32;
        long long num2 = -1111;
        long long num3 = -1;

        const char str1[] = "karina";

        my_printf("number = <%o>, <%s>, <%d>, <%x>, <%b>, %c %%\n", num1, str1, num2, num3, 888, 'g');

        return 0;
}
#include <stdlib.h>
#include <stdio.h>

//extern "C" int sum(int x, int y);

extern "C" int _PrintString(const char x[], ...);

int main()
{
        
        _PrintString("HELLO MY NAME IS %s my SURNAME IS %s, %c \n", "YAROSLAV", "zzzzzzzz", 'd');

        return 0;
}
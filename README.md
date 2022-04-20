# myth

## 用c程序作为ld, segmentation fault
```
╰$ gcc -static -o c c.c
╰$ gcc -Wl,-dynamic-linker,c -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |     ^~~~
╰$ ./hello 
[1]    48368 segmentation fault  ./hello
```

## 用go程序作为ld，正常
```
╰$ gcc -Wl,-dynamic-linker,go -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |     ^~~~
╰$ ./hello
```
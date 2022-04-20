# myth

## 用c程序作为ld, segmentation fault
```
╰$ gcc -static -o c c.c
c.c: In function ‘main’:
c.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("ld wrotten in c");
      |
╰$ gcc -Wl,-dynamic-linker,c -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |
╭─st0n3@yoga in ~/myproject/ld_myth on main ✘ (origin/main)
╰$ ldd hello
	linux-vdso.so.1 (0x00007ffccd945000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f8b44a88000)
	c => /lib64/ld-linux-x86-64.so.2 (0x00007f8b44c85000)
╰$ ./hello 
[1]    49773 segmentation fault  ./hello
```

## 用go程序作为ld，正常
```
╰$ go build go.go  
╰$ gcc -Wl,-dynamic-linker,go -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |     ^~~~
╰$ ldd hello
	linux-vdso.so.1 (0x00007ffd789e2000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f93f34f1000)
	go => /lib64/ld-linux-x86-64.so.2 (0x00007f93f36ee000)
╰$ ./hello 
ld wrotten in go
```
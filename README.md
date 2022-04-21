# myth

## 用c程序作为ld, segmentation fault
```
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ gcc -static -o c c.c
c.c: In function ‘main’:
c.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("ld wrotten in c");
      |
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ gcc -Wl,-dynamic-linker,c -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ldd hello
	linux-vdso.so.1 (0x00007ffccd945000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f8b44a88000)
	c => /lib64/ld-linux-x86-64.so.2 (0x00007f8b44c85000)
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ./hello 
[1]    49773 segmentation fault  ./hello
```

## 用go程序作为ld，正常
```
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ go build go.go  
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ gcc -Wl,-dynamic-linker,go -o hello hello.c
hello.c: In function ‘main’:
hello.c:2:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    2 |     puts("hello");
      |     ^~~~
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ldd hello
	linux-vdso.so.1 (0x00007ffd789e2000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f93f34f1000)
	go => /lib64/ld-linux-x86-64.so.2 (0x00007f93f36ee000)
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ./hello 
ld wrotten in go
```

## asm .data 正常

```
nasm -f elf64 asm.asm -o asm.o
ld -s -static -o asm asm.o
gcc -Wl,-dynamic-linker,asm -o hello hello.c
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ./hello 
[1]    64101 segmentation fault  ./hello
```

## asm .rodata 段错误
```
nasm -f elf64 asm2.asm -o asm2.o
ld -s -static -o asm2 asm2.o
gcc -Wl,-dynamic-linker,asm2 -o hello hello.c
╭─st0n3@yoga in ~/myproject/ld_myth on main ✔ (origin/main)
╰$ ./hello 
[1]    63992 segmentation fault  ./hello
```
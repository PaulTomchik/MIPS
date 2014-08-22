# With modifications, code taken from
# https://webcache.googleusercontent.com/search?q=cache:xDL5n2PIkosJ:www.linux-mips.org/wiki/Syscall+&cd=4&hl=en&ct=clnk&gl=us

#define O_RDWR                02

        .set    noreorder
        .globl  main

main:
#       fd = open("/dev/stdout", O_RDWR, 0);
        la      $a0,stdout
        li      $a1,2
        li      $a2,0
        li      $v0,4005
        syscall

        bnez    $a3,quit
        move    $s0,$v0                           # delay slot

#       write(fd, "hello, world.\n", 14);
        move    $a0,$s0
        la      $a1,hello
        li      $a2,14
        li      $v0,4004
        syscall

#       close(fd);
        move    $a0,$s0
        li      $v0,4006
        syscall

quit:
        li      $a0,0
        li      $v0,4001
        syscall

        j       quit
        nop

        .data
stdout:    .asciz  "/dev/stdout"
hello:  .ascii  "Hello, world.\n"

# Program: Hello, World!

# include <unistd.h>
# include <stdio.h>

          .data   # data declaration section; 
Hello:    .asciiz "Hello, World!\n"

          .text  # Start of code section
          .globl main

main:     la $a0, Hello
          jal printf

          add $a0, $0, $0
          jal exit

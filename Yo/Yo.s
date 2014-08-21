# This file contains the implementation of Yo

# include <stdio.h>

# Data segment

      .data
Yo:    .asciiz  "Yo\n"

      .text
      .global yo
yo:   
      addi  $sp, $sp, -4    # Prep for push
      sw    $ra, 0($sp)
      
      la     $a0, Yo
      jal   printf

      lw    $ra, 0($sp)
      addi  $sp, $sp, 4

      jr    $ra

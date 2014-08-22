# Quicksort
# void qsort (void* base, size_t num, size_t size,
#              int (*compar)(const void*,const void*));

# TODO: Figure out how to reference NULL macro from stdlib


# include <stdlib.h>

  .text
  .globl qcksrt

/* The quicksort algorithm
 *
 *    Parameters
 *
 *      $a0: mem address of the base
 *      $a1: number of elements (Unsigned int)
 *      $a2: size of an element (in bytes)
 *      $a3: pointer to the comparator
 */
# We shall use the first element of the array for the pivot
# assumes total mem of array < 2^32

qcksrt:
  add   $t0,$0,$0              # Use NULL from stdlib
  addi  $t1,$a1,-1
  addi  $t2,$a2,-1
                               # Escape conditions:
  beq   $a0,$t0,qcksrt_done    # if the base address is NULL
  blez  $t1,qcksrt_done        # if the number of elems <= 1
  bltz  $t2,qcksrt_done        # if the size of an elem <1
  beq   $a3,$t0,qcksrt_done    # if the comparitor ptr is NULL

  # push the saved registers to the stack
  addi  $sp,$sp,-32
  sw    $ra,28($sp)
  sw    $s6,24($sp)
  sw    $s5,20($sp)
  sw    $s4,16($sp)
  sw    $s3,12($sp)
  sw    $s2,8($sp)
  sw    $s1,4($sp)
  sw    $s0,0($sp)

  # Move the params to saved registers
  add   $s0,$a0,$0            # $s0 := base addr, used as PIVOT
  add   $s1,$a1,$0            # $s1 := num of elems
  add   $s2,$a2,$0            # $s2 := size of an elem
  add   $s3,$a3,$0            # $s3 := ptr to the comparator

  add   $s4,$s0,$0            # $s4 := init left scanner to the PIVOT
  mult  $s1,$s2               # Get the total mem footprint of array
  mflo  $t0                   # $t0 := total mem of array
  add   $s5,$s0,$t0           # $s5 := init right scanner to END
  add   $s6,$s0,$t0           # $s6 := END

leftscan:
  add   $s4,$s4,$s2           # Increment the left scanner
  sub   $t0,$s5,$s4           # Is the left scanner past the right?
  bltz  $t0,exchange_elems    #   if so, swap done scanning
  add   $a0,$s0,$0            # pass the pivot as arg0 of comparator
  add   $a1,$s4,$0            # pass the left scanner as arg1 of comparator
  jalr  $s3                   # call the comparator
  blez  $v0,rightscan         # If pivot < left scanner, start right scan
  j     leftscan              # continue left scan  
rightscan:        
  sub   $s5,$s5,$s2           # Decrement. (Not possible to go past beginning.)
  add   $a0,$s0,$0            # pass the pivot as arg0 of comparator
  add   $a1,$s5,$0            # pass the right scanner as arg1 of comparator
  jalr  $s3                   # call the comparator
  bgez  $v0,exchange_elems    # If pivot >= right scanner, stop scan. TODO? > better?
  j     rightscan

exchange_elems:
  sub   $t0,$s5,$s4           # $t0 := Have the scanners crossed? If $t0 < 0, yes.
  add   $t1,$s5,$0            # $t1 := init elem1 to right scanner
  add   $t3,$0,$0             # $t3 := init the transfered byte counter to zero
  bltz  $t0,crossed  
  add   $t2,$s4,$0            # $t2 := init elem2 to left scanner 
  j     mv_data
crossed:
  add    $t2,$s0,$0           # $t2 := init elem2 to the PIVOT

mv_data:
  lbu   $t4,0($t1)            # $t4 := move data at right scanner ptr to a temp register
  lbu   $t5,0($t2)            # $t4 := move data at right scanner ptr to a temp register
  sb    $t4,0($t2)            # move data from pivot ptr to the scanner ptr
  sb    $t5,0($t1)            # move data from the temp reg to the pivot ptr
  addi  $t1,$t1,1             # increment the elem1 cursor
  addi  $t2,$t2,1             # increment the elem2 cursor
  addi  $t3,$t3,1             # increment the counter
  sub   $t4,$s2,$t3           # $t5 := Have we transfered all the blocks?
  bgtz  $t4,mv_data           #    if not, continue transfer

  bgtz  $t0,leftscan          # Scanners haven't yet crossed
  
# Prepare for recursive call (note: the pivot is now at $s5)

  # Left Partition
  add   $a0,$s0,$0           # base stays the same
  sub   $t0,$s5,$s0          # $t0 = num of bytes between base and pivot
  div   $t0,$s2              # (Num of bytes) / (bytes per elem)
  mflo  $a1                  # Num of elems in left partition
  add   $a2,$s2,$0           # size of elem remains unchanged
  add   $a3,$s3,$0           # comparator remains unchanged
  add   $s0,$s5,$s2          # $s0 := base of the right partition = elem after pivot
  jal   qcksrt

  # Right Partition
  add   $a0,$s0,$0           # base of right partition
  sub   $t0,$s6,$s0          # $t0 = num of bytes between end & right partition base
  div   $t0,$s2              # (Num of bytes) / (bytes per elem)
  mflo  $a1                  # Number of elems in right partiton (could be zero)
  add   $a2,$s2,$0           # size of elem remains unchanged
  add   $a3,$s3,$0           # comparator remains unchanged
  jal   qcksrt

  # Restore values in the saved registers
pop_stack:
  lw    $ra,28($sp)
  lw    $s6,24($sp)
  lw    $s5,20($sp)
  lw    $s4,16($sp)
  lw    $s3,12($sp)
  lw    $s2,8($sp)
  lw    $s1,4($sp)
  lw    $s0,0($sp)
  addi  $sp,$sp,32      # restore the stack pointer

qcksrt_done:
  jr    $ra

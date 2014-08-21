# I wrote this code while learning MIPS for CSI333 @ ualbany
# It uses SPIM. I have yet to convert to gcc.
#
#	Current goals: skip whitespace method, parseCommand behave like strtok
#			??? Why not just implement strtok ???
	
	.data
	
# Node structure
#	 __________
#	|  count  |	int -  4bytes; offset = 0
#	|- - - - -|
#	|  symbol |	char* -  8bytes; offset = 4
#	|	  |
#	|- - - - -|
#	| nextPtr |	node* -  8bytes; offset = 12
#	|	  |
#	|- - - - -|

# Command Codes
#	INS: 1
	
nodeCountSize:		.word	4
nodeSymbolPtrSize:	.word	8
nodeNextPtrSize:	.word	8
nodeSymbolPtrOffset:	.word	4
nodeNextPtrOffset:	.word	12

# Output Formatting
endln:	        .asciiz	"\n"

# User Input Data
userInputStr:	.space	100
endCommand:	.asciiz	"end"

	
		.text 
		.globl main

	
# ==================== MAIN ====================
#
main:	 	addu	$s1,$0,$0			# $s1 is list head; initialized to NULL		
	
userInputLoop:	la	$a0, userInputStr	
	addu	$a1,$a0,99
	addu	$v0,$0,8
	syscall

	# Trim the '\n' off of the user input string
	# TODO: Improve implementation
	la	$a0, userInputStr
	jal	strlen
	la	$t0,userInputStr
	addu	$t1,$v0,$t0
	addi	$t1,$t1,-1
	sb	$0,($t1)
		
	# Check for "end" command
	la	$a0, userInputStr
	la	$a1, endCommand
	jal	strcmp
	beqz	$v0, endMain

	# Determine the command
	la	$a0, userInputStr
	jal 	getCommand

	j	userInputLoop
		
endMain: j	endProgram
#
# - - - - - - - - - - - end main - - - - - - - - - - - - - - 

	
# ==================== Get Command ====================
#
#	params:
#		$a0 = the string to parse
#	returns:
#		$v0 = the command code
#		$v1 = the pointer to the first non-whitespace char after the code
#			(null if no such char)
#
#	strtok like behavior
#	inserts '\0' in 4th char after the 1st non-whitespace char
#	returns pointer to the first non-whitespace after the command code
#
getCommand: li	$v0,-1			
bgnGetCommLoop: beqz	$a0,endGetCommand
		lb	$t0,($a0)
		li	$t1, 32				# ASCII for ' ' = 32
		beq	$t0, $t1, bgnGetCommLoop
		li	$t1, 9				# ASCII for '\t' = 9
		beq	$t0, $t1, bgnGetCommLoop
		li	$t1, 73				# ASCII for 'I' = 73
		bne	$t0,$t1,notINS
		addi	$a0,$a0,1			# increment strptr
		lb	$t0,($a0)
		li	$t1, 78				# ASCII for 'N' = 78
		bne	$t0,$t1,notINS
		addi	$a0,$a0,1			# increment strptr
		lb	$t0,($a0)
		li	$t1, 83				# ASCII for 'S' = 83
		bne	$t0,$t1,notINS
		li	$v0,1				# code for INS = 1
	
notINS:		addi	$v0,$a0,1			# move the 
		j	endGetCommand
		
endGetCommand: 	jr	$ra
#	
# - - - - - - - - - - - end getCommand - - - - - - - - - - -


	
# ===================== String Tokenizer ====================
#
# 	params:
#		$a0 = string to tokenize
#			If $a0 == NULL, continues tokenizing strtokLeftOff
#	 	$a1 = string of delimiters
#
#	returns:
# 		$v0 = pointer to the first character not in the list of delimiters
#			NULL if noting but delimiter chars
# 
#	!!! NOTE: This procedure is DESTRUCTIVE !!!
#		 Like C's strtok, replaces the first delimiter character 
#		 after the token with a '\0' !!!
#
#	
		# Need a static variable 
		.data
strtokLeftOff:	.word	8			# static variable for the last str tokenized

		.text

		# If string to tokenize null, use strtokLeftOff
strtok:		bnez	$a0, tokStrIsSet
		la	$a0, strtokLeftOff

		# If strtokLeftOff is null as well; TODO: probably should throw exception
		bnez	$a0, tokStrIsSet
		j	endStrtok

tokStrIsSet:	sw	$0, strtokLeftOff 		# set strtokLeftOff to default of NULL

		# If delimtersString NULL, return
		beqz	$a1,endStrtok
		
		# If the delimters string is empty, return 
		lb	$t0,($a1)
		beqz	$t0,endStrtok

	## Early exit cases covered... must parse the toTokenize string
		## Need to find the first non-delimiter char of toTokenize string 
		la	$t2, tokAtToken1stChar		# After done, jump to the movetoEndOfToken subroutine
		la	$t5, tokFindNonDelim
		j	tokFindDelim
	
	## tokFindNonDelim register mapping
	##
	## 	$a1 = char* to the 1st char of delimters string
	## 	$t0 = cursor over toTokenize (either for token start or 1st delim after token)
	## 	$t1 = cursor over delimiters string
	## 	$t2 = where to jump on loop break
	## 	$t3 = current char of toTokenize
	## 	$t4 = current delim char
	## 	$t5 = where to jump if char is a delim
	## 
	## TODO: could break out the following routine as a contains() procedure
	## 		??? Is it better to do now, or get working then break out ???
	## 
	## Algorithm:
	## 	Loop over delims, comparing with current toTokenize char
	## 		If match, increment toTokenize cursor & reset delims cursor to start
	## 		If no match, iterate delims cursor
	## 			if cursor at end of delims, break loop
	## 			
	## 	For the current char from toTokenize, must iterate over all delimiters 
tokFindNonDelim: addi	$t0,$t0,1 			# increment the pointer on toTokenize string

tokFindDelim:	move	$t0,$a0				# Initialize cursor of the toTokenizeString
		lb	$t3,($t0)			# $t3 <- current char of toTokenize
		beqz	$t3,$t2				# if at end of toTokenize, break the loop
		move	$t1,$a1				# reset delimiters cursor

tokCmpDelims:	lb	$t4,($t1)			# $t4 <- current char of delimiterString
		beqz	$t4, $t2 			# reached end of delimiter string

		## If current delim char != current toTokenize char, increment delims cursor
		bneq	$t3,$t4,tok2NxtDelim
		## Match between current toTokenize string and a delimiter
		j	$t5				# jump loop break specified for delim found
	
		##  Increment the cursors on delimiters & jump to top of cmpDelims loop
tok2NxtDelim: 	addi 	$t1,$t1,1
		j	tokCmpDelims		
	
	## At this point, cursor over toTokenize on firstNondelimiter char of token (could be '\0')

tokAtToken1stChar: move	$t0,$a0				# move toTokenize pointer to first nondelim char
		lb	$t3, ($t0)			# currently redundant, decoupling for eventual contains()
		beqz	$t3, endStrtok			# if cursor over toToken reached end, goto end routine
		la	$t2, tokZero1stDelim		# set jump2onBreak sub-routine to replaceWithNull
		la	$t5, tokZero1stDelim		# if 
		j	tokFindNonDelim

	## At this point, cursor over toTokenize on firstNondelimiter char after token (could be '\0')

## ~~~~~~~~~~~~~~~~~~~~~~ LEFT OFF ~~~~~~~~~~~~~~~~~~~~~~ 
tokZero1stDelim: lb	$t3,($t0) 			# 
		
		sb	$0,($a2)

	
endStrtok:	lb	$t0,($a0) 			# $t0 <- current char of toTokenize cursor
		lb	$t1,($a3)			# $t1 <- current char of leftOff seeker 

		bnez	$t0, tokFoundToken	
		move	$a0,$0
		sw	$0, strtokLeftOff
		bnez	$t1, strtokLeftOffSet
		sw	$0, strtokLeftOff

strtokLeftOffNotNull:
		## Set strtokLeftOff 
		bnez	$t1, strtokLeftOffSet
		sw	$0, strtokLeftOff

		## Return NULL if toTokenize On NULL
strtokLeftOffSet: 
strtokReturn:	lb	$t0,($t3)
		
		sw	$t2, strtokLeftOff #
		move	$v0,$a0
		jr	$ra


## Algorithm
## 1) Move $a0 along until a non-delimiter character reached
## 	-  If no such char found, return NULL
## 2) Move ptr along token until delimter char reached & replace with '\0'
## 		then move strtokLeftOff to the next char
## 	-  If end of str reached, set strtokLeftOff to NULL

#
# - - - - - - - - - -  end String Tokenizer - - - - - - - - - - 


	
# ===================== Insert Node =====================
#
# 	params:
# 		&listHead = $a0
# 		&symbol	 = $a1
#	returns:
#		$v0 = &listHead 
#
#	!!! Note: Caller should assign $v0 to local variable for listHead
#
		# need to spill registers
insertSymbol: 	addi	$sp,$sp,-32		# allocate 16 bytes on the stack
		sw	$ra,24($sp)		# spill registers
		sw	$s0,16($sp)			
		sw	$s1,8($sp)			
		sw	$s2,($sp)			
	
		# Check if list empty
		move	$s0, $a0		# $s0 <- List Head
		move	$s1, $a1		# $s1 <- Symbol address
		bnez	$s0, insSearchLoop		

		# The list head is null; ergo empty list
		move	$a0,$s1			# pass & of the symbol to insert to newNode
		jal	newNode								
		move	$s0,$v0
		j	endInsertSymbol		# newNode already in $v0, ready to return to caller

		# Search for symbol in list
		move	$s2,$s0			# init the cursor
insSearchLoop:	lw	$a0,4($s2)		# $a0 <- &node.symbol
		move	$a1,$s1			# $a1 <- $searchedForSymbol
		jal	strcmp

		# If str comp returns 0, increment count 
		bnez	$v0, insNotMatch
		lw	$t0,($s2)
		addi	$t0,$t0,1
		sw	$t0,($s2)
		j 	endInsertSymbol
		
		# Else move to node.next
insNotMatch:	lw	$s2,12($s2)

		# If node.next != NULL, continue search
		bnez	$s2,insSearchLoop
		# Else, append new node to end of list
		move	$a0,$s2
		jal	newNode								
		sw	$v0,12($s2)
		j	endInsertSymbol		# newNode already in $v0, ready to return to caller
	
endInsertSymbol: move	$v0,$s0			# put the list head in the return register
		lw	$s2,($sp)		# retore registers from the stack	
		lw	$s1,8($sp)
		lw	$s0,16($sp)
		lw	$ra,24($sp)
		addi	$sp,$sp,32		# restore stack pointer
		jr	$ra
#
# - - - - - - - - - -  end insertSymbol - - - - - - - - - - -


#===================== Get string length =====================
#
#	params:
# 		$a0 = & string for which to find length	
#
#	returns:
#		$v0 = length of the string
# 
strlen: addu	$t0,$0,$a0		# $t0 <== & of the string of which to find length
	beqz	$t0,endStrlenLoop	# NULL ptr check 
		
begStrlenLoop:
	lbu 	$t1,($t0)
	beqz	$t1,endStrlenLoop
	addu	$t0,$t0,1		# increment the char pointer
	j	begStrlenLoop
endStrlenLoop:
	subu	$v0,$t0,$a0		# return (current char pointer) - (start address of string passed in) 
	jr	$ra				
#	
#- - - - - - - - - -  end strlen - - - - - - - - - - -


	
#===================== NewNode =====================
#
# 	params:
#		$a0 = symbol string
#
#	returns:
#		$v0 = pointer to new node
#
# Allocate heap memory for, and set intial values of, a node
#
newNode: addi	$sp,$sp,-24			# allocate 16 bytes on the stack
	sw	$ra,16($sp)
	sw	$s0,8($sp)			# spill registers
	sw	$s1,($sp)

	# $s0 holds address of symbol param
	# $s1 holds address of the new node
	move	$s0,$a0				# $s0 <== node symbol, passed as parameter
	lw	$t1,nodeSymbolPtrSize		# compute the memory size of a node
	lw	$t2,nodeCountSize
	lw	$t3,nodeNextPtrSize
	addu	$t1,$t1,$t2			# $t1 <== sum of node member sizes
	addu	$t1,$t1,$t3
	addu	$a0,$0,$t1			# request block of node size ($t1)
	addu	$v0,$0,9			# allocates a block of memory
	syscall					# ??? is $t0 safe ???
	move	$s1,$v0				# $s1 <- address of allocated memory

	# Set count to 1
	li	$t0,1
	sw	$t0,($s1)			# node.count <- 1				 

	# Duplicate the symbol parameter
	move	$a0,$s0
	jal	strdup
	sw	$v0,4($s1)
	
	# Set next to NULL
	sw	$0,12($s1)

	move	$v0,$s1				# $v0 <- & of new node
	lw	$s1,($sp)			# restore $s0 from stack
	lw	$s0,8($sp)			# restore $s0 from stack
	lw	$ra,16($sp)			# restore $ra from stack
	addi	$sp,$sp,24			# restore stack pointer
	jr	$ra				# address of new node still in $v0
#
# - - - - - - - - - -  end newNode - - - - - - - - - - -


	
# ==================== String Duplicate ====================
#
	# Spill registers to the stack
strdup:	beqz	$a0,strdupRtnNULL		# end routine if null pointer passed in
	addi	$sp,$sp,-12			# save registers to the stack
	sw	$s0,8($sp)
	sw	$s1,4($sp)
	sw	$s2,($sp)
		
	# copy address of string to copy to an $s register
	addu	$s0,$0,$a0				
	addu	$s2,$0,$ra

	# Find the length of the original
	addu	$a0,$0,$s0
	jal	strlen
	addi	$t0,$v0,1	

	# Allocate memory for the copy 
	addu	$a0,$0,$t0			# request block of node size
	addi	$v0,$0,9			# allocates a block of memory	
	syscall
	addu	$s1,$0,$v0			# $s1 <== & copy
			
	# Copy the characters of the string
	addu	$a0,$0,$s1
	addu	$a1,$0,$s0		
	jal	strcpy
	addu	$v0,$0,$s1			# $v0 <== & of string copy
						
	addu	$ra,$0,$s2			# restore registers from stack
	lw	$s2,($sp)
	lw	$s1,4($sp)		
	lw	$s0,8($sp)
	addi	$sp,$sp,12
	jr	$ra

strdupRtnNULL: 	addu	$v0,$0,$0
		jr	$ra
#
# - - - - - - - - - -  end strdup - - - - - - - - - - -


	
# ===================== String Copy =====================
#
strcpy:
strcpyLoop:				# do while; handles "\0"
		lb	$t0, ($a1)		# $a0 == destinationString address	
		sb	$t0, ($a0)		# $a1 == sourceString address
		beqz	$t0, endStrcpy
		addi	$a0,$a0,1
		addi	$a1,$a1,1
		j	strcpyLoop
endStrcpy:
		jr	$ra
#
# - - - - - - - - - - - end strcpy - - - - - - - - - - - 


	
# =========================== String Compare ====================
#
strcmp: lbu	$t0,($a0)
	lbu	$t1,($a1)
	beqz	$t0,endStrcmp
	beqz	$t1,endStrcmp
	bne	$t0,$t1,endStrcmp
	addu	$a0,$a0,1
	addu	$a1,$a1,1
	j	strcmp		
	
endStrcmp: sub	$v0,$t0,$t1
	jr	$ra
#
# - - - - - - - - - -  end strcmp - - - - - - - - - - 



# ===================== Print List =====================
#
printList:	move	$t0,$a0				# $t0 <== List head passed in as parameter
printLoop:	beq 	$t0,$0,endPrintLoop

		# Print the count
		lw	$a0,($t0)			# $t1 <== node1.value
		addu	$v0,$0,1			# Print the int
		syscall 

		# Print a '\t'
		li	$a0,9				# $ao <= '\t'
		li	$v0,11				# Print char
		syscall
	
		# Print the node's symbol
		la	$a0,4($t0)
		li	$v0,4				# Print string
		syscall

		# Assign &newNode to previous node's next
		lw	$t1,nodeNextPtrOffset		
		add	$t1,$t1,$t0
		lw	$t0,($t1)
		bnez	$t0,printLoop
endPrintLoop:	jr	$ra
#
# - - - - - - - - - -  endPrintList - - - - - - - - - - -
	
		
	
# ===================== End the program =====================
#
endProgram:	addu	$v0, $0, 10		#halt code
		syscall
#
# - - - - - - - - - -end endProgram - - - - - - - - - - 

		
## ==================== Coding Helpers =====================
#DEBUG
#		addu	$a0,$0,$t1
#		addu	$v0,$0,11				#print char
#		syscall
#end DEBUG
		

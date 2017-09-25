# Radix Sort
# Author:			Caleb Baker
# Date:				September 18, 2017
# Function header:	void radixSort(int size, int *A)
# Summary:			A is an array of size size.
#					This function sorts it using radix sort.
# Modified: 9/20/17 by Caleb Baker
#			Changed it to sort by bytes rather than bits.


# Indexes to things starting from esp
# Indexes are only valid between subl $16, %esp and popl %ebx
.equ selectionBit, 0
.equ basePointer, 4
.equ size, 20
.equ A, 24

.equ SYS_BRK, 45
.equ LINUX_SYSCALL, 0x80

.section .bss
.lcomm countArray, 0x400

.section .data
stackSave:
	.long 0
selectByteSave:
	.long 0

.section .text
.globl radixSort
.type radixSort, @function

radixSort:
	pushl %ebp
	movl %esp, %ebp

	pushl %ebx

	# allocate an extra array to work with since this will not be an in-place sort
	# first find current break point
	movl $SYS_BRK, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL
	incl %eax
	subl $8, %esp	# Indexes are now valid
	movl %ebp, basePointer(%esp)
	movl %eax, %ebp

	# Set ebx to be the desired breakpoint
	# eax holds the address for the start of workArray
	movl size(%esp), %ebx
	shll $2, %ebx	# Array is 4 byte integers
	addl %eax, %ebx

	# Request more memory
	movl $SYS_BRK, %eax
	int $LINUX_SYSCALL


	# cl tracks which byte the items are being sorted by
	movb $0, %cl

	# esi holds the size of the arrays
	movl size(%esp), %esi

	# edi holds the address of the array
	movl A(%esp), %edi


mainLoop:
		movl $countArray, %ebx
		movl $0xFF, %edx
clearLoop:
			movl $0, 0(%ebx,%edx,4)
			decl %edx
			jns clearLoop


		movl size(%esp), %esi
		decl %esi
		movl $0xFF, %edx
		shll %cl, %edx

			# eax - scratch
			# ebx - countArray
			# cl - selection byte index
			# edx - selection byte
			# esi - loop control
			# edi - main array
			# ebp - work array
countLoop:
			movl %edx, %eax	# Create a copy of edx
			andl 0(%edi,%esi,4), %eax
			shrl %cl, %eax
			incl 0(%ebx,%eax,4)
			decl %esi
			jns countLoop

		movl $1, %esi
		movl (%ebx), %eax

			# Get some sums.
sumLoop:
			addl 0(%ebx,%esi,4), %eax
			movl %eax, 0(%ebx,%esi,4)
			incl %esi
			cmp $0x100, %esi
			jne sumLoop


		# Set eax for loop control
		decl %eax

		movl %edx, selectByteSave
		# Very hackish solution for when I really need one more register
		movl %esp, stackSave

			# eax - loop control
			# ebx - count array
			# cl  - selection byte index
			# edx - scratch
			# esi - scratch
			# edi - main array
			# ebp - workArray
			# esp - item to be considered
fillLoop:
			# Check selection bit and branch accordingly
			movl 0(%edi,%eax,4), %esi
			movl %esi, %esp
			andl selectByteSave, %esi
			shrl %cl, %esi

			movl 0(%ebx,%esi,4), %edx
			decl %edx
			movl %esp, 0(%ebp,%edx,4)
			decl 0(%ebx,%esi,4)

			# decrement eax and keep looping if non-negative
			decl %eax
			jns fillLoop

		# Restore esp and thereby return to sanity.
		movl stackSave, %esp
		movl selectByteSave, %edx

		# Swap the roles of the arrays
		xchg %edi, %ebp

		# Increment cl and probably jump to start of loop
		addb $8, %cl
		cmp $32, %cl
		jne mainLoop	#jump if not equal

	movl basePointer(%esp), %ebp

	popl %ebx	# Indexes are no longer valid

	movl %ebp, %esp
	popl %ebp
	ret

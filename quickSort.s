-- Main Function
-- int main();
-- R4:	function call first parameter
-- R5:	function call second paramter
-- R30:	stack pointer
--
Begin Assembly
--
-- Set stack pointer
-- Stack begins at 4000, but there is already an array on the stack
ADDI R30, R0, 4040
--
-- quickSort(arr, 10)
ADDI R4, R30, -40
ADDI R5, R0, 10
JAL quickSort
--
-- Finish
HALT
--
--
--
-- Quick Sort Subroutine
-- void quickSort(long *arr, size_t len);
-- R2:	Scratch Register
-- R4:	arr
-- R5:	len
-- R8:	pivot_index
-- R9:	pivot
-- R10:	i
-- R11:	j
-- R12: Scratch Register / left_len
-- R2, R4, R5, R8, R9, R10, R11, and R12 are caller saved 
--
LABEL quickSort
--
-- Allocate stack space and put return address on stack
ADDI R30, R30, 24
SW R31, -24(R30)
--
-- if (len < 2) return
ADDI R2, R5, -2
BLTZ R2, return
--
-- Set pivot, pivot_index, i, and j
ADDI R8, R5, -1
SLL R8, R8, 2
ADD R8, R8, R4
LW R9, 0(R8)
ADD R10, R4, R0
ADD R11, R4, R0
--
-- Partition
LABEL partition
LW R2, 0(R11)
SUB R12, R9, R2
BLEZ R12, postIf
LW R12, 0(R10)
SW R2, 0(R10)
SW R12, 0(R11)
ADDI R10, R10, 4
LABEL postIf
ADDI R11, R11, 4
BNE R8, R11, partition
--
-- SWAP(i,pivot_index)
LW R2, 0(R8)
LW R12, 0(R10)
SW R2, 0(R10)
SW R12, 0(R8)
--
-- Save arr and left_len to stack
SUB R12, R10, R4
SRL R12, R12, 2
SW R4, -16(R30)
SW R12, -8(R30)
--
-- quickSort(i + 1, len - left_len - 1)
ADDI R4, R10, 4
SUB R5, R5, R12
ADDI R5, R5, -1
JAL quickSort
--
-- quickSort(arr, left_len)
LW R4, -16(R30)
LW R5, -8(R30)
JAL quickSort
--
LABEL return
LW R31, -24(R30)
ADDI R30, R30, -24
JR R31
--
End Assembly
Begin Data 4000 1000
0
4
6
8
1
3
5
2
9
7
End Data

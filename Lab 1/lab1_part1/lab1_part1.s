	.text

	.global _start

	.org	0x00000000
	
	_start:
		
		# n_list1_has_max is r3
		movi	r3, 0
		# counting variable 'i' is r4
		movi		r4, 0
		# n is r5
		movi		r5, 0
		addi	r5, r5, 4
		# LIST1 is r6, LIST2 is r7, LIST3 is r8
		movia	r6, LIST1
		movia	r7, LIST2
		movia 	r8, LIST3
	
		call	ListMax
		
		movia	r2, MAX1_CNT
		stw		r3, 0(r2)
		br		_end
		
	_end:
		br	_end
	
	ListMax:
		
		ldw		r9, 0(r6)
		ldw		r10, 0(r7)
		ldw		r11, 0(r8)
		bgt		r10, r9, ELSE

		addi	r3, r3, 1
		stw		r9, 0(r8)		
		br		INCREMENT
		
	ELSE:	
		stw		r10, 0(r8)
		
	INCREMENT:
		addi	r6, r6, 4 #increment LIST1
		addi 	r7, r7, 4 #increment LIST2
		addi	r8, r8, 4 #increment LIST3
		addi	r4, r4, 1 #increment counter 'i'
		bgt		r5, r4, ListMax
		ret
	
	
	.org 0x1000
	
	MAX1_CNT:	.skip	4
	LIST1:		.word	9,6,7,8
	LIST2:		.word	8,7,6,5
	LIST3:		.skip	16
	
	.end
.global _start
.intel_syntax noprefix

.data
grid: .skip 256, 0x00
grid_ss: .skip 256, 0x00
character: .byte 0x00

.text
_start: 
	lea r11, [grid]
	lea r12, [grid_ss]
	mov r13, r12
	lea r15, [character]
	xor r9, r9

	verify_neighbors:
	cmp r9, 256
	je exit	
	xor r10, r10	
	
	cmp r9, 16
	jl go_middle
	go_up:
	sub r13, 16
	cmp byte ptr [r13], 0
	je verify_sides_up
	inc r10
	verify_sides_up:
	call verify_sides
	add r13, 16
	go_middle:
	call verify_sides
	cmp r9, 239
	jg decide
	go_down:
	add r13, 16
	cmp byte ptr [r13], 0
	je verify_sides_down
	inc r10
	verify_sides_down:
	call verify_sides

	decide:
	cmp byte ptr [r11], 0
	je decide_dead
	decide_live:
	cmp r10, 1
	jg condition_two_or_three
	call kill
	jmp next_cell
	condition_two_or_three:
	cmp r10, 2
	je born_cell
	cmp r10, 3
	je born_cell
	call kill
	jmp next_cell
	born_cell:
	call born
	jmp next_cell

	decide_dead:
	cmp r10, 3
	jne next_cell
	call born

	next_cell:
	inc r11
	inc r12
	inc r9
	mov r13, r12
	jmp verify_neighbors
	
	verify_sides:
	dec r13
	xor edx, edx
	mov eax, r9d
	mov ecx, 16
	div ecx
	cmp edx, 0
	je verify_right
	cmp byte ptr[r13], 0
	je verify_right
	inc r10
	verify_right:
	add r13, 2
	cmp edx, 15
	je return_side
	cmp byte ptr[r13], 0
	je return_side
	inc r10
	return_side:
	dec r13
	ret

	kill:
	mov byte ptr [r11], 0
	ret

	born:
	mov byte ptr [r11], 1
	ret

	exit: 
	xor rdi, rdi
	mov rax, 60
	syscall

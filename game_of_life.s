.global _start
.intel_syntax noprefix

.data
grid: .skip 256, 0x00
grid_ss: .skip 256, 0x00
delay:
	.quad 1
	.quad 0
limpiar: .ascii "\x1b[H"
.equ limpiar_len, 3
		
		
character: .byte 0x00


.text
_start: 
	lea r8, [grid]
	add r8, 18 
	inc byte ptr [r8]
	add r8, 17 
	inc byte ptr [r8]
	add r8, 16
	inc byte ptr[r8]
	dec r8
	inc byte ptr[r8]
	dec r8
	inc byte ptr[r8]
	lea r15, [character]
	jmp imprimir_copiar
	
	main_loop:
	call limpiar_pantalla
	lea r8, [grid]
	lea r12, [grid_ss]
	mov r13, r12
	xor r9, r9
	mov rax, 35
	lea rdi, [delay]
	mov rsi, 0
	syscall

	verify_neighbors:
	cmp r9, 256
	je imprimir_copiar
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
	cmp byte ptr [r8], 0
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
	inc r8
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
	mov byte ptr [r8], 0
	ret

	born:
	mov byte ptr [r8], 1
	ret

	imprimir_copiar:
	xor r9, r9
	lea r8, [grid]
	lea r12, [grid_ss]
	loop_filas:
		cmp r9, 256
		je main_loop

	loop_columnas:
		cmp byte ptr [r8], 1
		je asignar_vivo
		
	asignar_muerto:
		mov byte ptr [r15], 46
		jmp continuar_columnas
	asignar_vivo:
		mov byte ptr [r15], 35
	
	continuar_columnas:
		call imprimir_char
		mov r14b, byte ptr [r8]
		mov byte ptr [r12], r14b
		inc r8
		inc r12
		inc r9
		xor edx, edx
		mov eax, r9d
		mov ecx, 16
		div ecx
		cmp edx, 0
		je final_fila
		jmp loop_columnas
	

	final_fila:
	       mov byte ptr [r15], 10
	       call imprimir_char
	       jmp loop_filas

	imprimir_char:
		mov rax, 1
		mov rdi, 1
		mov rsi, r15
		mov rdx, 1
		syscall
		ret

	limpiar_pantalla:
	mov rax, 1
	mov rdi, 1
	lea rsi, [limpiar]
	mov rdx, limpiar_len
	syscall
	ret

	exit: 
	xor rdi, rdi
	mov rax, 60
	syscall

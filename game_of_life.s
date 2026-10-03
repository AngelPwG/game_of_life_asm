.global _start
.intel_syntax noprefix

.bss
termios: .skip 36
termios_new: .skip 36
// ICANON y ECHO = 0x0000000A

.data
grid: .skip 256, 0x00
grid_ss: .skip 256, 0x00
delay:
	.quad 1
	.quad 0

limpiar: .ascii "\x1b[H"
arr: .ascii "\x1b[A"
aba: .ascii "\x1b[B"
der: .ascii "\x1b[C"
izq: .ascii "\x1b[D"
ocultar_cursor: .ascii "\x1b[?25l"
mostrar_cursor: .ascii "\x1b[?25h"

.equ ascii_len, 3
		
character: .byte 0x00
key: .byte 0x00

.text
_start: 

	mov rax, 16
	mov rdi, 0
	mov rsi, 0x5401
	lea rdx, [termios]
	syscall

	mov rax, 16
	mov rdi, 0
	mov rsi, 0x5401
	lea rdx, [termios_new]
	syscall

	mov eax, [termios_new + 12]
	and eax, ~0x0000000A
	mov [termios_new + 12], eax
	
	lea rax, [termios_new + 22]
	mov byte ptr [rax], 0
	inc rax
	mov byte ptr [rax], 1

	mov rax, 16
	mov rdi, 0
	mov rsi, 0x5402
	lea rdx, [termios_new]
	syscall

	xor r9, r9
	mov rbx, 1
	lea r15, [character]

	jmp imprimir_copiar
	cursor_reset:
	call limpiar_pantalla
	xor r9, r9
	lea r8, [grid]
	edicion:
	mov rax, 0
	mov rdi, 0
	lea rsi, [key]
	mov rdx, 1
	syscall
	
	mov al, [key]
	cmp al, 0x68
	jne derecha
	mov ecx, 16
	call modulo
	cmp edx, 0
	je edicion
	dec r9
	// mover a la izquierda cursor
	push r15
	lea r15, [izq]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	jmp edicion

	derecha:
	cmp al, 0x6C
	jne abajo
	mov ecx, 16
	call modulo
	cmp edx, 15
	je edicion
	inc r9
	// mover a la derecha cursor
	push r15
	lea r15, [der]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	jmp edicion

	abajo:
	cmp al, 0x6A
	jne arriba
	cmp r9, 239
	jg edicion
	add r9, 16
	// mover el cursor hacia abajo
	push r15
	lea r15, [aba]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	jmp edicion

	arriba:
	cmp al, 0x6B
	jne enter
	cmp r9, 16
	jl edicion
	sub r9, 16
	// mover el cursor hacia arriba
	push r15
	lea r15, [arr]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	jmp edicion

	enter:
	cmp al, 0x0A
	jne salir
	xor rbx, rbx
	jmp inicializar_main

	salir:
	cmp al, 0x71
	jne toggle
	jmp exit

	toggle:
	cmp al, 0x20
	jne edicion
	xor byte ptr [r8 + r9], 1
	cmp byte ptr [r8 + r9], 1
	je char_vivo
	mov byte ptr [r15], 46
	jmp imprimir_toggle
	char_vivo:
	mov byte ptr [r15], 35
	imprimir_toggle:
	mov rdx, 1
	call imprimir_char
	push r15
	lea r15, [izq]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	jmp edicion

	inicializar_main:

	push r15
	lea r15, [ocultar_cursor]
	mov rdx, 6
	call imprimir_char
	mov rdx, 1
	pop r15

	lea rax, [termios_new + 23]
	mov byte ptr [rax], 0

	mov rax, 16
	mov rdi, 0
	mov rsi, 0x5402
	lea rdx, [termios_new]
	syscall

	jmp imprimir_copiar
	
	main_loop:
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
	mov rax, 0
	mov rdi, 0
	lea rsi, [key]
	mov rdx, 1
	syscall
	cmp rax, 0
	je continuar_verify
	
	mov al, [key]
	cmp al, 0x71
	je exit

	continuar_verify:
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
	mov ecx, 16
	call modulo
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

	modulo:
	xor edx, edx
	mov eax, r9d
	div ecx
	ret

	born:
	mov byte ptr [r8], 1
	ret

	imprimir_copiar:
	call limpiar_pantalla
	xor r9, r9
	lea r8, [grid]
	lea r12, [grid_ss]
	loop_filas:
		cmp r9, 256
		je regresar_imprimir

	loop_columnas:
		cmp byte ptr [r8], 1
		je asignar_vivo
		
	asignar_muerto:
		mov byte ptr [r15], 46
		jmp continuar_columnas
	asignar_vivo:
		mov byte ptr [r15], 35
	
	continuar_columnas:
		mov rdx, 1
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
	       mov rdx, 1
	       call imprimir_char
	       jmp loop_filas

	imprimir_char:
		mov rax, 1
		mov rdi, 1
		mov rsi, r15
		syscall
		ret

	limpiar_pantalla:
	push r15
	lea r15, [limpiar]
	mov rdx, ascii_len
	call imprimir_char
	pop r15
	ret

	regresar_imprimir:
	cmp rbx, 1
	je cursor_reset
	jmp main_loop

	exit: 
	lea r15, [mostrar_cursor]
	mov rdx, 6
	call imprimir_char
	mov rdx, 1
	mov rax, 16
	mov rdi, 0
	mov rsi, 0x5402
	lea rdx, [termios]
	syscall
	xor rdi, rdi
	mov rax, 60
	syscall

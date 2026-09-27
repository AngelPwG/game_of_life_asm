.global _start
.intel_syntax noprefix

.text
_start:
	lea rax, [tablero]
	add rax, 10
	inc byte ptr [rax]
	add rax, 9
	inc byte ptr [rax]
	add rax, 8
	inc byte ptr[rax]
	dec rax
	inc byte ptr[rax]
	dec rax
	inc byte ptr[rax]

	xor r12, r12 # Aqui hacemos que la fila se el registro que utilizaremos para las filas sea cero

	lea rbx, [tablero] # inicializamos el registro rbx con la direccion de memoria del tablero, para no tener que hacerlo en cada iteracion
	lea r14, [character] # lo mismo con el character
	loop_filas:
		cmp r12, 8 # Cmparamos para ver si ya se llego a la 8va fila
		je salir # Si se llego se sale del programa

		xor r13, r13 # El registro para las columnas se inicializa en cero
	
	loop_columnas:
		cmp r13, 8
		je final_fila
		mov rax, r12
		shl rax, 3
		add rax, r13 # Las ultimas 3 operaciones fueron para obtener el indice = fila * 8 + columna
		mov r11b, byte ptr [rbx + rax]
		cmp r11b, 1
		je asignar_vivo
		
	asignar_muerto:
		mov byte ptr [r14], 46
		jmp continuar_columnas
	asignar_vivo:
		mov byte ptr [r14], 35
	
	continuar_columnas:
		call imprimir_char
		inc r13
		jmp loop_columnas
	

	final_fila:
	       mov byte ptr [r14], 10
	       call imprimir_char
	       inc r12
	       jmp loop_filas

	imprimir_char:
		mov rax, 1
		mov rdi, 1
		mov rsi, r14
		mov rdx, 1
		syscall
		ret

	salir:
		xor rdi, rdi
		mov rax, 60
		syscall

.data
	tablero: .skip 64, 0x00
	character: .byte 0x00

; io.asm - Biblioteca de funciones auxiliares para programas en ensamblador x86
; Convención: Preserva los registros EBX, ESI, EDI, EBP (los demás pueden modificarse)
section .data
    newline     db  10, 0

section .bss
    number_input   resb 12    
    number_output  resb 12

section .text

; ----------------------------------------------------------
; scan_num - Lee un número desde la entrada estándar
; Salida: EAX = número leído (entero)
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
scan_num:    
    mov eax, 3                          ; Llamada al sistema para leer
    mov ebx, 0                          ; Entrada estándar (desde terminal)
    mov ecx, number_input               ; Guarda en ecx la dirección de memoria en donde se reservó el espacio para el número de entrada
    mov edx, 12                         ; Guarda en edx la cantidad máxima de bytes por leer
    int 0x80                            

    mov esi, input_buffer               ; ESI apunta al buffer de entrada
    call stoi                           ; Convierte una cadena ASCII a entero
    ret

; ----------------------------------------------------------
; print_str - Imprime una cadena terminada en NULL
; Entrada: ESI = dirección de la cadena a imprimir
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_str:
    mov edx, 0                  ; Inicia el contador de longitud en 0
.calc_len:
    cmp byte [esi+ edx], 0      ; Compara con NULL terminador
    je .print                   ; Si es NULL (el final de cadena), salta a la función que imprime
    inc edx                     ; Incrementa el contador para evaluar el siguiente caracter
    jmp .calc_len               
.print:
    mov eax, 4                  ; Llamada al sistema para imprimir
    mov ebx, 1                  ; Impresión estándar (a terminal)
    mov ecx, esi                ; Guarda en ecx la dirección de la cadena a imprimir
    int 0x80                    ; Imprime la cadena en la terminal
    ret


;----------------------------------------------------------
; print_num - Imprime un número almacenado en un buffer, 
;             primero lo convierte en cadena
; Entrada: EAX = número a imprimir
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
print_num:
    push edi                    ; Preserva EDI
    mov edi, number_output      ; Usa number_output para convertirlo en cadena

    call itos                   ; Llama a la función que convierte un entero en cadena ASCII
    mov esi, output_buffer      ; ESI apunta al buffer de salida
    call print_str              ; Imprime la cadena terminada en NULL
    pop edi                     ; Saca el EDI de la pila
    ret


; ----------------------------------------------------------
; print_newline - Imprime un carácter de nueva línea
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_newline:
    mov eax, 4                  ; Llamada al sistema para imprimir
    mov ebx, 1                  ; Impresión estándar (a terminal)
    mov ecx, newline            ; Guarda en ecx el caracter de nueva línea en ASCII y un caracter nulo (término de cadena)
    mov edx, 1                  ; Guarda en edx el número de bytes por escribir (1)
    int 0x80                    
    ret


; ----------------------------------------------------------
; stoi - Convierte una cadena ASCII a entero
; Entrada: ESI = dirección de la cadena
; Salida: EAX = número convertido
; Modifica: EAX, ECX, EDX
; ----------------------------------------------------------
stoi:
    xor eax, eax                        ; Limpia EAX (acumulador)
    xor ecx, ecx                        ; Limpia ECX (contador)
.convert:
    ; movz - Move with Zero Extend: Copia un valor pequeño en un registro grande rellenando con ceros
    movzx edx, byte [esi+ecx]           ; Lee siguiente caracter de la cadena
    cmp dl, 0x0A                        ; Compara el valor de dl con el salto de línea (final de la cadena)
    je ..convert_done                   ; Toda la cadena ASCII ya fue convertida a enteros, y termina la función
    cmp dl, '0'                         ; Compara el contenido de dl con el caracter '0'
    jb .convert_done                    ; Si dl es menor a '0', termina la función
    cmp dl, '9'                         ; Compara el contenido de dl con el caracter '9'
    ja .convert_done                    ; Si dl es mayor que '9', termina la función
    sub dl, '0'                         ; Convierte el contenido de dl a número 
    imul eax, 10                        ; Multiplica el número convertido por 10
    add eax, edx                        ; Suma el dígito recientemente convertido al número final
    inc ecx                             ; Avanza al siguiente caracter
    jmp .convert                     
.convert_done:
    ret


; ----------------------------------------------------------
; itos - Convierte un entero a cadena ASCII
; Entrada: EAX = número a convertir
;          EDI = dirección del buffer de salida
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
itos:
    mov ebx, 10                 ; Guarda en ecx la base para dividir
    xor ecx, ecx                ; Limpia el contador de dígitos

    test eax, eax               ; Verifica que eax = 0
    jnz .convertir              ; Si no es cero, salta a convertir

    ; Caso especial para cero
    mov byte [edi], '0'         ; Almacena '0' en el buffer
    inc edi                     ; Avanza el apuntador
    mov byte [edi], 0           ; Agrega fin de cadena
    ret                        

.convert:
    xor edx, edx                ; Limpia edx para la división
    div ebx                     ; eax = eax / 10
    add dl, '0'                 ; Convierte el residuo de la división en caracter
    push dx                     ; Guarda el dígito en la pila
    inc ecx                     ; Incrementa el contador de dígitos
    test eax, eax               ; Verifica que eax no sea 0 (aún tenga dígitos)
    jnz .convert                ; Si tiene dígitos, continúa dividiendo

    ; Para este ciclo es importante que el contador del ciclo este almacenado en ecx
.reverse:               
    pop dx                      ; Recupera el dígito en la pila
    mov [edi], dl               ; Almacena el dígito en el buffer
    inc edi                     ; Avanza el apuntador del buffer
    loop .reverse               ; Repite para todos los dígitos, decrementa automaticamente ecx

    mov byte [edi], 0           ; Agrega fin de cadena
    ret

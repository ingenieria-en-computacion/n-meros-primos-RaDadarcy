section .data
    msg_prime    db  "Es primo", 10, 0
    msg_not_prime db "No es primo", 10, 0

section .bss
    number_input   resb 12    
    number_output  resb 12

section .text
    global _start

_start:
    call scan_num   ; Leer número desde la entrada y almacenarlo en EAX
    mov ebx, eax    ; Guardar número en EBX para no modificarlo
    call is_prime   ; Verificar si es primo (resultado en EAX)
    
    cmp eax, 1      ; Si EAX = 1, es primo
    je print_prime  
    jmp print_not_prime

print_prime:
    mov esi, msg_prime
    call print_str
    jmp exit

print_not_prime:
    mov esi, msg_not_prime
    call print_str
    jmp exit

; ----------------------------------------------------------
; is_prime - Verifica si un número es primo
; Entrada: EBX = número a verificar
; Salida: EAX = 1 si es primo, 0 si no
; Modifica: EAX, ECX, EDX
; ----------------------------------------------------------
is_prime:
    cmp ebx, 2          ; Si el número es menor que 2, no es primo
    jl not_prime
    cmp ebx, 2          ; 2 es el único número par primo
    je prime
    test ebx, 1         ; Verifica si es par
    jz not_prime
    
    mov ecx, 3          ; Comenzar con 3

.loop_check:
    cmp ecx, ebx        ; Si ECX >= EBX, es primo
    jge prime
    mov eax, ebx        
    xor edx, edx        ; Limpia EDX para la división
    div ecx             ; EBX / ECX, cociente en EAX, residuo en EDX
    cmp edx, 0          ; Si el residuo es 0, no es primo
    je not_prime
    add ecx, 2          ; Siguiente divisor impar
    jmp .loop_check

prime:
    mov eax, 1
    ret

not_prime:
    xor eax, eax        ; Retornar 0 si no es primo
    ret

exit:
    mov eax, 1          ; Llamada al sistema para salir
    mov ebx, 0          ; Código de salida 0
    int 0x80

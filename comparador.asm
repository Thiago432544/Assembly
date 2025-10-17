segment .data
    LF equ 0xA
    NULL equ 0xD
    sys_write equ 0x1
    sys_read equ 0x0
    sys_exit equ 0x3C
    stdout equ 0x1
    stdin equ 0x0
    
    msg1 db 'x eh maior que y!', LF, NULL
    tam1 equ $- msg1

    msg2 db 'y eh maior que x!', LF, NULL
    tam2 equ $- msg2

    msg3 db 'Digite o primeiro numero: ', LF, NULL
    tam3 equ $- msg3

    msg5 db 'Digite o segundo numero: ', LF, NULL
    tam5 equ $- msg5

    msg4 db 'x e y sao iguais!', LF, NULL
    tam4 equ $- msg4

section .bss
    x resb 2
    y resb 2

section .text
    global _start

_start:
    ; Pede primeiro número
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, msg3
    mov rdx, tam3
    syscall
    
    ; Lê X
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, x
    mov rdx, 2
    syscall
    
    ; Pede segundo número
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, msg5
    mov rdx, tam5
    syscall
    
    ; Lê Y
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, y
    mov rdx, 2
    syscall
    
    ; Compara
    mov al, [x]
    sub al, '0'
    mov bl, [y]
    sub bl, '0'
    cmp al, bl
    jg xis
    jl ipslon
    je igual

xis:
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, msg1
    mov rdx, tam1
    syscall
    jmp final

ipslon:
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, msg2
    mov rdx, tam2
    syscall
    jmp final

igual:
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, msg4
    mov rdx, tam4
    syscall

final:
    mov rax, sys_exit
    xor rdi, rdi
    syscall
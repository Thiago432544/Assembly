default rel                ; Habilita RIP-relative por padrão

section .data
    ; Mensagens do menu
    menu_msg db 10, "=== CALCULADORA ASSEMBLY x64 ===", 10
             db "1. Adicao", 10
             db "2. Subtracao", 10  
             db "3. Multiplicacao", 10
             db "4. Divisao", 10
             db "5. Sair", 10
             db "Escolha uma opcao (1-5): ", 0
    
    ; Mensagens de entrada
    input_msg1 db "Digite o primeiro numero: ", 0
    input_msg2 db "Digite o segundo numero: ", 0
    
    ; Formatos de saída
    fmt_result_add db "Resultado: %d + %d = %d", 10, 0
    fmt_result_sub db "Resultado: %d - %d = %d", 10, 0
    fmt_result_mul db "Resultado: %d * %d = %d", 10, 0
    fmt_result_div db "Resultado: %d / %d = %d (resto: %d)", 10, 0
    
    ; Mensagens de erro
    err_div_zero db "ERRO: Divisao por zero nao permitida!", 10, 0
    err_overflow db "ERRO: Resultado muito grande (overflow)!", 10, 0
    err_invalid_option db "ERRO: Opcao invalida! Tente novamente.", 10, 0
    err_input db "ERRO: Entrada invalida! Use apenas numeros.", 10, 0
    
    ; Mensagens informativas
    goodbye_msg db "Obrigado por usar a calculadora!", 10, 0
    continue_msg db "Pressione Enter para continuar...", 10, 0
    
    ; Formatos para scanf
    fmt_int db "%d", 0
    fmt_char db "%c", 0
    
    ; Variáveis
    option dd 0
    num1 dd 0
    num2 dd 0
    result dd 0
    remainder dd 0
    temp_char db 0

section .text
    global main
    extern printf
    extern scanf
    extern getchar
    
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

main_loop:
    ; Exibir menu
    mov rcx, menu_msg
    call printf
    
    ; Ler opção
    mov rcx, fmt_int
    lea rdx, [option]
    call scanf
    
    ; Limpar buffer de entrada
    call clear_input_buffer
    
    ; Verificar opção
    mov eax, [option]
    cmp eax, 1
    je do_addition
    cmp eax, 2
    je do_subtraction
    cmp eax, 3
    je do_multiplication
    cmp eax, 4
    je do_division
    cmp eax, 5
    je exit_program
    
    ; Opção inválida
    mov rcx, err_invalid_option
    call printf
    jmp main_loop

do_addition:
    call read_two_numbers
    jc main_loop              ; Se erro na entrada, voltar ao menu
    
    mov eax, [num1]
    mov ebx, [num2]
    
    ; Verificar overflow na adição
    add eax, ebx
    jo addition_overflow      ; Jump if overflow
    
    mov rcx, fmt_result_add
    mov edx, [num1]
    mov r8d, [num2] 
    mov r9d, eax
    call printf
    jmp continue_prompt

addition_overflow:
    mov rcx, err_overflow
    call printf
    jmp continue_prompt

do_subtraction:
    call read_two_numbers
    jc main_loop
    
    mov eax, [num1]
    mov ebx, [num2]
    
    ; Verificar overflow na subtração
    sub eax, ebx
    jo subtraction_overflow
    
    mov rcx, fmt_result_sub
    mov edx, [num1]
    mov r8d, [num2]
    mov r9d, eax
    call printf
    jmp continue_prompt

subtraction_overflow:
    mov rcx, err_overflow
    call printf
    jmp continue_prompt

do_multiplication:
    call read_two_numbers
    jc main_loop
    
    mov eax, [num1]
    mov ebx, [num2]
    
    ; Verificar se algum número é zero (resultado será zero)
    cmp eax, 0
    je mult_zero_result
    cmp ebx, 0
    je mult_zero_result
    
    ; Verificar overflow na multiplicação
    imul eax, ebx
    jo multiplication_overflow
    
    mov rcx, fmt_result_mul
    mov edx, [num1]
    mov r8d, [num2]
    mov r9d, eax
    call printf
    jmp continue_prompt

mult_zero_result:
    mov rcx, fmt_result_mul
    mov edx, [num1]
    mov r8d, [num2]
    mov r9d, 0
    call printf
    jmp continue_prompt

multiplication_overflow:
    mov rcx, err_overflow
    call printf
    jmp continue_prompt

do_division:
    call read_two_numbers
    jc main_loop
    
    ; Verificar divisão por zero
    mov ebx, [num2]
    cmp ebx, 0
    je division_by_zero
    
    mov eax, [num1]
    cdq                       ; Estender sinal para EDX:EAX
    idiv ebx                  ; Dividir EDX:EAX por EBX
    
    mov [result], eax         ; Salvar quociente
    mov [remainder], edx      ; Salvar resto
    
    mov rcx, fmt_result_div
    mov edx, [num1]
    mov r8d, [num2]
    mov r9d, [result]
    
    ; Passar o resto como 5º parâmetro (na pilha)
    mov eax, [remainder]
    push rax
    sub rsp, 8                ; Alinhar pilha
    call printf
    add rsp, 16               ; Restaurar pilha
    jmp continue_prompt

division_by_zero:
    mov rcx, err_div_zero
    call printf
    jmp continue_prompt

continue_prompt:
    mov rcx, continue_msg
    call printf
    call getchar              ; Aguardar Enter
    jmp main_loop

exit_program:
    mov rcx, goodbye_msg
    call printf
    
    add rsp, 32
    pop rbp
    mov rax, 0
    ret

; Função para ler dois números com validação
read_two_numbers:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Ler primeiro número
    mov rcx, input_msg1
    call printf
    
    mov rcx, fmt_int
    lea rdx, [num1]
    call scanf
    cmp eax, 1                ; Verificar se leu com sucesso
    jne input_error
    
    ; Limpar buffer
    call clear_input_buffer
    
    ; Ler segundo número  
    mov rcx, input_msg2
    call printf
    
    mov rcx, fmt_int
    lea rdx, [num2]
    call scanf
    cmp eax, 1
    jne input_error
    
    ; Limpar buffer
    call clear_input_buffer
    
    ; Sucesso - limpar carry flag
    clc
    add rsp, 32
    pop rbp
    ret

input_error:
    mov rcx, err_input
    call printf
    call clear_input_buffer
    
    ; Definir carry flag para indicar erro
    stc
    add rsp, 32
    pop rbp
    ret

; Função para limpar buffer de entrada
clear_input_buffer:
    push rbp
    mov rbp, rsp
    sub rsp, 32

clear_loop:
    call getchar
    cmp eax, 10               ; Verificar se é '\n'
    je clear_done
    cmp eax, -1               ; Verificar EOF
    je clear_done
    jmp clear_loop

clear_done:
    add rsp, 32
    pop rbp
    ret
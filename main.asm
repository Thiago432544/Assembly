section .data
    msg db 'Hello, World!', 0   
    fmt db '%s', 0              

section .text
    global main
    extern printf
    extern ExitProcess

main:
    push rbp
    mov rbp, rsp
    
    sub rsp, 32                 
    mov rcx, fmt                
    mov rdx, msg                
    call printf
    
    add rsp, 32                 
    mov rsp, rbp
    pop rbp
    
    mov rcx, 0                  
    call ExitProcess
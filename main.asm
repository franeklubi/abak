
section .text
    global _start

_start:
    mov qword rax, 60
    mov qword rdi, 42
    syscall


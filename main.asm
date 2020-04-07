
%define BACKLIGHT_STRING "intel_backlight"

section .bss
    stack_start     resb 8


section .data
    BACKLIGHT_PATH  db "/sys/class/backlight/",BACKLIGHT_STRING,"/",0


section .text
    global _start

_start:
    mov [stack_start], rsp
    call check_args

    mov rdi, 0
    jmp exit_with_cleanup



check_args:
    mov rbx, [stack_start]
    mov rax, [rbx]  ; getting argc off the stack
    cmp rax, 1
    jne _ca_continue

    ; mov string to some register and printing
    mov rdi, 1
    jmp exit_with_cleanup

_ca_continue:
    add rbx, 16     ; getting address of pointer to the arg (second argv)
    mov rbx, [rbx]  ; dereferencing the address

    ret


exit_with_cleanup:
    mov rax, 60
    syscall


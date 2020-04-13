
%define BACKLIGHT_STRING "intel_backlight"
%define BACKLIGHT_PATH "/sys/class/backlight/",BACKLIGHT_STRING,"/"

READ_BUFF_SIZE  equ 32


section .bss
    read_buff           resb READ_BUFF_SIZE
    brightness_int      resb 8
    max_brightness_int  resb 8


section .data
    BRIGHTNESS_PATH     db BACKLIGHT_PATH,"brightness",0
    MAX_PATH            db BACKLIGHT_PATH,"max_brightness",0

    dummy_percentage    db "45",10


section .text
    global _start

_start:
    mov rdi, BRIGHTNESS_PATH
    call read_from_file
    mov [brightness_int], rbx

    mov rdi, MAX_PATH
    call read_from_file
    mov [max_brightness_int], rbx

    pop rax         ; getting argc off the stack
    cmp rax, 1
    jne _interpret  ; if argc != 1

    call print_percentage

    jmp exit_normally

_interpret:
    pop rax
    pop rax         ; getting pointer to second arg off the stack

    jmp exit_normally


; put file path into rdi; returns int in rbx
read_from_file:
    ; opening the file
    mov rax, 2      ; sys open
    mov rsi, 0      ; readonly
    mov rdx, 0440o
    syscall         ; opening file

    test rax, rax
    js exit_error   ; if the file couldn't be opened

    mov r8, rax     ; storing the posix file descriptor in r8

    ; reading from file
    mov rdi, r8
    mov rax, 0
    mov rsi, read_buff
    mov rdx, READ_BUFF_SIZE
    syscall

    mov r9, rax     ; storing buffer length

    ; closing the file
    mov rax, 3      ; sys close
    mov rdi, r8
    syscall

    test rax, rax
    js exit_error   ; if the file couldn't be closed

    dec r9
    mov rcx, r9     ; storing num of digits
    call convert_from_buffer

    ret


; assumes that the read_buff is filled and rcx is set to the number of digits
; returns int in rbx
convert_from_buffer:
    mov rsi, read_buff
    xor rbx, rbx

_cfb_loop:
    xor rax, rax
    lodsb
    sub rax, 0x30   ; extracting digit


    ; exponentiation rax*10^rcx
    push rcx
        push rax
        mov rax, 1
    _cfb_exp_loop:
        mov rdx, 10
        mul rdx
        dec rcx
        jnz _cfb_exp_loop

        mov rdx, rax
        pop rax
        mul rdx
    pop rcx

    ; add to value
    add rbx, rax

    dec rcx
    jnz _cfb_loop

    ret


print_percentage:
    mov rax, 1
    mov rdi, 1
    mov rsi, dummy_percentage
    mov rdx, 3
    syscall

    ret


exit_error:
    mov rdi, 1
    jmp exit
exit_normally:
    xor rdi, rdi
exit:
    mov rax, 60
    syscall

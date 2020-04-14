
%define BACKLIGHT_STRING "intel_backlight"
%define BACKLIGHT_PATH "/sys/class/backlight/",BACKLIGHT_STRING,"/"

CHAR_BUFF_SIZE  equ 32


section .bss
    char_buff           resb CHAR_BUFF_SIZE
    brightness_int      resb 8
    max_brightness_int  resb 8
    percentage_int      resb 8


section .data
    BRIGHTNESS_PATH     db BACKLIGHT_PATH,"brightness",0
    MAX_PATH            db BACKLIGHT_PATH,"max_brightness",0


section .text
    global _start

_start:
    mov rdi, BRIGHTNESS_PATH
    call read_from_file
    mov [brightness_int], rbx

    mov rdi, MAX_PATH
    call read_from_file
    mov [max_brightness_int], rbx

    ; calculating percentage
    mov rax, [brightness_int]
    mov rcx, 100
    mul rcx
    div rbx
    mov [percentage_int], rax

    ; getting argc off the stack
    pop rax
    cmp rax, 1
    jne _interpret  ; if argc != 1

    ; converting percentage_int to string
    mov rdi, char_buff
    mov rsi, [percentage_int]
    call int_to_buffer  ; rax already set after percentage calculation
    inc rcx
    add rdi, rcx
    mov byte [rdi], 10  ; storing newline

    mov rsi, char_buff
    mov rdx, rcx
    call print_buffer
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
    mov rsi, char_buff
    mov rdx, CHAR_BUFF_SIZE
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
    mov rsi, char_buff
    call buffer_to_int

    ret


; assumes that rsi is set to buffer and rcx is set to the number of digits
; returns int in rbx
buffer_to_int:
    xor rbx, rbx

_cfb_loop:
    xor rax, rax
    lodsb
    sub rax, 0x30   ; extracting digit

    ; exponentiation rax*10^rcx
    push rcx
        push rax
        dec rcx
        mov rax, 1
    _cfb_exp_loop:
        dec rcx
        js _cfb_exp_skip
        mov rdx, 10
        mul rdx
        jmp _cfb_exp_loop
    _cfb_exp_skip:

        mov rdx, rax
        pop rax
        mul rdx
    pop rcx

    ; add to value
    add rbx, rax

    dec rcx
    jnz _cfb_loop

    ret


; put buffer pointer in rdi and int in rsi
; returns char count in rcx
int_to_buffer:
    xor rcx, rcx
    mov rbx, 10
    mov rax, rsi

    ; calculating int's char count
_itb_loop_len:
    xor rdx, rdx
    div rbx

    inc rcx         ; incrementing char count

    test rax, rax
    jnz _itb_loop_len

    add rdi, rcx    ; moving buffer pointer ahead
    dec rdi
    std
    mov rax, rsi    ; restoring the original int

    ; storing in buffer
_itb_loop_stos:
    xor rdx, rdx
    div rbx

    add rdx, 0x30   ; converting int to char
    xchg rax, rdx   ; saving rax's value
    stosb           ; storing char in buffer
    mov rax, rdx    ; restoring rax's value

    test rax, rax
    jnz _itb_loop_stos

    cld

    ret


; rsi = buffer pointer
; rdx = character count
print_buffer:
    mov rax, 1
    mov rdi, 1
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

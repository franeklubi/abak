
%define BACKLIGHT_STRING "intel_backlight"
%define BACKLIGHT_PATH "/sys/class/backlight/",BACKLIGHT_STRING,"/"

SEEK_SET    equ 0
SEEK_CUR    equ 1
SEEK_END    equ 2
SEEK_DATA   equ 3
SEEK_HOLE   equ 4


section .data
    BRIGHTNESS_PATH db BACKLIGHT_PATH,"brightness",0
    MAX_PATH        db BACKLIGHT_PATH,"max_brightness",0

    dummy_percentage    db "96",10


section .text
    global _start

_start:
    mov rdi, BRIGHTNESS_PATH
    call read_from_file

__yo:

    pop rax         ; getting argc off the stack
    cmp rax, 1
    jne _interpret  ; if argc == 1

    call print_percentage

    jmp exit_normally

_interpret:
    pop rax
    pop rax         ; getting pointer to second arg off the stack

    jmp exit_normally


; put file path into rdi
read_from_file:
    ; opening file
    mov rax, 2      ; sys open
    mov rsi, 0      ; readonly
    mov rdx, 0440o
    syscall         ; opening file

    cmp rax, -1
    je exit_error   ; if the file couldn't be opened

    ; getting size of the file
    mov rdi, rax    ; moving posix file descriptor into rdi
    mov rax, 8
    mov rsi, 0
    mov rdx, SEEK_END
    syscall

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

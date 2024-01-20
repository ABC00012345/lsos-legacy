[org 0x7c00]
section .text
    ; Bootloader code

    ; Clear the screen
    mov ax, 0x03
    int 0x10

    ; Print LSOS BOOTLOADER at the top
    mov si, msg_bootloader
    call print_string

    ; Print user options
    mov si, msg_options
    call print_string

    ; Get user input
    mov ah, 0 ; function number: read from keyboard
    int 0x16 ; BIOS interrupt for keyboard input
    ; Check user input and jump accordingly
    cmp al, '1'
    je continue_boot
    cmp al, '2'
    je reboot
    cmp al, '3'
    je shutdown
    cmp al, '4'
    je boot_into_bios
    ; If no valid input, repeat the menu
    jmp $

continue_boot:
    ; Code for continuing the boot process goes here
    ; Load the kernel and jump to it
    mov si, run_kernel_msg
    call print_string
    int 0x10
    jmp load_kernel_and_jump

reboot:
    mov si, reboot_msg
    call print_string
    int 0x10
	; Connect to APM API
    mov ax, 5301h
    xor bx, bx
    int 15h
    ; Set APM version to 1.2
    mov ax, 530Eh
    xor bx, bx
    mov cx, 0102h
    int 15h
    ; Reboot the system
    mov ax, 5307h
    mov bx, 0001h
    mov cx, 0002h
    int 15h
    ; Exit
    ret
    jmp $

shutdown:
	mov si, shutdown_msg
	call print_string
	int 0x10
	; Connect to APM API
    mov ax, 5301h
    xor bx, bx
    int 15h
    ; Set APM version to 1.2
    mov ax, 530Eh
    xor bx, bx
    mov cx, 0102h
    int 15h
    ; Turn off the system
    mov ax, 5307
    mov bx, 0001h
    mov cx, 0003h
    int 15h
    ; Exit
    ret
    jmp $

boot_into_bios:
    ; Code for accessing UEFI firmware goes here
    mov si, boot_into_bios_msg
    call print_string
    int 0x10
    mov ax, 0x4F01
    xor cx, cx ; Specify warm reboot
    mov dx, 0 ; Specify to enter the BIOS setup
    int 0x15 ; Call the BIOS interrupt
    ret
    jmp $

load_kernel_and_jump:
    ; Code to load kernel and jump to it goes here
    ret

print_string:
    ; Print a null-terminated string at the address in SI
    mov ah, 0x0E ; BIOS teletype function
    .repeat:
        lodsb ; Load character from SI into AL and increment SI
        cmp al, 0 ; Check if it's the null terminator
        je .done
        int 0x10 ; Print the character
        jmp .repeat
    .done:
    ret

msg_bootloader db '---- LSOS BOOTLOADER ----', 0
msg_options db 0x0D, 0x0A, '1. Continue Boot', 0x0D, 0x0A, '2. Reboot', 0x0D, 0x0A, '3. Shutdown', 0x0D, 0x0A, '4. Enter BIOS setup', 0x0D, 0x0A, 0
run_kernel_msg db "Loading Kernel into Memory ...", 0x0D, 0x0A, 0
boot_into_bios_msg db "Enter BIOS Setup ...", 0x0D, 0x0A, 0
shutdown_msg db "Trying to shutdown ...", 0x0D, 0x0A, 0
reboot_msg db "Trying to reboot ...", 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0
dw 0xAA55

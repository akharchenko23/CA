.model small
.stack 100h
;ГОВОРИТЬ КИТАЙСЬКОЮ АЛЕ ХОЧ ГОВОРИТЬ
;воно кидає 0
.data
buffer_size equ 29     ; Define the size of the buffer
buffer db buffer_size dup(?)  ; Define a buffer to hold the read characters
key_buffer db 16 dup(?) ; Buffer to hold the key
value_buffer db 6 dup(?) ; Buffer to hold the value

.code
start PROC
    mov ax, @data       ; Initialize data segment
    mov ds, ax

    call read_file     ; Read from file
    call process_buffer  ; Process the read content

    ; Exit program
    mov ah, 4Ch         ; DOS function to terminate program
    int 21h             ; Call DOS interrupt
start ENDP

read_file PROC
    mov ah, 3Fh         ; DOS function to read from file
    mov bx, 0           ; stdin handleс 
    mov cx, buffer_size ; Number of bytes to read (buffer size)
    mov dx, offset buffer ; Buffer to store the read characters
    int 21h             ; Call DOS interrupt
    ret
read_file ENDP

process_buffer PROC
    mov si, offset buffer ; Set SI to point to buffer
    next_line:
        call read_key_value ; Read key and value from buffer
        cmp byte ptr [si], 0 ; Check for end of buffer
        je end_process_buffer
        add si, 29 ; Move to the next line, assuming each line is 29 bytes long (including newline characters)
    jmp next_line
    end_process_buffer:
    ret
process_buffer ENDP


read_key_value PROC
    mov di, offset key_buffer ; Set DI to point to key_buffer
    mov cx, 16 ; Maximum length of key
    read_key:
        lodsb ; Load byte from SI into AL, and increment SI
        cmp al, ' ' ; Check for space
        je end_read_key ; If space, end of key
        stosb ; Store AL into DI, and increment DI
    loop read_key
    end_read_key:
    mov byte ptr [di], 0 ; Null terminate key
    
    mov di, offset value_buffer ; Set DI to point to value_buffer
    mov cx, 6 ; Maximum length of value
    read_value:
        lodsb ; Load byte from SI into AL, and increment SI
        cmp al, 13 ; Check for carriage return
        je end_read_value ; If carriage return, end of value
        stosb ; Store AL into DI, and increment DI
    loop read_value
    end_read_value:
        mov byte ptr [di], 0 ; Null terminate value
        call convert_to_binary ; Convert value to binary
        ret
read_key_value ENDP


convert_to_binary PROC
    xor ax, ax             ; Clear AX
    mov si, offset value_buffer  ; Set SI to point to value_buffer

convert_loop:
    lodsb                  ; Load byte from SI into AL, and increment SI
    cmp al, 0              ; Check for null terminator
    je end_convert_to_binary   ; If null terminator, end of value

    sub al, '0'            ; Convert ASCII character to integer
    shl ax, 1              ; Shift left to make room for the new bit
    add ax, ax             ; Multiply current binary value by 2 (same as shift left)
    add ax, di             ; Add the current digit to the binary value in AX

    jmp convert_loop       ; Repeat for the next digit
    
end_convert_to_binary:
    call print_result      ; Print the binary representation as decimal
    ret
convert_to_binary ENDP

print_result PROC
    mov cx, 16            ; Number of bits to print (assuming 16-bit value)
    mov si, 16            ; Position of the most significant bit
print_loop:
    mov dx, 0             ; Clear DX register for division
    mov bx, 2             ; Divisor (binary, i.e., 2)
    div bx                ; Divide AX by BX (AX contains the binary value)
    add dl, '0'           ; Convert remainder to ASCII
    mov ah, 02h           ; Function to print character
    int 21h               ; Print the ASCII character
    dec si                ; Move to the next bit
    test si, si           ; Check if we've printed all bits
    jnz print_loop        ; If not, continue loop
    ret
print_result ENDP


convert_to_decimal:
    xor dx, dx        ; Clear DX for division
    div cx            ; Divide BX by 10, quotient in AX, remainder in DX
    add dl, '0'       ; Convert remainder to ASCII
    dec si            ; Move SI to the left
    mov [si], dl      ; Store ASCII digit
    dec di            ; Decrement iteration count
    test ax, ax      ; Check if quotient is zero
    jnz convert_to_decimal  ; If not zero, continue conversion

    mov byte ptr [si - 1], '$' ; Null-terminate the string before printing

    mov dx, offset value_buffer  ; Point DX to the beginning of the converted string
    mov ah, 9         ; DOS function to print string
    int 21h           ; Call DOS interrupt

    ret


end start
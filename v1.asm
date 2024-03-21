.model small
.stack 100h

.data
oneChar db ?

.code
main:
    ; Виведення символу '0' в stdout
    mov ah, 02h       ; Завантажуємо код функції для виводу символу
    mov dl, '0'       ; Завантажуємо ASCII-код символу '0' у регістр DL
    int 21h           ; Викликаємо DOS-функцію для виводу символу
    
    ; Читання символів з stdin до досягнення кінця файлу (EOF)
read_next:
    mov ah, 3Fh       ; Завантажуємо код функції для читання з файлу
    mov bx, 0         ; stdin handle
    mov cx, 1         ; 1 байт для читання
    mov dx, offset oneChar ; Адреса, куди зберігатиметься прочитаний символ
    int 21h           ; Викликаємо DOS-функцію для читання символу
    ; Опрацьовуємо прочитаний символ (oneChar)
    
    or ax, ax         ; Перевірка на кінець файлу (EOF)
    jnz read_next     ; Якщо файл ще не закінчився, повторюємо читання

    ; Копіювання параметрів з командного рядка
    xor ch, ch        ; Очистка регістру CH
    mov cl, ds:[80h] ; У регістр CL завантажуємо довжину "args" за адресою 80h

write_char:
    test cl, cl      ; Перевірка, чи досягли кінця рядка
    jz write_end     ; Якщо так, завершуємо

    mov si, 81h      ; Адреса першого символу "args" за адресою 81h
    add si, cx       ; Додаємо CL до адреси, щоб отримати адресу поточного символу
    mov ah, 02h      ; Завантажуємо код функції для виводу символу
    mov dl, ds:[si] ; Завантажуємо символ для виводу з пам'яті
    int 21h          ; Викликаємо DOS-функцію для виводу символу
    dec cl           ; Зменшуємо лічильник

    jmp write_char   ; Повертаємося для обробки наступного символу

write_end:
    ; Кінець програми
    mov ah, 4Ch      ; Код функції для завершення програми
    int 21h          ; Викликаємо DOS-функцію для завершення програми

end main
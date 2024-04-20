BITS 32

section .bss
  buffer resb 1024 ; init char buffer [1024]

section .data
  inputMsg db "Please enter a string: ", 0xa    ; string inputMsg
  lenInputMsg equ $-inputMsg                    ; save length of the string 

  isPalindromeMsg db "It is a Palindrome", 0xa
  lenIsPalindromeMsg equ $-isPalindromeMsg

  isNOTPalindromeMsg db "It is not a Palindrome", 0xa
  lenIsNOTPalindromeMsg equ $-isNOTPalindromeMsg

section .text
GLOBAL _start

_start:
  jmp while_loop    ;jump to start of input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; start with the while loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
while_loop:
  mov eax, 4                ;sys_write_call
  mov ebx, 1        ;stdout
  mov ecx, inputMsg ;print input message
  mov edx, lenInputMsg ;save input message length
  int 0x80

  mov eax, 3        ;sys_read_call
  mov ebx, 0        ;stdin
  mov ecx, buffer   ;input the string
  mov edx, 1024     ;len of str
  int 0x80

  cmp byte [buffer], 0xa        ; check for whether or not the buffer is newline
  je end_program                ; if it is newline, jump to the end of the program

  ; keep parameters at the ready/PROLOGUE
  mov ebx, eax      ; move the number of bytes read into ebx
  sub ebx, 2        ; decrease the size by two to account for string length 

  push ebx                  ; pass the length of the string
  push ecx                  ; pass the string itself
  call is_palindrome        ; call a palindrome checker
  add esp, 8                ; clean up the stack
  test eax, eax             ; check if it's a palindrome (1) or if it is not (0)
  jz print_not_palindrome   ; if it is a zero, jump to the print not palindrome branch
  jmp print_is_palindrome   ; if it is a one, jump to the 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; call the is palindrome function ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_palindrome:              ; BODY
  push ebp                  ; ebp is stacked first so we can use it access our parameters (think of it like self in python)
  mov ebp, esp              ; we set ebp to the same point as esp
  push esi                  ; we will use esi and edi to hold both the start and the end
  push edi                  ; edi holds the end while esi holds the start
  mov esi, [ebp + 12]        ; load the length of the string into esi
  xor edi, edi              ; zero out edi for use as index

for_loop:
  mov al, [buffer + edi]         ; move al to the start of the string
  mov ah, [buffer + esi]         ; move ah to the end of the string

  cmp al, ah                ; compare them to see if they're the same
  jne is_not_palindrome     ; jump to not palindrome branch if not the same

  inc edi                   ; move edi to the letter on the right of it 
  dec esi                   ; move esi to the letter on the left of it

  cmp edi, esi              ; check if they have both met
  jle for_loop              ; if they haven't yet, continue the loop
  mov eax, 1                ; set up return statement if they did meet
  jmp for_loop_end          ; end the for loop

is_not_palindrome:
  xor eax, eax              ; zero out eax if it is not a palindrome

for_loop_end:               ; EPILOUGE
  pop edi                   ; Send back the edi register called last
  pop esi                   ; next send back the esi register
  mov esp, ebp              ; send back the stack pointer
  pop ebp                   ; send ebp to where it came from
  ret                       ; end the function call

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; finally print statements saying whether or not they are palindromes ;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_not_palindrome:
  pushad                            ; we want to preserve anything within the main registers to the stack
  mov eax, 4
  mov ebx, 1
  mov ecx, isNOTPalindromeMsg       ; print out the failure message
  mov edx, lenIsNOTPalindromeMsg
  int 0x80
  popad                             ; release from stack
  jmp while_loop                    ; restart the while loop

print_is_palindrome:
  pushad                            ; preserve eax, ebx, edx, ecx to stack
  mov eax, 4
  mov ebx, 1
  mov ecx, isPalindromeMsg          ; print out the failreu message
  mov edx, lenIsPalindromeMsg       
  int 0x80
  popad                             ; release from stack
  jmp while_loop                    ; restart the while loop
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end of the program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end_program:
  mov eax, 1                        ; move the sys_end_call to eax
  xor ebx, ebx                      ; zero out ebx
  int 0x80

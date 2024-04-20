BITS 32
GLOBAL addstr                       ; push addStr from assembly to C 
GLOBAL factstr                      ; push factStr from assembly to C
GLOBAL palindrome_check             ; push palindrome_check from assembly to C
GLOBAL is_palindrome                ; push is_palindrome from assembly to C
extern isPalindrome                 ; pull isPalindrome from C to assembly
extern atoi                         ; pull atoi from C to assembly
extern fact                         ; pull fact from C to assembly

section .data
    inputMsg db "Please enter a string: "    ; string inputMsg
    lenInputMsg equ $-inputMsg                    ; save length of the string 

    palindromeMsg db "It is a palindrome", 0xa
    lenPalindromeMsg equ $-palindromeMsg

    notPalindromeMsg db "It is not a palindrome", 0xa
    lenNotPalindromeMsg equ $-notPalindromeMsg
section .bss
    buffer resb 1024            ; set up buffer for the 4th function
section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ADD STRINGS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addstr:
  push ebp                    ; set up the function stack
  mov ebp, esp                ; set up ebp to access parameters and the funciton stack addresses

  push ebx                    ; callee saved register needs to be pushed
  push edi                    ; callee saved register needs to be pushed
  push esi                    ; callee saved register needs to be pushed

  mov edi, [ebp + 12]          ; pass the FIRSTINPUT
  mov esi, [ebp + 8]           ; pass the SECONDINPUT

  push edi                    ; push the first input within edi
  call atoi                   ; call atoi to make sure we can convert firstinput
  mov ebx, eax                ; atoi returns to eax; save within ebx
  pop edi                     ; release current contents of edi from the stack

  push esi                    ; push the second input within esi
  call atoi                   ; call atoi to translate between string and integer
  mov edx, eax                ; atoi returns to eax; save the result within edx; 
  pop esi                     ; release current contetns of esi from the stack

  add ebx, edx                ; perform the add
    
  mov eax, ebx                ; return the value through eax so we can make sure eax has the right return value

  pop esi
  pop edi                     ; release all of the registers from the stack
  pop ebx
  mov esp, ebp
  pop ebp
  ret

;;;;;;;;;;;;;;;;;;;;;IS PALINDROME (C -> ASM);;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_palindrome:              ; BODY
  push ebp                  ; ebp is stacked first so we can use it access our parameters (think of it like self in python)
  mov ebp, esp              ; we set ebp to the same point as esp
    
  push edi                  ; we will use esi and edi to hold both the start and the end
  push esi                  ; edi holds the end while esi holds the start
 
  mov edi, [ebp + 12]         ; load the length of the string into edi
  mov esi, [ebp + 8]          ; load the buffer into esi
  dec edi                 ; subtract the length of the string by 1
  xor ecx, ecx              ; zero out ecx and set it as the start of the string
for_loop:
  mov al, [esi + ecx]         ; move al to the start of the string
  mov ah, [esi + edi]         ; move ah to the end of the string

  cmp al, ah                ; compare them to see if they're the same
  jne is_not_palindrome     ; jump to not palindrome branch if not the same

  inc ecx                   ; move ecx to the letter on the right of it 
  dec edi                   ; move edi to the letter on the left of it

  cmp ecx, edi              ; check if they have both met
  jle for_loop              ; if they haven't yet, continue the loop

  mov eax, 1                ; set up return statement if they did meet
  jmp for_loop_end          ; end the for loop


is_not_palindrome:
  xor eax, eax              ; zero out eax if it is not a palindrome

for_loop_end:               ; EPILOUGE
  pop esi                   ; Send back the edi register called last
  pop edi                   ; next send back the esi register
  mov esp, ebp              ; send back the stack pointer
  pop ebp                   ; send ebp to where it came from
  ret                       ; end the function call

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FACTORIAL STRING;;;;;;;;;;;;;;;;;;;;;;;;;;;;
factstr:
  push ebp                ; set up stack and ebp pointer that will move forward and backeard
  mov ebp, esp            ; move ebp to esp so we can manipulate it
  push ebx
  push edi
  mov edi, [ebp + 8]      ; pass the string 

  push edi                ; push the string to the stack
  call atoi               ; convert from string to integer
  pop edi                 ; release from stack

  mov ebx, eax            ; make sure the return variable is saved

  push ebx                ; pass the result 
  call fact               ; call fact from the c program while passing what's in eax
  pop ebx                 ; release eax from the stack

  pop edi 
  pop ebx
  mov esp, ebp            ; reset ebp and get it ready to be released from the stack
  pop ebp                 ; release ebp from the stack
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PALINDROME CHECK (ASM -> C);;;;;;;;;;;;;;;
palindrome_check:     
  push ebp                ; set up the function stack
  mov ebp, esp            ; set up ebp so it can move around the stack
  push ebx                ; push ebx 
    

  mov eax, 4                 
  mov ebx, 1
  mov ecx, inputMsg           ; output the banner message
  mov edx, lenInputMsg
  int 0x80
                
  mov eax, 3
  mov ebx, 0
  mov ecx, buffer           ; set up the buffer input
  mov edx, 1024
  int 0x80

  mov ebx, ecx            ; move buffer stored within ecx to ebx

  push ebx                  ; pass the input
  call isPalindrome         ; call isPalindrome from the C file
  pop ebx
    
  cmp eax, 0                ; check if it is palindrome
  jz palindrome_no          ; jump to palindrome_no if not

palindrome_yes:             ; continue to palindrome yes if it is

  mov eax, 4
  mov ebx, 1
  mov ecx, palindromeMsg          
  mov edx, lenPalindromeMsg       ; output that it is a plaindrome
  int 0x80

  jmp palindrome_end              ; branches go back to plaindrome_end
palindrome_no:              ; jump to palindrome no if it isn't

  mov eax, 4
  mov ebx, 1
  mov ecx, notPalindromeMsg
  mov edx, lenNotPalindromeMsg    ; output the failure message
  int 0x80

  jmp palindrome_end              ; branches go back to plaindrome_end
  
palindrome_end:
    ; reset the buffer
  mov edi, buffer ; move edi to buffer to get it ready to clear
  mov ecx, 1024   ; reset the size of ecx
  xor eax, eax    ; zero out eax
  rep stosb       ; store 0s repeatedly until the program clears all off buffer and therefore edi
    ; end the function call
  pop ebx         ; pop ebx (callee saved register)
  mov esp, ebp    ; move ebp to the point where esp is 
  pop ebp         ; pop ebp off the stack
  ret             ; go back to the stored return address




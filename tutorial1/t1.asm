;; Author: Eligijus Skersonas
;; Student ID: 19335661

.686                                ; create 32 bit code
.model flat, C                      ; 32 bit memory model
 option casemap:none                ; case sensitive

.data

.code
	
	public factorial
factorial:
	;; Prologue
	push ebp
	mov ebp, esp

	push esi	;; callee must preserve esi 

	;; if N == 1 return 1
	mov esi, [ebp+8]
	cmp esi, 1	
	jne elsee
	mov eax, 1
	jmp ret_f

	;; else
elsee:
	mov eax, [ebp+8]	;; move into eax pushed parameter (N)
	push eax			;; push eax onto stack

	add eax, -1			;; N-1
	push eax			;; push parameter(N-1) onto stack (Start of new stack frame)
	call factorial		;; call factorial (pushes return address onto stack)
	mov esi, eax		;; mov value returned into esi
	add esp, 4			;; pop stack
	pop eax				;; pop stack into eax (restore eax (N))
	mul esi				;; multiply eax by esi (N*(N-1)) and save result in eax
	jmp ret_f			;; return eax

	;; Epilogue
ret_f:
	;; Restoring callee preserved register
	pop esi	
	mov esp, ebp
	pop ebp
	ret
	


	public poly
poly:
	;; Prologue
	;;  pushing the base pointer onto the stack
	push ebp
	;; establishing the stack frame
	mov ebp, esp

	;; Main function body
	;; Callee preserved ESI register
	push esi
	push ebx
	
	;; pushing parameters for function pow
	push 2			;; start of new stack frame / parameter 2
	push [ebp+8]	;; parameter 1
	call pow		;; call pow (pushing return address onto stack)
	mov esi, eax	;; move return value into esi
	pop	[ebp+8]		;; restore pushed parameters
	add esp, 4

	;; pushing parameters for funtion pow
	push 3			;; start of new stack frame / parameter 2
	push [ebp+8]	;; parameter 1
	call pow		;; call pow (pushing return address onto stack)
	mov ebx, eax	;; move return value into ebx
	pop [ebp+8]		;; restore pushed parameters
	add esp, 4

	;; EAX is the accumulator
	;; Compute x^3+x^2+x+1 and store in eax
	mov eax, 1
	add eax, [ebp+8]
	add eax, esi
	add eax, ebx

	;; Epilogue
	pop ebx
	pop esi
	mov esp, ebp
	pop ebp
	ret

pow:	
	;; Prologue
	;;  pushing the base pointer onto the stack
	push ebp
	;; establishing the stack frame
	mov ebp, esp

	;; Main function body
	;; Callee preserved ESI register
	push esi

	;; EAX is the accumulator
	;; set eax to 1
	mov eax, 1

	;; Retreiving the arguments
	mov ecx, [ebp+12]	; mov into ecx arg1
	mov esi, [ebp+8]	; mov into esi arg0
	
	;; the main loop
L1: mul esi				; multiplies eax by esi and stores in edx:eax
	loop L1			    ; looping back to L1

	;; Epilogue
	pop esi
	mov esp, ebp
	pop ebp

	ret

	public multiple_k_asm
multiple_k_asm:
	;; Prologue
	push ebp
	mov ebp, esp

	;; callee preserved registers
	push si
	push di

	mov si, [ebp+16]	;; divisor K
	mov cx, [ebp+12]	;; N
	mov ax, [ebp+8]		;; M (i) 

forr:
	mov ebx, [ebp+20]	;; restore ebx by moving address of the start of the array into ebx at each loop
	add ax, 1			;; ++i

	cmp ax, cx			;; i < N
	jge rett

	push ax				;; preserve ax
	cwd					;; sign-extend AX into DX
	idiv si				;; quotient AX remainder DX
	pop ax				;; pop ax (we dont care about the quotient)

	;; since we are accessing memory with 32 bit addresses we must move ax to a 32-bit register
	movzx edi, ax		 ;; move 16 bit ax register into edi with extending zeros

	;; index the array
	lea ebx, [ebx+edi*2] ;; array[i]

	cmp dx, 0			;; if(i%K == 0)
	jne next
	mov di, 1
	mov [ebx], di		;; array[i] = 1
	jmp forr
next:					;; else
	mov di, 0
	mov [ebx], di		;; array[i] = 0
	jmp forr

rett:
	;; Epilogue
	pop di
	pop si
	mov esp, ebp
	pop ebp
	ret
	
end

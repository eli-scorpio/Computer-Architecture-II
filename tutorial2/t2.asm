includelib legacy_stdio_definitions.lib
extrn printf : near
extrn scanf : near


;; Data segment
.data

print_string BYTE "Please enter an integer: ", 00h
print_string2 BYTE "The sum of the maximum value and user input (%lld, %lld): %lld", 0Ah, 00h

scan_string BYTE "%lld", 00h

public inp_int
inp_int QWORD 0

;; Code segment
.code

;;	  gcd_recursion FUNCTION
;; parameter 1: _int64 a
;; parameter 2: _int64 b
public gcd_recursion

gcd_recursion :
	;; RAX is the accumulator
	xor rax, rax

	;; Main Body
	cmp rdx, 0		;; if (b == 0)
	jne next		;;
	mov rax, rcx	;;	return a
	jmp ret_gcd
next:				;; else
	;; Caller does not care if Caller preserved registers get overwritten so we dont preserve them for efficiency
	mov r8, rdx		;; save rdx (b) into r8, more efficient to temporarily save to register than memory (less latency)
	mov rax, rcx	;; idiv is applied to rax, therefore we move rcx (a) contents into rax
	cqo				;; sign extend rax into rdx RDX:RAX
	idiv r8			;; a%b  RDX: remainder RAX: quotient

	;; calling function recursively
	sub rsp, 32		;; allocate shadow space
	mov rcx, r8		;; 1st parameter : b
					;; 2nd parameter : rdx already contains remainder (a%b) 
	call gcd_recursion
	add rsp, 32		;; deallocate the shadow space
ret_gcd:
	ret

;;	  use_scanf FUNCTION
;; parameter 1: _int64 array_size
;; parameter 2: _int64 array[]
public use_scanf

use_scanf:
	mov rax, 0			;; using register rax to store local variable max
	mov [rsp + 16], rdx ;; preserve RDX
	mov [rsp + 8], rcx	;; preserve RCX

	;; find max			;; for( int i = 0; i < arr_size; i++)
max: mov r8, [rdx]		;;	r8 = array[i]
	cmp r8, rax			;;	
	jle nexxt			;;	if(r8 > max)	
	mov rax, r8			;;		max = r8
nexxt:					
	add rdx, TYPE QWORD
	loop max

	mov [rsp+24], rax

	sub rsp, 32				;; allocate the shadow space
	lea rcx, print_string	;; 1st argument : string
	call printf				;; call the printf function prompting the user for input
	lea rcx, scan_string	;; 1st argument string
	lea rdx, inp_int		;; 2nd argument
	call scanf				;; call the scanf function to get user input

	lea rcx, print_string2  ;; 1st parameter : string
	mov rdx, [rsp + 56]		;; 2nd parameter : max (local varibale in shadow space)
	mov r8, inp_int			;; 3rd parameter : inp_int
	lea r9, [rdx + r8]		;; 4th parameter : sum (max + inp_int)
	mov [rsp + 64], r9		;; preserve return value (sum) in shadow space
	call printf				;; call printf function to print the result
	add rsp, 32				;; deallocate shadow space

	mov rax, [rsp + 32]		;; return sum (stored in shadow space)
	ret


;;	  min FUNCTION
;; parameter 1: _int64 a
;; parameter 2: _int64 b
;; parameter 3: _int64 c

min: 
	xor rax, rax ;; clear rax
	mov rax, rcx ;; v = a

	cmp rdx, rax	;; if (b < v)
	jge iff
	mov rax, rdx	;; v = b
iff:
	cmp r8, rax		;; if (c < v)
	jge ret_ff
	mov rax, r8		;; v = c
ret_ff:

	ret	;; return v


;;	  min5 FUNCTION
;; parameter 1: _int64 i
;; parameter 2: _int64 j
;; parameter 3: _int64 k
;; parameter 4: _int64 l
public min5

min5:
	xor rax, rax

	mov [rsp+8], rcx	;; preserve rcx : i
	mov [rsp+16], rdx	;; preserve rdx : j
	mov [rsp+24], r8	;; preserve r8  : k
	mov [rsp+32], r9	;; preserve r9  : l

	sub rsp, 32			;; allocate shadow space 
	mov rcx, inp_int	;; rcx <- inp_int : 1st parameter
	mov rdx, [rsp+40]	;; rdx <-	i	  : 2nd parameter
	mov r8, [rsp+48]	;; r8  <-	j	  : 3rd parameter
	call min			;; call min function

	mov rcx, rax		;; rcx <-	rax	  : 1st parameter  (rax stores the result from the first call to min)
	mov rdx, [rsp+56]	;; rdx <-	k	  : 2nd parameter
	mov r8, r9			;; r8  <-	l	  : 3rd parameter
	call min			;; call min function
	add rsp, 32			;; deallocate shadow space

	ret






end
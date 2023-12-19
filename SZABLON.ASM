_code segment
	assume  cs:_code

start:	mov	ax, _data
	mov	ds, ax
	assume	ds:_data
	mov	ax, _stack
	mov	ss, ax
	assume	ss:_stack
	mov	sp, top_stack
        
	; your code goes here
		
	mov	ah, 4ch
	mov	al, 0
	int	21h
_code ends

_data segment
	; your data goes here
_data ends

_stack segment stack
	top_stack	equ 100h
_stack ends

end start
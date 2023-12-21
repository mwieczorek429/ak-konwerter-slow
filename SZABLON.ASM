_code segment
	assume  cs:_code

start:	mov	ax, _data
	mov	ds, ax
	assume	ds:_data
	mov	ax, _stack
	mov	ss, ax
	assume	ss:_stack
	mov	sp, top_stack
	
	mov cx,5	; Maksymalna liczba iteracji
	mov dx,0	; Wyczyszczenie DX
	
INPUT:    
	mov ah,08h	
	int 21h		; Pobranie znaku z klawiatury
	mov dl,al	; Przeniesinie znaku do wypisania
	cmp dl,13
	JE ENT	; Jesli wprowadzono enter
	mov ah,02h
	int 21h		; Wypisanie znaku w konsoli
	cmp cx,5	
	JE SIGN		; Ustawienie znaku liczby
	PUSH dx
	LOOP INPUT

SUM:
		
	mov	ah, 4ch
	mov	al, 0
	int	21h
	
SIGN:	
	cmp dl,'-'
	JE MINUS	; Znak jesli liczba jest ujemna
	PUSH '+'	; Liczba jest dodatnia
	dec cx		; dekrementacja poniewaz nie bedziemy wypisywac plusa
	JMP INPUT
MINUS:
	PUSH dx
	JMP INPUT
ENT:
	cmp cx,4
	JBE SUM
	mov dl,'B'	; TU ZMIENIC NA WYSWIETLNIE BLEDU
	mov ah,02h
	int 21h	
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
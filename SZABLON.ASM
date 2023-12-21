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
	mov di,0
	
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
	MOV ax,dx
	STOSB		; umieszczenie bajtu w ES:DI
	LOOP INPUT	
INIT:
	mov bx,0
	mov cx,1
	dec di
	mov si,di
	mov ax,ES:[SI]	; pobranie pierwszego znaku od konca 
SUM:
	mov ah,0
	SUB	al,48d	; ZAMIANA ASCII NA LICZBE
	CMP al,10d	; SPRAWDZENIE CZY 0-9 WIEKSZE ZNAKI
	JGE ERR		; JESLI INNA NIZ DEC PRZEJDZ DO WYSWIELENIA BLEDU 
	CMP al,0d		; SPRAWDZENIE CZY 0-9 MNIEJSZE ZNAKI SPACJA itd.
	JL ERR
	MUL cx		; PRZEMNOZENIE ZALEZNIE OD POZYCJI
	ADD bx,ax	; SUMOWANIE LICZBY 10
	mov ax,cx	; MNOZENIE 1 -> 10 -> 100 -> ...
	mov dx,10d
	MUL dx
	mov cx,ax
	dec si
	mov ax,ES:[SI]	; POBRANIE KOLEJNEGO ZNAKU
	cmp al,'-'
	JE STOP		; Konwersja jesli liczba ujemna 
	cmp al,'+'
	JE STOP		; Konwersja jesli liczba dodatnia 
	nop		; JMP nie chcialo dzialac bez tego
	JMP SUM
	
STOP:
	mov	ah, 4ch
	mov	al, 0
	int	21h
	
SIGN:	
	cmp dl,'-'
	JE MINUS	; Znak jesli liczba jest ujemna
	MOV AX,'+'	; Liczba jest dodatnia
	STOSB
	MOV AX,DX	
	STOSB		; ZAPISANIE PIERWSZEJ CYFRY PO ZNAKU
	dec cx		; dekrementacja poniewaz nie bedziemy wypisywac plusa
	JMP INPUT
MINUS:
	MOV AX,'-'
	STOSB		; ZAPISANIE ZNAKU
	MOV AX,DX
	STOSB		 ; ZAPISANIE PIERWSZEJ CYFRY PO ZNAKU
	JMP INPUT
ENT:			; OBSLUGA PIERWSZEGO ENTERa
	cmp cx,4
	JBE INIT	; PONIZEJ LUB ROWNO, KIEDY KLIKNIETO ENTER
	mov dl,'B'	; TU ZMIENIC NA WYSWIETLNIE BLEDU
	mov ah,02h
	int 21h	
	mov	ah, 4ch
	mov	al, 0
	int	21h
ERR:			; OBSLUGA NIEPRAWIDLOWYCH DANYCH
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
_code segment
	assume  cs:_code

start:	mov	ax, _data
	mov	ds, ax
	assume	ds:_data
	mov	ax, _stack
	mov	ss, ax
	assume	ss:_stack
	mov	sp, top_stack
	
	mov cx,6d				; Maksymalna liczba iteracji
	mov dx, offset indata	; Tekt do wypisania
	mov ah,09h				; Funkcja wypisujaca tekst
	int 21h					; Wywolanie przerwania Dos
	mov dx,0 				; Wyczyszczenie DX
	
INPUT:    
	mov ah,08h				;Funkcja pobrania 1 znaku z klawiatury
	int 21h					; Pobranie znaku z klawiatury
	mov dl,al				; Przeniesinie znaku do wypisania
	cmp dl,13
	JE ENT					; Jesli wprowadzono enter
	cmp dl,8d
	JE BACKSP
	mov ah,02h
	int 21h					; Wypisanie znaku w konsoli
	cmp cx,6	
	JE SIGN					; Ustawienie znaku liczby
	MOV ax,dx
	STOSB					; Umieszczenie bajtu w ES:DI
	LOOP INPUT	
INIT:
	mov bx,0				; Rejestr do przechowania obliczonej liczby
	mov cx,1				; Rejestr do liczenia poteg
	dec di					; Ustawienie indeksu na ostatni pobrany znak
	mov si,di				
	mov ax,ES:[SI]			; Pobranie pierwszego znaku od konca 
SUM:
	mov ah,0
	SUB	al,48d				; ZAMIANA ASCII NA LICZBE
	CMP al,10d				; SPRAWDZENIE CZY 0-9 WIEKSZE ZNAKI
	JGE ERR					; JESLI INNA NIZ DEC PRZEJDZ DO WYSWIELENIA BLEDU / (S xor O) = 0 
	CMP al,0d				; SPRAWDZENIE CZY 0-9 MNIEJSZE ZNAKI
	JL ERR
	MUL cx					; PRZEMNOZENIE ZALEZNIE OD POZYCJI, WYNIK W AX DLA OPERACJI 8 BIT
	JO ERR					; JESLI WYNIK ZA DUZY BLAD
	ADD bx,ax				; SUMOWANIE LICZBY 10
	JC ERR 					; JESLI NADWYZKA WYSWIETL BLAD
	mov ax,cx				; MNOZENIE 1 -> 10 -> 100 -> ...
	mov dx,10d				
	MUL dx					; W AX KOLEJNA POTEGA 10
	mov cx,ax				
	dec si					; INDEKS KOLEJNEGO ZNAKU 
	mov ax,ES:[SI]			; POBRANIE KOLEJNEGO ZNAKU
	cmp al,'-'
	JE MINNB				; Przerwanie petli i przejscie do konwersji jesli liczba ujemna 
	cmp al,'+'
	JE PLUS					; JESLI LICZBA DODATNIA, PRZEJD DO WYSWIETLANIA 
	nop						; JMP nie chcialo dzialac bez tego
	JMP SUM
SHOW:
	CMP SI,0d				; SPRAWDZENIE CZY ODCZYTALISMY WSZYSTKIE ZNAKI
	JNZ ERR
	CALL SBINARY
	CALL SHOWHEX
	JMP STOP
BACKSP:
	cmp di,0
	JE INPUT
	CALL PRINTBS
	dec di
	mov dx,ES:[di]-1		
	cmp dl,'+'
	JNE INPUT
	dec di
	ADD CX,1
	JMP INPUT
ENT:						; OBSLUGA PIERWSZEGO ENTERa
	cmp cx,5
	JBE INIT				; PONIZEJ LUB ROWNO, KIEDY KLIKNIETO ENTER
	JMP ERR
ERR:						; OBSLUGA NIEPRAWIDLOWYCH DANYCH
	mov dx, offset blad
	mov ah,09h
	int 21h
	JMP STOP
SIGN:	
	cmp dl,'-'
	JE MINUS				; Znak jesli liczba jest ujemna
	MOV AX,'+'				; Liczba jest dodatnia
	STOSB
	MOV AX,DX	
	STOSB					; ZAPISANIE PIERWSZEJ CYFRY PO ZNAKU
	sub cx,2d				; Zmniejszenie o 2, poniewaz nie bedziemy wypisywac plusa
	JMP INPUT
MINNB:
	cmp bx,32768d 			; Liczba ujemna nie moze przekraczac 32768
	JA ERR					; BADANIE C=0 AND Z=0 
CONV:
	NOT bx					; Konwersja poprzez negacje wszystkich bitow
	ADD bx,1d				; Uzupelnienie do 2
	JMP SHOW 
PLUS:						; SPRAWDZENIE CZY WIEKSZE NIZ 32767
	cmp bx,32767d 			
	JA ERR	
	JMP SHOW
MINUS:
	MOV AX,'-'
	STOSB					; ZAPISANIE ZNAKU
	DEC cx					; Zmniejszenie, aby przejsc do kolejnej iteracji
	JMP INPUT
PRINTBS:
	ADD CX,1				;	USUWANIE LITERY BACKSPACE -> PUSTY ZNAK -> BACKSPACE
	mov dl,8d
	mov ah,02h
	int 21h	
	mov dl,' '
	int 21h
	mov dl,8d
	int 21h
	ret
STOP:
	mov	ah, 4ch
	mov	al, 0
	int	21h

;*****************************************SHOW BINARY(){
SBINARY:
mov dx, offset binTekst		; WYSWIETLENIE TEKSTU
mov ah,09h
int 21h
clc            				; WYZEROWANIE FLAGI C
xor ax,ax					; WYZEROWANIE REJESTRU ax
xor dx,dx					; WYZEROWANIE REJESTRU dx
push bx						; ZACHOWANIE NA STOSIE POLICZONEJ LICZBY 10
mov cx,16d					; LICZBA ITERACJI
LOOPBIN:
mov dl,'0'					; DOMYSLNIE WYSWIETL 0
rcl bx,1d					; OBROT W LEWO Z BITEM CARRY
jnc SKIPONE					; JESLI C=0, ZOSTAJE DOMYSLNIE WYSWIETLONE 0
mov dl,'1'					; W PRZECIWNYM RAZIE USTAW DO WYSWIETLENIA 1
SKIPONE:
mov ah,02h					; FUNKCJA DO WYSWIETLENIA ZNAKU
int 21h
loop LOOPBIN				; POWTARZAJ PETLE 16 razy
pop bx						; NA ZAKONCZENIE PRZYWROC POLICZONA LB 10
ret							; POWROT
;********************************************}

;**********************************************SHOWHEX{
SHOWHEX:
mov dx, offset hexTekst		; WYSWIETLANIE TEKSU
mov ah,09h
int 21h
push bx        				; UMIESZCZENIE LICZBY NA STOS
mov di,0d      				; LICZBA ITERACJI PETLI
mov cl,12d     				; USTAWIENIE LICZBY PRZESUNIEC
DIVPETLA:
shr bx,cl      				; PRZESUNIECIE LOGICZNE W PRAWO CL RAZY, ABY LICZBA NIE PRZEKRACZALA 16
mov dx,bx					; PRZECHOWANIE PRZESUNIETEJ LICZBY W DX, DO WYSWIETLENIA
call WYS					; WYSWIETLANIE AKTUALNEJ CZESCI LICZBY
shl bx,cl					; PRZESUNIECIE LOGICZNE W LEWO, DZIEKI CZEMU LICZBA MA PODOBNA POSTAC: XXXX00000000 -> 0000XXXX00000000 -> ...
pop dx						; POLICZONA WCZESNIEJ LICZBA
sub dx,bx					; ODJECIE OD POLICZONEJ LICZBY, CZESCI JUZ WYSWIETLONEJ (np: 0000101011011111 - 0000101000000000)
mov bx,dx					; ZAPISANIE WYNIKU
push bx						

sub cl,4d      				; KOLEJNA ITERACJA WYKONA O 4 MNIEJ PRZESUNIEC
inc di         				; ZWIEKSZENIE ITERACJI
cmp di,4d      				
jc DIVPETLA					; POWTARZAJ PETLE 4 RAZY
pop bx						; POBRANIE ZE STOSU LICZBY, ABY ZOSTAL ADRES POWROTU
ret

WYS:
add dx,48d					; DODANIE 48, ABY WYSWIETLIC LICZBE W ASCII
cmp dx,58d					; SPRAWDZENIE CZY LICZBA JEST MNIEJSZA OD 10
jc SKIPLETTER				; JESLI JEST MNIEJSZA POMIN DODAWANIE
add dx,7d					; DODAJ 7 ABY WYSWIETLALO A-F W ASCII
SKIPLETTER:
mov ah,02h					; WYSWIETL ZNAK ZAPISANY W DL
int 21h
ret
;***********************************************}

_code ends

_data segment
	indata db 'Podaj liczbe:$'
	blad db 10,13,'Nieprawidlowe dane',10,13,'$'
	binTekst db 10,13,'Liczba binarnie: $'
	hexTekst db 10,13,'Liczba heksadecymalnie: $'
_data ends

_stack segment stack
	top_stack	equ 100h
_stack ends

end start
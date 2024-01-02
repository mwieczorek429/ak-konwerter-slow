Wyświetlanie binarne działa podobnie do 8080.
Wyświetlanie hex również wykorzystuje przesuwanie logiczne. W każdej iteracji przesuwa liczbę aż wszystkie bity oprócz 4 najmniej znaczących są zerami. Dzięki temu liczba jest równa/mniejsza od 16. Następnie po wyświetleniu przesuwa w lewo.
Tak powstaje liczba, która zawiera tylko bity już wyświetlone. Wystarczy od oryginalnej liczby usunąć już wyświetloną.
Przykład:
liczba: 0010 1111 0001 1110
Najpierw przesuniecie w prawo: 0000 0000 0000 0010  -> Wyświetlenie
Przesuniecie w lewo: 0010 0000 0000 0000
Odjęcie od oryginalnej wyświetloną: 0010 1111 0001 1110 - 0010 0000 0000 0000 = 0000 1111 0001 1110
Powtarzanie 4 razy.

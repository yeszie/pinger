# Pinger

**Pinger** to prosty program dla systemu Windows, który działa w zasobniku (tray) i służy do monitorowania dostępności hostów.

## Funkcjonalność

- Po uruchomieniu program tworzy plik `hosts.txt`, który należy wyedytować, aby dodać listę hostów do monitorowania.
- Program monitoruje dostępność hostów poprzez wysyłanie zapytań ping.
- Zmiana koloru ikony w tray sygnalizuje status dostępności monitorowanych hostów.

## Statusy programu

- **Zielony**: Wszystkie hosty odpowiadają na ping.
- **Czerwony**: Żaden z wpisanych w pliku `hosts.txt` hostów nie odpowiada na ping.
- **Inny kolor**: Część hostów odpowiada, a część jest niedostępna.

## Konfiguracja
1. Po pierwszym uruchomieniu program automatycznie tworzy plik `hosts.txt` w katalogu programu.
2. W pliku `hosts.txt` dodaj hosty, które chcesz monitorować, wpisując adresy IP lub nazwy domen.
3. Program automatycznie sprawdza dostępność hostów i zmienia kolor ikony w zasobniku w zależności od wyników pingowania.


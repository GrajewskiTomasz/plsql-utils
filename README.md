# plsql-utils

**A. Opis pakietu PKG_KSEF_UTILS**

****1. Cel pakietu****
Pakiet `PKG_KSEF_UTILS` służy do generowania testowych numerów KSeF na potrzeby:
 - wsadów do pism
 - testów integracyjnych
 - testów obciążeniowych
Numer KSeF generowany przez pakiet ma poprawny format, ale używa uproszczonej, wewnętrznej logiki technicznej części numeru i liczby kontrolnej. Algorytm nie odtwarza oficjalnego sposobu nadawania numerów przez KSeF.

****2. Zakres zastosowania:****
 - Środowiska: DEV, TEST, ewentualnie SANDBOX.
 - Typ danych: wyłącznie dane testowe, sztuczne, symulowane.
 - Kod nie służy do walidacji numerów KSeF otrzymanych z systemu MF.
 - Pakiet nie powinien być używany w kodzie produkcyjnym obsługującym realne faktury.

****3. Format generowanego numeru****
Pełny numer KSeF zwracany przez pakiet ma format:
`NIP-YYYYMMDD-TECH-CC`
gdzie:
 - `NIP` to NIP po usunięciu znaków innych niż cyfry
 - `YYYYMMDD` to data w formacie rok, miesiąc, dzień
 - `TECH` to wygenerowana pseudolosowa część techniczna (domyślnie 12 znaków)
 - `CC` to uproszczona, wewnętrzna liczba kontrolna w zakresie 00–99

**B. Przypadki testowe**

Poniżej lista case’ów do testów jednostkowych i integracyjnych.

****1. Testy dla GEN_KSEF_TECH_PART****

Długość domyślna
 - Wejście: `gen_ksef_tech_part` bez parametrów.
 - Spodziewane: długość 12, tylko litery A–Z i cyfry 0–9.
Długość niestandardowa
 - Wejście: `gen_ksef_tech_part(20)`.
 - Spodziewane: długość 20, format jak wyżej.
Różne wywołania
 - Dwa wywołania po kolei w tym samym bloku.
 - Spodziewane: w większości przypadków różne wartości (statystycznie).
Parametr niepoprawny
 - Wejście: `gen_ksef_tech_part(0)` lub wartość ujemna.
 - Do przygotowania: albo obsługa przez raise_application_error, albo opisane zachowanie w pakiecie. Dopisać walidację w refaktorze.

****2. Testy dla GEN_KSEF_CHECKSUM****

Deteministyczność
 - Te same parametry `p_nip`, `p_date`, `p_tech` dają ten sam wynik.
Wpływ zmiany części technicznej
 - Zmieniasz jeden znak w `p_tech`.
 - Spodziewane: w większości przypadków inna suma kontrolna.
NIP z separatorami
 - Wejście np. `p_nip => '123-456-32-18'`.
 - Spodziewane: wynik taki sam jak dla `1234563218`.
Małe i duże litery w części technicznej
 - Wejście: `p_tech` w małych i dużych literach.
 - Sprawdź czy funkcja traktuje je spójnie (według aktualnego kodu: małe i duże litery mają podobne mapowanie numeryczne).

****3. Testy dla GEN_KSEF_NUMBER****

Standardowy scenariusz
 - Wejście: poprawny NIP, data jawna.
 - Spodziewane:
a) początek numeru to NIP bez separatorów
b) środek to data w formacie `YYYYMMDD`
c) część techniczna ma długość 12
d) suma kontrolna ma 2 znaki
NIP z myślnikami i spacjami
 - Wejście: `p_nip => '123-456 32-18'`.
 - Spodziewane: początek numeru to `1234563218`.
Domyślna data
 - Wejście: `gen_ksef_number('1234563218')`.
 - Spodziewane: w środku numeru jest dzisiejsza data `YYYYMMDD`.
NIP pusty lub NULL
 - Wejście: `p_nip => null`.
 - Aktualne zachowanie: wynik najprawdopodobniej NULL.
 - Zalecenie: dopisać walidację i obsługa przez raise_application_error w refaktorze.

****4. Testy integracyjne****
   
Generowanie wsadu do pisma
 - Sprawdź, że procedura wsadowa poprawnie woła `PKG_KSEF_UTILS.GEN_KSEF_NUMBER` i zapisuje wartość w kolumnie używanej przez system pism.
Eksport do zewnętrznego systemu
 - Sprawdź, że numer w formacie `NIP-YYYYMMDD-TECH-CC` jest poprawnie przenoszony do pliku lub API.
Testy obciążeniowe
 - Wygeneruj kilkadziesiąt lub kilkaset tysięcy numerów.
 - Sprawdź, czy nie ma błędów wydajnościowych, a rozkład wartości TECH jest akceptowalny.

**C. Instrukcja dla użytkowników (dev, QA, analitycy)**

****1. Po co jest ten pakiet****
 - Pakiet służy tylko do generowania numerów KSeF w środowiskach testowych. Pomaga zasilić aplikacje danymi, które wyglądają realistycznie, ale nie odnoszą się do prawdziwych faktur w KSeF.

****2. Jak używać****
 - W kodzie PL/SQL zawsze używaj funkcji `PKG_KSEF_UTILS.GEN_KSEF_NUMBER`.
 - Podawaj NIP w dowolnym formacie, np. `123-456-32-18`.
 - Jeśli nie podasz daty, zostanie użyta dzisiejsza.
 - Nie próbuj z tych numerów wnioskować o strukturze prawdziwych numerów KSeF.

****3. Czego nie robić****
 - Nie używaj tego pakietu w produkcji dla realnych faktur.
 - Nie używaj funkcji `GEN_KSEF_CHECKSUM` do walidacji numerów otrzymanych z KSeF.
 - Nie kopiuj wygenerowanych numerów KSeF do innych systemów jako dane rzeczywiste.
 - Nie mieszaj danych z tego pakietu z danymi z produkcyjnego KSeF w jednej tabeli.

****4. Ograniczenia i wykluczenia****
 - Algorytm sumy kontrolnej jest uproszczony i wewnętrzny.
 - Numery generowane przez pakiet nie są i nie będą akceptowane przez prawdziwy KSeF.
 - Pakiet nie zapewnia unikalności numerów w skali całej bazy, tylko statystycznie niskie ryzyko kolizji.
 - Nie ma mechanizmu wstecznej walidacji numerów, które przyszły z zewnątrz.

**D. Wyłączenie odpowiedzialności**

Pakiet PKG_KSEF_UTILS jest przeznaczony wyłącznie do generowania testowych numerów KSeF w środowiskach deweloperskich, testowych i sandbox. Numery generowane przez pakiet nie są numerami nadawanymi przez KSeF i nie mogą być traktowane jako dane rzeczywiste.

Autor nie ponosi odpowiedzialności za jakiekolwiek szkody, straty finansowe, utratę danych, błędne rozliczenia podatkowe ani inne negatywne skutki wynikające z:
1) użycia pakietu PKG_KSEF_UTILS w środowisku produkcyjnym,
2) wykorzystania wygenerowanych numerów KSeF w procesach biznesowych opartych na rzeczywistych danych,
3) użycia pakietu w sposób sprzeczny z niniejszą dokumentacją lub z jego przeznaczeniem.
Każde użycie pakietu poza jasno opisanym zakresem odbywa się wyłącznie na ryzyko użytkownika.

PHP Subnet Scout is een kleine, portable Windows-tool in assembler om lokale IPv4-subnetten op PHP-websites te inventariseren.

- Automatisch CIDR-subnet op basis van lokale interface en subnetmasker; aanpasbaar, /16 t/m /32.
- HTTP op 80/8080 en HTTPS op 443/4430; 32 parallelle verbindingen.
- Instelbare totale timeout per IP/poort; standaard 3000 ms.
- PHP-detectie via zichtbare headers en PHPSESSID-cookies; verborgen PHP blijft onbekend.
- Dark/lightmode, resultaatdetails, filters, stoppen en CSV-export inclusief foutcodes en ruwe headers.
- Interne HTTPS-certificaten worden standaard meegenomen; strikte certificaatcontrole is optioneel.

De EXE vereist geen extra runtime of administratorrechten. Broncode en automatische build staan in de repository. Download de EXE of portable ZIP en controleer desgewenst `SHA256SUMS.txt`. De executable is niet digitaal ondertekend.

Validatie: 40 lokale integratiecontroles, inclusief HTTP/HTTPS, meerdere cookieheaders, redirects, timeout, annuleren, CIDR-grenzen en CSV. Dark- en lightmode zijn lokaal visueel gecontroleerd. Er is geen klantnetwerk als onderdeel van deze releasevalidatie gescand.

# PHP Subnet Scout

Compacte Windows-tool, volledig geschreven in x86-assembler (FASM). De portable EXE gebruikt alleen Windows-DLL's; geen installatie, .NET, Python of administratorrechten nodig. Getest op Windows 11 x64.

Download de portable EXE of ZIP via [GitHub Releases](https://github.com/Jaap79/PhpSubnetScout/releases/latest). De SHA-256-checksums staan bij dezelfde release. De executable is niet digitaal ondertekend.

## Gebruik

Start `dist\PhpSubnetScout.exe`, controleer het automatisch ingevulde CIDR-subnet en klik **Scannen**. Detectie gebruikt het IPv4-adres en subnetmasker van de interface voor de standaardroute, met een actieve IPv4-interface als fallback. Bij meerdere adapters/VPN's kun je het subnet aanpassen.

- Doel: een IPv4-subnet (`192.168.1.0/24`), een los intern of extern IPv4-adres, een servernaam/FQDN (`webserver.example.com`) of een letterlijk IPv6-adres (`::1`, zonder brackets). Het automatisch ingevulde interne subnet blijft de standaard. Voer geen URL, pad of poortnummer in. DNS-namen gebruiken de Windows-resolver; internationale namen moeten als ASCII/punycode worden ingevoerd.
- IPv4-subnetten: `/16` t/m `/32`, zowel intern als extern. De grens voorkomt onbedoeld zeer grote scans. `/31` scant beide adressen; `/32` scant een enkel adres; anders worden netwerk- en broadcastadressen overgeslagen. IPv6-subnetten en IPv6-adressen met een zone-ID worden niet ondersteund.
- HTTP op **80, 81, 5000, 8000, 8008, 8080, 8081 en 8888**; HTTPS op **443 en 8443**. Zie [selectie en bronnen](docs/PORT_RESEARCH.md) voor het poortonderzoek. Dit is een praktische top 10 voor algemene webservers, geen universele actuele wereldranglijst.
- **32 parallelle verbindingen**. De standaardtimeout is **2000 ms per IP/poort-combinatie**, instelbaar van 250 tot 30000 ms. Dit is een totaalbudget voor verbinding, TLS en het ontvangen van HTTP-headers, geen afzonderlijke timeout per fase. De tien poorten worden via dezelfde parallelle wachtrij verdeeld. Het is dus geen gegarandeerde totale deadline van twee seconden voor een volledig IP-adres.
- De scan verstuurt `GET /`, gebruikt geen proxy en volgt geen redirects. Automatische Windows-authenticatie, cookies en het aanbieden van clientcertificaten zijn uitgeschakeld. De responsebody wordt niet gedownload of onderzocht.
- **TLS-controle: uit** is bedoeld voor inventarisatie van interne HTTPS-sites met bijvoorbeeld zelfondertekende certificaten. De serveridentiteit wordt dan niet geverifieerd. Zet deze controle aan om certificaten door Windows te laten controleren. Het gebruik van HTTPS volgt de TLS-mogelijkheden en het beleid van Windows.
- **Stoppen** annuleert lopende aanvragen en houdt afgeronde resultaten vast. Het venster sluiten stopt ook de workers.

## PHP-detectie

| Uitkomst | Bewijs |
|---|---|
| Bevestigd | `PHP` in `X-Powered-By` of `Server` |
| Indicatie | `PHPSESSID=` in een `Set-Cookie`-header, ook bij meerdere cookieheaders |
| Onbekend | Geen herkenbaar PHP-signaal in de ontvangen headers |

Dit zijn zichtbare signalen, geen sluitend bewijs van de gebruikte servertechnologie: headers kunnen worden verborgen of aangepast en een cookienaam kan door andere software worden gebruikt. Een ingevoerde servernaam blijft behouden in de HTTP Host-header en TLS-SNI. Bij een scan op IP kunnen websites die een specifieke hostnaam vereisen ontbreken. Andere paden en andere poort/protocol-combinaties kunnen ontbreken. Er wordt geen reverse DNS, vhost-enumeratie of `/index.php`-probe uitgevoerd. DNS kiest een adres voor de verbinding; niet alle adressen achter een naam worden afzonderlijk geinventariseerd. Een korte timeout kan langzame systemen missen; verhoog hem als dat nodig is.

Het filter wisselt tussen **overzicht** (alle afgeronde endpoints), **PHP-signalen** en **problemen**. Selecteer een rij voor URL, status, WinHTTP-/Winsock-foutcode, verbindingsfase, verbindingsdiagnose, certificaatinstelling en ruwe HTTP-headers. Beide thema's hebben ook een passende Windows-titelbalk. De native bestandsdialoog volgt de Windows-weergave.

## Verbindingsproblemen en uitgaande blokkades

Mislukte verbindingen zijn standaard zichtbaar in het overzicht. Als Windows een lokale uitgaande toegangsweigering meldt (Winsock `10013` of WinHTTP `5`), verschijnt **Uitgaand lokaal geweigerd**. Dat kan een lokale firewall, endpointbeleid of een andere lokale toegangsbeperking zijn; de scanner identificeert geen specifieke firewallregel.

Een TCP-timeout of generieke verbindingsfout bewijst geen uitgaande firewallblokkade. Een lokale of tussenliggende firewall, firewall op de doelserver, routing en een offline host kunnen hetzelfde beeld geven. De details benoemen die onzekerheid. Een weigering, DNS-fout of fout na TCP-connectie krijgt een eigen diagnose. Succesvolle verbindingen krijgen geen extra verbindingswaarschuwing. Zie ook Microsofts documentatie over [WinHTTP-fouten](https://learn.microsoft.com/en-us/windows/win32/winhttp/error-messages), [Winsock-fouten](https://learn.microsoft.com/en-us/windows/win32/winsock/windows-sockets-error-codes-2) en de [onderliggende foutcode](https://learn.microsoft.com/en-us/windows/win32/winhttp/option-flags).

Bij een mislukte TCP-verbinding waarvoor WinHTTP geen onderliggende foutcode bewaart, volgt maximaal een extra TCP-verbindingspoging naar hetzelfde waargenomen adres en dezelfde poort. Deze duurt hoogstens 200 ms, binnen het resterende timeoutbudget, en verstuurt geen HTTP-aanvraag. Alleen een expliciete lokale toegangsweigering uit die controle telt als aanvullend bewijs.

## CSV

**Exporteer CSV** is beschikbaar zodra de scan klaar of gestopt is. De export bevat **alle afgeronde endpoints**, onafhankelijk van het zichtbare filter. Niet gestarte endpoints van een gestopte scan worden niet geëxporteerd.

Kolommen: Target, IP, poort, URL, HTTP-status, PHP-uitkomst, detectiebewijs, Server, X-Powered-By, Location, verstreken milliseconden, resultaat, WinHTTP-foutcode, certificaatcontrole, ruwe headers, WinsockError, ConnectionStage en ConnectionDiagnostic. Target bewaart het doel; IP bevat bij een DNS-naam het laatst waargenomen verbindingsadres (ook bij een mislukte poging), of blijft leeg als dat niet beschikbaar is. CSV gebruikt komma's, RFC4180-quoting en UTF-8 met BOM. Potentiële spreadsheetformules krijgen een voorloopapostrof. Houd rekening met sessiecookies in de ruwe headers als je exports deelt.

## Build

Gebruik FASM 1.73.x met de standaard Windows-includes:

```powershell
.\scripts\setup-fasm.ps1
.\build.ps1
```

Alle productcode staat in `src\PhpSubnetScout.asm`. Het manifest en het eigen geometrische icoon staan ernaast. De tests in `tests\Support.cs` en `tests\smoke.ps1` zijn uitsluitend testondersteuning en geen onderdeel van de executable.

## Validatie

De integratietest gebruikt loopback-fixtures voor IPv4, hostnamen en IPv6 en controleert HTTP, HTTPS, Host/SNI, DNS-fouten, PHP-signalen, meerdere cookieheaders, redirects, trage responses, timeout, annuleren/sluiten, CIDR-grenzen, filters en CSV-inhoud. Voor Windows-TLS is toegang tot tijdelijke certificaatsleutels nodig. De tests gebruiken PowerShell 7 en System.Drawing; ze zijn lokaal uitgevoerd op PowerShell 7.6 / .NET 10.

```powershell
.\tests\smoke.ps1
```

Dark- en lightmode zijn visueel bekeken op de huidige Windows-schaal. Andere Windows-versies, 125%/150% weergaveschaal, publieke/on-link subnetten en een volledige klantomgeving zijn niet getest.

GitHub Actions bouwt de broncode met FASM 1.73.35 en voert dezelfde loopback-tests uit, met een tijdelijke FQDN in het hosts-bestand van de runner. Alleen op die tijdelijke runner test `tests/ci-network.ps1` ook een echte lokale uitgaande firewallblokkade, beperkt tot de scanner en een documentatie-IP. Deze test weigert lokaal te draaien en herstelt het tijdelijke beleid. Tags van de vorm `v1.0.0` publiceren na een geslaagde controle automatisch een EXE, portable ZIP en `SHA256SUMS.txt`.

## Licentie

De eigen applicatiecode valt onder de [MIT License](LICENSE). De officiële FASM-toolchain staat apart in `third_party/` en wordt op SHA-256 gecontroleerd; de bijbehorende voorwaarden staan in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). De toolchain zit niet in de portable release.

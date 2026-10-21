# PHP Subnet Scout

Compacte Windows-tool, volledig geschreven in x86-assembler (FASM). De portable EXE gebruikt alleen Windows-DLL's; geen installatie, .NET, Python of administratorrechten nodig. Getest op Windows 11 x64.

Download de portable EXE of ZIP via [GitHub Releases](https://github.com/Jaap79/PhpSubnetScout/releases/latest). De SHA-256-checksums staan bij dezelfde release. De executable is niet digitaal ondertekend.

## Gebruik

Start `dist\PhpSubnetScout.exe`, controleer het automatisch ingevulde CIDR-subnet en klik **Scannen**. Detectie gebruikt het IPv4-adres en subnetmasker van de interface voor de standaardroute, met een actieve IPv4-interface als fallback. Bij meerdere adapters/VPN's kun je het subnet aanpassen.

- IPv4: private subnetten, link-local en loopback; `/16` t/m `/32`. De grens voorkomt onbedoeld zeer grote scans. `/31` scant beide adressen; `/32` scant een enkel adres; anders worden netwerk- en broadcastadressen overgeslagen.
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

Dit zijn zichtbare signalen, geen sluitend bewijs van de gebruikte servertechnologie: headers kunnen worden verborgen of aangepast en een cookienaam kan door andere software worden gebruikt. Verborgen PHP, websites die alleen met een specifieke hostnaam/SNI werken, andere paden en andere poort/protocol-combinaties kunnen ontbreken. Er wordt geen reverse DNS, vhost-enumeratie of `/index.php`-probe uitgevoerd. Een korte timeout kan langzame systemen missen; verhoog hem als dat nodig is.

Het filter wisselt tussen **websites**, **PHP-signalen** en **alle endpoints**. Selecteer een rij voor URL, status, Windows-foutcode, certificaatinstelling en ruwe HTTP-headers. Beide thema's hebben ook een passende Windows-titelbalk. De native bestandsdialoog volgt de Windows-weergave.

## CSV

**Exporteer CSV** is beschikbaar zodra de scan klaar of gestopt is. De export bevat **alle afgeronde endpoints**, onafhankelijk van het zichtbare filter. Niet gestarte endpoints van een gestopte scan worden niet geëxporteerd.

Kolommen: IP, poort, URL, HTTP-status, PHP-uitkomst, detectiebewijs, Server, X-Powered-By, Location, verstreken milliseconden, resultaat, WinHTTP-foutcode, certificaatcontrole en ruwe headers. CSV gebruikt komma's, RFC4180-quoting en UTF-8 met BOM. Potentiële spreadsheetformules krijgen een voorloopapostrof. Houd rekening met sessiecookies in de ruwe headers als je exports deelt.

## Build

Gebruik FASM 1.73.x met de standaard Windows-includes:

```powershell
.\scripts\setup-fasm.ps1
.\build.ps1
```

Alle productcode staat in `src\PhpSubnetScout.asm`. Het manifest en het eigen geometrische icoon staan ernaast. De tests in `tests\Support.cs` en `tests\smoke.ps1` zijn uitsluitend testondersteuning en geen onderdeel van de executable.

## Validatie

De integratietest start lokale fixtures op `127.23.45.67`, scant uitsluitend loopback en controleert HTTP, HTTPS, PHP-signalen, meerdere cookieheaders, redirects, trage responses, timeout, annuleren/sluiten, CIDR-grenzen, filters en CSV-inhoud. Voor Windows-TLS is toegang tot tijdelijke certificaatsleutels nodig. De tests gebruiken PowerShell 7 en System.Drawing; ze zijn lokaal uitgevoerd op PowerShell 7.6 / .NET 10.

```powershell
.\tests\smoke.ps1
```

Dark- en lightmode zijn visueel bekeken op de huidige Windows-schaal. Andere Windows-versies, 125%/150% weergaveschaal, publieke/on-link subnetten en een volledige klantomgeving zijn niet getest.

GitHub Actions bouwt de broncode met FASM 1.73.35 en voert dezelfde loopback-tests uit. Tags van de vorm `v1.0.0` publiceren na een geslaagde controle automatisch een EXE, portable ZIP en `SHA256SUMS.txt`.

## Licentie

De eigen applicatiecode valt onder de [MIT License](LICENSE). De officiële FASM-toolchain staat apart in `third_party/` en wordt op SHA-256 gecontroleerd; de bijbehorende voorwaarden staan in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). De toolchain zit niet in de portable release.

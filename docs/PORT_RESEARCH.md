# Poortkeuze voor PHP Subnet Scout 1.1.0

Onderzocht op 21 oktober 2026. Er bestaat geen gezaghebbende, actuele universele top 10 voor HTTP/HTTPS binnen lokale netwerken. Internetmetingen bevatten bovendien proxies, appliances, developmentservers en andere protocollen op dezelfde poort. De selectie hieronder is daarom een praktische, onderbouwde top 10 voor algemene webservers; geen claim dat dit wereldwijd exact de tien grootste HTTP(S)-poorten zijn.

## Selectiemethode

1. Neem de standaardpoorten 80 en 443 en bekende alternatieve poorten voor algemene HTTP-webservers, proxies, beheerinterfaces en developmentservers.
2. Controleer HTTP-gebruik tegen de officiële Nmap-service/probedocumentatie en de actuele publieke Shodan-poortwaarnemingen. Voorbeelden zoals Flask onderbouwen dat 5000 ook als algemene webpoort relevant is.
3. Vergelijk binnen deze kandidaten de empirische open-poortfrequentie uit de actuele `nmap-services`-database. Dat is historische onderzoeksdata, geen actuele HTTP-marktverdeling; een open poort kan een ander protocol bevatten.
4. Kies de tien hoogst scorende kandidaten. De kandidaatset was: 80, 81, 82, 83, 84, 85, 443, 3000, 4443, 5000, 5001, 7001, 8000, 8001, 8008, 8080, 8081, 8082, 8083, 8084, 8085, 8088, 8181, 8443, 8880, 8888, 9000 en 9443. Specifieke transportdiensten zoals RPC-over-HTTP, IPP, VNC-over-HTTP en TR-069 zijn niet gebruikt als algemene websitekandidaten.

| Poort | Protocol | Nmap open-frequency | Onderbouwing |
|---:|---|---:|---|
| 80 | HTTP | 0.484143 | Standaard HTTP |
| 443 | HTTPS | 0.208669 | Standaard HTTPS |
| 8080 | HTTP | 0.042052 | Veelgebruikte HTTP/proxy-alternatiefpoort |
| 8888 | HTTP | 0.016522 | Alternatieve HTTP-server/webinterface |
| 81 | HTTP | 0.012056 | Bekende alternatieve webpoort; Nmap-servicenaam alleen identificeert HTTP hier niet |
| 8443 | HTTPS | 0.009986 | Veelgebruikte HTTPS-alternatiefpoort |
| 8000 | HTTP | 0.009710 | Alternatieve HTTP-server/developmentpoort |
| 8008 | HTTP | 0.006843 | HTTP-alternatiefpoort |
| 5000 | HTTP | 0.006423 | Algemene web/developmentpoort, onder andere Flask; kan ook UPnP zijn |
| 8081 | HTTP | 0.006147 | Alternatieve webinterface/proxybeheerpoort |

4430 vervalt: daarvoor is geen vergelijkbare onderbouwing als veelgebruikte algemene webpoort. 3000 en 9000 zijn wel relevante webkandidaten, maar vallen bij deze beperkte selectie onder de frequentiegrens. Dit zegt niets over hun aanwezigheid in een specifieke organisatie.

## Bronnen en beperkingen

- [Nmap: betekenis van de frequentiekolom](https://nmap.org/book/nmap-services.html). Dit meet open-poortfrequentie uit onderzoeksscans, niet uitsluitend HTTP, en is geen live LAN-statistiek.
- [Nmap-services, officiële database](https://raw.githubusercontent.com/nmap/nmap/master/nmap-services). Onderzochte snapshot SHA-256: `6017b72e5e4194b0904ac9a0bd8a1bbfe790a6ee9953da08ed1bf1eaf8307176`.
- [Nmap: HTTP-serviceprobes](https://nmap.org/book/vscan-technique.html) en [officiële probedatabase](https://raw.githubusercontent.com/nmap/nmap/master/nmap-service-probes). Alleen geraadpleegd voor onderzoek; er is geen Nmap-engine, database of probecode in de applicatie opgenomen.
- [Shodan: poortwaarnemingen](https://data-status.shodan.io/ports.html), geraadpleegde pagina gedateerd 19 oktober 2026. Gebruikt als tweede controle voor waargenomen services op alternatieve poorten, niet als bewijs van een universele HTTP-top 10. Banneraantallen zijn geen telling van unieke websites en sommige poorten zijn als Unknown geclassificeerd.
- [Flask: officiële quickstart](https://flask.palletsprojects.com/en/stable/quickstart/), standaard ontwikkelserver op TCP 5000.

De tool gebruikt per poort het bovengenoemde gebruikelijke protocol. Er wordt geen volledige poortscan of dubbele HTTP/HTTPS-probe op elke poort toegevoegd. Websites met een andere protocolkeuze, afwijkende hostnaam/SNI of verborgen PHP kunnen daarom nog ontbreken.

## Timeoutkeuze

2000 ms per IP/poort-combinatie is een bruikbare snelle LAN-default, met één totaalbudget voor verbinden, TLS en HTTP-headers. Dit is een ontwerpkeuze, geen garantie dat alle hosts binnen twee seconden reageren. Langzame PHP-backends, TLS-initialisatie, VPN-verbindingen en slapende apparaten kunnen meer tijd nodig hebben. Daarom blijft 250–30000 ms instelbaar.

De integratietests controleren vertraagde HTTP- en HTTPS-responses binnen en buiten het budget, plus een verhoogde timeout voor een HTTPS-response van drie seconden. De testhost krijgt een aparte warm-up voor crypto/JIT; die warm-up verandert de applicatiedefault niet.

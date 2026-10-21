De scanner onderzoekt nu tien onderbouwde, veelgebruikte webpoorten in plaats van vier:

- HTTP: **80, 81, 5000, 8000, 8008, 8080, 8081 en 8888**.
- HTTPS: **443 en 8443**.
- Standaardtimeout verlaagd naar **2000 ms per IP/poort**; blijft instelbaar tot 30000 ms.
- 32 parallelle verbindingen, PHP-detectie, resultaatdetails, CSV-export en beide thema's blijven beschikbaar.

De selectie en bronnen staan in [het poortonderzoek](https://github.com/Jaap79/PhpSubnetScout/blob/main/docs/PORT_RESEARCH.md). Dit is een praktische set voor lokale webinventarisatie, geen universele actuele wereldranglijst. 4430 vervalt. De gekozen protocolindeling is vast; er wordt geen volledige poortscan toegevoegd.

Twee seconden is geschikt als snelle LAN-default, maar kan trage systemen missen. Verhoog de timeout bij VPN's of langzame backends. De 46 integratiecontroles dekken alle tien poorten, HTTP/HTTPS-timeouts, aangepaste timeout, CIDR-grenzen, annuleren, filtering en CSV-inhoud. De executable vereist geen extra runtime of administratorrechten.

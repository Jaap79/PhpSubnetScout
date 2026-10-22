De scanner accepteert nu naast IPv4-subnetten ook losse interne en externe IPv4-adressen, servernamen/FQDN's en letterlijke IPv6-adressen. Het automatisch bepaalde interne subnet blijft de standaard.

- Hostnaam blijft behouden voor HTTP Host en TLS-SNI. Snelle IPv6-naar-IPv4-terugval voorkomt dat een onbereikbaar IPv6-adres het volledige timeoutbudget verbruikt.
- Verbindingsproblemen staan standaard in het overzicht; een apart problemenfilter is toegevoegd.
- Een door Windows bevestigde lokale toegangsweigering verschijnt als **Uitgaand lokaal geweigerd**. Een timeout wordt niet als bewezen firewallblokkade gepresenteerd: de oorzaak kan lokaal, onderweg of op het doel liggen.
- Details en CSV bevatten het doel, waargenomen IP-adres, WinHTTP-/Winsock-foutcodes, verbindingsfase en diagnose. Succesvolle verbindingen krijgen geen extra waarschuwing.
- De tien webpoorten, standaardtimeout van 2000 ms, 32 parallelle verbindingen en dark-/lightmode blijven beschikbaar.

De portable x86-EXE gebruikt alleen Windows-DLL's. Geen installatie, extra runtime of administratorrechten nodig. IPv6-subnetten en URL-invoer worden niet ondersteund. De protocolkeuze per poort blijft vast.

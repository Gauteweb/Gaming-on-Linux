# Gaming på Linux
Her finner du en samling med diverse shell skript jeg har laget for forskjellige formål, stort sett for å gjøre livet enklere, spesielt for oss som liker å spille dataspill på Linux.

Er du fortsatt usikker på om du skal prøve deg på gaming med Linux? Ta gjerne og [les denne artikkelen](https://www.spillnorge.no/blog/er-gaming-pa-linux-for-deg) min om akkurat det på SpillNorge.no før du kaster deg ut i det.


## Fedora og Nvidia oppsett for gaming
Har du installert [Fedora Workstation](https://fedoraproject.org/workstation/) eller [Fedora KDE Plasma Desktop](https://fedoraproject.org/kde/) og du har en maskin med Nvidia grafikkort? 

Isåfall har jeg her laget et [skript som installerer alt du måtte trenge av drivere og programvare](https://github.com/Gauteweb/GNU-Linux/blob/main/fedora_nvidia_gaming.sh) for å enkelt komme igang med gaming på Linux. 

![Min desktop](https://github.com/Gauteweb/GNU-Linux/blob/main/stormtrooper_desktop.jpg)

Bare [kjør skriptet](https://github.com/Gauteweb/GNU-Linux/blob/main/fedora_nvidia_gaming.sh), ta en restart og voila: Du har en super gaming-maskin med de nyeste og beste Nvidia-driverne og alt du trenger av programvare for å starte og spille, bare logg inn på Steam, GOG eller Epic og last ned spillene dine. Du kan også strømme spill fra GeForce NOW om du har bra nok nettverk.

Sjekk også ut mine [rapporter på ProtonDB](https://www.protondb.com/users/440092954) for tweaking av individuelle spill på Fedora og SteamOS.

## Forenklet oppdatering av Fedora
Dette skriptet fungerer på alle varianter av Fedora og sannsynligvis også på alle Fedora-baserte distroer som for eksempel Bazzite og Nobara. [Skriptet oppdaterer både Flatpak og DNF i en swoop](https://github.com/Gauteweb/GNU-Linux/blob/main/update_fedora.sh). 

Jeg har satt det opp til å startes fra en knapp på min Stream Deck slik at oppdateringer alltid bare er et knappetrykk unna. Jeg har da brukt OpenDeck med "Run Command":
- KDE Plasma: konsole -e ./update.sh
- GNOME: terminal -e ./update.sh

![Mitt Stream Deck oppsett](https://github.com/Gauteweb/GNU-Linux/blob/main/streamdeck_update.jpg)

Siden Fedora har rullende oppdateringer kommer det ganske mye småoppdateringer jevnlig, så det kan bli litt tidkrevende å stadig åpne opp oppdaterings-GUI'et og kjøre oppdateringene der. 

Dette skriptet forkorter tiden brukt på oppdateringer ganske mye, spesielt om du knytter det opp til en knapp på for eksempel Stream Deck, eller ved å knytte det til en tastatursnarvei på tastaturet ditt (_dette gjør du under tastatur-innstillingene i Fedora_).

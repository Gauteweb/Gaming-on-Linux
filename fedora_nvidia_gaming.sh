#!/bin/bash

# Skript skrevet av: Gaute Holmin.
# Første versjon utgitt: 19/5-2026.
# Dette skriptet vil installere alt du trenger for å komme gang med gaming på Fedora Linux (Workstation og KDE Plasma Desktop) med Nvidia grafikkort.
# Skriptet vil også gjøre noen steg som forbedrer ytelsen på Fedora for gaming.
# Skriptet er skrevet og testet på Fedora 44, men bør virke på alle Fedora-baserte distroer.
# En forutsetning for dette skriptet er at du har aktivert tredjeparts repo's (Enable Third Party Repositories). Dette gjør du enkelt i GUI på Fedora.
# For å kunne kjøre skriptet etter nedlasting må du åpne en terminal i mappen du har lastet ned skriptet og bruke kommandoene:
# chmod +x fedora_nvidia_gaming.sh
# ./fedora_nvidia_gaming.sh

# Sjekker at Fedora er helt oppdatert før du starter.
echo -e "\nSjekker at systemet er helt oppdatert før vi starter. Underveis kan det hende at du må skrive inn passordet ditt flere ganger."
sudo dnf update -y
read -p "Trykk [Enter] for å starte..."

# installerer kjernemoduler for å gjøre klart for Nvidia-drivere
echo -e "\nForberedende pakker før Nvidia installasjon."
dnf install kernel-devel-matched kernel-headers
read -p "Trykk [Enter] for å fortsette..."

# Oppstart av skript
echo -e "\nDette skriptet vil installere drivere for moderne Nvidia grafikkort og annen programvare du trenger få spille på Fedora Linux."
read -p "Trykk [Enter] for å fortsette..."

# Installerer Nvidia-drivere for Nvidia GPU fra 2017 og nyere.
echo -e "Installerer nyeste Nvidia-drivere via DNF. NB: Hvis Secure Boot er aktivert i BIOS kan det skape problemer ved restart, sjekk: https://rpmfusion.org/Howto/Secure%20Boot"
sudo dnf install akmod-nvidia

# Ferdig med å installere Nvidia-drivere
echo -e "\nMerk: Det kan ta opp mot 5 minutter før driveren er helt oppdatert"
read -p "Trykk [Enter] for sjekke driver-versjon..."

# Oppdater med DNF
echo -e "\nSjekker Nvidia-versjon, om det ikke kommer opp et versjonsnummer, vent noen minutter før du går videre:"
modinfo -F version nvidia
read -p "Trykk [Enter] for å teste driver-versjon en gang til..."

# Oppdater med DNF
echo -e "\nSjekker Nvidia versjon en gang til, bare for å være sikker."
modinfo -F version nvidia
read -p "Trykk [Enter] for å fortsette..."

# Hardware codecs for Nvidia
echo -e "\nInstallerer hardware codecs for Nvidia."
sudo dnf install libva-nvidia-driver
read -p "Trykk [Enter] for å fortsette..."

# Installerer Nvidia GeForce Now
echo -e "\nInstallerer Nvidia Geforce NOW for strømming av spill."
flatpak remote-add --user --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrep
flatpak install --user GeForceNOW com.nvidia.geforcenow
read -p "Trykk [Enter] for å fortsette..."

# Bytter ut åpne ffmpeg codecs med proprietære
echo -e "\nInstallerer alle ffmpeg codecs (trengs ofte for cutscenes og intro til spill)."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
read -p "Trykk [Enter] for å fortsette..."

# Gstreamer framework og mer..
echo -e "\nInstallerer andre proprietære codecs du kan trenge."
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
read -p "Trykk [Enter] for å fortsette..."

# Installere GameMode
echo -e "\nInstallerer Gamemode via DNF (det kan hende dette er installert fra før)."
sudo dnf install gamemode
read -p "Trykk [Enter] for å fortsette..."

# Installere ProtonPlus
echo -e "\nInstallerer ProtonPlus via Flatpak."
flatpak install flathub com.vysp3r.ProtonPlus
read -p "Trykk [Enter] for å fortsette..."

# Installere Protontricks
echo -e "\nInstallerer Protontricks via DNF."
sudo dnf install protontricks
read -p "Trykk [Enter] for å fortsette..."

# Installere Steam
echo -e "\nInstallerer Steam via DNF."
sudo dnf install steam
read -p "Trykk [Enter] for å fortsette..."

# Installere Heroic Launcher
echo -e "\nInstallerer Heroic Launcher via Flatpak (for å kunne spille spill fra Epic og GoG)."
flatpak install heroic
read -p "Trykk [Enter] for å fortsette..."

# Justerer kjerneparametre for gaming
sudo grubby --args="preempt=full transparent_hugepage=always" --update-kernel=ALL

# Fullført melding
echo -e "\nNå er Fedora klart for gaming, men ta en restart først, så du er sikker på at de beste Nvidia-driverne og de oppdaterte kjerneparameterne blir brukt."
echo -e "\nHvis restart feiler, prøv å deaktivere Secure Boot i BIOS."
echo -e
read -p "Trykk [Enter] for å ta en restart av PC'en..."

#restart
sudo systemctl reboot

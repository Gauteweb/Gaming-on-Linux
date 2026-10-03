#!/bin/bash

# Skript skrevet av: Gaute Holmin.
# Dette skriptet vil installere alt du trenger for å komme i gang med gaming på openSUSE Tumbleweed (KDE Plasma Desktop) med Nvidia grafikkort.
# Skriptet vil også gjøre noen steg som forbedrer ytelsen på Tumbleweed for gaming.
# Skriptet er ment for openSUSE Tumbleweed (rolling release). Det passer IKKE for openSUSE Leap (andre repo-URLer og driverpakker der).
# En forutsetning for dette skriptet er at de offisielle repoene (oss, non-oss, update) er aktivert, noe som er standard ved installasjon.
# For å kunne kjøre skriptet etter nedlasting må du åpne en terminal i mappen du har lastet ned skriptet og bruke kommandoene:
# chmod +x opensuse_nvidia_gaming.sh
# ./opensuse_nvidia_gaming.sh

# Sjekker at Tumbleweed er helt oppdatert før du starter.
echo -e "\nSjekker at systemet er helt oppdatert før vi starter. Underveis kan det hende at du må skrive inn passordet ditt flere ganger."
echo -e "På Tumbleweed oppgraderer vi med 'zypper dup' (dist-upgrade), som er riktig måte å holde en rolling release oppdatert på."
sudo zypper dup -y
read -p "Trykk [Enter] for å starte..."

# Oppstart av skript
echo -e "\nDette skriptet vil installere drivere for moderne Nvidia grafikkort og annen programvare du trenger for å spille på openSUSE Tumbleweed."
read -p "Trykk [Enter] for å fortsette..."

# Legger til Nvidias offisielle repo for Tumbleweed og installerer Nvidia-drivere (G06-driveren, for kort fra 2017 og nyere).
# Obs: Hvis Secure Boot er aktivert i BIOS/UEFI, må du enten deaktivere det eller selv signere Nvidia-kjernemodulen, ellers starter ikke driveren.
echo -e "\nLegger til Nvidias offisielle repo og installerer nyeste Nvidia-drivere (G06)."
echo -e "NB: Hvis Secure Boot er aktivert i BIOS kan det skape problemer ved restart. Enkleste løsning er å deaktivere Secure Boot i BIOS."
sudo zypper --gpg-auto-import-keys addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed/ nvidia
sudo zypper --gpg-auto-import-keys --auto-agree-with-licenses install -y x11-video-nvidiaG06
read -p "Trykk [Enter] for å fortsette..."

nedtellingsfunksjon() {
    local sekunder=60
    while ((sekunder > 0)); do
        printf "\rVenter %2d sekunder før vi tester driver-versjonen... " "$sekunder"
        sleep 1
        ((sekunder--))
    done
    printf "\r60 sekunder har gått — fortsetter!     \n\n"
}

echo "Kjernemodulen bygges ferdig i bakgrunnen, så vi venter et minutt."
nedtellingsfunksjon    # venter 60 sekunder med live nedtelling

# Sjekk Nvidia-versjon
echo -e "\nSjekker Nvidia-versjon, om det ikke kommer opp et versjonsnummer, vent noen minutter før du går videre:"
modinfo -F version nvidia
read -p "Trykk [Enter] for å fortsette..."

# Installerer Nvidia GeForce Now
echo -e "\nInstallerer Nvidia GeForce NOW for strømming av spill (via Flatpak)."
flatpak remote-add --user --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrep
flatpak install --user -y GeForceNOW com.nvidia.geforcenow
read -p "Trykk [Enter] for å fortsette..."

# Bytter ut åpne ffmpeg codecs med fullversjonen fra Packman (trengs ofte for cutscenes og intro til spill).
# Packman er det etablerte tredjeparts-repoet for kodeker på openSUSE, og er nødvendig fordi de offisielle repoene
# kun leverer frie/åpne codecs.
echo -e "\nLegger til Packman-repoet og bytter til full ffmpeg med alle codecs."
sudo zypper --gpg-auto-import-keys addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
sudo zypper --gpg-auto-import-keys --auto-agree-with-licenses install -y --from packman ffmpeg libavcodec-full libavdevice-full
read -p "Trykk [Enter] for å fortsette..."

# Sikrer at flathub er lagt til (trengs for appene under)
echo -e "\nLegger til Flathub-repoet for Flatpak (hvis det ikke finnes fra før)."
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
read -p "Trykk [Enter] for å fortsette..."

# Installere GameMode
echo -e "\nInstallerer GameMode via Zypper (det kan hende dette er installert fra før)."
sudo zypper install -y gamemode
read -p "Trykk [Enter] for å fortsette..."

# Installere ProtonPlus
echo -e "\nInstallerer ProtonPlus via Flatpak."
flatpak install --user -y flathub com.vysp3r.ProtonPlus
read -p "Trykk [Enter] for å fortsette..."

# Installere Protontricks
echo -e "\nInstallerer Protontricks via Zypper."
sudo zypper install -y protontricks
read -p "Trykk [Enter] for å fortsette..."

# Installere Steam
echo -e "\nInstallerer Steam via Zypper (ligger i non-oss-repoet som er standard aktivert)."
sudo zypper install -y steam
read -p "Trykk [Enter] for å fortsette..."

# Installere Heroic Launcher
echo -e "\nInstallerer Heroic Launcher via Flatpak (for å kunne spille spill fra Epic og GoG)."
flatpak install --user -y flathub com.heroicgameslauncher.hgl
read -p "Trykk [Enter] for å fortsette..."

# Justerer kjerneparametre for gaming.
echo -e "\nJusterer kjerneparametre for gaming (preempt=full og transparent_hugepage=always)."
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 preempt=full transparent_hugepage=always"/' /etc/default/grub
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="preempt=full transparent_hugepage=always"' | sudo tee -a /etc/default/grub > /dev/null
fi
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
read -p "Trykk [Enter] for å fortsette..."

# Fullført melding
echo -e "\nNå er openSUSE Tumbleweed klart for gaming, men ta en restart først, så du er sikker på at de beste Nvidia-driverne og de oppdaterte kjerneparameterne blir brukt."
echo -e "\nHvis restart feiler, prøv å deaktivere Secure Boot i BIOS."
echo -e "\nTips: Tumbleweed tar automatisk Btrfs-snapshots med Snapper før alle systemoppgraderinger. Hvis en oppdatering skulle ødelegge noe, kan du boote tilbake til forrige snapshot fra GRUB-menyen og rulle tilbake med 'sudo snapper rollback' (etterfulgt av restart)."
echo -e
read -p "Trykk [Enter] for å ta en restart av PC'en..."

#restart
sudo systemctl reboot

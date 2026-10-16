#!/bin/bash

# Skript skrevet av: Gaute Holmin.
# Dette skriptet vil installere alt du trenger for å komme i gang med gaming på openSUSE Tumbleweed (KDE Plasma Desktop) med Nvidia grafikkort.
# Skriptet vil også gjøre noen steg som forbedrer ytelsen på Tumbleweed for gaming.
# Skriptet er ment for openSUSE Tumbleweed (rolling release). Det passer IKKE for openSUSE Leap (andre repo-URLer og driverpakker der).
# En forutsetning for dette skriptet er at de offisielle repoene (oss, non-oss, update) er aktivert, noe som er standard ved installasjon.

# For å kunne kjøre skriptet etter nedlasting må du åpne en terminal i mappen du har lastet ned skriptet og bruke kommandoene:
# chmod +x opensuse_nvidia_gaming.sh
# ./opensuse_nvidia_gaming.sh

# Sjekker at skriptet faktisk kjører på openSUSE Tumbleweed (passer ikke for Leap eller andre distroer).
if ! grep -q 'ID=opensuse-tumbleweed' /etc/os-release; then
    echo "Dette skriptet er kun for openSUSE Tumbleweed — avbryter."
    exit 1
fi

# Sjekker at det faktisk finnes et Nvidia-kort i maskinen (myk advarsel, avbryter ikke).
if command -v lspci > /dev/null 2>&1 && ! lspci | grep -qi nvidia; then
    echo "Advarsel: fant ingen Nvidia-grafikkort i systemet (lspci). Skriptet er ment for maskiner med Nvidia-kort."
fi

# Sjekker at Tumbleweed er helt oppdatert før du starter.
echo -e "\nSjekker at systemet er helt oppdatert før vi starter. Underveis kan det hende at du må skrive inn passordet ditt flere ganger."
echo -e "På Tumbleweed oppgraderer vi med 'zypper dup' (dist-upgrade), som er riktig måte å holde en rolling release oppdatert på."
sudo zypper --gpg-auto-import-keys --auto-agree-with-licenses dup -y
read -p "Trykk [Enter] for å starte..."

# Oppstart av skript
echo -e "\nDette skriptet vil installere drivere for moderne Nvidia grafikkort og annen programvare du trenger for å spille på openSUSE Tumbleweed."
read -p "Trykk [Enter] for å fortsette..."

# Legger til Nvidias offisielle repo for Tumbleweed og installerer Nvidia-drivere.
# Nvidia-pakkenavnene er omorganisert (2025): for kort fra Turing-generasjonen og nyere (GTX 16xx, RTX 20xx og nyere)
# brukes G07-driveren med åpne kjernemoduler som er ferdigbygget og signert for Secure Boot.
# Eldre kort (GeForce 700-serien til GTX 10xx) bruker den proprietære G06-driveren, som ikke er Secure Boot-signert.
echo -e "\nLegger til Nvidias offisielle repo og installerer nyeste Nvidia-driver."
if ! zypper lr nvidia > /dev/null 2>&1; then
    sudo zypper --gpg-auto-import-keys addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed/ nvidia
fi
echo -e "Nvidia-driveren finnes i to varianter:"
echo -e "  1) G07 (anbefalt): Turing og nyere — GTX 16xx, RTX 20xx og nyere (fra 2018). Kjernemodulen er signert, så Secure Boot fungerer."
echo -e "  2) G06: eldre kort — GeForce 700-serien til GTX 10xx (2014-2017). Obs: ikke signert, så Secure Boot må deaktiveres i BIOS."
read -p "Hvilken generasjon er grafikkortet ditt? Skriv 1 eller 2 og trykk [Enter]: " gpu_valg
if [ "$gpu_valg" = "1" ]; then
    nvidia_pakker="nvidia-open-driver-G07-signed-kmp-meta"
elif [ "$gpu_valg" = "2" ]; then
    nvidia_pakker="nvidia-driver-G06-kmp-default nvidia-video-G06 nvidia-gl-G06 nvidia-compute-G06"
else
    echo "Ugyldig valg — avbryter. Kjør skriptet på nytt og velg 1 eller 2."
    exit 1
fi
if ! sudo zypper --gpg-auto-import-keys --auto-agree-with-licenses install -y $nvidia_pakker; then
    echo -e "\nFeil: Nvidia-driveren kunne ikke installeres (sjekk nettverk og repo-URL). Avbryter skriptet."
    exit 1
fi

# 32-bit Nvidia-biblioteker trengs av Steam og mange spill via Proton/Wine.
if [ "$gpu_valg" = "1" ]; then
    nvidia_32bit_pakker="nvidia-gl-G07-32bit nvidia-video-G07-32bit"
else
    nvidia_32bit_pakker="nvidia-gl-G06-32bit nvidia-video-G06-32bit"
fi
echo -e "\nInstallerer 32-bit Nvidia-biblioteker (trengs av Steam og eldre 32-bit spill)."
if ! sudo zypper --auto-agree-with-licenses install -y $nvidia_32bit_pakker; then
    echo -e "\nAdvarsel: 32-bit-bibliotekene kunne ikke installeres. Dette er ikke kritisk, men enkelte eldre spill kan feile."
fi
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

echo "Vi venter et minutt før vi tester driver-versjonen, slik at pakkeoppsettet rekker å bli ferdig."
nedtellingsfunksjon    # venter 60 sekunder med live nedtelling

# Sjekk Nvidia-versjon (modinfo ligger i kmod-pakken)
sudo zypper --auto-agree-with-licenses install -y kmod
echo -e "\nSjekker Nvidia-driverstatus, om det ikke kommer opp et versjonsnummer, vent noen minutter før du går videre:"
if command -v modinfo > /dev/null 2>&1; then
    modinfo -F version nvidia
elif [ -x /usr/sbin/modinfo ]; then
    /usr/sbin/modinfo -F version nvidia
elif command -v nvidia-smi > /dev/null 2>&1; then
    nvidia-smi --query-gpu=driver_version --format=csv,noheader
else
    echo "Hverken modinfo eller nvidia-smi fant driveren ennå — vent noen minutter og kontroller manuelt etter restart."
fi
read -p "Trykk [Enter] for å fortsette..."

# Sjekker at Flatpak er installert (er standard på KDE, men kan mangle).
if ! command -v flatpak > /dev/null 2>&1; then
    echo -e "\nInstallerer Flatpak (ikke funnet på systemet)."
    sudo zypper --auto-agree-with-licenses install -y flatpak
fi

# Installerer Nvidia GeForce Now (strømming av spill).
# NB: Nvidias flatpak-repo har av og til ødelagt metadata ("no summary found"). Dette steget er ikke kritisk
# for gaming-oppsettet, så hvis det feiler hopper skriptet over det. Prøv igjen senere.
echo -e "\nInstallerer Nvidia GeForce NOW for strømming av spill (via Flatpak)."
flatpak remote-add --user --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrep
if flatpak install --user -y GeForceNOW com.nvidia.geforcenow; then
    echo -e "GeForce NOW ble installert."
else
    echo -e "\nAdvarsel: GeForce NOW kunne ikke installeres nå (Nvidias flatpak-repo har av og til ødelagt metadata)."
    echo -e "Dette er IKKE kritisk for gaming — prøv på nytt senere med: flatpak install --user GeForceNOW com.nvidia.geforcenow"
fi
read -p "Trykk [Enter] for å fortsette..."

# Bytter ut åpne ffmpeg codecs med fullversjonen fra Packman (trengs ofte for cutscenes og intro til spill).
echo -e "\nLegger til Packman-repoet og bytter til full ffmpeg med alle codecs."
if ! zypper lr packman > /dev/null 2>&1; then
    sudo zypper --gpg-auto-import-keys addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
fi
sudo zypper --gpg-auto-import-keys --auto-agree-with-licenses install -y --from packman ffmpeg libavcodec-full libavdevice-full
read -p "Trykk [Enter] for å fortsette..."

# Sikrer at flathub er lagt til (trengs for appene under)
echo -e "\nLegger til Flathub-repoet for Flatpak (hvis det ikke finnes fra før)."
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
read -p "Trykk [Enter] for å fortsette..."

# Installere GameMode
echo -e "\nInstallerer GameMode via Zypper (det kan hende dette er installert fra før)."
sudo zypper --auto-agree-with-licenses install -y gamemode
echo -e "Tips: GameMode aktiveres per spill i Steam ved å legge 'gamemoderun %command%' i startvalgene til spillet."
read -p "Trykk [Enter] for å fortsette..."

# Installere ProtonPlus
echo -e "\nInstallerer ProtonPlus via Flatpak."
flatpak install --user -y flathub com.vysp3r.ProtonPlus
read -p "Trykk [Enter] for å fortsette..."

# Installere Protontricks
echo -e "\nInstallerer Protontricks via Zypper."
sudo zypper --auto-agree-with-licenses install -y protontricks
read -p "Trykk [Enter] for å fortsette..."

# Installere Steam
echo -e "\nInstallerer Steam via Zypper (ligger i non-oss-repoet som er standard aktivert)."
sudo zypper --auto-agree-with-licenses install -y steam
read -p "Trykk [Enter] for å fortsette..."

# Installere Heroic Launcher
echo -e "\nInstallerer Heroic Launcher via Flatpak (for å kunne spille spill fra Epic og GoG)."
flatpak install --user -y flathub com.heroicgameslauncher.hgl
read -p "Trykk [Enter] for å fortsette..."

# Justerer kjerneparametre for gaming (idempotent: parametrene legges bare til hvis de ikke finnes fra før).
echo -e "\nJusterer kjerneparametre for gaming (preempt=full og transparent_hugepage=always)."
if grep -q 'preempt=full' /etc/default/grub && grep -q 'transparent_hugepage=always' /etc/default/grub; then
    echo "Kjerneparametrene står allerede i /etc/default/grub — ingen endring nødvendig."
else
    if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 preempt=full transparent_hugepage=always"/' /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="preempt=full transparent_hugepage=always"' | sudo tee -a /etc/default/grub > /dev/null
    fi
    # Rydder bort ledende mellomrom hvis linjen var tom fra før.
    sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="\) /\1/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
read -p "Trykk [Enter] for å fortsette..."

# Fullført melding
echo -e "\nNå er openSUSE Tumbleweed klart for gaming, men ta en restart først, så du er sikker på at de beste Nvidia-driverne og de oppdaterte kjerneparameterne blir brukt."
echo -e "\nHvis restart feiler og du valgte G06-driveren (eldre kort), prøv å deaktivere Secure Boot i BIOS."
echo -e "\nTips: Tumbleweed tar automatisk Btrfs-snapshots med Snapper før alle systemoppgraderinger. Hvis en oppdatering skulle ødelegge noe, kan du boote tilbake til forrige snapshot fra GRUB-menyen og rulle tilbake med 'sudo snapper rollback' (etterfulgt av restart)."
echo -e
read -p "Trykk [Enter] for å ta en restart av PC'en..."

#restart
sudo systemctl reboot

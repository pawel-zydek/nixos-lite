# Konfiguracja NixOS – stary laptop

Konfiguracja laptopa **Lenovo IdeaPad 110-15IBR** (typ 80T7) – host `nixos-lite`: NixOS z menedżerem
okien **Sway** na **btrfs** (szyfrowanym LUKS2), Home Manager jako moduł NixOS. Jest to repozytorium do nauki.

| Sprzęt | Jak to obsługuje konfiguracja |
|---|---|
| Celeron N3060 / Pentium N3710 (Braswell) | ma AES-NI, więc szyfrowanie LUKS prawie nie kosztuje; na baterii bez turbo (TLP) |
| Intel HD 400/405 | VA-API przez sterownik `i965` (nowszy `iHD` nie obsługuje Braswell) |
| brak sprzętowego VP9/AV1 | Firefox ma wyłączone VP9/AV1, więc YouTube przysyła H.264 dekodowane przez GPU; mpv: H.264 do 720p |
| 4 GB DDR3L | zram (zstd), earlyoom, lekkie programy |
| dysk SATA: HDD 5400 obr. lub SSD | kompresja zstd:1, planista I/O dobierany automatycznie (HDD: `bfq`, SSD: `mq-deadline`) |
| ekran 1366x768 | Sway w skali 1 |
| Wi-Fi + Bluetooth na jednej karcie | firmware z `hardware.enableRedistributableFirmware`, Bluetooth włączany ręcznie (blueman) |
| UEFI | systemd-boot |
Struktura jest taka sama jak w [nixos-config](https://github.com/pawel-zydek/nixos-config) i
[nixos-vm](https://github.com/pawel-zydek/nixos-vm).

## Dlaczego tak

- **Sway, a nie i3** – Sway to i3 dla Waylanda: ta sama składnia konfiguracji i te same skróty, więc wiedza
  z VM przechodzi 1:1. Wayland jest kierunkiem rozwoju (Plasma, GNOME, Fedora, Ubuntu domyślnie),
  a X11 jest już tylko utrzymywany. Na zintegrowanej grafice Intela Sway działa bardzo dobrze,
  a nie potrzebuje osobnego kompozytora (picom) ani programu do tapety.
- **btrfs, a nie ZFS** – ZFS trzyma własną pamięć podręczną (ARC) obok zwykłej pamięci podręcznej Linuksa
  i na 4 GB RAM zabierałby pamięć programom. btrfs korzysta ze zwykłej pamięci podręcznej jądra, a daje to,
  czego używasz na PG: sumy kontrolne, kompresję (zstd) i snapshoty `/home`.
- **zram + earlyoom** (`modules/nixos/core/memory.nix`) – skompresowany swap w RAM i zamykanie
  najbardziej pamięciożernego programu, zanim system zamarznie. To daje więcej niż wybór menedżera okien.
- **Lekkie programy**: greetd/tuigreet zamiast SDDM/LightDM, foot (terminal), fuzzel (wyszukiwarka programów),
  mako (powiadomienia), i3status (pasek), pcmanfm, mpv, imv, zathura.
  Programy Electron (Obsidian, Spotify, drawio) są w `modules/home/packages.nix` zakomentowane.

## Struktura repozytorium

```
flake.nix                    # wejścia (nixpkgs, disko, home-manager) i lista hostów
flake.lock                   # przypięte wersje wejść
hosts/
  lite/
    default.nix              # tożsamość hosta, dysk + lista włączonych funkcji (my.*.enable)
    hardware-configuration.nix
modules/
  nixos/                     # moduły systemowe; default.nix importuje wszystkie
    core/                    # zawsze włączone: nix, boot, memory (zram, earlyoom), locale, użytkownik, pakiety, HM
    storage/                 # disko-btrfs (układ dysku), btrfs (scrub, TRIM, snapper), ntfs
    desktop/                 # sway + greetd, audio
    hardware/                # firmware, intel-graphics (i965), laptop (TLP), bluetooth
    services/                # ssh, printing
  home/                      # moduły Home Managera: sway, foot, git, vim, bash, firefox, ...
users/
  pawel.nix                  # które moduły z modules/home/ dostaje użytkownik
assets/
  wallpapers/                # tapety
scripts/
  ustaw-dysk.sh              # wpisuje dysk laptopa do hosts/lite/default.nix (instalacja, krok 4)
```

Moduły spoza `core/` nic nie robią, dopóki host ich nie włączy, np. w `hosts/lite/default.nix`:

```nix
my.hardware.bluetooth.enable = true;
```

Nowy moduł: utwórz plik w odpowiednim katalogu `modules/nixos/`, dopisz go do
`modules/nixos/default.nix` i włącz w hoście. Formatowanie całego repo: `nix fmt`.

## Układ dysku

| Partycja / subwolumen | Punkt montowania | Uwagi |
|---|---|---|
| ESP (1 GB, FAT32) | `/boot` | systemd-boot |
| LUKS2 `cryptroot` (reszta dysku) | — | szyfrowanie, hasło przy starcie |
| btrfs `@` | `/` | wszystkie subwolumeny: `compress=zstd:1`, `noatime` |
| btrfs `@home` | `/home` | snapshoty snapper (24 h / 7 dni / 3 mies.) w `/home/.snapshots` |
| btrfs `@nix` | `/nix` | |
| btrfs `@log` | `/var/log` | logi poza snapshotami i poza `/` |

Brak partycji swap — używany jest zram (hibernacja nie jest dostępna).

### Odpowiedniki poleceń ZFS

| ZFS (PG) | btrfs (ten laptop) |
|---|---|
| `zpool status` | `sudo btrfs device stats /` oraz `sudo btrfs scrub status /` |
| `zfs list` | `sudo btrfs subvolume list /` |
| `zfs list -o compressratio` | `sudo compsize /` (`nix-shell -p compsize`) |
| `zfs list -t snapshot` | `snapper -c home list` |
| `ls /home/.zfs/snapshot/` | `ls /home/.snapshots/*/snapshot/` |
| `zpool scrub rpool` | `sudo btrfs scrub start /` |

---

# Sposób instalacji

> **Uwaga:** krok 7 kasuje **cały** dysk wskazany w `my.disk` (`hosts/lite/default.nix`).

## 0. Przygotowanie

1. Pobierz **minimalny** obraz NixOS 26.05 z <https://nixos.org/download/> (*Minimal ISO image*, 64-bit Intel/AMD)
   i zapisz go na pendrive (KDE ISO Image Writer, Rufus w trybie DD albo `dd`).
2. Ustawienia BIOS laptopa – wejście: **F2** (lub **Fn+F2**) przy starcie (albo mały przycisk *Novo* z boku obudowy
   przy wyłączonym laptopie → *BIOS Setup*):
   - *Boot* → **Boot Mode: UEFI**,
   - *Security* → **Secure Boot: Disabled** (systemd-boot nie jest podpisany),
   - zapisz **F10**.
3. Start z pendrive'a: **F12** (lub **Fn+F12**) przy starcie (lub *Novo* → *Boot Menu*), wybierz pendrive w trybie UEFI.

## 1. Start instalatora i klawiatura

```bash
sudo -i                 # dalej wszystko jako root
loadkeys pl2            # polska klawiatura w konsoli
export NIX_CONFIG="experimental-features = nix-command flakes"
```

`NIX_CONFIG` włącza flakes na czas tej sesji – bez tego polecenia `nix` nie zadziałają z repozytorium.

## 2. Połączenie z siecią

Kabel Ethernet działa od razu (DHCP). Wi-Fi:

```bash
nmcli device wifi list
nmcli device wifi connect "NAZWA_SIECI" --ask
ping -c 3 nixos.org
```

Nie widać karty Wi-Fi? `rfkill unblock all`, potem znowu `nmcli device wifi list`.

## 3. (Opcjonalnie) Praca przez SSH z PG

Wygodniej kopiować polecenia z tej instrukcji.

```bash
passwd nixos            # tymczasowe hasło dla użytkownika instalatora
ip -br addr             # adres IP laptopa
```

Na PG: `ssh nixos@ADRES_IP`, potem znowu `sudo -i` oraz `export NIX_CONFIG=...` z kroku 1.

## 4. Pobranie repozytorium i sprawdzenie sprzętu

```bash
git clone https://github.com/pawel-zydek/nixos-lite /tmp/nixos-lite
cd /tmp/nixos-lite
```

### 4a. Dysk

Skrypt sam znajduje wewnętrzny dysk SATA (pomija pendrive i napęd DVD), wypisuje go
i wpisuje do `hosts/lite/default.nix`:

```bash
./scripts/ustaw-dysk.sh
```

Sprawdź, czy rozmiar i model się zgadzają. `ROTA` pokaże przy okazji, czy w laptopie jest jeszcze
fabryczny dysk talerzowy (`1`), czy SSD (`0`) – konfiguracja działa z oboma bez zmian.

Numer seryjny dysku jest inny w każdym egzemplarzu, dlatego nie da się go wpisać w repozytorium z góry.

## 5. Plik hardware-configuration.nix

`--no-filesystems`, bo systemy plików opisuje disko.

```bash
nixos-generate-config --no-filesystems --show-hardware-config > hosts/lite/hardware-configuration.nix
```

Flake widzi **tylko pliki śledzone przez gita** – dodaj zmiany:

```bash
git add -A
git status
```

## 6. Szybki test konfiguracji

```bash
nix eval .#nixosConfigurations.nixos-lite.config.system.build.toplevel.drvPath
```

Jeśli wypisze ścieżkę `/nix/store/...drv`, konfiguracja jest poprawna. Błąd pokaże plik i linię.

## 7. Partycjonowanie i formatowanie (disko)

Ostatnia kontrola – ścieżka musi wskazywać na dysk laptopa (`sda` lub `nvme0n1`), nie na pendrive:

```bash
ls -l $(grep -o '/dev/disk/by-id/[^"]*' hosts/lite/default.nix)
```

```bash
nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake .#nixos-lite
```

- disko poprosi o potwierdzenie usunięcia danych,
- potem **dwa razy o hasło LUKS** – będzie wpisywane przy każdym starcie, nie zgub go.

Sprawdzenie:

```bash
lsblk -f
btrfs subvolume list /mnt
findmnt -R /mnt         # /mnt, /mnt/boot, /mnt/home, /mnt/nix, /mnt/var/log
```

## 8. Instalacja

```bash
nixos-install --flake .#nixos-lite --no-root-passwd
```

Pobiera kilka GB, więc na starym laptopie trochę potrwa. `--no-root-passwd` – root bez hasła logowania,
administrujemy przez `sudo` (grupa `wheel`).

## 9. Czynności po instalacji (jeszcze w instalatorze)

```bash
# hasło użytkownika pawel
nixos-enter --root /mnt -c 'passwd pawel'

# przeniesienie zapisanej sieci Wi-Fi do nowego systemu
mkdir -p /mnt/etc/NetworkManager/system-connections
cp /etc/NetworkManager/system-connections/*.nmconnection /mnt/etc/NetworkManager/system-connections/ 2>/dev/null
chmod 600 /mnt/etc/NetworkManager/system-connections/* 2>/dev/null

# kopia repozytorium (z hardware-configuration.nix) do katalogu domowego
cp -r /tmp/nixos-lite /mnt/home/pawel/
chown -R 1000:100 /mnt/home/pawel/nixos-lite      # 1000 = pawel, 100 = grupa users
```

## 10. Odmontowanie i restart

```bash
umount -R /mnt
cryptsetup close cryptroot     # tylko przy szyfrowaniu
reboot
```

Wyjmij pendrive.

## 11. Pierwsze uruchomienie

1. Wpisz hasło LUKS.
2. W tuigreet zaloguj się jako `pawel` – startuje Sway (tuigreet zapamięta użytkownika).
3. Wi-Fi powinno połączyć się samo (krok 9); jeśli nie – ikona sieci w zasobniku na górnym pasku
   albo `nmtui` w terminalu.
4. Sprawdź sprzętowe dekodowanie wideo: `nix-shell -p libva-utils --run vainfo` – powinien pokazać
   sterownik *Intel i965 driver … Braswell* i listę profili (m.in. `VAProfileH264High`).
5. Zapisz zmiany w repozytorium (głównie `hardware-configuration.nix` i `my.disk`):

```bash
cd ~/nixos-lite
git status
git add -A
git commit -m "Laptop: hardware-configuration i dysk"
git push
```

Przy pierwszym `git push` podaj login GitHub i **token** (Personal Access Token) zamiast hasła –
zostanie zapamiętany w GNOME Keyring (podgląd: program *Hasła i klucze* / `seahorse`).

## Podstawowe skróty Sway

Klawisz `Mod` to **Super** (klawisz Windows). Skróty są takie same jak w i3.

| Skrót | Działanie |
|---|---|
| `Super+Enter` | terminal (foot) |
| `Super+d` | uruchamianie programów (fuzzel) |
| `Super+Shift+q` | zamknięcie okna |
| `Super+1` … `Super+0` | przełączenie obszaru roboczego |
| `Super+Shift+1` … | przeniesienie okna na obszar roboczy |
| `Super+strzałki` | zmiana aktywnego okna |
| `Super+b` / `Super+v` | następne okno obok / pod spodem |
| `Super+w` / `Super+e` | układ w kartach / z powrotem kafelki |
| `Super+f` | pełny ekran |
| `Super+Shift+Spacja` | okno pływające / kafelkowe |
| `Super+r` | tryb zmiany rozmiaru (strzałki, `Esc` kończy) |
| `Super+Shift+x` | blokada ekranu |
| `Print` / `Shift+Print` | zrzut ekranu / zaznaczonego obszaru do schowka |
| `Super+Shift+c` | przeładowanie konfiguracji |
| `Super+Shift+e` | wyjście z Sway |

Klawisze głośności i jasności laptopa działają. Ekran blokuje się po 5 min bezczynności,
wygasza po 10 min, a także przed uśpieniem (zamknięcie klapy).
Konfiguracja: `modules/home/sway.nix`, dokumentacja: `man 5 sway`.

---

# Codzienna praca

```bash
cd ~/nixos-lite

# po zmianie plików konfiguracji
git add -A
sudo nixos-rebuild switch --flake .#nixos-lite     # albo alias: rebuild

# aktualizacja systemu
nix flake update
sudo nixos-rebuild switch --flake .#nixos-lite
nvd diff /run/booted-system /run/current-system    # co się zmieniło
git commit -am "Aktualizacja flake.lock" && git push

# test bez zapisywania jako domyślna generacja
sudo nixos-rebuild test --flake .#nixos-lite
```

Stara generacja zawsze jest dostępna w menu startowym.

## Budowanie na PG, wdrażanie na laptop (szybciej)

Ewaluacja konfiguracji i budowanie potrafią zająć na 4 GB RAM sporo czasu. Można to zrobić na PG,
a na laptop wysłać tylko gotowy wynik. Logowanie tylko kluczem; dozwolone klucze są w `hosts/lite/default.nix`.

```bash
# na PG, w katalogu z tym repo
git clone https://github.com/pawel-zydek/nixos-lite ~/nixos-lite    # raz
cd ~/nixos-lite && git pull
nixos-rebuild switch --flake .#nixos-lite --target-host pawel@ADRES_IP_LAPTOPA --sudo
```

`--sudo` zapyta o hasło użytkownika `pawel` na laptopie.

## Snapshoty /home (snapper)

```bash
snapper -c home list                          # lista snapshotów
sudo snapper -c home create -d "przed zmianą" # ręczny snapshot
ls /home/.snapshots/                          # numery snapshotów
ls /home/.snapshots/NUMER/snapshot/pawel/     # pliki ze snapshotu (tylko do odczytu)
snapper -c home diff NUMER1..NUMER2           # co zmieniło się między snapshotami
```

Pojedynczy plik przywraca się zwykłym kopiowaniem z katalogu `snapshot/`.

## Pamięć

```bash
free -h                 # RAM i swap (zram)
zramctl                 # ile zajmuje zram i jaki ma współczynnik kompresji
btop                    # co zjada pamięć
journalctl -u earlyoom  # co earlyoom zamknął z braku pamięci
```

## Firmware

```bash
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```

Stare laptopy często nie mają aktualizacji przez fwupd – wtedy `get-updates` nic nie pokaże.

---

# Rozwiązywanie problemów

| Objaw | Rozwiązanie |
|---|---|
| Po instalacji laptop nie startuje z dysku | BIOS (F2) → *Boot*: przesuń „Linux Boot Manager” na pierwsze miejsce; Boot Mode musi być UEFI |
| Sway nie startuje, czarny ekran po zalogowaniu | w konsoli (`Ctrl+Alt+F2`): `sway 2> ~/sway.log`, przeczytaj log |
| Laptop losowo zamarza (znany problem części układów Bay Trail/Braswell) | dopisz w `modules/nixos/core/boot.nix` do `kernelParams`: `"intel_idle.max_cstate=1"` |
| Wi-Fi zablokowane (`rfkill list` → *Hard blocked: yes*) | `sudo modprobe -r ideapad_laptop`; jeśli pomaga, dopisz w hoście `boot.blacklistedKernelModules = [ "ideapad_laptop" ];` |
| YouTube klatkuje | `about:support` w Firefoksie → *Media* → dekodowanie sprzętowe H.264 musi być „Supported”; jakość 720p |
| Program nie działa / wygląda źle pod Waylandem | uruchomi się przez XWayland; dla Electron: `NIXOS_OZONE_WL=` (puste) przed nazwą programu |
| Brak ikony sieci w pasku | `nm-applet --indicator &` w terminalu; zamiennik: `nmtui` |
| Touchpad nie klika stuknięciem | `swaymsg -t get_inputs` – sprawdź, czy urządzenie ma typ `touchpad` |
| System zwalnia przy wielu kartach | to normalne przy 4 GB; earlyoom zamknie najcięższy proces. Mniej kart, uBlock Origin |
| Bardzo wolno działa przy fabrycznym HDD | to dysk 5400 obr. – największą różnicę da wymiana na dowolny SSD SATA 2,5" (i reinstalacja z tego repo) |
| `nix` nie zna `flake` / `run` | `export NIX_CONFIG="experimental-features = nix-command flakes"` |
| Zmiany w plikach są ignorowane | `git add -A` – flake widzi tylko pliki w gicie |
| System nie startuje po zmianie | wybierz poprzednią generację w menu startowym |

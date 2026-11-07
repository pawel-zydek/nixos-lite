#!/usr/bin/env bash
# Wyszukuje wewnętrzny dysk SATA laptopa i wpisuje jego ścieżkę /dev/disk/by-id/...
# do hosts/lite/default.nix (my.disk). Pendrive (USB) i napęd DVD są pomijane.
# Uruchomienie z katalogu repozytorium: ./scripts/ustaw-dysk.sh
set -euo pipefail

host_file="hosts/lite/default.nix"
[ -f "$host_file" ] || { echo "Uruchom skrypt z katalogu repozytorium (brak $host_file)."; exit 1; }

# dyski (TYPE=disk) podłączone przez SATA (TRAN=sata)
mapfile -t disks < <(lsblk -dnpo NAME,TYPE,TRAN | awk '$2 == "disk" && $3 == "sata" { print $1 }')

if [ "${#disks[@]}" -ne 1 ]; then
  echo "Znaleziono ${#disks[@]} dysków SATA (oczekiwano 1):"
  lsblk -do NAME,SIZE,TYPE,TRAN,MODEL
  echo "Wpisz ścieżkę ręcznie: ls -l /dev/disk/by-id/ | grep -v part"
  exit 1
fi
dev="${disks[0]}"

# stała nazwa dysku (ata-MODEL_NUMER) wskazująca na znalezione urządzenie
id=""
for link in /dev/disk/by-id/ata-*; do
  case "$link" in *-part*) continue ;; esac
  if [ "$(readlink -f "$link")" = "$dev" ]; then id="$link"; break; fi
done
[ -n "$id" ] || { echo "Brak wpisu ata-* dla $dev w /dev/disk/by-id."; exit 1; }

echo "Dysk systemowy:"
lsblk -do NAME,SIZE,ROTA,MODEL "$dev"
echo "(ROTA=1 - dysk talerzowy HDD, ROTA=0 - SSD)"
echo

sed -i "s|my.disk = \".*\";|my.disk = \"$id\";|" "$host_file"
echo "Zapisano w $host_file:"
grep -n 'my.disk =' "$host_file"

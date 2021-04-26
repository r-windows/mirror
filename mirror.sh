#!/bin/sh
set -e

#  Wipe existing dir
if [ "${CLEAN}" ]; then
echo "Running with clean"
rm -Rf mingw32 mingw64 ucrt64
fi
mkdir -p {mingw32,mingw64,ucrt64}
./restore-timestamps.sh

# Cleanup and switch to staging server
cp -f pacman.conf /etc/pacman.conf
pacman --noconfirm -Rcsu $(pacman -Qqe | grep "^mingw-w64-") || true
pacman -Scc
pacman -Syy

# Download mingw32
(cd mingw32; 
  curl -OL https://ftp.opencpu.org/rtools/mingw32/mingw32.db;
  curl -OL https://ftp.opencpu.org/rtools/mingw32/mingw32.files;
  pacman -Syyw --noconfirm --cache=. $(pacman -Slq | grep mingw-w64-i686))

# Downoad mingw64
(cd mingw64; 
  curl -OL https://ftp.opencpu.org/rtools/mingw64/mingw64.db;
  curl -OL https://ftp.opencpu.org/rtools/mingw64/mingw64.files;
  pacman -Syyw --noconfirm --cache=. $(pacman -Slq | grep mingw-w64-x86_64))

# Download ucrt64
(cd ucrt64; 
  curl -OL https://ftp.opencpu.org/rtools/ucrt64/ucrt64.db;
  curl -OL https://ftp.opencpu.org/rtools/ucrt64/ucrt64.files;
  pacman -Syyw --noconfirm --cache=. $(pacman -Slq | grep mingw-w64-ucrt-x86_64))

#!/bin/sh
set -e

#  Wipe existing dir
if [ "${CLEAN}" ]; then
echo "Running with clean"
rm -Rf mirrors mingw32 mingw64 ucrt64
else
./restore-timestamps.sh
fi
mkdir -p {mirrors,mingw32,mingw64,ucrt64}

# Cleanup and switch to staging server
cp -f pacman.conf /etc/pacman.conf
pacman --noconfirm -Rcsu $(pacman -Qqe | grep "^mingw-w64-") || true
pacman -Scc
pacman -Syy

# Download rtools-mirrors index
(cd mirrors;
  curl -OL https://ftp.opencpu.org/rtools/x86_64/mirrors.db;
  curl -OL https://ftp.opencpu.org/rtools/x86_64/mirrors.files;
  pacman -Syyw --noconfirm --cache=. rtools-mirrors)

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

# Store the timestamps of the builds (git loses this)
find . -regex ".*\.\(xz\|db\|files\)" -mount -print0 | perl -ne 'INIT{ $/ = "\0"; use File::stat;} chomp; my $s = stat($_); next unless $s; print $s->ctime . "/" . $s->mtime . "/" . $s->atime ."/$_\0"; ' > dates.txt

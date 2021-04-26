#!/bin/sh
set -e

# Setup git
git config --global user.email 'jeroenooms@gmail.com'
git config --global user.name  'Jeroen Ooms (via CI)'

# Commit files
git add mingw32 mingw64 ucrt64
if [[ -z $(git diff --name-only --cached) ]]; then
	echo "No changes to commit"
	exit 0
fi

# Store the timestamps of the builds (git loses this)
find . -regex ".*\.\(xz\|db\|files\)" -mount -print0 | perl -ne 'INIT{ $/ = "\0"; use File::stat;} chomp; my $s = stat($_); next unless $s; print $s->ctime . "/" . $s->mtime . "/" . $s->atime ."/$_\0"; ' > dates.txt
git add dates.txt

# Commit and push
git commit -m "Mirror update $(date +%F)"
git push origin master

#!/usr/bin/env sh

dataDirs="${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS}"
appDirs=$(for dir in $(echo "$dataDirs" | tr : '\n'); do
  if [ -e "$dir/applications" ]; then
    echo "$dir/applications"
  fi
done)

for file in $(find $appDirs -type f,l -name *.desktop | xargs grep --files-without-match NoDisplay=true); do
  name=$(grep --max 1 ^Name= $file | cut -d= -f2)
  command="gtk-launch $(basename "$file")"
  echo "$name=$command"
done | sort --ignore-case --unique

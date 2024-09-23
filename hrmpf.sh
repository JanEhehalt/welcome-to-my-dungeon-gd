#!/bin/sh
echo -ne '\033c\033]0;welcome-to-my-dungeon-gd\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/hrmpf.x86_64" "$@"

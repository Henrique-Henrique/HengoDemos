#!/usr/bin/env bash
# replaces the addons/ folder of every demo project with the one at the repo root
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$root_dir/addons"
dry_run=0

case "${1:-}" in
	-n|--dry-run) dry_run=1 ;;
	-h|--help)
		echo "usage: $(basename "$0") [-n|--dry-run]"
		echo
		echo "copies $(basename "$root_dir")/addons into every folder that has a project.godot,"
		echo "deleting the addons folder that project had."
		exit 0
		;;
	'') ;;
	*)
		echo "unknown option: $1" >&2
		exit 2
		;;
esac

if [ ! -d "$source_dir" ]; then
	echo "error: no addons folder at the repo root ($source_dir)" >&2
	exit 1
fi

if [ -z "$(ls -A "$source_dir")" ]; then
	echo "error: the addons folder at the repo root is empty" >&2
	exit 1
fi

projects=()

for godot_file in "$root_dir"/*/project.godot; do
	[ -e "$godot_file" ] || continue
	projects+=("$(dirname "$godot_file")")
done

if [ "${#projects[@]}" -eq 0 ]; then
	echo "no demo project found next to $(basename "$0")"
	exit 0
fi

echo "source: $source_dir"

for project in "${projects[@]}"; do
	name="$(basename "$project")"

	if [ "$dry_run" -eq 1 ]; then
		if [ -d "$project/addons" ]; then
			echo "would replace $name/addons"
		else
			echo "would create $name/addons"
		fi
		continue
	fi

	rm -rf "$project/addons"
	cp -r "$source_dir" "$project/addons"
	echo "updated $name/addons"
done

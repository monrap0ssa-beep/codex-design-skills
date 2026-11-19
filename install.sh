#!/usr/bin/env bash
set -euo pipefail

destination=${1:-"$HOME/.agents/skills"}
mkdir -p -- "$destination"
temporary_dir=$(mktemp -d)
trap 'rm -rf -- "$temporary_dir"' EXIT

source_dir=''
while read -r repository revision directory name; do
  if [[ -e "$destination/$name" || -L "$destination/$name" ]]; then
    printf 'Уже установлен: %s\n' "$name"
    continue
  fi

  checkout="$temporary_dir/${repository%%/*}"
  if [[ "$source_dir" != "$checkout" ]]; then
    git init -q "$checkout"
    git -C "$checkout" fetch -q --depth 1 "https://github.com/$repository.git" "$revision"
    git -C "$checkout" checkout -q --detach FETCH_HEAD
    source_dir="$checkout"
  fi

  skill_dir="$checkout/$directory"
  test -s "$skill_dir/SKILL.md"
  cp -a -- "$skill_dir" "$temporary_dir/staged-$name"
  mv -T --no-clobber -- "$temporary_dir/staged-$name" "$destination/$name"
  printf 'Установлен: %s\n' "$name"
done <<'SKILLS'
pbakaus/impeccable b49177d32788f2dc585c42831d845dacf1ebed2c .agents/skills/impeccable impeccable
Leonxlnx/taste-skill f6b76575f949707b4e3c37cd86cb44b0b98643e8 skills/taste-skill design-taste-frontend
emilkowalski/skills 64eb3deb9a5fbfa041faf783e0bc3fd635872e9c skills/animate animate
anthropics/skills e4bb5d960d87126ff3b3a8af1a104b7db67560ba skills/canvas-design canvas-design
anthropics/skills e4bb5d960d87126ff3b3a8af1a104b7db67560ba skills/algorithmic-art algorithmic-art
SKILLS

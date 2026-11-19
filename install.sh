#!/usr/bin/env bash
set -euo pipefail

destination=${1:-"$HOME/.agents/skills"}
mkdir -p -- "$destination"
temporary_dir=$(mktemp -d)
trap 'rm -rf -- "$temporary_dir"' EXIT

install_skill() {
  local skill_dir="$1" name="$2"
  local staged="$temporary_dir/staged-$name"

  if [[ -e "$destination/$name" || -L "$destination/$name" ]]; then
    printf 'Уже установлен: %s\n' "$name"
    return
  fi

  test -s "$skill_dir/SKILL.md"
  if [[ "$skill_dir" == "$checkout/." ]]; then
    mkdir -- "$staged"
    git -C "$checkout" archive HEAD | tar -x -C "$staged"
  else
    cp -a -- "$skill_dir" "$staged"
  fi
  mv -T --no-clobber -- "$staged" "$destination/$name"
  printf 'Установлен: %s\n' "$name"
}

while read -r repository revision directory name; do
  if [[ "$name" != '*' && ( -e "$destination/$name" || -L "$destination/$name" ) ]]; then
    printf 'Уже установлен: %s\n' "$name"
    continue
  fi

  checkout="$temporary_dir/${repository//\//-}"
  if [[ ! -d "$checkout" ]]; then
    git init -q "$checkout"
    git -C "$checkout" fetch -q --depth 1 "https://github.com/$repository.git" "$revision"
    git -C "$checkout" checkout -q --detach FETCH_HEAD
  fi

  if [[ "$name" == '*' ]]; then
    for skill_file in "$checkout/$directory"/*/SKILL.md; do
      skill_dir="${skill_file%/SKILL.md}"
      install_skill "$skill_dir" "${skill_dir##*/}"
    done
  else
    install_skill "$checkout/${directory}" "$name"
  fi
done <<'SKILLS'
pbakaus/impeccable b49177d32788f2dc585c42831d845dacf1ebed2c .agents/skills/impeccable impeccable
Leonxlnx/taste-skill f6b76575f949707b4e3c37cd86cb44b0b98643e8 skills/taste-skill design-taste-frontend
emilkowalski/skills 64eb3deb9a5fbfa041faf783e0bc3fd635872e9c skills/animate animate
anthropics/skills e4bb5d960d87126ff3b3a8af1a104b7db67560ba skills/canvas-design canvas-design
anthropics/skills e4bb5d960d87126ff3b3a8af1a104b7db67560ba skills/algorithmic-art algorithmic-art
coreyhaines31/marketingskills 73573e94a06a39965978b3fa1f9c1eace8cebc7c skills *
hardikpandya/stop-slop 8da1f030185bdfe8471220585162991eaeb970e9 . stop-slop
nextlevelbuilder/ui-ux-pro-max-skill 2de1134dc4d1cfe112934611ae5803ae17a1bd7e .claude/skills/ui-ux-pro-max ui-ux-pro-max
SKILLS

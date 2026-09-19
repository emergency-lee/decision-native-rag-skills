#!/usr/bin/env bash
# Repository consistency checks. Run from the repository root.
#   scripts/check.sh           local checks only
#   scripts/check.sh --sources also re-check public sources (network)
set -u
fail=0
say() { printf '%s\n' "$*"; }

# 1. Shared decision schema must be identical in both skills.
if diff -q skills/rag-migrate/references/decisions.md skills/rag-design/references/decisions.md >/dev/null; then
  say "ok   decisions.md copies identical"
else
  say "FAIL decisions.md differs between rag-migrate and rag-design"; fail=1
fi

# 2. Relative links inside each skill must resolve within that skill folder.
for skill in skills/*/; do
  while IFS= read -r link; do
    target="$skill$link"
    if [ -e "$target" ]; then say "ok   $skill$link"; else say "FAIL missing $target"; fail=1; fi
  done < <(grep -rhoE '\]\((references/[^)#]+)\)' "$skill" --include='*.md' | sed -E 's/^\]\(//; s/\)$//' | sort -u)
done

# 3. Frontmatter: name matches folder, description <= 1024 chars.
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(sed -n 's/^name: //p' "$f" | head -1)
  dlen=$(sed -n 's/^description: //p' "$f" | head -1 | wc -m | tr -d ' ')
  if [ "$name" = "$dir" ] && [ "$dlen" -le 1025 ]; then say "ok   $dir frontmatter ($dlen chars)"; else say "FAIL $dir frontmatter name=$name len=$dlen"; fail=1; fi
done

# 4. Optional: public sources still resolve; GitHub HEAD commits vs recorded.
if [ "${1:-}" = "--sources" ]; then
  while IFS= read -r url; do
    code=$(curl -sL -o /dev/null -w '%{http_code}' -A 'Mozilla/5.0' "$url")
    [ "$code" = 200 ] && say "ok   $code $url" || { say "FAIL $code $url"; fail=1; }
  done < <(grep -oE 'https://[^ |)]+' references/public-sources.md | sort -u)
  while IFS='|' read -r repo sha; do
    if command -v gh >/dev/null 2>&1; then
      head=$(gh api "repos/$repo/commits?per_page=1" -q '.[0].sha[0:7]' 2>/dev/null)
    else
      head=$(curl -s "https://api.github.com/repos/$repo/commits?per_page=1" | grep -m1 '"sha"' | sed -E 's/.*"([0-9a-f]{7}).*/\1/')
    fi
    [ -z "$head" ] && { say "FAIL $repo HEAD lookup failed"; fail=1; continue; }
    [ "$head" = "$sha" ] && say "ok   $repo HEAD $sha unchanged" || say "NOTE $repo HEAD $head (recorded $sha) — re-read its README and update public-sources.md"
  done < <(sed -nE 's#.*github.com/([^/]+/[^ :|]+).*commit ([0-9a-f]{7}).*#\1|\2#p' references/public-sources.md)
fi

exit $fail

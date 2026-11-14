#!/bin/bash
# site-check.sh -- run before every publish. Scans *.html in the site root and reports file:line.
#   1. prices: "$" followed by a digit, "2.99", "0.99"                         (FAILS)
#   2. "Build <n>" and "Updated <date>" stamps older than 45 days              (report only)
#   3. "beta" / "TestFlight" outside help.html                                 (FAILS)
#   4. "PROMO BANNER: remove after <date>" whose date has passed               (FAILS)
#   5. the latest version in whats-new.html, to compare with the App Store     (report only)
# Bash only, no dependencies. Exit 1 if 1, 3 or 4 find anything.
cd "$(dirname "$0")/.." || exit 2
shopt -s nullglob
FILES=(*.html)
[ ${#FILES[@]} -gt 0 ] || { echo "no *.html here"; exit 2; }
fail=0
MAX_AGE_DAYS=45
now=$(date +%s)

# "Nov 30, 2026" / "November 30, 2026" -> epoch seconds (BSD date, then GNU date); empty if unreadable.
epoch() {
  local d="$1" e
  for f in "%b %d, %Y" "%B %d, %Y" "%b %d %Y" "%B %d %Y"; do
    e=$(date -j -f "$f %H:%M:%S" "$d 00:00:00" +%s 2>/dev/null) && { echo "$e"; return; }
  done
  date -d "$d" +%s 2>/dev/null
}
# grep with a short snippet (some lines hold embedded images and are very long).
scan() { grep -HnoE "$@" | cut -c1-200; }

echo "== 1. Prices (\$<digit>, 2.99, 0.99) =="
out=$(scan '.{0,40}(\$[0-9]|2\.99|0\.99).{0,40}' "${FILES[@]}")
if [ -n "$out" ]; then echo "$out"; fail=1; else echo "none"; fi

echo; echo "== 2. Build numbers and old \"Updated\" stamps (over $MAX_AGE_DAYS days) =="
out=$(scan '.{0,30}Build [0-9]+.{0,30}' "${FILES[@]}")
if [ -n "$out" ]; then echo "$out"; else echo "no \"Build <n>\""; fi
stale=0
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  loc=${hit%%:Updated*}; d=${hit#*:Updated }
  e=$(epoch "$d")
  if [ -z "$e" ]; then echo "$loc: Updated $d  (date not understood)"; stale=1
  else
    age=$(( (now - e) / 86400 ))
    if [ "$age" -gt "$MAX_AGE_DAYS" ]; then echo "$loc: Updated $d  ($age days old)"; stale=1; fi
  fi
done < <(grep -HnoE 'Updated [A-Z][a-z]+ [0-9]{1,2},? [0-9]{4}' "${FILES[@]}")
[ $stale -eq 0 ] && echo "no \"Updated\" stamp older than $MAX_AGE_DAYS days"

echo; echo "== 3. \"beta\" / \"TestFlight\" outside help.html =="
OTHERS=(); for f in "${FILES[@]}"; do [ "$f" = "help.html" ] || OTHERS+=("$f"); done
out=""
[ ${#OTHERS[@]} -gt 0 ] && out=$(grep -HnoiE '.{0,40}(\bbeta\b|testflight).{0,40}' "${OTHERS[@]}" | cut -c1-200)
if [ -n "$out" ]; then echo "$out"; fail=1; else echo "none"; fi

echo; echo "== 4. Promo banners past their date =="
found=0; expired=0
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  found=1
  loc=${hit%%:PROMO BANNER*}; d=${hit#*remove after }
  e=$(epoch "$d")
  if [ -z "$e" ]; then echo "$loc: remove after $d  (date not understood)"; expired=1
  elif [ "$now" -ge $(( e + 86400 )) ]; then echo "$loc: remove after $d  -- PAST, remove it"; expired=1
  else echo "$loc: remove after $d  (ok, $(( (e + 86400 - now) / 86400 )) days left)"; fi
done < <(grep -HnoE 'PROMO BANNER: remove after [A-Z][a-z]+ [0-9]{1,2},? [0-9]{4}' "${FILES[@]}")
[ $found -eq 0 ] && echo "no promo banners"
[ $expired -eq 1 ] && fail=1

echo; echo "== 5. Latest version in whats-new.html (compare with the App Store) =="
if [ -f whats-new.html ]; then
  v=$(grep -oE 'Version [0-9]+(\.[0-9]+)+' whats-new.html | head -1)
  echo "${v:-no \"Version x.y\" found}"
else echo "whats-new.html not found"; fi

echo
if [ $fail -ne 0 ]; then echo "SITE CHECK: FAILED (see 1, 3 or 4 above)"; exit 1; fi
echo "SITE CHECK: OK"

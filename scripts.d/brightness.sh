#!/usr/bin/env bash

if ! command -v ddcutil &>/dev/null; then
  echo "ddcutil not found"
  exit 1
fi

displays=(2 3)
only_bus=""

while [[ "$1" != "" ]]; do
  case $1 in
    --only)
      shift
      only_bus="$1"
      ;;
  esac
  shift
done

if [[ -n "$only_bus" ]]; then
  displays=("$only_bus")
fi

declare -A old_brightness

get_icon() {
  local p=$1
  if (( p < 20 )); then echo ""
  elif (( p < 50 )); then echo ""
  elif (( p < 80 )); then echo ""
  else echo ""
  fi
}

while :; do
  output_text=""
  all_failed=true

  for bus in "${displays[@]}"; do
    ddcout=$(ddcutil --noconfig --terse --sleep-multiplier=0 --bus=$bus getvcp 10 2>/dev/null)

    read -r _ _ _ current max <<< "$ddcout"

    if [[ "$current" =~ ^[0-9]+$ && "$max" =~ ^[0-9]+$ && "$max" -ne 0 ]]; then
      all_failed=false
      percent=$(( current * 100 / max ))

      icon=$(get_icon "$percent")

      if [[ "${old_brightness[$bus]}" != "$percent" ]]; then
        old_brightness[$bus]=$percent
        pkill -RTMIN+1 waybar
      fi

      if [[ -n "$only_bus" ]]; then
        output_text="$icon  ${percent}%"
      else
        output_text+="[bus $bus: $icon ${percent}%] "
      fi
    fi
  done

  if $all_failed; then
    echo '{"text": " Error", "tooltip": "Failed to read brightness"}'
  else
    echo "{\"text\": \"${output_text% }\"}"
  fi

  sleep 1
done
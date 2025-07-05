#!/usr/bin/env bash

if ! command -v ddcutil &>/dev/null; then
  echo "ddcutil not found"
  exit 1
fi

# Default to both buses 2 and 3
displays=(2 3)
only_bus=""

# Optional: --only BUS_ID
while [[ "$1" != "" ]]; do
  case $1 in
    --only)
      shift
      only_bus="$1"
      ;;
  esac
  shift
done

# If --only was passed, override displays list
if [[ -n "$only_bus" ]]; then
  displays=("$only_bus")
fi

declare -A old_brightness

# Get icon by brightness percentage
get_icon() {
  local percent=$1
  if (( percent < 20 )); then echo ""
  elif (( percent < 50 )); then echo ""
  elif (( percent < 80 )); then echo ""
  else echo ""
  fi
}

while true; do
  output_text=""
  all_failed=true

  for bus in "${displays[@]}"; do
    output=$(ddcutil --noconfig --sleep-multiplier=0 --bus=$bus getvcp 10 2>/dev/null)

    current=$(awk -F'=' '/current value/ {gsub(/[^0-9]/,"",$2); print $2}' <<< "$output")
    max=$(awk -F'=' '/max value/ {gsub(/[^0-9]/,"",$3); print $3}' <<< "$output")

    if [[ "$current" =~ ^[0-9]+$ && "$max" =~ ^[0-9]+$ && "$max" -ne 0 ]]; then
      all_failed=false
      percent=$(( current * 100 / max ))

      if [[ "${old_brightness[$bus]}" != "$percent" ]]; then
        icon=$(get_icon "$percent")
        old_brightness[$bus]=$percent
        pkill -RTMIN+1 waybar
      else
        icon=$(get_icon "$percent")
      fi

      if [[ -n "$only_bus" ]]; then
        output_text="$icon  ${percent}%"
      else
        output_text+="[bus $bus: $icon ${percent}%] "
      fi
    fi
  done

  if [[ "$all_failed" == true ]]; then
    echo '{"text": " Error", "tooltip": "Failed to read brightness"}'
  else
    echo "{\"text\": \"${output_text% }\"}"
  fi

  sleep 1
done
#!/bin/bash
# 사용: downloads-sorter-toggle.sh [on|off]
# on: 마커 파일 mtime을 현재 시각으로 갱신 → 그 이후 들어온 파일만 정리 대상
# off: LaunchAgent 언로드

PLIST="$HOME/Library/LaunchAgents/com.user.downloads-sorter.plist"
MARKER="$HOME/.downloads-sorter.installed"

case "$1" in
  on)
    touch "$MARKER"
    /bin/launchctl load "$PLIST"
    ;;
  off)
    /bin/launchctl unload "$PLIST"
    ;;
esac

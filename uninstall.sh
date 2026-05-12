#!/bin/bash
# Downloads Sorter — 제거 스크립트

set +e

LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.user.downloads-sorter.plist"

echo "Downloads Sorter 제거 중..."

launchctl unload "$LAUNCH_AGENT" 2>/dev/null
rm -f "$LAUNCH_AGENT"
rm -rf "$HOME/Applications/DownloadsSorter.app"
rm -f "$HOME/bin/downloads-sorter-toggle.sh"
rm -f "$HOME/.downloads-sorter.installed"
rm -f "$HOME/Library/Application Support/SwiftBar/Plugins/downloads-sorter.5s.sh"
rm -f /tmp/downloads-sorter.log /tmp/downloads-sorter.err

echo "✅ 제거 완료."
echo
echo "참고: 이미 정리된 ~/Downloads/downloaded_YYYY-MM-DD 폴더들은 그대로 남아있습니다."
echo "      SwiftBar 자체를 제거하려면: brew uninstall --cask swiftbar"
echo "      전체 디스크 접근 권한 목록의 'DownloadsSorter'는 수동으로 제거해주세요."

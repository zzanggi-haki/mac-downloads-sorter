#!/bin/bash
# <bitbar.title>Downloads Sorter Toggle</bitbar.title>
# <bitbar.version>1.1</bitbar.version>
# <bitbar.desc>다운로드 폴더 자동 날짜별 정리 on/off 토글</bitbar.desc>

TOGGLE="$HOME/bin/downloads-sorter-toggle.sh"
TODAY_DIR="$HOME/Downloads/downloaded_$(date +%Y-%m-%d)"

if launchctl list 2>/dev/null | grep -q com.user.downloads-sorter; then
  echo "📂✅"
  echo "---"
  echo "다운로드 자동 정리: 켜짐 | color=green"
  echo "끄기 | bash=$TOGGLE param1=off terminal=false refresh=true"
else
  echo "📂⏸"
  echo "---"
  echo "다운로드 자동 정리: 꺼짐 | color=gray"
  echo "켜기 | bash=$TOGGLE param1=on terminal=false refresh=true"
fi
echo "---"
echo "오늘 폴더 열기 ($(date +%Y-%m-%d)) | bash=/usr/bin/open param1=$TODAY_DIR terminal=false"
echo "다운로드 폴더 열기 | bash=/usr/bin/open param1=$HOME/Downloads terminal=false"
echo "---"
echo "로그 보기 | bash=/usr/bin/open param1=/tmp/downloads-sorter.log terminal=false"

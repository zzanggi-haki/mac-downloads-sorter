#!/bin/bash
# Downloads Sorter — 원클릭 설치 스크립트
# 사용법: ./install.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$HOME/Applications/DownloadsSorter.app"
BIN_DIR="$HOME/bin"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.user.downloads-sorter.plist"
SWIFTBAR_PLUGINS="$HOME/Library/Application Support/SwiftBar/Plugins"
MARKER="$HOME/.downloads-sorter.installed"

echo "=========================================="
echo "  Downloads Sorter 설치 시작"
echo "=========================================="
echo

# 1. 사전 요구사항 확인
echo "[1/8] 사전 요구사항 확인 중..."
if ! command -v swiftc >/dev/null 2>&1; then
  echo "  ❌ Swift 컴파일러(swiftc) 없음. Xcode Command Line Tools 설치가 필요합니다."
  echo "  다음 명령으로 설치하세요: xcode-select --install"
  exit 1
fi
echo "  ✅ swiftc 확인됨"

if ! command -v brew >/dev/null 2>&1; then
  echo "  ⚠️  Homebrew 없음. SwiftBar는 수동으로 설치해야 합니다."
  echo "  Homebrew 설치: https://brew.sh"
  BREW_AVAILABLE=0
else
  echo "  ✅ Homebrew 확인됨"
  BREW_AVAILABLE=1
fi

# 2. SwiftBar 설치
echo
echo "[2/8] SwiftBar 설치 확인 중..."
if [ -d "/Applications/SwiftBar.app" ]; then
  echo "  ✅ SwiftBar 이미 설치됨"
elif [ "$BREW_AVAILABLE" = "1" ]; then
  echo "  SwiftBar 설치 중..."
  brew install --cask swiftbar
else
  echo "  ⚠️  SwiftBar를 수동으로 설치하세요: https://github.com/swiftbar/SwiftBar/releases"
fi

# 3. 마커 파일 생성
echo
echo "[3/8] 기준선 마커 파일 생성..."
touch "$MARKER"
echo "  ✅ $MARKER 생성됨 (이 시점 이후 다운로드된 파일만 정리 대상)"

# 4. .app 번들 생성 + Swift 컴파일
echo
echo "[4/8] DownloadsSorter.app 빌드 중..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DownloadsSorter</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.downloads-sorter</string>
    <key>CFBundleName</key>
    <string>DownloadsSorter</string>
    <key>CFBundleDisplayName</key>
    <string>Downloads Sorter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST_EOF

swiftc -O "$SCRIPT_DIR/src/DownloadsSorter.swift" -o "$APP_DIR/Contents/MacOS/DownloadsSorter"
echo "  ✅ Swift 바이너리 컴파일 완료"

# 5. 코드 서명 (ad-hoc)
echo
echo "[5/8] 코드 서명 (ad-hoc)..."
codesign --force --deep --sign - "$APP_DIR"
echo "  ✅ 서명 완료"

# 6. 토글 헬퍼 스크립트 배치
echo
echo "[6/8] 토글 헬퍼 스크립트 배치..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/bin/downloads-sorter-toggle.sh" "$BIN_DIR/downloads-sorter-toggle.sh"
chmod +x "$BIN_DIR/downloads-sorter-toggle.sh"
echo "  ✅ $BIN_DIR/downloads-sorter-toggle.sh"

# 7. LaunchAgent 등록
echo
echo "[7/8] LaunchAgent 등록..."
mkdir -p "$(dirname "$LAUNCH_AGENT")"
sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/plist/com.user.downloads-sorter.plist.template" > "$LAUNCH_AGENT"
launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
launchctl load "$LAUNCH_AGENT"
echo "  ✅ LaunchAgent 로드 완료"

# 8. SwiftBar 플러그인 배치
echo
echo "[8/8] SwiftBar 플러그인 배치..."
mkdir -p "$SWIFTBAR_PLUGINS"
cp "$SCRIPT_DIR/swiftbar/downloads-sorter.5s.sh" "$SWIFTBAR_PLUGINS/downloads-sorter.5s.sh"
chmod +x "$SWIFTBAR_PLUGINS/downloads-sorter.5s.sh"
echo "  ✅ SwiftBar 플러그인 설치됨"

# SwiftBar 실행
if [ -d "/Applications/SwiftBar.app" ]; then
  open -a SwiftBar 2>/dev/null || true
fi

echo
echo "=========================================="
echo "  ✅ 설치 완료!"
echo "=========================================="
echo
echo "⚠️  마지막 한 단계 (수동) - 전체 디스크 접근 권한 부여:"
echo
echo "  1. 시스템 설정이 자동으로 열립니다"
echo "  2. '전체 디스크 접근 권한' 화면에서 '+' 버튼 클릭"
echo "  3. ⌘ + Shift + G 누르고 아래 경로 붙여넣기 후 Enter:"
echo
echo "       $APP_DIR"
echo
echo "  4. DownloadsSorter 선택 → 열기"
echo "  5. 파란 토글이 켜진 것 확인"
echo
echo "권한 부여 후, 메뉴바에 📂✅ 아이콘이 보이면 정상 동작 중입니다."
echo

sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

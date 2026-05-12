# Downloads Sorter

macOS의 `~/Downloads` 폴더에 새로 다운로드되는 파일을 **오늘 날짜 폴더로 자동 정리**해주는 도구입니다. 메뉴바에서 클릭 한 번으로 켜고 끌 수 있습니다.

## 기능

- 📂 파일 다운로드 즉시 `~/Downloads/downloaded_YYYY-MM-DD/` 폴더로 자동 이동
- 🎚️ 메뉴바 아이콘 클릭 한 번으로 ON/OFF 토글 (📂✅ / 📂⏸)
- 🛡️ 설치 전부터 있던 파일/폴더는 절대 건드리지 않음
- ⏸️ 끈 상태에서 받은 파일은 다시 켤 때도 그대로 유지됨
- 🚀 다운로드 중인 임시 파일(`.crdownload`, `.download`, `.part`, `.tmp`)은 자동 제외 → 완료된 순간에만 이동
- 🔄 재부팅 후에도 자동 시작

## 요구사항

- macOS (Apple Silicon 또는 Intel)
- [Homebrew](https://brew.sh) (SwiftBar 자동 설치용)
- Xcode Command Line Tools — `xcode-select --install`

## 설치

```bash
git clone https://github.com/zzanggi-haki/downloads-sorter.git
cd downloads-sorter
chmod +x install.sh
./install.sh
```

설치 스크립트가 자동으로:
1. SwiftBar 설치 (없는 경우)
2. Swift 코드 컴파일 + 코드 서명
3. `~/Applications/DownloadsSorter.app` 생성
4. LaunchAgent 등록 (Downloads 폴더 변경 감지)
5. SwiftBar 플러그인 배치 (메뉴바 토글)

마지막에 **시스템 설정 → 전체 디스크 접근 권한** 화면이 자동으로 열립니다. 아래 절차로 권한을 부여해주세요:

1. `+` 버튼 클릭
2. ⌘ + Shift + G 누르고 다음 경로 붙여넣기:
   ```
   ~/Applications/DownloadsSorter.app
   ```
3. `DownloadsSorter` 선택 → 열기
4. 파란 토글이 켜진 것 확인

권한 부여가 완료되면 메뉴바에 📂✅ 아이콘이 표시됩니다.

## 사용법

**자동 정리**: 파일을 다운로드받으면 → 즉시 `~/Downloads/downloaded_2026-05-12/` 같은 오늘 날짜 폴더로 이동

**ON/OFF**: 메뉴바의 📂✅ (켜짐) / 📂⏸ (꺼짐) 아이콘 클릭 → 드롭다운 메뉴에서 토글

**메뉴 항목**:
- `켜기` / `끄기` — 자동 정리 활성/비활성 토글
- `오늘 폴더 열기` — Finder에서 오늘 날짜 폴더 열기
- `다운로드 폴더 열기` — Finder에서 Downloads 루트 열기
- `로그 보기` — `/tmp/downloads-sorter.log` 열기 (이동 이력)

## 제거

```bash
./uninstall.sh
```

이미 정리된 `~/Downloads/downloaded_*` 폴더들은 그대로 남습니다. SwiftBar 자체와 권한 항목은 수동으로 제거해주세요.

## 작동 원리

| 구성요소 | 위치 | 역할 |
|---|---|---|
| Swift 바이너리 | `~/Applications/DownloadsSorter.app` | 실제 파일 이동 (Mach-O, ad-hoc 서명) |
| LaunchAgent | `~/Library/LaunchAgents/com.user.downloads-sorter.plist` | `WatchPaths`로 Downloads 변경 감지 |
| 마커 파일 | `~/.downloads-sorter.installed` | mtime이 "이 시점 이후 파일만 정리" 기준선 |
| 토글 헬퍼 | `~/bin/downloads-sorter-toggle.sh` | 켜기 시 마커 갱신 + launchctl load/unload |
| SwiftBar 플러그인 | `~/Library/Application Support/SwiftBar/Plugins/downloads-sorter.5s.sh` | 메뉴바 UI |

**왜 Swift 바이너리인가?**: macOS TCC(Transparency, Consent, Control)는 shell script가 아니라 실제 실행 바이너리에 권한을 부여합니다. 쉘 스크립트로는 launchd-spawned 프로세스가 Downloads 폴더에 접근할 수 없어, 컴파일된 Mach-O 바이너리가 필요합니다.

## 트러블슈팅

**메뉴바 아이콘이 안 보여요**
- SwiftBar가 실행 중인지 확인: `open -a SwiftBar`
- SwiftBar 첫 실행 시 플러그인 폴더를 묻습니다 → 기본 경로 그대로 선택

**파일이 이동되지 않아요**
- 전체 디스크 접근 권한 목록에서 `DownloadsSorter` 토글이 켜져있는지 확인
- 로그 확인: `cat /tmp/downloads-sorter.log` 및 `cat /tmp/downloads-sorter.err`
- "Operation not permitted" 오류 → 권한 미부여 상태. 위 설치 절차 4번 다시 확인

**다른 맥에서 설치 시 "확인되지 않은 개발자" 경고가 떠요**
- ad-hoc 서명만 되어 있어 발생. 우클릭 → 열기로 한 번 실행하면 이후엔 정상 동작

## 라이선스

MIT

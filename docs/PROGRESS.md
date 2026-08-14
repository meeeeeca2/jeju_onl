# Progress

## phase-4-widget (2026-08-14)

- 한 일:
  - 템플릿 emoji `ConfigurationAppIntent`를 `TodayWidgetConfigIntent` + `CityAppEnum`(제주시/서귀포시, 기본 `.seogwipo`)로 교체. `cityID`는 force unwrap 없이 실패 시 서귀포.
  - 위젯 kind `kr.jejuonl.widget.today`. 갤러리 표시명 `오늘 뭐 버려?`. 설명 `오늘 클린하우스에 넣을 수 있는 쓰레기를 보여 줍니다`.
  - `TodayProvider`: `WidgetTimelineDates.timelineDates(from:count:4, calendar: SeoulCalendar)` + `policy = .atEnd`. `Calendar.current` 시간별/자정 엔트리 없음.
  - 도시 소스는 Intent만. App Group / UserDefaults로 일정 도시를 읽지 않음.
  - `TodayLoad` / `TodayEntry`. 카탈로그는 `ScheduleCatalog.load()` / `Bundle(for: CatalogBundleToken.self)`. `catalogStale`은 계산만 하고 위젯 배너는 없음.
  - Small 1/2/3(뱃지·팬·숫자 3), Medium(상태+도시+제한 타일+매일 짧은 라벨), Large(히어로+월–일 7열+내일 한 줄).
  - 품목 JPG 10종을 위젯 에셋에 복사. 얼굴 탭은 기본 앱 열기. 도시 토글 버튼 없음.
  - `WidgetBundle`은 `jejuonlWidget()`만 등록. Control / Live Activity 파일은 유지하되 갤러리에 안 나옴.
  - 위젯 `INFOPLIST_KEY_CFBundleDisplayName` = `오늘 뭐 버려?`.
- 검증:
  ```
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  xcodebuild test -project jejuonl/jejuonl.xcodeproj -scheme jejuonl \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:jejuonlTests
  xcodebuild build -project jejuonl/jejuonl.xcodeproj -scheme jejuonl \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
  ```
  - 결과: `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **`
  - xcresult: `totalTestCount: 32`, `passedTests: 32`, `failedTests: 0`, `skippedTests: 0`
  - 구성: ScheduleEngineTests 11 / ScheduleCatalogTests 8 / WidgetTimelineDatesTests 3 / ClockTimeTests 3 / CountdownFormatTests 7
  - 빌드 산출 Info.plist: `CFBundleDisplayName` = `오늘 뭐 버려?`
  - 위젯 스킴(jejuonlWidgetExtension)은 실행하지 않음.
- 남긴 것:
  - 온보딩 풀스크린(페이즈 6), NotificationScheduler/SET-2(페이즈 5).
  - Control / Live Activity 소스 파일은 남아 있으나 WidgetBundle 미등록.
- 태그: snapshot/phase-4-widget
- 오케스트레이터 재검증: 테스트 32 passed.
- 다음: 페이즈 5 — 로컬 알림 + 알림 설정

## phase-3-app-today-week (2026-08-14)

- 한 일:
  - 앱 탭 루트: 오늘 / 이번 주 / 설정. Hello world `ContentView` 삭제.
  - `TodayView`: 도시 세그먼트만(헤더 톱니 없음). `city == nil`이면 ONB-1 스타일 두 카드(서귀포 강조, 탭해야 저장). 날짜는 `snapshot.dischargeDayStart` + `dischargeWeekday`. 창 `지금`/`저녁부터` + 카운트다운. 오늘만/매일 `ItemTile`. PET는 엔진 결과대로 제주시만.
  - `WeekView`: `engine.week` 월–일 7행, 오늘 배출일 강조, 행 탭 시트. `Calendar.firstWeekday` 미사용.
  - `SettingsView`: 도시(같은 피커), 알림 행은 `14:30` 표시만(SET-2/UNUserNotificationCenter 없음), 위젯 힌트, 카탈로그 버전.
  - Core: `WasteItem.assetName`, `AppGroupSettingsStore` (`group.kr.jejuonl.shared` / `settings.v1`, 컨테이너 URL로만 그룹 판정), `CountdownFormat`.
  - 시안 JPG 10종을 앱 에셋으로 복사. 앱 크롬에 `wallpaper.jpg` 없음. 배경은 틸–슬레이트 그라디언트.
- 검증:
  ```
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  xcodebuild test -project jejuonl/jejuonl.xcodeproj -scheme jejuonl \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:jejuonlTests
  xcodebuild build -project jejuonl/jejuonl.xcodeproj -scheme jejuonl \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
  ```
  - 결과: `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **`
  - xcresult: `totalTestCount: 32`, `passedTests: 32`, `failedTests: 0`, `skippedTests: 0`
  - 구성: ScheduleEngineTests 11 / ScheduleCatalogTests 8 / WidgetTimelineDatesTests 3 / ClockTimeTests 3 / CountdownFormatTests 7
- 남긴 것:
  - 온보딩 풀스크린(페이즈 6), 위젯 얼굴(페이즈 4, Hello 위젯 유지), NotificationScheduler/SET-2(페이즈 5), Live Activity 파일 유지.
  - 시뮬레이터 첫 실행은 `AppSettings.default`(city nil) → 도시 카드. Preview는 `AppSettings.preview`(서귀포).
- 태그: snapshot/phase-3-app-today-week
- 오케스트레이터 재검증: 테스트 32 passed. 시뮬 첫 화면 도시 피커 스크린샷 확인.
- 사용자 확인: Autocreate로 `jejuonl` 스킴 복구 후 Run, 화면 동작 OK. 공유 스킴을 레포에 고정.
- 다음: 페이즈 4 — Small·Medium·Large 위젯

## phase-2-schedule-engine (2026-08-14)

- 한 일:
  - `Shared/jejuonlCore/` 순수 Swift 코어: CityID, WasteItem, WindowState, LocaleWeekday, DischargeSnapshot, AppSettings/NotificationPrefs/ClockTime, SeoulCalendar, ScheduleCatalog, ScheduleEngine, WidgetTimelineDates, ScheduleEngineError.
  - `schedule_v1.json` 스키마 1 (제주시 PET 구분, 서귀포 PET 없음, `foodWasteAlways` 없음).
  - `jejuonlTests`: E1–E10, nextRestrictedChange/nextWindowToggle, 카탈로그 로드·요일표·unknown item·restriction-disabled union, timelineDates 세 시각, ClockTime 클램프.
  - pbxproj: Core `.swift` 11개를 jejuonl / jejuonlWidgetExtension / jejuonlTests Sources에, `schedule_v1.json`을 세 타깃 Copy Bundle Resources에 추가.
  - `Shared/jejuonlCore/.gitkeep` 삭제. UI·위젯 얼굴·알림 스케줄러·AppGroup store는 안 만듦.
- 검증:
  ```
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  xcodebuild test -project jejuonl/jejuonl.xcodeproj -scheme jejuonl \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:jejuonlTests
  ```
  - 결과: `** TEST SUCCEEDED **`
  - xcresult: `totalTestCount: 25`, `passedTests: 25`, `failedTests: 0`, `skippedTests: 0`
  - 구성: ScheduleEngineTests 11 (E1–E10 + next 04:00/toggle) / ScheduleCatalogTests 8 / WidgetTimelineDatesTests 3 / ClockTimeTests 3
- 남긴 것:
  - ContentView는 템플릿 Hello 화면 그대로. 오늘/주간 UI는 페이즈 3.
  - AppGroupSettingsStore / NotificationScheduler 없음 (페이즈 3·5).
  - 테스트는 `Bundle(for: CatalogBundleToken.self)`로 JSON을 읽음 (Bundle.module 없음).
- 태그: snapshot/phase-2-schedule-engine
- 오케스트레이터 재검증: 동일 명령, E1–E10·카탈로그·timeline·ClockTime 전부 passed, exit 0
- 다음: 페이즈 3 — 오늘 / 이번 주 / 도시 세그먼트

## phase-1-skeleton (2026-08-14)

- 한 일:
  - Xcode 템플릿으로 앱 `jejuonl` + 위젯 `jejuonlWidget` 생성. Configuration App Intent 포함.
  - 저장 위치 `jejuonl/jejuonl.xcodeproj` (설계의 `App/` `Widget/` 레이아웃은 템플릿 구조를 유지).
  - Team: Yeongseop Jeong (Personal Team) `D997V885SZ`. 앱·위젯 동일.
  - App Groups `group.kr.jejuonl.shared`를 두 타깃 entitlements에 넣음. 체크 켜짐.
  - 시뮬레이터 iPhone 17 Pro에서 빈 앱 기동 확인.
  - 표시명 `오늘 뭐 버려?` (`INFOPLIST_KEY_CFBundleDisplayName`).
  - `Shared/jejuonlCore/` 빈 자리만. 엔진은 페이즈 2.
  - README / INSTALL 초안.
- 검증:
  - 시뮬레이터에 빈 앱이 뜸.
  - 앱·위젯 Team 동일.
  - App Groups: 로컬 capability + entitlements 있음. Signing 노란 경고는 “실기기 없음 / 프로파일 없음”이지 그룹 거절 문구가 아님. Personal Team이라 컨테이너 등록은 미확인 → 제품은 Intent만으로 동작한다고 가정.
- 식별자 (잠김):
  - 앱 `kr.jejuonl.jejuonl`
  - 위젯 `kr.jejuonl.jejuonl.jejuonlWidget`
  - 그룹 `group.kr.jejuonl.shared`
- 남긴 것:
  - 템플릿이 Control / Live Activity 파일을 넣음. v1 비목표. 지금은 삭제하지 않음.
  - Deployment target이 26.5 (Xcode 기본). 최소 iOS 17로 내리는 일은 이후.
  - 위젯 스킴을 시뮬에서 Run하면 트랩이 날 수 있음. 페이즈 1 인수는 앱 스킴.
- 태그: snapshot/phase-1-skeleton
- 다음: 페이즈 2 — `schedule_v1.json` + ScheduleEngine + 단위 테스트

# Progress

## item-sheet-43-and-full-captions (2026-08-14)

- 품목 시트 히어로 높이 240 → 가로:세로 **4:3**.
- 오늘 `매일` 줄은 짧은 이름(`스티로`) 대신 풀네임(`스티로폼`). 캡션이 아이콘 폭에 잘리지 않게 `minWidth` + `fixedSize`.

## ui-scale-item-tiles (2026-08-14)

- 품목 타일·캡션을 눈에 띄게 키움 (`ItemTile.SizeKind`: large 188/40/16, regular 132/28/15, daily 76/20/13, week 58/16/13). daily/week 간격 6·8.
- 인접 글자만: `SectionLabel` 13, 주간 요일 글자 15 / 폭 28. 위젯·온보딩·CitySegment·알림·엔진은 그대로.
- 오늘만/매일, `WeekDaySheet`, 주간 행 아이콘은 `ScrollView(.horizontal)` + `scrollIndicators(.hidden)` + `scrollBounceBehavior(.basedOnSize)`. 넘치면 좌우 스크롤, 스크롤바 없음. 주간 행은 그대로 하루 시트 버튼, 아이콘만 가로 스크롤.
- 품목 시트 히어로는 가운데 `ItemTile` 제거. `Image` 전폭·높이 240, 시트 상단 0pt(그레버가 사진 위에 겹침). 제목 20 / 본문 15.
- 검증: 스킴 `jejuonl` only. `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **`. `jejuonlWidgetExtension` 미실행.

## item-detail-sheet (2026-08-14)

- 오늘 `오늘만`/`매일` 타일, `beforeOpen` 상태 카드 음식물 타일, 주간 `WeekDaySheet` 타일 탭 → 다크 바텀시트(큰 사진·이름·메타·짧은 배출 안내). 타일 크기·캡션·간격·그림자는 그대로.
- 주간 목록 행 아이콘·알림 설정 행·위젯은 탭해도 품목 시트를 열지 않음.
- 카피 `WasteItemGuide`는 앱 타깃. 창 시간은 섬 공통 15:00–04:00. 서귀포 PET만 공식 요일표 주석.
- 검증: 스킴 `jejuonl` only. `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **`. xcresult `totalTestCount: 48` (`WasteItemGuideTests` 4). `jejuonlWidgetExtension` 미실행.

## widget-small-icon-badge-fit (2026-08-14)

- 작은 칸이 다시 그려진 뒤, 고정 56pt+큰 글자 대신 **남은 칸을 채우는 아이콘 + 사진 안 이름 뱃지**. 고정 120pt는 쓰지 않음(스냅샷 실패 재발 방지). 뱃지 `offset` 제거해 칸 밖으로 안 나감.
- 0개 문구 유지. 2–3개는 남은 폭에 맞춘 팬.

## widget-small-large-snapshot-fit (2026-08-14)

- Small/Large 홈 위젯이 스냅샷 실패로 빈 다크 카드. 기기에서 중간만 보이다가 지우고 다시 넣으면 중간도 자리표시에 고정됨.
- Small: 120/90/74 팬 제거. 상태+요일 + 18pt 흰 품목명(0개면 `오늘은 제한 품목 없음`) + 최대 3장 56pt. 패딩 8. 141pt 안에 맞춤.
- Large: 히어로 72/56, 매일 24, 주간 28. 패딩 14→12, 하단 Spacer 제거. 같은 정보 유지.
- `WidgetItemImage`: `UIImage(named:)` 다운샘플 `side*3`(최대 256px). 없으면 `WasteItem.symbolName` SF Symbol. 사진은 `.widgetAccentedRenderingMode(.fullColor)`. Medium 68pt 뱃지도 이 헬퍼를 탐.
- 앱이 포그라운드가 되면 `WidgetCenter.reloadAllTimelines()` (도시 바꿀 때만 리로드하던 것 보강).
- 검증: 스킴 `jejuonl` only. `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **` (44 tests). `jejuonlWidgetExtension` 미실행.

## onboarding-city-cards (2026-08-14)

- 실기기: 도시 카드가 화면을 세로로 채움, 서귀포 테두리만 있고 다음은 꺼짐, 터치가 글자에만 반응.
- 카드 높이 고정, `contentShape`로 카드 전체 탭. 온보딩 기본 선택 서귀포 → 다음 활성.

## phase-6-onboarding-install (2026-08-14)

- 한 일:
  - 신규 설치만 온보딩. `settings.v1` 키가 표준·앱그룹 **둘 다 없으면** `AppSettings.freshInstall` (`hasCompletedOnboarding == false`). 키는 있는데 디코드 실패면 `.default`(온보딩 true). 디코드 성공은 그대로. `.default.hasCompletedOnboarding`은 true 유지.
  - `AppGroupSettingsStore.load()`가 키 없음 / 깨짐 / 정상 저장을 구분. 테스트는 격리 `UserDefaults` 스위트만 사용.
  - `OnboardingView` 풀스크린(탭 바 없음). 1/3 도시(서귀포 “집” 강조, 탭 전 미저장, 다음=탭 후), 2/3 알림(`알림 받기`=`setNotificationsEnabled(true)`, `나중에`는 권한 창 없음), 3/3 위젯 4단계 + 앱이 대신 못 붙임. `[시작하기]` → `hasCompletedOnboarding = true` → 오늘 탭.
  - 설정에 재온보딩 없음. 앱·온보딩 `preferredColorScheme(.dark)`. 아이콘 에셋은 기존 라이트 사진, AppIcon dark/tinted 슬롯 유지.
  - 온보딩 제목·버튼 Dynamic Type, 카드·CTA VoiceOver.
  - `docs/INSTALL.md`를 비개발자용 완성본으로 다시 씀(스킴 jejuonl, 같은 Team, 신뢰, 위젯 길게 도시, 주 1회 앱, 7일 재설치, 시뮬레이터 no devices, 확인 메모).
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
  - xcresult: `totalTestCount: 44`, `passedTests: 44`, `failedTests: 0`, `skippedTests: 0`
  - 구성: ScheduleEngineTests 11 / ScheduleCatalogTests 8 / WidgetTimelineDatesTests 3 / ClockTimeTests 3 / CountdownFormatTests 7 / NotificationPlannerTests 8 / AppGroupSettingsStoreTests 4
  - 위젯 스킴(jejuonlWidgetExtension)은 실행하지 않음.
- 남긴 것:
  - 수동 실기기 체크리스트 15(권한 거부)·16(재부팅)·17(TZ)·18(위젯 시·Large). 커밋은 오케스트레이터.
- 태그: snapshot/phase-6-onboarding-install (커밋은 오케스트레이터)
- 다음: v1 페이즈 끝. 실기기 설치·위젯 붙이기.

## phase-5-notifications (2026-08-14)

- 한 일:
  - Core: `NotificationCopy` (한국어 제목·본문·품목 표시명 투명페트병/종이류/비닐류), `NotificationPlanner` (순수, D0=현재 배출일부터 7일, Seoul `DateComponents`), `NotificationScheduler` (`UNCalendarNotificationTrigger` `repeats: false`, pending `jejubin.*` 삭제 후 추가. 배지 없음).
  - SET-2: 설정 → 알림 push. 틸 유리, 한라봉 마스터 토글, 열리기 전 시각(04:00–14:59), 저녁에도(17:00–23:30), 품목 체크(서귀포 PET 비활성+`제주시만`), `매일 품목도`. 거부 배너+설정 앱, 0건이면 `다시 예약`.
  - `AppModel`: 알림 prefs 저장+reschedule. `selectCity`·`scenePhase == .active`·타임존 변경 시 reschedule. 카테고리 `JEJUBIN_REMIND` + `OPEN_TODAY` 한 번 등록. 권한 `.notDetermined` 요청, `.denied`는 마스터 off+배너, `.provisional`은 허용.
  - 도시는 항상 `settings.city`. 위젯 Intent는 알림에 안 씀. `NSUserNotificationsUsageDescription` 추가. INSTALL “알림을 쓰려면 일주일에 한 번은 앱을 여세요.”
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
  - xcresult: `totalTestCount: 40`, `passedTests: 40`, `failedTests: 0`, `skippedTests: 0`
  - 구성: ScheduleEngineTests 11 / ScheduleCatalogTests 8 / WidgetTimelineDatesTests 3 / ClockTimeTests 3 / CountdownFormatTests 7 / NotificationPlannerTests 8
  - 위젯 스킴(jejuonlWidgetExtension)은 실행하지 않음.
  - 오케스트레이터 재검증: xcodebuild test exit 0.
- 남긴 것:
  - 온보딩 풀스크린(페이즈 6). 푸시 서버·배지·BGAppRefresh·반복 트리거 없음.
- 태그: snapshot/phase-5-notifications (커밋은 오케스트레이터)
- 다음: 페이즈 6 — 온보딩 + 설치 가이드

## app-icon-and-widget-plate (2026-08-14)

- 앱 아이콘: `docs/mockups/app-icon.jpg`를 아이콘 판(705²)으로 잘라 1024 PNG `jejuonl/jejuonl/Assets.xcassets/AppIcon.appiconset/AppIcon.png`. Contents.json 기본·dark·tinted 1024 슬롯 모두 같은 파일명. 빈 유리 판 아이콘 해소.
- 위젯 판: `@Environment(\.widgetRenderingMode)`. `.accented`(홈 Clear/틴트)는 불투명 채움 없음 + `.containerBackgroundRemovable(true)`로 시스템 유리. `.fullColor`(기본 홈)는 Color.clear/ultraThinMaterial 대신 틸–슬레이트 프로스트 그라디언트 `#24383d → #1a2c30 → #152024` (불투명 0.65–0.75). 사진 `.widgetAccentedRenderingMode(.fullColor)` (`Image.resizable()` 직후). `contentMarginsDisabled` 유지. 아이콘 크기·뱃지 변경 없음.
- 검증: `jejuonl` 스킴 ** TEST SUCCEEDED ** 32/32 / ** BUILD SUCCEEDED **. 위젯 스킴 미실행. 커밋 없음.

## widget-glass-and-name-badges (2026-08-14)

- 유리 판: 커스텀 `containerBackground` + `WidgetGlassPlate`(ultraThinMaterial / glassEffect) 제거. iOS SDK에서 `widgetTexture(.glass)`는 visionOS-only(`@available(iOS, unavailable)`)라 생략. `.containerBackgroundRemovable(true)` + 커스텀 배경 없음 + `.contentMarginsDisabled()` 유지. 시스템이 iOS 26 기본 유리 텍스처를 씌움.
- 이름 뱃지: `WidgetItemWithNameBadge`를 WidgetTheme에 추출(작은 위젯 1개 아이콘과 같은 하단 겹침 다크 캡슐). Medium 제한 품목, Large 히어로 1개·멀티에 적용. Large 주간 열·매일 행은 이름 없음. VoiceOver는 `koreanName`.
- 검증: `jejuonl` 스킴 test 32 / build. 위젯 스킴 미실행. 커밋 없음.

## phase-4 polish — medium always-on line (2026-08-14)

- 중간 칸 하단 `종량제 · … · 스티로`가 위젯 바닥에 잘림. Spacer 제거, 아래 패딩 확보, 스티로폼 풀네임.

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

## phase-4-widget-polish (2026-08-14)

- 위젯 판: `Color.clear` 제거. Small·Medium·Large 공통 `WidgetGlassPlate` — iOS 26 `glassEffect(.regular)` + `.ultraThinMaterial`, 그 이하는 material만. 불투명 흰/틸 없음. `contentMarginsDisabled` 유지.
- 아이콘: Small 1/2/3 = 120 / 90(overlap 42) / 74(overlap 42, 한라봉 뱃지). Medium 제한 76. Large 히어로 110·멀티 92, 매일 36, 주간 42.
- 검증: `jejuonl` 스킴 test 32 passed / build succeeded. 위젯 스킴 미실행. 커밋 없음.

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

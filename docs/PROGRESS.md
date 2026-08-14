# Progress

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

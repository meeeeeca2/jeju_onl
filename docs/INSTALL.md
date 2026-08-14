# 설치 (초안)

비개발자가 본인 아이폰에 올리는 순서입니다. 페이즈 6에서 다듬습니다.

1. Mac에 Xcode 설치 (App Store). 첫 실행 추가 구성 요소를 끝까지 기다립니다.
2. 아이폰: 설정 → 개인정보 보호 및 보안 → 개발자 모드 켬 → 재시작.
3. 케이블로 Mac과 연결. 아이폰에서 “이 컴퓨터를 신뢰”.
4. Xcode → `jejuonl/jejuonl.xcodeproj` 를 엽니다.
5. 왼쪽 위(또는 가운데) 스킴을 **jejuonl** 로. `jejuonlWidgetExtension`이면 앱이 아니라 위젯을 실행합니다. 목록에 `jejuonl`이 없으면 Product → Scheme → Manage Schemes → Autocreate Schemes Now.
6. Signing: TARGETS `jejuonl`과 `jejuonlWidget` 모두 같은 Team.
7. ▶ Run. 아이폰에 뜨면 끝.
8. “신뢰할 수 없는 개발자”면 설정 → 일반 → VPN 및 기기 관리 → 개발자 앱 → 신뢰.
9. 홈 화면 빈곳 길게 → + → “오늘 뭐 버려?” → 작은 칸·넓은 칸·큰 칸.
10. 위젯을 길게 눌러 제주시 / 서귀포시를 고릅니다. (페이즈 4 이후)
11. 알림을 쓰려면 일주일에 한 번은 앱을 엽니다. (페이즈 5 이후)
12. 무료 Apple ID면 약 7일마다 Xcode로 다시 설치합니다.

시뮬레이터만 볼 때: 스킴 `jejuonl` + iPhone 시뮬레이터 → ▶ Run.

Signing에 “Your team has no devices”가 떠도 시뮬레이터 Run은 됩니다. 실기기는 아이폰을 한 번 연결하면 프로파일이 생깁니다.

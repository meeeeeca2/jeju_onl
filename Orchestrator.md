# Orchestrator — 오늘 뭐 버려? (JejuBin)

새 세션은 **이 파일부터** 읽는다. 설계 원문은 `docs/design.md`, 화면 정답은 `docs/mockups/`.

이 문서는 인수인계용이다. 페이즈가 끝나거나 의미 있는 결정이 나면 **맨 위 상태**와 **세션 로그**를 같이 고친다.

---

## 지금 어디

| 항목 | 값 |
| --- | --- |
| 날짜 | 2026-08-14 |
| 제품 | 오늘 뭐 버려? / JejuBin — 제주 클린하우스 요일제 위젯 우선 앱 |
| 설계 | `docs/design.md` Approved (2026-08-13) |
| GUI 시안 | 잠김. HTML + PNG 재캡처 완료 (헤더 톱니 제거, 탭 라인 아이콘 SVG 고정, 품목 아이콘 베이지 풀블리드 세트) |
| 코드 | 없음. Xcode 프로젝트 없음 |
| Git | 원격 고정 `https://github.com/meeeeeca2/jeju_onl.git` (`origin`, 브랜치 `main`). 다른 레포 쓰지 않음 |
| 다음 한 가지 | **페이즈 1 — Xcode 뼈대** (계획 승인 후). 태그 목표 `snapshot/phase-1-skeleton` |

**아직 하지 말 것:** 승인 없이 구현 위임하지 않는다. `pbxproj`를 손으로 쓰지 않는다. 페이즈 1 태그 없이 페이즈 2 UI/엔진을 시작하지 않는다.

---

## 이 세션의 역할

스킬: `orchestrator-build-partner-v2`  
경로: `~/.claude/skills/orchestrator-build-partner-v2/SKILL.md`

- 메인 스레드 = **지휘**. 탐색·계획·diff 검토·커밋/푸시·이 문서 갱신.
- 기능 코드 = **서브에이전트 위임**. 승인된 계획 범위만.
- 사용자 = 제품 방향·계획 승인·서브에이전트 모델 선택.
- 한 바퀴: 계획 승인 → 위임 → `git diff`로 직접 검토 → 커밋/푸시 → 이 문서 기록.

---

## 새 세션 콜드스타트

아래를 첫 메시지에 붙이면 된다.

```
/orchestrator-build-partner-v2
Orchestrator.md 읽고 이어서. 설계는 docs/design.md, 시안은 docs/mockups/.
지금은 GUI 시안까지 잠겼고 앱 코드는 없다. Git 원격은 https://github.com/meeeeeca2/jeju_onl.git (origin/main)만 쓴다.
다음 한 가지: 페이즈 1 Xcode 뼈대. 구현 전에 계획만 보여 주고 승인 기다려.
```

---

## 잠긴 결정 (다시 묻지 말 것)

제품·도메인 전부는 `docs/design.md` **Resolved Decisions / Key Decisions**. 시안 리뷰로 추가 잠긴 것만 여기 적는다.

- GitHub는 `https://github.com/meeeeeca2/jeju_onl.git`만 쓴다. 브랜치 `main`. 다른 원격·포크를 만들지 않는다.
- 표시명 `오늘 뭐 버려?`. 번들 `kr.jejubin.app` / 위젯 `kr.jejubin.app.widget` / 그룹 `group.kr.jejubin.shared`.
- 집 도시 = 서귀포시. 제주시만 투명페트 제한 품목.
- 창 15:00–04:00. 배출일은 Seoul 04:00에 롤. 창 상태는 `beforeOpen` / `open` 두 값.
- 위젯 도시 = Configuration Intent. App Groups는 시도만, 실패해도 제품은 동작.
- 무료 Apple ID 사이드로드. 스토어·유료 ADP 전제 없음.
- 앱 화면은 `wallpaper.jpg`를 쓰지 않는다. 틸–슬레이트 그라디언트 + 본문 `#F4F0EA`. 벽지는 홈/잠금 위젯만.
- 한라봉 `#FF4E08`. 재활용 연두색 브랜드 금지.
- 품목 = `ItemTile` (하이퍼리얼 JPG). `ItemChip` 캡슐+SF Symbol 폐기.
- 알약은 탭되는 컨트롤만.
- **앱 헤더에는 도시 세그먼트만.** 설정 톱니를 헤더에 두면 하단 탭과 중복이므로 넣지 않는다.
- 탭 라인 아이콘은 Imagine으로 그리지 않는다. 소스: `docs/mockups/icons/ui/{today,week,settings}.svg`.
- 품목 아이콘 규칙: 베이지 필드 풀블리드 + 현무암 슬래브 + 물건. iOS 둥근 사각형 카드·흰 코너 없음. 세트가 깨지면 크롭하지 말고 **좋은 형제에서 image_edit**로 물건만 바꾼다.
- 작은 위젯: 1개=뱃지 오버랩, 2–3개=겹친 팬+숫자. 큰 위젯: 오늘 히어로 + 7열 주간 + “내일 …” 한 줄.

---

## 파일 지도

| 경로 | 역할 |
| --- | --- |
| `Orchestrator.md` | 이 파일. 세션 인수인계 |
| `docs/design.md` | 잠긴 설계서. 구현 계약 |
| `docs/mockups/index.html` | GUI 시안 v3 (정답 화면) |
| `docs/mockups/styles.css` | 시안 토큰·레이아웃 |
| `docs/mockups/png/*.png` | 13장 캡처 (구현 대조) |
| `docs/mockups/icons/*.jpg` | 품목 아이콘 최종 세트 |
| `docs/mockups/icons/ui/*.svg` | 탭 라인 아이콘 |
| `docs/mockups/app-icon.jpg` | 앱 아이콘 |
| `docs/mockups/wallpaper.jpg` | 홈/잠금 배경만 |
| `.gitignore` | Xcode/macOS 잡파일. design.md 최소안 |
| `docs/PROGRESS.md` | 아직 없음. 페이즈 1에서 생성 |
| `docs/INSTALL.md` | 아직 없음. 페이즈 1 초안 |
| `JejuBin.xcodeproj` | 아직 없음 |

시안 화면: `home`, `today-open`, `today-wait`, `today-jeju`, `week`, `settings`, `notify-settings`, `onb-city`, `onb-notify`, `onb-widget`, `widget-edit`, `lock-notify`, `today-dark`.

---

## 페이즈 (design.md PR Plan)

앞 페이즈 태그 없이 다음 페이즈 UI를 시작하지 않는다. 브랜치는 `main` 하나. 페이즈 끝 = 커밋 + 태그.

| # | 내용 | 태그 | 상태 |
| --- | --- | --- | --- |
| 0 | 설계 + GUI 시안 | — | **완료** |
| 1 | Xcode 뼈대, gitignore, App Groups 시도 | `snapshot/phase-1-skeleton` | **다음** |
| 2 | schedule JSON + ScheduleEngine + 단위 테스트 | `snapshot/phase-2-schedule-engine` | 대기 |
| 3 | 오늘 / 이번 주 / 도시 세그먼트 | `snapshot/phase-3-app-today-week` | 대기 |
| 4 | Small·Medium·Large 위젯 | `snapshot/phase-4-widget` | 대기 |
| 5 | 로컬 알림 + 알림 설정 | `snapshot/phase-5-notifications` | 대기 |
| 6 | 온보딩·다듬기·INSTALL | `snapshot/phase-6-onboarding-install` | 대기 |

페이즈 1 주의:

- 사용자가 Xcode 템플릿으로 앱+위젯을 만든다. 에이전트가 `pbxproj` 손수 작성 금지.
- 앱·위젯 **같은 Team**. App Groups `group.kr.jejubin.shared`는 시도만. 실패해도 통과, 결과를 `PROGRESS.md`에 적는다.
- 인수: 시뮬레이터에 빈 앱이 뜬다.

---

## 기록 규칙

한 바퀴가 끝나면 오케스트레이터가 **직접** 이 파일을 고친다.

1. **지금 어디** 표를 현재형으로 고친다. `다음 한 가지`는 항상 하나만.
2. **세션 로그**에 날짜·무엇을 했는지·검증·남긴 결정·다음을 4~8줄로 붙인다. 최신이 위.
3. 페이즈가 끝나면 `docs/PROGRESS.md`에도 같은 내용을 남기고, 이 문서 페이즈 표 상태를 바꾼다.
4. 잠긴 결정을 바꿨으면 **잠긴 결정** 절을 고친다. design.md와 모순이면 design.md가 원문이다.
5. 새 세션으로 넘길 때는 **콜드스타트** 블록만 최신 한 줄로 고친다. 서브에이전트 위임문을 미리 쓰지 않는다.

서브에이전트에게 코드를 맡길 때: 완료 기준, 보존할 것, 검증 명령, 건드리지 말 범위, 이 문서/`PROGRESS.md`에 적을 내용을 지시에 넣는다.

---

## 세션 로그

### 2026-08-14 — GitHub 원격 고정

- 사용자 레포: `https://github.com/meeeeeca2/jeju_onl.git` (생성 직후 빈 저장소).
- 로컬 `git init`, `origin` = 위 URL, 브랜치 `main`. 다른 원격 쓰지 않음.
- `.gitignore`는 design.md 최소안. 설계·시안·Orchestrator를 첫 커밋으로 푸시(페이즈 1 코드 아님).

### 2026-08-14 — Orchestrator.md 신설 + 시안 잠금 확인

- 개발을 `orchestrator-build-partner-v2`로 진행하기로 함. 인수인계 파일 이 문서로 둠.
- GUI 시안 재캡처 완료 상태: 헤더 설정 톱니 제거(하단 탭과 중복 UX 에러). 탭 아이콘은 `icons/ui/*.svg` (시계/달력/톱니). 품목 JPG는 베이지 풀블리드 세트.
- 저장소에 앱 코드 없음. git 미초기화. `PROGRESS.md` / `INSTALL.md` / Xcode 없음.
- 구현은 시작하지 않음. 다음 한 가지는 페이즈 1 계획 승인.

### 2026-08-13 — 설계 승인 + GUI 시안 반복

- `docs/design.md` 승인. 위젯 우선, 오프라인, 이중 도시, 로컬 알림.
- 시안을 HTML로 고정(이미지 모델은 UI 글자를 깨뜨림). Liquid Glass, 하이퍼리얼 아이콘, 앱 배경은 벽지 대신 틸–슬레이트.
- 품목 아이콘 세트 통일: 기준 장면에서 물건만 교체. 유리병 포함 10종 맞춤.
- 작은/큰 위젯 레이아웃 잠김.
---

# 📦 Project Crate D: Agile Implementation Plan

## 🎯 개발 철학 (Agile Strategy)
- **Extreme Agility**: 기능을 작게 쪼개어 하나씩 완성하고, 즉시 데모를 통해 RD 군의 피드백을 반영합니다.
- **Fail Fast, Fix Faster**: 실제 기기(혹은 시뮬레이터)에서 동작하는 코드를 최우선으로 확보합니다.

---

## 🗺️ 프로젝트 마일스톤 (Milestones)

### Stage 1: The Core Identity (Base & Theme) ✅
- **목적**: 앱의 뼈대를 세우고 'RainDrop' 감성을 입힌 기본 UI 시스템 구축.
- **Demo 목표**: 글래스모피즘 테마가 적용된 빈 대시보드 및 네비게이션.
- **검증 방안**: 실물을 시뮬레이터에서 구동하여 이브가 제안한 비주얼 가이드라인과 1:1 대조.
- **진행 상황**: 완료 (2026-03-07) - Premium Dark 테마 및 Glassmorphism UI 기반 확보.

### Stage 2: The Digital Crate (Grid & Mock Data) ✅
- **목적**: 바이널 컬렉션을 보여주는 '풍부한 시각적 리스트' 구현.
- **Demo 목표**: 샘플 데이터를 활용한 고품질 커버 이미지 그리드 뷰 및 스크롤 경험.
- **검증 방안**: 100개 이상의 더미 데이터를 부드럽게(60FPS) 렌더링하는지 테스트.
- **진행 상황**: 완료 (2026-03-07) - 100개의 더미 데이터를 활용한 글래스모피즘 그리드 레이아웃 구현.

### Stage 3: The Master Shell (UI Unity) ✅
- **목적**: 앱의 모든 메뉴와 화면 전환을 완성하여 백엔드 없이도 앱의 흐름을 100% 체험 가능하게 함.
- **Demo 목표**: 하단 네비게이션바, 가로 모드 레이아웃, 모든 메뉴(Search, Community, Profile)의 프리뷰 구현.
- **검증 방안**: 웹 환경에서 모든 메뉴가 정상적으로 클릭되고 전환되는지 확인.
- **진행 상황**: 완료 (2026-03-07) - 전 메뉴 고해상도 디자인 완료 및 프리미엄 더미 데이터 적용.

### Stage 4: AI Intelligence Integration (Final Prototype) ✅
- **목적**: 완성된 껍데기(Shell)에 AI 비전 인식과 외부 API 데이터를 주입하여 생명을 불어넣음.
- **진행 상황**: 완료 (2026-03-07)
  - Camera interface with neon scan animation implemented.
  - Simulated Gemini AI analysis & Discogs data enrichment flow established.
  - Unified 3-tab navigation with merged Dashboard/Profile.

### Stage 5: Backend & Data Layer Integration 🚧
- **목적**: 프로토타입의 더미 데이터를 실 데이터(DB & 외부 API)로 완벽히 대체하여 실제 구동되는 서비스로 전환.
- **주요 작업**:
  1. **Isar DB 마이그레이션**: 더미 데이터를 Isar 컬렉션으로 설계 및 CRUD 연동.
  2. **Real AI Vision 연동**: Gemini API를 통해 실제 카메라 이미지를 분석하고 JSON(아티스트, 앨범명 등) 포맷으로 파싱.
  3. **Discogs API 연동**: 인식된 앨범 정보를 바탕으로 실제 시세(Market Value) 및 고화질 커버 이미지 획득.

---

## 🛠️ 두 번째 스프린트 (Sprint 2: Stage 5 Data Layer)
1. **[실리콘]**: Isar DB Schema(`Vinyl` 모델) 작성 및 `CollectionProvider`와 연동.
2. **[실리콘 & 베리파이]**: Gemini API(AI 분석) 및 Discogs API 연동 모듈 개발, 에러 핸들링 테스트 구현.
3. **[프레임]**: 백엔드 연동에 따른 로딩 로직(비동기 UI) 및 스켈레톤 로딩(Shimmer Effect) 보강.

---
*수정일: 2026-03-07*
*작성자: 전략 총괄 쿠엔틴*

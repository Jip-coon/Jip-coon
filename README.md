# Jip-coon (집쿤)

> **가족 구성원이 함께하는 게이미피케이션 집안일 관리 앱**

## 앱스토어 출시
<a href="https://apps.apple.com/au/app/%EC%A7%91%EC%BF%A4/id6751805920">
 <img src="https://github.com/user-attachments/assets/4a8856c1-efb7-4b7b-82cc-1116b50c5678" width="250px">
</a>

## 📖 프로젝트 소개
**Jip-coon(집쿤)** 은 가족 구성원들이 집안일을 퀘스트처럼 수행하고 보상을 받으며, 집안일을 놀이처럼 즐길 수 있도록 돕는 서비스입니다.
딱딱하고 지루한 집안일 관리가 아닌, 가족 간의 소통과 경쟁을 유도하여 자발적인 참여를 이끌어내는 것을 목표로 했습니다.

- **개발 기간**: 2025.08 ~ 2026.02
- **개발 인원**: iOS 2명
- **역할**:
    - **심관혁**: 추후 작성 예정
    - **김예슬**: 추후 작성 예정

## ✨ 핵심 기능

### 1. 퀘스트(집안일) 관리
- 부모는 집안일을 ‘퀘스트’로 등록하고 담당자(자녀)를 지정할 수 있습니다.
- 자녀는 할당받은 퀘스트를 완료하고 인증샷을 남겨 승인을 요청합니다.
- 승인 완료 시 포인트가 지급됩니다.

### 2. 가족 관리
- 초대 코드를 통해 간편하게 가족 그룹을 생성하고 멤버를 초대할 수 있습니다.
- 부모/자녀 역할을 구분하여 권한을 관리합니다.

### 3. 게이미피케이션 (Gamification)
- 퀘스트 완료 보상으로 포인트를 획득합니다.
- 가족 구성원 간의 랭킹 시스템을 통해 경쟁 요소를 도입했습니다.

### 4. 소셜 로그인
- Google Sign-In 및 자체 이메일 회원가입을 지원하여 접근성을 높였습니다.

## 🛠 기술 스택 (Tech Stack)

| Category | Stacks |
| --- | --- |
| **Language** | Swift 5.10 |
| **UI Framework** | UIKit (Code-based) |
| **Architecture** | MVVM + Combine, Modular Architecture |
| **Dependency Manager** | Tuist |
| **Network & DB** | Firebase (Firestore, Auth, Messaging) |
| **Libraries** | Lottie, GoogleSignIn |
| **Cooperation** | GitHub, Slack, Figma, Jira |

## 🏗 아키텍처 (Architecture)

본 프로젝트는 **Tuist**를 활용한 모듈러 아키텍처(Modular Architecture)를 채택하여, 빌드 속도를 최적화하고 기능 간 결합도를 낮췄습니다.

```mermaid
graph TD
    App[App Module] --> Feature[Feature Module]
    Feature --> Core[Core Module]
    Feature --> UI[UI Module]
    UI --> Core
    Core --> External[External Dependencies<br/>(Firebase, etc)]
```

- **App**: 애플리케이션의 진입점, AppDelegate/SceneDelegate 포함
- **Feature**: 핵심 기능 구현 (화면 단위 Scene, ViewModel, UseCase)
- **UI**: 공통으로 사용되는 커스텀 뷰, 디자인 시스템, 리소스 관리
- **Core**: 네트워킹, 유틸리티, 익스텐션 등 비즈니스 로직과 무관한 핵심 기능

## 🔧 기술적 도전 및 문제 해결

### 1. Tuist 기반의 모듈화 도입
**문제**: 초기 단일 모듈 구조에서 기능이 추가됨에 따라 빌드 시간이 증가하고, 코드 간 의존성이 복잡해지는 문제가 발생했습니다.
**해결**: Tuist를 도입하여 프로젝트를 `Feature`, `UI`, `Core` 모듈로 분리했습니다.
**결과**:
- 모듈 단위 빌드가 가능해져 개발 생산성이 향상되었습니다.
- 명확한 의존성 그래프를 통해 순환 참조 문제를 방지했습니다.

### 2. Combine을 활용한 반응형 UI 구현 (MVVM)
**문제**: 비동기 데이터 처리(네트워크 요청, 사용자 입력)와 UI 업데이트 간의 동기화 코드가 복잡해졌습니다.
**해결**: MVVM 패턴과 Combine 프레임워크를 도입하여 데이터 스트림을 단방향으로 관리했습니다.
- `ViewModel`에서 `Input/Output` 패턴을 정의하여 데이터 흐름을 명확히 했습니다.
- `PassthroughSubject`, `@Published` 등을 활용하여 상태 변화를 구독하고 UI에 자동 반영되도록 구현했습니다.

## 📱 실행 화면

| 로그인 | 홈 (퀘스트 목록) | 퀘스트 상세 | 가족 관리 |
| :---: | :---: | :---: | :---: |
||||
추가예정
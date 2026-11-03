# LINGO BRIDGE

> **질문** 설치 없이 브라우저만으로 한국어 다국어 번역 서비스를 구현할 수 있을까?

> **답** HTML/CSS/JS만으로 MyMemory 번역 API를 연동해 5개 언어를 지원하는 반응형 웹 번역기를 구현했다. Python CLI 버전도 병행 제공한다.

한국어 텍스트를 영어, 일본어, 중국어, 스페인어, 프랑스어로 번역하는 웹 서비스

---

## 기술 스택 및 역량

![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)

| 역량 | 내용 |
|------|------|
| REST API 연동 | MyMemory Translation API를 fetch로 호출, JSON 응답 파싱 및 에러 처리 |
| 반응형 웹 구현 | 프레임워크 없이 순수 CSS로 모바일 대응 레이아웃 구현 |
| 이벤트 기반 UX | 언어 선택 즉시 번역, 글자수 실시간 표시, 입력 초기화 등 인터랙션 처리 |
| Python CLI 도구 | deep-translator 라이브러리로 터미널 버전 병행 구현 |
| 다국어 확장 구조 | 언어 버튼 추가만으로 지원 언어를 확장할 수 있는 구조 설계 |

---

## 기능

| 기능 | 내용 |
|------|------|
| 5개 언어 번역 | 영어, 일본어, 중국어, 스페인어, 프랑스어 |
| 언어 전환 시 즉시 번역 | 언어 버튼 클릭 시 현재 입력값으로 자동 재번역 |
| 글자수 표시 및 제한 | 실시간 글자수 표시, 1000자 입력 제한 |
| 입력 초기화 | 원클릭으로 입력창 초기화 |
| 모바일 반응형 | 브라우저만으로 모바일 환경에서도 사용 가능 |
| Python CLI 버전 | 터미널에서도 동일한 번역 기능 사용 가능 |

---

## 프로젝트 동기

- 외부 번역 API를 직접 연동하는 경험이 필요했다
- 별도 설치 없이 파일 하나로 실행되는 가벼운 도구를 만들고 싶었다
- 핵심 질문: 프레임워크 없이 순수 HTML/CSS/JS만으로 실용적인 웹 서비스를 구현할 수 있는가

---

## 사용 방법

**웹 버전 (브라우저)**

```
index.html 파일을 브라우저로 열기
```

1. 번역할 언어 버튼 클릭
2. 한국어 텍스트 입력
3. 번역하기 버튼 클릭

**CLI 버전 (Python)**

```
pip install deep-translator
python translator.py
```

---

## 한계

- MyMemory 무료 플랜은 하루 5000단어 번역 제한이 있음
- 네트워크 연결 없이는 사용 불가 (API 의존)
- 한국어 → 타 언어 단방향만 지원; 역방향 번역은 미구현
- 긴 문장의 경우 번역 품질이 낮아질 수 있음 (MyMemory 특성)

---

## 회고

외부 API를 연동한 첫 번째 웹 프로젝트로, 프론트엔드와 Python CLI 양쪽을 모두 직접 구현했다.

과정에서 체감한 점:
- fetch API로 외부 서비스를 연동할 때 에러 처리(네트워크 실패, API 한도 초과)가 UX에 직접 영향을 미침
- 프레임워크 없이 순수 JS로 상태(선택된 언어, 글자수)를 관리하면 구조가 단순해지는 대신 확장 시 복잡도가 커질 수 있음
- Python과 JS로 동일한 기능을 각각 구현하면서 두 환경의 API 호출 방식 차이를 체감

---

## 폴더 구조

```
translator/
├── index.html        # 웹 번역기
├── translator.py     # Python CLI 버전
├── screenshot.png    # 실행 화면
└── README.md
```

---

## 사용 기술

- 번역 API: MyMemory Translation API (무료, 회원가입 불필요)
- Python 라이브러리: deep-translator
- 폰트: Noto Sans KR (Google Fonts)

# 🚀 dev-logs

프로그래밍의 기초를 다지고, 다양한 실습을 진행하며 개인적인 성장 과정을 기록하는 공간입니다.

이론에만 머무르기보다 직접 코드를 작성하고 결과물을 만들어 보면서, 각각의 로직이 실제로 어떻게 작동하고 구현되는지 확인하는 것을 목적으로 두고 있습니다.

---

## 📂 전체 저장소 구조

```text
dev-logs/
├── air-analysis/          📂 대기오염 분석 프로젝트 폴더
│   ├── air_analysis.ipynb 📄 주피터 노트북 파일
│   └── last_amb_hour_time.xls 📊 원본 엑셀 데이터 파일
│
└── translator/            📂 링고 브릿지 번역기 프로젝트 폴더
    ├── index.html         🌐 웹 서비스 화면 파일
    ├── translator.py      🐍 파이썬 CLI 로직 파일
    ├── screenshot.png     📸 실행 화면 스크린샷
    └── README.md          📝 번역기 상세 설명 문서

```

## 📍 프로젝트 목록 및 지도

### 2. 🌤️ 서울 한강대로 대기오염 물질 분석 ➡️ [`/air-analysis`](./air-analysis)
- **설명**: 서울역 앞(한강대로 측정소)의 일주일간 대기오염 데이터를 활용하여 Pandas 및 데이터 시각화를 연습해 본 프로젝트입니다.
- **🔗 분석 결과 블로그**: [nbviewer로 분석 그래프 확인하기](https://nbviewer.org/github/Jenny5789/dev-logs/blob/main/air-analysis/air_analysis.ipynb)

<br>

### 1. 🔤 LINGO BRIDGE (번역기 프로젝트) ➡️ [`/translator`](./translator)
- **설명**: 한국어를 5개 국어(영어/일본어/중국어/스페인어/프랑스어)로 변환해 주는 웹 번역기입니다. CLI 환경과 웹 브라우저 환경을 동시에 구현해 보았습니다.
- **🔗 배포 링크**: [LINGO BRIDGE 직접 사용해보기](https://dev-logs-sdqg.vercel.app/)

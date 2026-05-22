from deep_translator import GoogleTranslator

LANGUAGES = {
    "1": ("영어", "en"),
    "2": ("일본어", "ja"),
    "3": ("중국어", "zh-CN"),
    "4": ("스페인어", "es"),
    "5": ("프랑스어", "fr"),
}

print("번역할 언어를 선택하세요:")
for key, (name, _) in LANGUAGES.items():
    print(f"  {key}. {name}")

choice = input("선택: ")
lang_name, lang_code = LANGUAGES.get(choice, ("영어", "en"))

korean_text = input("번역할 한국어 문장을 입력하세요: ")
result = GoogleTranslator(source='ko', target=lang_code).translate(korean_text)

print("\n--- 번역 결과 ---")
print(f"원문: {korean_text}")
print(f"{lang_name}: {result}")
import os
import replicate
import base64
import requests
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

THEMES = {
    "gatsby": "1920s gatsby party, woman img, elegant golden dress, champagne glass, han river fireworks background, luxury, photorealistic",
    "royal": "royal portrait, woman img, renaissance painting style, crown, velvet dress, palace background, oil painting, regal, photorealistic",
    "cyberpunk": "cyberpunk city, woman img, neon lights, futuristic outfit, rainy night, seoul city background, cinematic, photorealistic",
    "korean": "korean traditional hanbok, woman img, gyeongbokgung palace background, cherry blossom, elegant, photorealistic",
    "fantasy": "fantasy world, woman img, wizard robe, magic staff, dragon background, glowing spells, epic, photorealistic",
    "hollywood": "hollywood red carpet, woman img, glamorous gown, paparazzi flashes, luxury, celebrity, photorealistic",
    "joseon": "joseon dynasty queen, woman img, royal court dress, gyeongbokgung palace throne room, traditional korean, photorealistic",
    "chef": "michelin star chef, woman img, luxury restaurant kitchen, white chef uniform, elegant plating, photorealistic",
    "idol": "kpop idol on stage, woman img, concert spotlight, glamorous outfit, colorful lights, crowd, photorealistic",
    "drama": "kdrama main character, woman img, rooftop, cherry blossoms, cinematic lighting, emotional, photorealistic",
    "fighter": "UFC champion, woman img, octagon ring, championship belt, dramatic lighting, intense, photorealistic",
    "detective": "1940s noir detective, woman img, black and white, rainy city street, trench coat, mysterious, cinematic"
}

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['photo']
    theme = request.form.get('theme', 'gatsby')

    if file.filename == '':
        return '파일을 선택해주세요!'

    filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(filepath)

    prompt = THEMES.get(theme, THEMES['gatsby'])

    with open(filepath, 'rb') as f:
        output = replicate.run(
            "tencentarc/photomaker:ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4",
            input={
                "input_image": f,
                "prompt": prompt,
                "num_outputs": 1
            }
        )

    image_url = output[0] if isinstance(output, list) else str(output)
    image_data = requests.get(image_url).content
    image_b64 = base64.b64encode(image_data).decode('utf-8')

    theme_names = {
    "gatsby": "🥂 개츠비 파티",
    "royal": "👑 로열 포트레이트",
    "cyberpunk": "🌆 사이버펑크",
    "korean": "🇰🇷 한복",
    "fantasy": "🧙 판타지",
    "hollywood": "🎬 할리우드",
    "joseon": "🏯 조선시대",
    "chef": "👨‍🍳 미슐랭 셰프",
    "idol": "🎤 K-POP 아이돌",
    "drama": "📸 드라마 주인공",
    "fighter": "🥊 격투기 선수",
    "detective": "🕵️ 누아르 탐정"
}
    return f'''
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>AI Photo Studio</title>
            <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;400;600&family=Noto+Sans+KR:wght@300;400&display=swap" rel="stylesheet">
            <style>
                * {{ margin: 0; padding: 0; box-sizing: border-box; }}
                body {{ font-family: 'Noto Sans KR', sans-serif; background: #fafafa; display: flex; align-items: center; justify-content: center; min-height: 100vh; }}
                .container {{ max-width: 560px; width: 100%; padding: 60px 40px; text-align: center; }}
                .title {{ font-family: 'Cormorant Garamond', serif; font-size: 36px; font-weight: 300; margin-bottom: 8px; }}
                .theme-tag {{ font-size: 13px; color: #999; margin-bottom: 32px; }}
                img {{ width: 100%; border-radius: 12px; box-shadow: 0 8px 40px rgba(0,0,0,0.12); margin-bottom: 32px; }}
                .btn {{ display: inline-block; padding: 14px 32px; background: #1a1a1a; color: #fff; text-decoration: none; border-radius: 8px; font-size: 14px; font-family: 'Noto Sans KR', sans-serif; letter-spacing: 0.05em; }}
                .btn:hover {{ background: #333; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1 class="title">변환 완료</h1>
                <p class="theme-tag">{theme_names.get(theme, '')}</p>
                <img src="data:image/jpeg;base64,{image_b64}">
                <a href="/" class="btn">다시 변환하기</a>
            </div>
        </body>
        </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

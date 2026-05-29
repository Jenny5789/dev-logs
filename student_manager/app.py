from flask import Flask, render_template, request, redirect, url_for, jsonify, flash
from database.db_manager import DBManager

app = Flask(__name__)
app.secret_key = "student_mgr_2025"
db = DBManager()

@app.before_request
def setup():
    db.init()

# ── 학생 관리 ────────────────────────────────────────────
@app.route("/")
def index():
    q = request.args.get("q", "").strip()
    students = db.search(q) if q else db.get_all()
    return render_template("index.html", students=students, query=q, total=db.total_count())

@app.route("/add", methods=["POST"])
def add():
    try:
        name      = request.form["name"].strip()
        grade     = int(request.form["grade"])
        class_num = int(request.form["class_num"])
        num       = int(request.form["num"])
        if not name: raise ValueError
        ok, msg = db.add(grade, class_num, num, name)
        flash(("success" if ok else "danger", msg))
    except (ValueError, KeyError):
        flash(("danger", "입력값을 확인해주세요."))
    return redirect(url_for("index"))

@app.route("/delete", methods=["POST"])
def delete():
    grade     = int(request.form["grade"])
    class_num = int(request.form["class_num"])
    num       = int(request.form["num"])
    db.delete(grade, class_num, num)
    flash(("success", "학생이 삭제되었습니다."))
    return redirect(url_for("index"))

# ── 성적 관리 ────────────────────────────────────────────
@app.route("/scores")
def scores():
    grade     = int(request.args.get("grade", 1))
    class_num = int(request.args.get("class_num", 1))
    students  = db.get_by_class(grade, class_num)
    return render_template("scores.html", students=students, grade=grade, class_num=class_num)

@app.route("/scores/update", methods=["POST"])
def update_scores():
    grade     = int(request.form["grade"])
    class_num = int(request.form["class_num"])
    errors = []
    for key in request.form:
        if key.startswith("kor_"):
            num = int(key.split("_")[1])
            try:
                kor  = int(request.form[f"kor_{num}"])
                eng  = int(request.form[f"eng_{num}"])
                math = int(request.form[f"math_{num}"])
                if not all(0 <= s <= 100 for s in [kor, eng, math]): raise ValueError
                db.update_scores(grade, class_num, num, kor, eng, math)
            except (ValueError, KeyError):
                errors.append(num)
    if errors:
        flash(("danger", f"저장 실패 (번호: {errors}) — 0~100 숫자만 입력 가능"))
    else:
        flash(("success", "성적이 저장되었습니다."))
    return redirect(url_for("scores", grade=grade, class_num=class_num))

# ── 통계 ─────────────────────────────────────────────────
@app.route("/api/stats")
def api_stats():
    grade = request.args.get("grade", type=int)
    subj_avg = db.subject_averages(grade)
    rows = db.class_averages(grade if grade else 1)
    class_data = {
        "labels":  [f"{r[0]}반" for r in rows],
        "korean":  [r[1] for r in rows],
        "english": [r[2] for r in rows],
        "math":    [r[3] for r in rows],
    }
    scores = db.score_list(grade)
    buckets = [0]*10
    for s in scores:
        buckets[min(int(s//10), 9)] += 1
    ranking = [{"rank":r[8],"name":r[0],"class":f"{r[1]}학년 {r[2]}반 {r[3]}번",
                "korean":r[4],"english":r[5],"math":r[6],"average":r[7]}
               for r in db.ranking(grade)]
    return jsonify(subject_avg=subj_avg, class_data=class_data, histogram=buckets, ranking=ranking)

@app.route("/stats")
def stats():
    return render_template("stats.html")

if __name__ == "__main__":
    app.run(debug=True)
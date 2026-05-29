import sqlite3
import random
import os

LAST_NAME  = ["김","이","박","최","정","강","조","윤","장","임"]
FIRST_NAME = ["민준","서준","도윤","주원","예준","현우","준서","지훈","하준","우진",
              "서연","서윤","지우","서현","민서","하은","지민","윤서","지안","은서"]

class DBManager:
    def __init__(self):
        base = os.path.dirname(os.path.abspath(__file__))
        self.path = os.path.join(base, "student.db")

    def conn(self):
        c = sqlite3.connect(self.path)
        c.row_factory = sqlite3.Row
        return c

    def init(self):
        with self.conn() as c:
            c.execute("""CREATE TABLE IF NOT EXISTS students(
                grade INTEGER, class_num INTEGER, num INTEGER,
                name TEXT NOT NULL,
                korean INTEGER DEFAULT 0,
                english INTEGER DEFAULT 0,
                math INTEGER DEFAULT 0,
                average REAL DEFAULT 0.0,
                PRIMARY KEY(grade,class_num,num))""")
            if c.execute("SELECT COUNT(*) FROM students").fetchone()[0] == 0:
                rows = []
                for g in range(1,4):
                    for cl in range(1,9):
                        for n in range(1, random.randint(25,30)+1):
                            name = random.choice(LAST_NAME)+random.choice(FIRST_NAME)
                            kor  = random.randint(40, 100)
                            eng  = random.randint(40, 100)
                            math = random.randint(40, 100)
                            avg  = round((kor+eng+math)/3, 1)
                            rows.append((g,cl,n,name,kor,eng,math,avg))
                        c.executemany("INSERT OR IGNORE INTO students(grade,class_num,num,name,korean,english,math,average) VALUES(?,?,?,?,?,?,?,?)", rows)

    def get_all(self):
        with self.conn() as c:
            return c.execute("SELECT * FROM students ORDER BY grade,class_num,num").fetchall()

    def get_by_class(self, grade, class_num):
        with self.conn() as c:
            return c.execute(
                "SELECT * FROM students WHERE grade=? AND class_num=? ORDER BY num",
                (grade, class_num)).fetchall()

    def search(self, name):
        with self.conn() as c:
            return c.execute(
                "SELECT * FROM students WHERE name LIKE ? ORDER BY grade,class_num,num",
                (f"%{name}%",)).fetchall()

    def add(self, grade, class_num, num, name):
        try:
            with self.conn() as c:
                c.execute("INSERT INTO students(grade,class_num,num,name) VALUES(?,?,?,?)",
                          (grade, class_num, num, name))
            return True, "추가 성공"
        except sqlite3.IntegrityError:
            return False, "이미 존재하는 학번입니다."

    def delete(self, grade, class_num, num):
        with self.conn() as c:
            c.execute("DELETE FROM students WHERE grade=? AND class_num=? AND num=?",
                      (grade, class_num, num))

    def update_scores(self, grade, class_num, num, kor, eng, math):
        with self.conn() as c:
            c.execute("""UPDATE students SET korean=?,english=?,math=?,average=?
                         WHERE grade=? AND class_num=? AND num=?""",
                      (kor, eng, math, (kor+eng+math)/3, grade, class_num, num))

    def subject_averages(self, grade=None):
        sql = "SELECT AVG(korean),AVG(english),AVG(math) FROM students"
        p = ()
        if grade:
            sql += " WHERE grade=?"; p = (grade,)
        with self.conn() as c:
            r = c.execute(sql, p).fetchone()
            return [round(v or 0, 1) for v in r]

    def class_averages(self, grade):
        with self.conn() as c:
            return c.execute(
                "SELECT class_num,ROUND(AVG(korean),1),ROUND(AVG(english),1),"
                "ROUND(AVG(math),1),ROUND(AVG(average),1) "
                "FROM students WHERE grade=? GROUP BY class_num ORDER BY class_num",
                (grade,)).fetchall()

    def ranking(self, grade=None):
        sql = ("SELECT name,grade,class_num,num,korean,english,math,"
               "ROUND(average,1), RANK() OVER(ORDER BY average DESC) "
               "FROM students")
        p = ()
        if grade:
            sql += " WHERE grade=?"; p = (grade,)
        sql += " ORDER BY average DESC LIMIT 50"
        with self.conn() as c:
            return c.execute(sql, p).fetchall()

    def score_list(self, grade=None):
        sql = "SELECT average FROM students"
        p = ()
        if grade:
            sql += " WHERE grade=?"; p = (grade,)
        with self.conn() as c:
            return [r[0] for r in c.execute(sql, p).fetchall()]

    def total_count(self):
        with self.conn() as c:
            return c.execute("SELECT COUNT(*) FROM students").fetchone()[0]
        
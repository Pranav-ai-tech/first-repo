from fastapi import FastAPI, Query
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi.middleware.cors import CORSMiddleware
import os
import json

app = FastAPI()

# ✅ Allow Flutter app to access backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# 🔥 Initialize Firebase using ENVIRONMENT VARIABLE (Render)
# ============================================================

if not firebase_admin._apps:
    firebase_key = os.environ.get("FIREBASE_KEY")

    if not firebase_key:
        raise Exception("FIREBASE_KEY environment variable not set")

    cred_dict = json.loads(firebase_key)
    cred = credentials.Certificate(cred_dict)
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ============================================================
# 🔥 ROOT CHECK (optional but useful)
# ============================================================

@app.get("/")
def root():
    return {"message": "Portfolio backend is running"}

# ============================================================
# 🔥 GET LATEST STUDENT DATA (FROM USER DOCUMENT)
# ============================================================

@app.get("/latest-student")
def latest_student(uid: str = Query(...)):
    try:
        user_ref = db.collection("users").document(uid)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return {"error": "User not found"}

        data = user_doc.to_dict()

        return {
            "CGPA": data.get("cgpa", 0),
            "Attendance": data.get("attendance", 0),
            "Projects": data.get("projects", 0),
            "Skills": data.get("skills", []),
            "Timestamp": data.get("timestamp"),
        }

    except Exception as e:
        return {"error": str(e)}

# ============================================================
# 🔥 SIMPLE HISTORY (optional – returns same doc for now)
# ============================================================

@app.get("/student-history/{uid}")
def student_history(uid: str):
    try:
        user_ref = db.collection("users").document(uid)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return {"error": "User not found"}

        data = user_doc.to_dict()

        return [{
            "cgpa": data.get("cgpa", 0),
            "attendance": data.get("attendance", 0),
            "projects": data.get("projects", 0),
            "timestamp": data.get("timestamp"),
        }]

    except Exception as e:
        return {"error": str(e)}
from fastapi import FastAPI, Query
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ✅ Allow Flutter app to access backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Initialize Firebase (ONLY ONCE)
if not firebase_admin._apps:
    cred = credentials.Certificate("analytics/firebasekey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ============================================================
# 🔥 GET LATEST STUDENT PERFORMANCE
# ============================================================

@app.get("/latest-student")
def latest_student(uid: str = Query(...)):
    try:
        user_ref = db.collection("users").document(uid)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return {"error": "User not found"}

        user_data = user_doc.to_dict()

        performance_docs = (
            user_ref
            .collection("performance")
            .order_by("timestamp", direction=firestore.Query.DESCENDING)
            .limit(1)
            .stream()
        )

        performance_doc = next(performance_docs, None)

        if not performance_doc:
            return {"error": "No performance data found"}

        performance_data = performance_doc.to_dict()

        return {
            "CGPA": performance_data.get("cgpa", 0),
            "Attendance": performance_data.get("attendance", 0),
            "Projects": performance_data.get("projects", 0),
            "Skills": performance_data.get("skills", []),
            "Timestamp": performance_data.get("timestamp"),
            "Name": user_data.get("name", ""),
            "Email": user_data.get("email", "")
        }

    except Exception as e:
        return {"error": str(e)}


# ============================================================
# 🔥 GET FULL PERFORMANCE HISTORY
# ============================================================

@app.get("/student-history/{uid}")
def student_history(uid: str):
    try:
        user_ref = db.collection("users").document(uid)

        if not user_ref.get().exists:
            return {"error": "User not found"}

        performance_docs = (
            user_ref
            .collection("performance")
            .order_by("timestamp")
            .stream()
        )

        history = []

        for doc in performance_docs:
            data = doc.to_dict()
            history.append({
                "cgpa": data.get("cgpa", 0),
                "attendance": data.get("attendance", 0),
                "projects": data.get("projects", 0),
                "timestamp": data.get("timestamp")
            })

        return history

    except Exception as e:
        return {"error": str(e)}
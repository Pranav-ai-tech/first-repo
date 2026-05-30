# 🎓 Student Analytics & Portfolio Management Platform

A full-stack analytics platform designed to help students track academic performance, manage portfolios, and gain actionable insights through descriptive, diagnostic, and predictive analytics.

## 🚀 Features

- 📊 Academic Performance Tracking (CGPA, Attendance, Projects)
- 📈 Historical Performance Analysis
- 🔍 Descriptive Analytics
- ⚠️ Diagnostic Analytics & Risk Assessment
- 🔮 Predictive Performance Insights
- 📝 Student Portfolio Management
- 🔐 Secure User Authentication with Firebase
- ☁️ Cloud-Based Backend Deployment
- 📱 Cross-Platform Mobile Application

---

## 🏗️ System Architecture

```text
Flutter Mobile App
        │
        ▼
 FastAPI Backend (Render)
        │
        ▼
 Firebase Firestore
```

The Flutter application communicates with a FastAPI backend through REST APIs. The backend retrieves and processes data stored in Firebase Firestore to generate analytical insights and performance reports.

---

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Python
- FastAPI

### Database & Authentication
- Firebase Firestore
- Firebase Authentication

### Cloud & DevOps
- Render Cloud
- Git
- GitHub

---

## 📂 Project Structure

```text
project-root/
│
├── lib/                     # Flutter Frontend
├── analytics/               # FastAPI Backend
│   └── api.py
├── android/
├── ios/
├── requirements.txt
├── pubspec.yaml
└── README.md
```

---

## 📊 Analytics Implemented

### Descriptive Analytics
- CGPA Trend Analysis
- Attendance Monitoring
- Project Tracking

### Diagnostic Analytics
- Academic Risk Assessment
- Performance Evaluation
- Attendance vs Performance Analysis

### Predictive Analytics
- Performance Forecasting
- Future Academic Risk Identification

### Prescriptive Analytics
- Personalized Recommendations
- Academic Improvement Suggestions

---

## 🔥 Key Functionalities

### Student Dashboard
Provides an overview of:
- CGPA
- Attendance
- Completed Projects
- Skills Portfolio

### Performance History
Stores and tracks historical academic records using Firebase Firestore.

### Actionable Insights
Generates meaningful recommendations based on academic performance and engagement metrics.

---

## 🔐 Authentication

The platform uses Firebase Authentication for secure login and user-specific access control.

Features:
- User Registration
- User Login
- Secure Session Management

---

## 🌐 Deployment

### Backend Deployment
The FastAPI backend is deployed on Render Cloud.

### Database
Firebase Firestore is used for real-time data synchronization and storage.

---

## 📈 Future Enhancements

- Machine Learning-based Performance Prediction
- Interactive Data Visualization Charts
- Power BI Integration
- Placement Readiness Scoring
- Recommendation Engine for Courses and Certifications
- AI-powered Student Performance Advisor

---

## 🎯 Learning Outcomes

This project demonstrates:

- Full-Stack Application Development
- REST API Design and Integration
- Cloud Deployment
- Firebase Integration
- Data Analytics Implementation
- Software Engineering Best Practices

---

## 👨‍💻 Author

**Pranav M**

Student | Aspiring Business Analytics Professional

---

## 📄 License

This project is developed for educational and portfolio purposes.

# 🌿 Aira - Emotional Support Companion

A gentle, calm emotional support companion app built with **Flutter** and **FastAPI + Agno**.

> *Aira is not a product that "does things." Aira is a space people step into when they feel heavy, confused, or alone.*

---

## ✨ What is Aira?

Aira is designed to provide a **safe, non-judgmental space** for people to express their thoughts and feelings freely.

Aira exists for moments when someone wants:
- 🎧 To feel **heard**
- 🧘 To **slow down** mentally
- 💭 To express emotions **safely**
- 🤝 To not feel **alone** with their thoughts

### What Aira Does
- Listens and reflects emotions
- Asks gentle open-ended questions
- Offers grounding or breathing suggestions
- Encourages real human support when needed

### What Aira Does NOT Do
- ❌ Diagnose or treat conditions
- ❌ Give medical/psychological advice
- ❌ Replace professional help
- ❌ Push or pressure users

---

## 🏗️ Project Structure

```
aiera/
├── backend/                 # FastAPI + Agno Backend
│   ├── main.py             # API server
│   ├── agent.py            # Aira agent logic
│   ├── requirements.txt    # Python dependencies
│   ├── railway.json        # Railway deployment config
│   └── .env.example        # Environment template
│
└── lib/                     # Flutter App
    ├── main.dart
    ├── theme/
    │   └── aira_theme.dart # Calm color palette
    ├── screens/
    │   ├── home_screen.dart
    │   └── chat_screen.dart
    ├── widgets/
    │   └── message_bubble.dart
    └── services/
        └── chat_service.dart
```

---

## 🚀 Quick Start

### Backend Setup

```bash
cd aiera/backend

# Create virtual environment (optional)
python -m venv venv
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Configure environment
copy .env.example .env
# Edit .env and add your GOOGLE_API_KEY

# Run server
python main.py
```

The API will be available at `http://localhost:8000`

### Flutter App Setup

```bash
cd aiera

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on Android
flutter run -d android
```

---

## 🌐 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API info |
| `/health` | GET | Health check |
| `/chat` | POST | Send message to Aira |
| `/docs` | GET | Interactive API docs |

### Chat Request

```json
POST /chat
{
  "message": "I feel overwhelmed today...",
  "session_id": "optional-uuid",
  "user_id": "optional-user-id"
}
```

### Chat Response

```json
{
  "response": "It sounds like today has been heavy...",
  "session_id": "uuid",
  "is_crisis": false
}
```

---

## 🎨 Design Philosophy

| Principle | Meaning |
|-----------|---------|
| **Calm > Engagement** | Don't overstimulate |
| **Safety > Cleverness** | Don't be risky |
| **Presence > Productivity** | Don't rush |
| **Softness > Brightness** | Don't distract |
| **Trust > Retention** | Don't manipulate |

### Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Background | Soft beige | `#F5F2ED` |
| Primary | Muted sage green | `#A8C5A8` |
| Text | Dark warm gray | `#4A4A4A` |
| User bubble | Pale green | `#E8F0E8` |
| Aira bubble | Soft lavender | `#F0E8F4` |

---

## ☁️ Deployment (Railway)

1. Push `backend/` folder to GitHub
2. Create new project on [Railway.app](https://railway.app)
3. Connect your GitHub repo
4. Add environment variables:
   - `GOOGLE_API_KEY` = your API key
   - `DB_PATH` = data/aira.db
5. Deploy and get your URL
6. Update `chat_service.dart` with Railway URL

---

## 🛡️ Safety Features

- **Crisis Detection**: Scans for keywords indicating distress
- **Crisis Response**: Provides helpline numbers and support resources
- **Session Persistence**: Remembers conversation context
- **Gentle Boundaries**: Never pushes or pressures

---

## 📚 Tech Stack

- **Backend**: Python, FastAPI, Agno, Google Gemini
- **Frontend**: Flutter, Dart
- **Database**: SQLite
- **Deployment**: Railway

---

## 📄 License

MIT License - Feel free to use and modify.

---

*Built with 💚 for mental wellness*

*Aira — A space to breathe, feel, and be.*

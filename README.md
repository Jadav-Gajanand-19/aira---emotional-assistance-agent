# 🌿 Aira - Your AI Best Friend for Emotional Support

A warm, caring emotional support companion app built with **Flutter** and **FastAPI + Gemini AI**.

> *Aira feels less like a chatbot and more like texting your most understanding best friend.*

---

## ✨ Features

### 🎤 Voice Interaction
- **Speech-to-Text** — Talk naturally, Aira understands
- **Text-to-Speech** — Aira responds with voice
- **Voice Settings** — Customize speed, pitch, and voice type
- **Demo Preview** — Test voice before applying

### 🌐 Multi-Language Support
- English, Hindi (हिंदी), Telugu (తెలుగు), Tamil (தமிழ்), Kannada (ಕನ್ನಡ)
- Speak in any language — Aira understands!
- Aira responds in your selected language

### 💚 Best Friend Personality
- Casual, friendly conversation style
- Matches your energy — playful or serious
- Actually listens and remembers
- No robotic or clinical vibes

### 🛡️ Safety Features
- Crisis detection with helpline resources
- Gentle boundaries — never pushes or pressures
- Encourages professional help when needed

---

## 📱 Screenshots

| Splash | Chat | Voice Settings |
|--------|------|----------------|
| Animated splash screen | Talk or type with Aira | Customize voice |

---

## 🚀 Quick Start

### Backend Setup

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Configure environment
copy .env.example .env
# Add your GOOGLE_API_KEY

# Run server
python main.py
```

### Flutter App Setup

```bash
# Install dependencies
flutter pub get

# Run on Chrome
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
| `/chat` | POST | Send message with language |
| `/docs` | GET | Interactive docs |

### Chat Request

```json
POST /chat
{
  "message": "I feel overwhelmed...",
  "language": "hi",
  "session_id": "optional-uuid"
}
```

---

## 🎨 Design

| Principle | Meaning |
|-----------|---------|
| **Calm > Engagement** | Don't overstimulate |
| **Safety > Cleverness** | Don't be risky |
| **Presence > Productivity** | Don't rush |

### Colors
- **Background**: Soft beige `#F5F2ED`
- **Primary**: Sage green `#A8C5A8`
- **Aira bubble**: Soft lavender `#F0E8F4`

---

## ☁️ Deployment

**Backend**: Deployed on [Render](https://render.com)  
**Frontend**: Flutter Web/Android/iOS

---

## 📚 Tech Stack

| Layer | Technology |
|-------|------------|
| AI | Google Gemini + Agno |
| Backend | Python, FastAPI |
| Frontend | Flutter, Dart |
| Voice | speech_to_text, flutter_tts |
| Database | SQLite |

---

## 📄 License

MIT License

---

*Built with 💚 for mental wellness*

**Aira — Your person. Always there for you.**

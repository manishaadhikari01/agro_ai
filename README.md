

# 🌾 DeepShiva – AI Chatbot for Indian Farmers

**DeepShiva** is an **AI-powered chatbot** designed to assist Indian farmers by providing **real-time, accessible, and language-inclusive support**. The project aims to **bridge the information gap** in agriculture through a multilingual conversational interface available on both **mobile and web platforms**.

---

## 🚜 Problem Statement

Indian farmers face multiple challenges that directly affect their productivity and income:

1. **Unpredictable Weather** – Affects crop planning, irrigation, and yield.
2. **Pest and Disease Outbreaks** – Cause heavy losses due to lack of early detection.
3. **Limited Access to Modern Farming Techniques** – Leads to reduced efficiency and soil degradation.
4. **Fluctuating Market Prices** – Impacts profitability and decision-making.
5. **Low Awareness of Government Schemes/Subsidies** – Farmers miss financial opportunities.
6. **Language Barriers and Low Digital Literacy** – Restrict access to vital information.

---

## 💡 Proposed Solution

**DeepShiva** offers an AI-based chatbot system that addresses these issues through:

| Problem                         | Chatbot Solution                                                        |
| ------------------------------- | ----------------------------------------------------------------------- |
| Unpredictable weather           | 📊 Live weather updates for planning sowing, irrigation, and harvesting |
| Pest & disease issues           | 🐛 Early pest/disease identification and treatment suggestions          |
| Lack of modern knowledge        | 🌱 Guidance on sustainable and modern farming practices                 |
| Market price fluctuations       | 💰 Real-time market price insights from Agmarknet or scraping           |
| Lack of awareness about schemes | 🏛️ Information and guidance on government schemes and subsidies        |
| Language & accessibility        | 🌐 Multilingual support using Indic NLP tools (Bhashini / AI4Bharat)    |

---

## 🧠 System Architecture

```plaintext
Users (Farmers)
      │
      ▼
Access via Mobile App (Flutter) or Web App (HTML/CSS/JS)
      │
      ▼
┌───────────────────────────────────────────────┐
│ Frontend (Flutter / React)                    │
│ - User Interface (UI)                         │
│ - Multilingual input/output                   │
└───────────────────────────────────────────────┘
      │
      ▼
┌───────────────────────────────────────────────┐
│ Python Backend (FastAPI)                      │
│ - Handles requests from frontend              │
│ - Connects to external APIs & ML models       │
│ - Formats and sends chatbot replies           │
└───────────────────────────────────────────────┘
      │
┌────────────┬───────────────┬───────────────┬───────────────┐
▼            ▼               ▼               ▼               ▼
Chatbot      Weather API     Market Prices   Pest Detection  Scheme Info
(LLM API)    (OpenWeather)   (Agmarknet)     (ML Model)      (Scraped/DB)
      │
      ▼
┌───────────────────────────────────────────────┐
│ Language Support Layer                        │
│ - Bhashini / AI4Bharat / IndicTrans           │
│ - Regional translation (text-to-text)         │
└───────────────────────────────────────────────┘
      │
      ▼
┌───────────────────────────────────────────────┐
│ LangSmith (Optional - Development)             │
│ - Prompt evaluation, debugging, monitoring     │
└───────────────────────────────────────────────┘
```

---

## ⚙️ Tech Stack

| Component             | Technology                             |
| --------------------- | -------------------------------------- |
| **Frontend (App)**    | Flutter (Mobile) / React (Web)         |
| **Backend**           | FastAPI (Python)                       |
| **Database**          | PostgreSQL / MongoDB                   |
| **Chatbot Model**     | OpenAI GPT / Hugging Face LLM          |
| **Weather Data**      | OpenWeather API                        |
| **Market Data**       | Agmarknet CSV or Web Scraping          |
| **Pest Detection**    | Custom ML Model (Image Classification) |
| **Translation Layer** | AI4Bharat / Bhashini / IndicTrans      |
| **Monitoring (Dev)**  | LangSmith / LangFuse (Optional)        |

---

## 📱 Features

✅ Real-time weather updates
✅ Pest & disease identification (via image upload or description)
✅ Crop guidance and sustainable farming tips
✅ Daily market prices for crops
✅ Centralized scheme and subsidy information
✅ Multilingual interface for regional accessibility
✅ Voice and text input options

---

## 🔧 Installation & Setup

### 1️⃣ Clone the repository

```bash
git clone https://github.com/your-username/deepshiva.git
cd deepshiva
```

### 2️⃣ Backend Setup (FastAPI)

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### 3️⃣ Frontend Setup (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

### 4️⃣ Environment Variables

Create a `.env` file in the backend folder with:

```
OPENAI_API_KEY=your_api_key
WEATHER_API_KEY=your_api_key
DB_URL=your_database_url
```

---

## 🧩 Future Enhancements

🚜 Integration with IoT-based sensors for soil and weather data
🧬 Advanced pest detection using computer vision models
🗣️ Voice-based chat in regional languages
📈 Predictive analytics for crop planning
🛰️ Satellite-based crop monitoring

---

## 👨‍💻 Contributors

| Name                              | Role                    |
| --------------------------------- | ----------------------- |
| **Yuuqi (Manisha Adhikari)**      | Project Lead, Developer |
| *(Add other contributors if any)* |                         |

---

## 🛠️ License

This project is licensed under the **MIT License** – free to use, modify, and distribute with proper credit.

---

## 🌱 Vision

> “Empowering every Indian farmer with the knowledge, tools, and technology they need — one conversation at a time.”


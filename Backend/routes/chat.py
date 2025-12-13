from fastapi import APIRouter
from groq import Groq
import os

# -----------------------------
# DEBUG: Check if API key loads
# -----------------------------
print("DEBUG: .env GROQ_API_KEY =", os.getenv("GROQ_API_KEY"))

# Import offline model from agent.py (dummy model)
from chatbot.agent import get_bot_reply  

router = APIRouter()

# -----------------------------
# TRY TO INITIALIZE GROQ CLIENT
# -----------------------------
GROQ_KEY = os.getenv("GROQ_API_KEY")

if not GROQ_KEY or GROQ_KEY.strip() == "":
    print("❌ ERROR: GROQ_API_KEY is missing — online model will not work!")
    groq_client = None
else:
    try:
        groq_client = Groq(api_key=GROQ_KEY)
        print("✅ Groq client initialized")
    except Exception as e:
        print("❌ ERROR initializing Groq client:", e)
        groq_client = None


@router.post("/chat")
def unified_chat(query: str, mode: str = "auto"):

    # FORCE ONLINE
    if mode == "online":
        return call_online_model(query)

    # FORCE OFFLINE
    if mode == "offline":
        return call_offline_model(query)

    # AUTO MODE
    try:
        return call_online_model(query)
    except Exception as e:
        print("⚠️ AUTO MODE: Online failed, falling back offline. Error:", e)
        return call_offline_model(query)


def call_online_model(prompt: str):

    if groq_client is None:
        return call_offline_model(prompt)

    try:
        response = groq_client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[{"role": "user", "content": prompt}],
        )

        return {
            "mode_used": "online",
            "answer": response.choices[0].message.content
        }

    except Exception as e:
        print("❌ ONLINE MODEL ERROR:", e)
        return call_offline_model(prompt)


# -----------------------------
# 🟠 OFFLINE MODEL (Dummy)
# -----------------------------
def call_offline_model(prompt: str):
    reply = get_bot_reply(prompt)
    return {
        "mode_used": "offline",
        "answer": reply
    }

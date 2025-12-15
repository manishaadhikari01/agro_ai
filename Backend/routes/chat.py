from fastapi import APIRouter
from groq import Groq
import os
from pydantic import BaseModel
from datetime import datetime
from sqlalchemy import select
from fastapi import Depends
from auth.jwt import get_current_user
from db.models import Message, User
from db.session import get_session
from sqlalchemy.ext.asyncio import AsyncSession

# -----------------------------
# 🌾 AgroAI System Prompt
# -----------------------------
SYSTEM_PROMPT = """
You are AgroAI, an expert agricultural assistant.

Your role:
- Provide practical, clear, and actionable farming advice
- Give crop-specific and region-aware recommendations when possible
- Explain causes before suggesting solutions
- Avoid unsafe, illegal, or harmful recommendations
- If unsure, say so and suggest consulting an expert

Tone:
- Helpful, respectful, and simple
- Suitable for farmers and agriculture students
"""
INTENT_PROMPTS = {
    "disease": """
You are an agricultural expert.
When discussing crop diseases:
- Do not guess blindly
- Ask about symptoms, color, spread, and duration
- Suggest preventive measures first
""",

    "fertilizer": """
You are an agricultural expert.
When giving fertilizer advice:
- Suggest affordable options
- Mention organic alternatives
- Explain dosage and timing
""",

    "weather": """
You are an agricultural assistant.
When answering weather-related questions:
- Be cautious with predictions
- Suggest risk-mitigation steps
""",

    "general": ""
}

def detect_intent(query: str) -> str:
    q = query.lower()

    if any(word in q for word in ["disease", "spot", "yellow", "brown", "fungus", "rot"]):
        return "disease"

    if any(word in q for word in ["fertilizer", "urea", "npk", "manure", "compost"]):
        return "fertilizer"

    if any(word in q for word in ["rain", "weather", "temperature", "humidity"]):
        return "weather"

    return "general"

def build_groq_messages(system_prompt: str, history: list, user_query: str):
    """
    Converts DB messages into Groq-compatible format.
    """
    messages = [{"role": "system", "content": system_prompt}]

    for item in history:
        messages.append({"role": "user", "content": item["query"]})
        messages.append({"role": "assistant", "content": item["reply"]})

    messages.append({"role": "user", "content": user_query})

    return messages

# Import offline model from agent.py (dummy model)
from chatbot.agent import get_bot_reply  

router = APIRouter()

#------schemas------
class ChatHistoryItem(BaseModel):
    query: str
    reply: str
    created_at: datetime


class ChatHistoryResponse(BaseModel):
    history: list[ChatHistoryItem]


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
def unified_chat(query: str, history: list, mode: str = "auto"):

    # FORCE ONLINE
    if mode == "online":
        return call_online_model(query, history)

    # FORCE OFFLINE
    if mode == "offline":
        return call_offline_model(query)

    # AUTO MODE
    try:
        return call_online_model(query, history)
    except Exception as e:
        print("⚠️ AUTO MODE: Online failed, falling back offline. Error:", e)
        return call_offline_model(query)


def call_online_model(prompt: str, history: list):

    if groq_client is None:
        return call_offline_model(prompt)

    try:
        # 🧠 Detect intent
        intent = detect_intent(prompt)
        intent_prompt = INTENT_PROMPTS.get(intent, "")

        # 🧾 Build messages with intent-aware system prompt
        messages = build_groq_messages(
            SYSTEM_PROMPT + intent_prompt,
            history,
            prompt
        )

        response = groq_client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=messages,
        )

        return {
            "mode_used": "online",
            "intent": intent,   # 👈 useful for debugging / frontend later
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

#------------------ CHAT HISTORY ------------------
@router.get("/chat/history", response_model=ChatHistoryResponse)
async def get_chat_history(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    limit: int = 20
):
    """
    Returns recent chat history for the logged-in user
    """

    result = await session.execute(
        select(Message)
        .where(Message.user_id == current_user.id)
        .order_by(Message.created_at.asc())
        .limit(limit)
    )

    messages = result.scalars().all()

    history = [
        ChatHistoryItem(
            query=m.query,
            reply=m.reply,
            created_at=m.created_at
        )
        for m in messages
    ]

    return ChatHistoryResponse(history=history)
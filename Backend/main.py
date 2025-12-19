from dotenv import load_dotenv
load_dotenv()
import os, json, hashlib
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from routes import audit, farmers, auth
from routes.chat import unified_chat
from routes.chat import router as chat_router
from chatbot.utils import heuristic_enrich
from db.session import get_session, engine
from db import models
from db.models import User, Message
from auth.jwt import get_current_user
from routes import users
from routes.plant_disease import router as plant_disease_router
from routes.crop_recommendation import router as crop_router
from routes import govt_data
from routes.fields import router as fields_router



app = FastAPI(title="AgroAI Backend 🌾", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MEMORY_LIMIT = 5

IGNORED_PHRASES = {
    "hi", "hello", "hey", "ok", "okay",
    "thanks", "thank you", "yes", "no"
}

def is_useful_message(text: str) -> bool:
    text = text.lower().strip()
    return len(text) >= 5 and text not in IGNORED_PHRASES


# ------------------ DB INIT ------------------
@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)
    print("✅ Database initialized successfully!")
    print("🔐 Chat is JWT protected")


# ------------------ SCHEMAS ------------------
class ChatRequest(BaseModel):
    query: str


class ChatResponse(BaseModel):
    answer: str
    message_id: str
    fabric_tx_id: str | None = None
    polygon_tx_hash: str | None = None


# ------------------ UTILS ------------------
def canonical_record(user_id: str, query: str, reply: str) -> bytes:
    payload = json.dumps(
        {"user_id": user_id, "query": query, "reply": reply},
        ensure_ascii=False,
        separators=(",", ":"),
        sort_keys=True
    )
    return payload.encode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


# ------------------ CHAT (JWT PROTECTED) ------------------
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(
    req: ChatRequest,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session)
):
    try:
        user = current_user  # 🔐 identity from JWT

        # 🔁 Load conversation memory
        result = await session.execute(
            select(Message)
            .where(Message.user_id == user.id)
            .order_by(Message.created_at.desc())
            .limit(MEMORY_LIMIT)
        )
        past_messages = result.scalars().all()

        history = [
            {"query": m.query, "reply": m.reply}
            for m in reversed(past_messages)
            if is_useful_message(m.query)
        ]

        # 🤖 Online → Offline logic
        chat_result = unified_chat(
            query=req.query,
            history=history,
            mode="auto"
        )

        base_reply = chat_result["answer"]
        full_reply = (
            heuristic_enrich(req.query, base_reply)
            if "heuristic_enrich" in globals()
            else base_reply
        )

        # 💾 Save message
        msg = Message(
            user_id=user.id,
            query=req.query,
            reply=full_reply,
            intent="advice",
            record_hash=""
        )
        session.add(msg)
        await session.flush()

        msg.record_hash = sha256_hex(
            canonical_record(user.id, req.query, full_reply)
        )

        await session.commit()

        return ChatResponse(
            answer=full_reply,
            message_id=str(msg.id)
        )

    except Exception as e:
        await session.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# ------------------ HEALTH ------------------
@app.get("/health")
async def health_check(session: AsyncSession = Depends(get_session)):
    health = {"status": "ok", "db": "unknown"}

    try:
        await session.execute(select(User).limit(1))
        health["db"] = "connected"
    except Exception:
        health["db"] = "disconnected"
        health["status"] = "degraded"

    return health


@app.get("/")
async def root():
    return {"message": "Welcome to AgroAI Backend 🚜"}


# ------------------ ROUTERS ------------------
app.include_router(audit.router, prefix="/audit", tags=["Audit"])
app.include_router(farmers.router, prefix="/farmers", tags=["Farmers"])
app.include_router(chat_router, prefix="/api", tags=["Chat"])
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(plant_disease_router)
app.include_router(crop_router)
app.include_router(govt_data.router, prefix="/govt", tags=["Government Data"])
app.include_router(fields_router)


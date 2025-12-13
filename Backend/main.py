# main.py

import os, json, hashlib
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

# Local imports
from routes import audit, farmers
from routes.chat import unified_chat
from routes.chat import router as chat_router
from chatbot.utils import heuristic_enrich  # optional
from db.session import get_session, engine
from db import models
from db.models import User, Message

# ---------------------------------------------------------------------
# 🌱 Load environment variables
# ---------------------------------------------------------------------
load_dotenv()

# ---------------------------------------------------------------------
# 🚀 Initialize FastAPI app
# ---------------------------------------------------------------------
app = FastAPI(title="AgroAI Backend 🌾", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------
# 🧱 Database Initialization
# ---------------------------------------------------------------------
@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)
    print("✅ Database initialized successfully!")
    print("🤖 Chat system ready (Groq + Offline fallback)")

# ---------------------------------------------------------------------
# 🧩 Pydantic Schemas
# ---------------------------------------------------------------------
class ChatRequest(BaseModel):
    user_id: str
    query: str

class ChatResponse(BaseModel):
    answer: str
    message_id: str
    fabric_tx_id: str | None = None
    polygon_tx_hash: str | None = None

# ---------------------------------------------------------------------
# 🔐 Utility functions
# ---------------------------------------------------------------------
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

# ---------------------------------------------------------------------
# 💬 Chat Endpoint – MAIN ENTRY POINT
# ---------------------------------------------------------------------
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(req: ChatRequest, session: AsyncSession = Depends(get_session)):
    try:
        # ✅ User lookup / creation
        result = await session.execute(
            select(User).where(User.external_id == req.user_id)
        )
        user = result.scalar_one_or_none()

        if not user:
            user = User(external_id=req.user_id)
            session.add(user)
            await session.flush()

        # ✅ CALL ONLINE/OFFLINE CHAT LOGIC (Groq → fallback)
        chat_result = unified_chat(query=req.query, mode="auto")
        base_reply = chat_result["answer"]

        # Optional heuristic enrichment
        full_reply = (
            heuristic_enrich(req.query, base_reply)
            if "heuristic_enrich" in globals()
            else base_reply
        )

        # ✅ Save message
        msg = Message(
            user_id=user.id,
            query=req.query,
            reply=full_reply,
            intent="advice",
            record_hash=""
        )
        session.add(msg)
        await session.flush()

        # ✅ Hash record
        record_hash = sha256_hex(
            canonical_record(req.user_id, req.query, full_reply)
        )
        msg.record_hash = record_hash
        await session.flush()

        await session.commit()

        return ChatResponse(
            answer=full_reply,
            message_id=str(msg.id),
            fabric_tx_id=None,
            polygon_tx_hash=None
        )

    except Exception as e:
        await session.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# ---------------------------------------------------------------------
# 🩺 Health Check
# ---------------------------------------------------------------------
@app.get("/health")
async def health_check():
    return {
        "status": "running",
        "chat_model": "Groq (online) + Dummy (offline)",
        "database": "connected"
    }

# ---------------------------------------------------------------------
# 🏠 Root
# ---------------------------------------------------------------------
@app.get("/")
async def root():
    return {"message": "Welcome to AgroAI Backend 🚜"}

# ---------------------------------------------------------------------
# 🔗 Routers
# ---------------------------------------------------------------------
app.include_router(audit.router, prefix="/audit", tags=["Audit"])
app.include_router(farmers.router, prefix="/farmers", tags=["Farmers"])
app.include_router(chat_router, prefix="/api", tags=["Chat"])

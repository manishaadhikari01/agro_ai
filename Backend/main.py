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
from chatbot.agent import get_bot_reply
from chatbot.utils import heuristic_enrich  # If exists
from db.session import get_session, engine
from db import models
from db.models import User, Message
# from fabric_sdk.fabric_client import log_to_fabric
# from chain.polygon_client import publish_hash_on_polygon

# ---------------------------------------------------------------------
# 🌱 Load environment variables
# ---------------------------------------------------------------------
load_dotenv()

# ---------------------------------------------------------------------
# 🚀 Initialize FastAPI app
# ---------------------------------------------------------------------
app = FastAPI(title="AgroAI Backend 🌾", version="1.0")

# CORS setup – allow frontend to connect to backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ⚠️ Change to your Flutter web URL in production
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
    print("🤖 Chatbot model loaded and backend ready!")

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
    """Create a canonical JSON record for blockchain hashing."""
    payload = json.dumps(
        {"user_id": user_id, "query": query, "reply": reply},
        ensure_ascii=False, separators=(",", ":"), sort_keys=True
    )
    return payload.encode("utf-8")

def sha256_hex(data: bytes) -> str:
    """Generate SHA256 hash for blockchain record integrity."""
    return hashlib.sha256(data).hexdigest()


# ---------------------------------------------------------------------
# 💬 Chat Endpoint – Connects Frontend to Chatbot
# ---------------------------------------------------------------------
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(req: ChatRequest, session: AsyncSession = Depends(get_session)):
    try:
        # ✅ Check if user exists, else create new
        result = await session.execute(select(User).where(User.external_id == req.user_id))
        user = result.scalar_one_or_none()
        if not user:
            user = User(external_id=req.user_id)
            session.add(user)
            await session.flush()

        # ✅ Generate chatbot response using your HuggingFace model
        base_reply = get_bot_reply(req.query)
        full_reply = heuristic_enrich(req.query, base_reply) if 'heuristic_enrich' in globals() else base_reply

        # ✅ Save message to database
        msg = Message(
            user_id=user.id,
            query=req.query,
            reply=full_reply,
            intent="advice",
            record_hash=""
        )
        session.add(msg)
        await session.flush()

        # ✅ Generate record hash for blockchain logging
        canon = canonical_record(req.user_id, req.query, full_reply)
        record_hash = sha256_hex(canon)
        msg.record_hash = record_hash
        await session.flush()

        # ⚙️ Blockchain placeholders (for later integration)
        fabric_tx_id = None
        polygon_tx_hash = None

        '''try:
            fabric_tx_id = log_to_fabric(user_id=req.user_id, message_id=msg.id, record_hash=record_hash)
            msg.fabric_tx_id = fabric_tx_id
        except Exception as fe:
            print("⚠️ Fabric log failed:", fe)

        try:
            polygon_tx_hash = publish_hash_on_polygon(message_id=msg.id, record_hash="0x" + record_hash)
            msg.polygon_tx_hash = polygon_tx_hash
        except Exception as pe:
            print("⚠️ Polygon log failed:", pe)'''

        await session.commit()

        return ChatResponse(
            answer=full_reply,
            message_id=str(msg.id),
            fabric_tx_id=fabric_tx_id,
            polygon_tx_hash=polygon_tx_hash
        )

    except Exception as e:
        await session.rollback()
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

# ---------------------------------------------------------------------
# 🩺 Health Check
# ---------------------------------------------------------------------
@app.get("/health")
async def health_check():
    return {"status": "running", "chat_model": "HuggingFace LLM", "database": "connected"}

# ---------------------------------------------------------------------
# 🏠 Root Route
# ---------------------------------------------------------------------
@app.get("/")
async def root():
    return {"message": "Welcome to AgroAI Backend 🚜"}

# ---------------------------------------------------------------------
# 🔗 Include Routers
# ---------------------------------------------------------------------
app.include_router(audit.router, prefix="/audit", tags=["Audit"])
app.include_router(farmers.router, prefix="/farmers", tags=["Farmers"])

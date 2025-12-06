from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from db.session import get_session
from db.models import Message, User
from chatbot.utils import sha256_hex, canonical_record

router = APIRouter()

@router.get("/audit/{message_id}")
async def audit(message_id: str, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Message).where(Message.id == message_id))
    msg = result.scalar_one_or_none()
    if not msg:
        raise HTTPException(status_code=404, detail="Not found")

    user = await session.get(User, msg.user_id)

    canon = canonical_record(
        user_id=user.external_id,
        query=msg.query,
        reply=msg.reply
    )
    recomputed = sha256_hex(canon)

    return {
        "message_id": msg.id,
        "db_hash": msg.record_hash,
        "recomputed_hash": recomputed,
        "hash_matches": msg.record_hash == recomputed,
        "fabric_tx_id": msg.fabric_tx_id,
        "polygon_tx_hash": msg.polygon_tx_hash
    }

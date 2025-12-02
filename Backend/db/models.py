from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import String, Text, DateTime, ForeignKey
from datetime import datetime
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import declarative_base

import uuid

Base = declarative_base()

class Farmer(Base):
    __tablename__ = "farmers"

    farmer_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    location = Column(String(150))
    phone = Column(String(20), unique=True)

def uuid_str() -> str:
    return str(uuid.uuid4())

class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=uuid_str)
    external_id: Mapped[str] = mapped_column(String, unique=True, index=True)

class Message(Base):
    __tablename__ = "messages"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=uuid_str)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True)
    query: Mapped[str] = mapped_column(Text)
    reply: Mapped[str] = mapped_column(Text)
    intent: Mapped[str] = mapped_column(String, default="general")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # audit
    record_hash: Mapped[str] = mapped_column(String, index=True)
    fabric_tx_id: Mapped[str | None] = mapped_column(String, nullable=True)
    polygon_tx_hash: Mapped[str | None] = mapped_column(String, nullable=True)

    user: Mapped["User"] = relationship(backref="messages")

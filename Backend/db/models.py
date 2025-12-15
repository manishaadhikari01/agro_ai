import uuid
from datetime import datetime

from sqlalchemy import (
    Column,
    String,
    Text,
    DateTime,
    ForeignKey,
    Integer,
    Boolean,
)
from sqlalchemy.orm import (
    declarative_base,
    relationship,
    Mapped,
    mapped_column,
)

Base = declarative_base()


def uuid_str() -> str:
    return str(uuid.uuid4())


# ------------------ FARMER ------------------
class Farmer(Base):
    __tablename__ = "farmers"

    farmer_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    location = Column(String(150))
    phone = Column(String(20), unique=True)


# ------------------ USER ------------------
class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    # System identity
    external_id = Column(String, unique=True, index=True, default=lambda: str(uuid.uuid4()))

    # Auth
    phone = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=True)
    password_hash = Column(String, nullable=True)

    # Profile
    name = Column(String, nullable=False)
    farmer_type = Column(String, nullable=True)
    crops_grown = Column(String, nullable=True)

    # Location
    state = Column(String, nullable=False)
    district = Column(String, nullable=False)
    address = Column(String, nullable=True)

    # Verification
    phone_verified = Column(Boolean, default=False)


# ------------------ OTP ------------------
class OTPCode(Base):
    __tablename__ = "otp_codes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    phone = Column(String, index=True)
    otp_hash = Column(String)
    expires_at = Column(DateTime)


# ------------------ MESSAGE ------------------
class Message(Base):
    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=uuid_str
    )
    user_id: Mapped[str] = mapped_column(
        String, ForeignKey("users.id"), index=True
    )
    query: Mapped[str] = mapped_column(Text)
    reply: Mapped[str] = mapped_column(Text)
    intent: Mapped[str] = mapped_column(String, default="general")
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow
    )

    # audit
    record_hash: Mapped[str] = mapped_column(String, index=True)
    fabric_tx_id: Mapped[str | None] = mapped_column(String, nullable=True)
    polygon_tx_hash: Mapped[str | None] = mapped_column(String, nullable=True)

    user: Mapped["User"] = relationship(backref="messages")

# ------------------ REFRESH TOKEN ------------------
class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(String, primary_key=True, default=uuid_str)
    user_id = Column(String, ForeignKey("users.id"), index=True)
    token_hash = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    revoked = Column(Boolean, default=False)

    user = relationship("User", backref="refresh_tokens")
    
    
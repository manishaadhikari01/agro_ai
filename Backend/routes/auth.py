from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, update
from passlib.context import CryptContext
from datetime import datetime, timedelta
import random

from db.session import get_session
from db.models import User, OTPCode, RefreshToken
from auth.utils import (
    create_access_token,
    create_refresh_token,
    hash_token
)
from auth.jwt import get_current_user   # ✅ FIXED

router = APIRouter()

# ------------------ SECURITY ------------------
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ------------------ SCHEMAS ------------------

class LoginRequest(BaseModel):
    email: EmailStr | None = None
    phone: str | None = None
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RegisterRequest(BaseModel):
    name: str
    phone: str
    password: str
    confirm_password: str

    email: EmailStr | None = None
    state: str
    district: str
    address: str | None = None

    farmer_type: str | None = None
    crops_grown: list[str] | None = None


class LogoutRequest(BaseModel):
    refresh_token: str
    
class RefreshRequest(BaseModel):
    refresh_token: str


# ------------------ HELPERS ------------------

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


# ------------------ LOGIN ------------------

@router.post("/login", response_model=TokenResponse)
async def login(
    data: LoginRequest,
    session: AsyncSession = Depends(get_session)
):
    if not data.email and not data.phone:
        raise HTTPException(
            status_code=400,
            detail="Either email or phone number is required"
        )

    stmt = (
        select(User).where(User.email == data.email)
        if data.email
        else select(User).where(User.phone == data.phone)
    )

    result = await session.execute(stmt)
    user = result.scalar_one_or_none()

    if not user or not user.password_hash:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    access_token = create_access_token(user.id)
    refresh_token, expires = create_refresh_token(user.id)

    session.add(
        RefreshToken(
            user_id=user.id,
            token_hash=hash_token(refresh_token),
            expires_at=expires
        )
    )
    await session.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token
    )


# ------------------ REGISTER ------------------

@router.post("/register", response_model=TokenResponse)
async def register(
    data: RegisterRequest,
    session: AsyncSession = Depends(get_session)
):
    otp_check = await session.execute(
        select(OTPCode).where(OTPCode.phone == data.phone)
    )
    if otp_check.scalar_one_or_none():
        raise HTTPException(
            status_code=400,
            detail="Phone number not verified. Please verify OTP first."
        )

    if data.password != data.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    if (await session.execute(
        select(User).where(User.phone == data.phone)
    )).scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Phone already registered")

    if data.email:
        if (await session.execute(
            select(User).where(User.email == data.email)
        )).scalar_one_or_none():
            raise HTTPException(status_code=409, detail="Email already registered")

    user = User(
        name=data.name,
        phone=data.phone,
        email=data.email,
        password_hash=pwd_context.hash(data.password),
        state=data.state,
        district=data.district,
        address=data.address,
        farmer_type=data.farmer_type,
        crops_grown=",".join(data.crops_grown) if data.crops_grown else None,
        phone_verified=True
    )

    session.add(user)
    await session.commit()

    access_token = create_access_token(user.id)
    refresh_token, expires = create_refresh_token(user.id)

    session.add(
        RefreshToken(
            user_id=user.id,
            token_hash=hash_token(refresh_token),
            expires_at=expires
        )
    )
    await session.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token
    )


# ------------------ OTP ------------------

def generate_otp() -> str:
    return str(random.randint(100000, 999999))


class SendOTPRequest(BaseModel):
    phone: str


@router.post("/send-otp")
async def send_otp(
    data: SendOTPRequest,
    session: AsyncSession = Depends(get_session)
):
    otp = generate_otp()
    otp_hash = pwd_context.hash(otp)

    await session.execute(
        delete(OTPCode).where(OTPCode.phone == data.phone)
    )

    session.add(
        OTPCode(
            phone=data.phone,
            otp_hash=otp_hash,
            expires_at=datetime.utcnow() + timedelta(minutes=5)
        )
    )
    await session.commit()

    print(f"📲 OTP for {data.phone}: {otp}")
    return {"message": "OTP sent successfully"}


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str


@router.post("/verify-otp")
async def verify_otp(
    data: VerifyOTPRequest,
    session: AsyncSession = Depends(get_session)
):
    result = await session.execute(
        select(OTPCode).where(OTPCode.phone == data.phone)
    )
    otp_entry = result.scalar_one_or_none()

    if not otp_entry:
        raise HTTPException(status_code=400, detail="OTP not found")

    if datetime.utcnow() > otp_entry.expires_at:
        raise HTTPException(status_code=400, detail="OTP expired")

    if not pwd_context.verify(data.otp, otp_entry.otp_hash):
        raise HTTPException(status_code=400, detail="Invalid OTP")

    await session.delete(otp_entry)
    await session.commit()

    return {"message": "Phone number verified"}


# ------------------ LOGOUT ------------------

@router.post("/logout")
async def logout(
    payload: LogoutRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    hashed_token = hash_token(payload.refresh_token)

    result = await session.execute(
        select(RefreshToken).where(
            RefreshToken.user_id == current_user.id,
            RefreshToken.token_hash == hashed_token,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.utcnow()
        )
    )

    token = result.scalar_one_or_none()

    if not token:
        return {"message": "Already logged out"}

    token.revoked = True
    await session.commit()

    return {"message": "Logged out successfully"}


# ------------------ LOGOUT ALL ------------------

@router.post("/logout-all")
async def logout_all(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    await session.execute(
        update(RefreshToken)
        .where(
            RefreshToken.user_id == current_user.id,
            RefreshToken.revoked == False
        )
        .values(revoked=True)
    )

    await session.commit()

    return {"message": "Logged out from all devices"}

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    payload: RefreshRequest,
    session: AsyncSession = Depends(get_session)
):
    hashed = hash_token(payload.refresh_token)

    result = await session.execute(
        select(RefreshToken).where(
            RefreshToken.token_hash == hashed,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.utcnow()
        )
    )

    token_entry = result.scalar_one_or_none()

    if not token_entry:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired refresh token"
        )

    # 🔁 ROTATE refresh token (best practice)
    token_entry.revoked = True

    access_token = create_access_token(token_entry.user_id)
    new_refresh_token, expires = create_refresh_token(token_entry.user_id)

    session.add(
        RefreshToken(
            user_id=token_entry.user_id,
            token_hash=hash_token(new_refresh_token),
            expires_at=expires
        )
    )

    await session.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token
    )

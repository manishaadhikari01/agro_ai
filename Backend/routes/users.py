from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from passlib.context import CryptContext

from db.session import get_session
from db.models import User, RefreshToken
from auth.jwt import get_current_user

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ------------------ SCHEMAS ------------------

class UserProfileResponse(BaseModel):
    id: str
    name: str
    phone: str
    email: EmailStr | None = None

    state: str
    district: str
    address: str | None = None

    farmer_type: str | None = None
    crops_grown: list[str] | None = None

    phone_verified: bool


class UserProfileUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None

    state: str | None = None
    district: str | None = None
    address: str | None = None

    farmer_type: str | None = None
    crops_grown: list[str] | None = None

# ------------------ CHANGE PASSWORD SCHEMA ------------------    
class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str
    confirm_new_password: str


# ------------------ GET PROFILE ------------------

@router.get("/me", response_model=UserProfileResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user)
):
    return UserProfileResponse(
        id=current_user.id,
        name=current_user.name,
        phone=current_user.phone,
        email=current_user.email,
        state=current_user.state,
        district=current_user.district,
        address=current_user.address,
        farmer_type=current_user.farmer_type,
        crops_grown=(
            current_user.crops_grown.split(",")
            if current_user.crops_grown
            else None
        ),
        phone_verified=current_user.phone_verified
    )


# ------------------ UPDATE PROFILE ------------------

@router.put("/me", response_model=UserProfileResponse)
async def update_my_profile(
    data: UserProfileUpdate,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    updates = data.dict(exclude_unset=True)

    # 🔐 Email uniqueness check
    if "email" in updates and updates["email"] is not None:
        result = await session.execute(
            select(User).where(
                User.email == updates["email"],
                User.id != current_user.id
            )
        )
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=409,
                detail="Email already in use"
            )

    # Apply updates
    for field, value in updates.items():
        if field == "crops_grown" and value is not None:
            setattr(current_user, field, ",".join(value))
        else:
            setattr(current_user, field, value)

    await session.commit()
    await session.refresh(current_user)

    return UserProfileResponse(
        id=current_user.id,
        name=current_user.name,
        phone=current_user.phone,
        email=current_user.email,
        state=current_user.state,
        district=current_user.district,
        address=current_user.address,
        farmer_type=current_user.farmer_type,
        crops_grown=(
            current_user.crops_grown.split(",")
            if current_user.crops_grown
            else None
        ),
        phone_verified=current_user.phone_verified
    )

# ------------------ CHANGE PASSWORD ------------------
@router.post("/change-password")
async def change_password(
    data: ChangePasswordRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # 1️⃣ Verify current password
    if not pwd_context.verify(data.current_password, current_user.password_hash):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect"
        )

    # 2️⃣ Validate new password
    if data.new_password != data.confirm_new_password:
        raise HTTPException(
            status_code=400,
            detail="New passwords do not match"
        )

    if data.new_password == data.current_password:
        raise HTTPException(
            status_code=400,
            detail="New password must be different from current password"
        )

    # 3️⃣ Update password
    current_user.password_hash = pwd_context.hash(data.new_password)

    # 4️⃣ Revoke all refresh tokens (logout from all devices)
    await session.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == current_user.id)
        .values(revoked=True)
    )

    await session.commit()

    return {"message": "Password changed successfully. Please log in again."}

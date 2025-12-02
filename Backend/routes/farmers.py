from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from db.models import Farmer
from db.session import get_session

router = APIRouter()

@router.get("/farmers")
async def get_farmers(session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Farmer))
    farmers = result.scalars().all()
    return farmers

@router.post("/farmers")
async def create_farmer(name: str, location: str, phone: str, session: AsyncSession = Depends(get_session)):
    farmer = Farmer(name=name, location=location, phone=phone)
    session.add(farmer)
    await session.commit()
    await session.refresh(farmer)
    return farmer

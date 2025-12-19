from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

import os
import httpx
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime


from db.session import get_session
from db.models import Field
from auth.jwt import get_current_user

router = APIRouter(prefix="/fields", tags=["Fields"])

#------------------ SCHEMAS ------------------
class FieldCreateRequest(BaseModel):
    field_name: str
    coordinates: List[List[float]]  # [[lon, lat], ...]
    crop_type: Optional[str] = None
    season: Optional[str] = None
    
AGRO_API_KEY = os.getenv("AGROMONITORING_API_KEY")
AGRO_BASE_URL = "https://api.agromonitoring.com/agro/1.0"

#------------------ HELPERS ------------------
def interpret_ndvi(ndvi: float | None):
    if ndvi is None:
        return {
            "status": "Pending",
            "badge": "⏳",
            "message": "Satellite data not available yet",
        }

    if ndvi >= 0.65:
        return {
            "status": "Healthy",
            "badge": "🟢",
            "message": "Crop growth is healthy with good vegetation cover",
        }
    elif ndvi >= 0.45:
        return {
            "status": "Moderate",
            "badge": "🟡",
            "message": "Mild vegetation stress detected. Monitor irrigation",
        }
    elif ndvi >= 0.25:
        return {
            "status": "Poor",
            "badge": "🟠",
            "message": "High vegetation stress detected. Action recommended",
        }
    else:
        return {
            "status": "Critical",
            "badge": "🔴",
            "message": "Critical crop stress detected. Immediate attention required",
        }
 
 #------------------ FETCH NDVI DATA ------------------       
async def fetch_latest_ndvi(polygon_id: str):
    url = (
        f"{AGRO_BASE_URL}/ndvi/history"
        f"?polyid={polygon_id}&appid={AGRO_API_KEY}"
    )

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.get(url)

    if response.status_code != 200:
        return None, None

    data = response.json()
    if not data:
        return None, None

    latest = data[0]
    ndvi = latest.get("mean")
    timestamp = latest.get("dt")

    last_updated = (
        datetime.utcfromtimestamp(timestamp).strftime("%Y-%m-%d")
        if timestamp
        else None
    )

    return ndvi, last_updated

#------------------ CREATE POLYGON IN AGROMONITORING ------------------
async def create_polygon_in_agromonitoring(field_name: str, coordinates: list):
    url = f"{AGRO_BASE_URL}/polygons?appid={AGRO_API_KEY}"

    payload = {
        "name": field_name,
        "geo_json": {
            "type": "Feature",
            "properties": {},
            "geometry": {
                "type": "Polygon",
                "coordinates": [coordinates],
            },
        },
    }

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(url, json=payload)

    if response.status_code not in (200, 201):
        raise HTTPException(
            status_code=400,
            detail=f"AgroMonitoring error: {response.text}",
        )

    return response.json()

@router.post("")
async def create_field(
    payload: FieldCreateRequest,
    db: AsyncSession = Depends(get_session),
    current_user=Depends(get_current_user),
):
    # 1️⃣ Validate & close polygon
    coords = payload.coordinates
    if len(coords) < 3:
        raise HTTPException(status_code=400, detail="Invalid polygon")

    if coords[0] != coords[-1]:
        coords.append(coords[0])

    # 2️⃣ Create polygon in AgroMonitoring
    agro_data = await create_polygon_in_agromonitoring(
        field_name=payload.field_name,
        coordinates=coords,
    )

    # 3️⃣ Save field in DB
    field = Field(
        user_id=current_user.id,
        field_name=payload.field_name,
        polygon_id=agro_data["id"],
        area_hectare=agro_data.get("area"),
        center_lat=str(agro_data["center"][1]),
        center_lon=str(agro_data["center"][0]),
        crop_type=payload.crop_type,
        season=payload.season,
    )

    db.add(field)
    await db.commit()
    await db.refresh(field)

    # 4️⃣ Return success
    return {
        "message": "Field created successfully",
        "field_id": field.id,
        "polygon_id": field.polygon_id,
        "area_hectare": field.area_hectare,
    }
    
@router.get("")
async def get_fields(
    db: AsyncSession = Depends(get_session),
    current_user=Depends(get_current_user),
):
    # 1️⃣ Fetch user fields
    result = await db.execute(
        select(Field).where(
            Field.user_id == current_user.id,
            Field.is_active == True,
        )
    )
    fields = result.scalars().all()

    response = []

    # 2️⃣ Attach health data per field
    for field in fields:
        ndvi, last_updated = await fetch_latest_ndvi(field.polygon_id)

        health = interpret_ndvi(ndvi)
        health["ndvi"] = ndvi
        health["last_updated"] = last_updated

        response.append(
            {
                "field_id": field.id,
                "field_name": field.field_name,
                "crop_type": field.crop_type,
                "area_hectare": field.area_hectare,
                "health": health,
            }
        )

    return response
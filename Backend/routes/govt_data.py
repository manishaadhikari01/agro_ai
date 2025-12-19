# routes/govt_data.py

from fastapi import APIRouter, Depends, HTTPException
import requests, os

from auth.jwt import get_current_user
from db.models import User
from pydantic import BaseModel
from typing import List

class LiveMandiRequest(BaseModel):
    crops: List[str]
    limit_mandis: int = 5

router = APIRouter()

DATA_GOV_BASE_URL = "https://api.data.gov.in/resource"
DATA_GOV_API_KEY = os.getenv("DATA_GOV_API_KEY")

if not DATA_GOV_API_KEY:
    raise RuntimeError("DATA_GOV_API_KEY missing from environment")

SCHEME_RESOURCE_ID = "47a0970a-9fef-427d-8cdd-767085fda87b"
MANDI_RESOURCE_ID  = "9ef84268-d588-465a-a308-a864a43d0070"

# ------------------ GOVT SCHEMES ------------------

@router.get("/schemes")
async def get_govt_schemes(
    state: str | None = None,
    scheme: str | None = None,
    limit: int = 20,
    current_user: User = Depends(get_current_user)
):
    params = {
        "api-key": DATA_GOV_API_KEY,
        "format": "json",
        "limit": limit
    }

    if state:
        params["filters[state]"] = state

    if scheme:
        params["filters[scheme_name]"] = scheme

    url = f"{DATA_GOV_BASE_URL}/{SCHEME_RESOURCE_ID}"

    response = requests.get(url, params=params, timeout=10)

    if response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail="Failed to fetch government schemes"
        )

    return response.json()

# ------------------ MANDI PRICES ----------------
@router.post("/live-mandi")
async def live_mandi_prices(
    payload: LiveMandiRequest,
    current_user: User = Depends(get_current_user)
):
    results = []

    for crop in payload.crops:
        params = {
            "api-key": DATA_GOV_API_KEY,
            "format": "json",
            "filters[commodity]": crop,
            "filters[state]": current_user.state,
            "limit": 50
        }

        url = f"{DATA_GOV_BASE_URL}/{MANDI_RESOURCE_ID}"
        response = requests.get(url, params=params)

        if response.status_code != 200:
            continue

        records = response.json().get("records", [])

        # Prefer nearby mandis (same district)
        nearby = [
            r for r in records
            if r.get("district") == current_user.district
        ]

        # Fallback: any mandi in state
        if not nearby:
            nearby = records

        # Sort by modal price (best selling price)
        nearby.sort(
            key=lambda x: float(x.get("modal_price", 0)),
            reverse=True
        )

        top_mandis = nearby[:payload.limit_mandis]

        results.append({
            "crop": crop,
            "mandis": top_mandis
        })

    return {
        "state": current_user.state,
        "district": current_user.district,
        "data": results
    }

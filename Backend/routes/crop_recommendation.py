from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

from ml_models.crop_recommendation.engine import CropRecommendationEngine

router = APIRouter(
    prefix="/ml/crop-recommendation",
    tags=["ML | Crop Recommendation"]
)

engine = CropRecommendationEngine()

class CropRequest(BaseModel):
    district: str
    season: str
    soil_type: str
    altitude_zone: str
    irrigation: str
    top_k: Optional[int] = 3

@router.post("/predict")
def recommend_crop(req: CropRequest):
    return engine.recommend(req.dict())

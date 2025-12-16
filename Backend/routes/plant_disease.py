from fastapi import APIRouter, UploadFile, File
from pathlib import Path
import shutil
import uuid

from ml_models.plant_disease.predictor import predict

router = APIRouter(
    prefix="/ml/plant-disease",
    tags=["ML | Plant Disease"]
)

# Temp folder for uploaded images
UPLOAD_DIR = Path("temp_uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


CONFIDENCE_THRESHOLD = 0.4  # ← you can tune this


@router.post("/predict")
async def predict_plant_disease(file: UploadFile = File(...)):
    # Save uploaded image temporarily
    file_suffix = Path(file.filename).suffix
    temp_filename = f"{uuid.uuid4()}{file_suffix}"
    temp_path = UPLOAD_DIR / temp_filename

    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run prediction
    result = predict(str(temp_path))

    # Clean up temp file
    temp_path.unlink(missing_ok=True)

     # 🔑 Confidence handling (HERE)
    if result["confidence"] < CONFIDENCE_THRESHOLD:
        result["note"] = (
            "Low confidence prediction. "
            "Please upload a clearer image or inspect manually."
        )

    return result

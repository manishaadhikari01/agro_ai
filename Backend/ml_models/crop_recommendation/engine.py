"""
hybrid_inference_api.py

Usage:
  1) Put this file in the same project folder as:
       - crop_model.pkl
       - UTTARAKHAND_SOIL_CLIMATE_ADVANCED.csv
  2) Install requirements if needed:
       pip install fastapi uvicorn pandas scikit-learn joblib
  3) Run:
       uvicorn hybrid_inference_api:app --reload
  4) Open Swagger UI: http://127.0.0.1:8000/docs
"""
#from fastapi import FastAPI
#from pydantic import BaseModel
from typing import Optional, List, Tuple, Dict, Any
import pandas as pd
import numpy as np
import joblib
import os
from pathlib import Path

# ----------------- CONFIG -----------------
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "crop_model.pkl"
MAP_CSV = BASE_DIR / "uttarakhand_mapping.csv"
TOP_K_DEFAULT = 3

# These are the feature names your model expects.
# Adjust if your training used different names/order.
MODEL_FEATURES = ["N", "P", "K", "SOIL_PH", "TEMP", "RELATIVE_HUMIDITY"]

# ----------------- LOAD MODEL -----------------
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found at {MODEL_PATH}. Train and save model first.")

model = joblib.load(MODEL_PATH)
# model.classes_ should be string crop names (you said Label encoding not used)

# ----------------- LOAD MAPPING CSV -----------------
if not os.path.exists(MAP_CSV):
    raise FileNotFoundError(f"Mapping CSV not found at {MAP_CSV}. Place Uttarakhand CSV there.")

uk_df = pd.read_csv(MAP_CSV)
# normalize column names to lowercase for robust access
uk_df.columns = [c.strip() for c in uk_df.columns]
col_map = {c.lower(): c for c in uk_df.columns}  # map lowercase -> original

# required mapping columns expected in CSV (case-insensitive)
required_cols = ["district", "season", "soil_type", "altitude_zone",
                 "est_n", "est_p", "est_k", "est_ph", "temperature", "humidity", "rainfall"]
for rc in required_cols:
    if rc not in [c.lower() for c in uk_df.columns]:
        raise ValueError(f"Mapping CSV is missing required column (case-insensitive): {rc}")

# helper to access original column name by lowercase
def col(name: str) -> str:
    return col_map[name.lower()]

# ----------------- RULE-BASED FILTER -----------------
def rule_based_filter(predicted: List[Tuple[str, float]],
                      season: str,
                      soil_type: str,
                      altitude_zone: str,
                      irrigation: str) -> List[Dict[str, Any]]:
    """
    Keeps only crops that are sensible for Uttarakhand constraints.
    predicted: list[(crop_name, prob)] sorted desc
    Returns list of dicts {'crop','score','reasons'}
    """
    season = season.strip().lower()
    soil_type = soil_type.strip().lower()
    altitude_zone = altitude_zone.strip().lower()
    irrigation = irrigation.strip().lower()

    altitude_restrictions = {
        'high-hills': ['sugarcane', 'paddy', 'maize'],
        'mid-hills': ['sugarcane', 'paddy'],
        'terai': []
    }
    season_crops = {
        'kharif': ['paddy','maize','millets','pulses','soybean','groundnut','sorghum'],
        'rabi': ['wheat','barley','mustard','chickpea','lentil','potato','vegetables'],
        'zaid': ['watermelon','cucumber','vegetables','muskmelon','fodder crops','cucurbits']
    }
    soil_crops = {
        'loamy': None,
        'clay': ['rice','maize','sugarcane'],
        'silty': ['wheat','vegetables','horticulture'],
        'sandy': ['millets','potato','fodder crops','groundnut']
    }
    irrigation_restrictions = {
        'rainfed': ['paddy','sugarcane'],
        'canal': [],
        'tube well': [],
        'tubewell': []
    }

    final = []
    for crop, prob in predicted:
        crop_l = str(crop).strip().lower()
        reasons = []
        # altitude
        if any([crop_l == x for x in altitude_restrictions.get(altitude_zone, [])]):
            reasons.append(f"Not suitable for altitude zone '{altitude_zone}'")
            continue
        # season
        allowed = season_crops.get(season, None)
        if allowed is not None and crop_l not in allowed:
            reasons.append(f"Not typical for season '{season}'")
            continue
        # soil
        allowed_soil = soil_crops.get(soil_type, None)
        if allowed_soil is not None and crop_l not in allowed_soil:
            reasons.append(f"Not preferred for soil '{soil_type}'")
            continue
        # irrigation
        if crop_l in irrigation_restrictions.get(irrigation, []):
            reasons.append(f"Requires more irrigation than available ('{irrigation}')")
            continue
        # passed
        reasons.append(f"Matches season '{season}', soil '{soil_type}' and altitude '{altitude_zone}'")
        final.append({"crop": crop, "score": float(prob), "reasons": reasons})
    return final

# ----------------- MAPPING / FEATURE BUILDING -----------------
def find_mapping_row(district: str, season: str, soil_type: str, altitude_zone: str) -> pd.Series:
    """
    Try to find the best match row in uk_df. Fall back progressively.
    Returns a pandas Series (row).
    """
    d = district.strip().lower()
    s = season.strip().lower()
    so = soil_type.strip().lower()
    a = altitude_zone.strip().lower()

    df = uk_df.copy()
    # Normalize lookup columns for matching
    df['_district_l'] = df[col('district')].astype(str).str.strip().str.lower()
    df['_season_l'] = df[col('season')].astype(str).str.strip().str.lower()
    df['_soil_l'] = df[col('soil_type')].astype(str).str.strip().str.lower()
    df['_alt_l'] = df[col('altitude_zone')].astype(str).str.strip().str.lower()

    # 1) exact match
    cond = (df['_district_l'] == d) & (df['_season_l'] == s) & (df['_soil_l'] == so) & (df['_alt_l'] == a)
    if cond.any():
        return df.loc[cond].iloc[0]

    # 2) relax altitude
    cond = (df['_district_l'] == d) & (df['_season_l'] == s) & (df['_soil_l'] == so)
    if cond.any():
        return df.loc[cond].iloc[0]

    # 3) relax soil_type
    cond = (df['_district_l'] == d) & (df['_season_l'] == s)
    if cond.any():
        return df.loc[cond].iloc[0]

    # 4) district-level fallback
    cond = (df['_district_l'] == d)
    if cond.any():
        return df.loc[cond].iloc[0]

    # 5) global fallback: mean numeric values
    numeric_cols = [c for c in df.columns if np.issubdtype(df[c].dtype, np.number)]
    if len(numeric_cols) == 0:
        raise ValueError("Mapping table has no numeric columns to fallback on.")
    avg = df[numeric_cols].mean()
    # construct a series with avg values and minimal metadata
    srs = pd.Series({col('district'): district, col('season'): season, col('soil_type'): soil_type, col('altitude_zone'): altitude_zone})
    for n in numeric_cols:
        srs[n] = avg[n]
    return srs

def build_feature_vector_from_row(row: pd.Series) -> List[float]:
    """
    Build model feature vector in the order MODEL_FEATURES from a mapping row.
    Tries to map model feature names to CSV columns.
    """
    # mapping from model feature name -> candidate column names in uk_df
    mapping_candidates = {
        "N": ['est_n','n','est_N'],
        "P": ['est_p','p','est_P'],
        "K": ['est_k','k','est_K'],
        "SOIL_PH": ['est_ph','est_pH','soil_ph','est_pH'],
        "TEMP": ['temperature','temp','ave_temp','avg_temperature'],
        "RELATIVE_HUMIDITY": ['humidity','relative_humidity','avg_humidity']
    }

    vec = []
    for feat in MODEL_FEATURES:
        found = False
        for cand in mapping_candidates.get(feat, [feat.lower()]):
            # compare case-insensitive to actual columns
            for c in uk_df.columns:
                if c.strip().lower() == cand.strip().lower():
                    val = row[c] if c in row.index else row.get(c, None)
                    if val is None or (isinstance(val, float) and np.isnan(val)):
                        continue
                    vec.append(float(val))
                    found = True
                    break
            if found:
                break
        if not found:
            # fallback: use mean of first numeric column
            numeric_cols = [c for c in uk_df.columns if np.issubdtype(uk_df[c].dtype, np.number)]
            if numeric_cols:
                vec.append(float(uk_df[numeric_cols[0]].mean()))
            else:
                vec.append(0.0)
    return vec

# ----------------- PREDICTION PIPELINE -----------------
def predict_topk_from_inputs(district: str, season: str, soil_type: str,
                             altitude_zone: str, irrigation: str,
                             top_k: int = TOP_K_DEFAULT) -> Dict[str, Any]:
    """
    Returns JSON-serializable dict with top-k recommendations.
    """
    # find mapping row
    row = find_mapping_row(district, season, soil_type, altitude_zone)
    # build features
    feat_vec = build_feature_vector_from_row(row)
    X = np.array(feat_vec).reshape(1, -1)

    # predict probabilities
    if hasattr(model, "predict_proba"):
        probs = model.predict_proba(X)[0]  # assuming shape [n_classes]
        classes = list(model.classes_)     # crop names as strings
    else:
        # fallback: model doesn't support predict_proba
        pred = model.predict(X)[0]
        return {"final_recommendations": [{"crop": pred, "score": 1.0, "reasons": ["Predicted by model (no proba)"]}]}

    # pair and take top-K
    paired = list(zip(classes, probs))
    paired_sorted = sorted(paired, key=lambda x: x[1], reverse=True)[:max(top_k, TOP_K_DEFAULT)]

    # apply rule-based filter
    filtered = rule_based_filter(paired_sorted, season, soil_type, altitude_zone, irrigation)

    # If fewer than top_k passed the rule filter → fill remaining from model top_k
    if len(filtered) < top_k:
        needed = top_k - len(filtered)
        for c, p in paired_sorted:
            if c not in [x["crop"] for x in filtered]:
                filtered.append({
                    "crop": c,
                    "score": float(p),
                    "reasons": ["Model-recommended (not fully matched to Uttarakhand rules)"]
                })
            if len(filtered) == top_k:
                break
        
    return {
    "mapping_row": row.to_dict() if isinstance(row, pd.Series) else {},
    "final_recommendations": filtered
}

def enrich_crop_recommendation(crop_name: str, score: float) -> Dict[str, str]:
    crop = crop_name.strip().lower()

    # ---- Emojis based on crop ----
    emoji_map = {
        "rice": "🌾",
        "wheat": "🌾",
        "maize": "🌽",
        "corn": "🌽",
        "millets": "🌱",
        "sorghum": "🌱",
        "soybean": "🫘",
        "pulses": "🫘",
        "chickpea": "🧆",
        "lentil": "🧆",
        "potato": "🥔",
        "vegetables": "🥕",
        "mustard": "🌼",
        "groundnut": "🥜",
        "sugarcane": "🍬",
        "watermelon": "🍉",
        "cucumber": "🥒"
    }
    emoji = emoji_map.get(crop, "🌱")

    # ---- Fertilizer suggestions ----
    fertilizer_map = {
        "rice": "Apply N-rich fertilizer early; keep moderate P, K.",
        "wheat": "Use balanced NPK; apply nitrogen during tillering.",
        "maize": "High N requirement; apply urea in split doses.",
        "millets": "Minimal fertilizer; small N application boosts yield.",
        "soybean": "Low N need; use P and K base fertilizer.",
        "groundnut": "Apply gypsum + P; minimal nitrogen needed.",
        "potato": "High K and nitrogen demand for tuber growth.",
        "vegetables": "Use compost + balanced NPK for faster growth.",
        "mustard": "Requires sulfur + moderate nitrogen.",
        "sugarcane": "High N requirement; apply compost for soil health.",
        "watermelon": "Use N early, K during fruiting.",
        "cucumber": "Use balanced NPK; ensure micronutrients."
    }
    fertilizer = fertilizer_map.get(crop, "Use balanced NPK based on soil test.")

    # ---- Irrigation advice ----
    irrigation_map = {
        "rice": "Requires standing water; irrigate frequently.",
        "wheat": "Irrigate 4–5 times at critical stages.",
        "maize": "Needs good moisture; irrigate every 7–10 days.",
        "millets": "Grows well with low irrigation.",
        "soybean": "Light irrigation during flowering.",
        "groundnut": "Keep soil moist; avoid waterlogging.",
        "potato": "Regular irrigation needed for tuber expansion.",
        "vegetables": "Requires frequent, light irrigation.",
        "mustard": "Minimal irrigation; 2–3 times is enough.",
        "sugarcane": "Heavy irrigation needed throughout growing season.",
        "watermelon": "Moderate irrigation; reduce near harvesting.",
        "cucumber": "Light, frequent irrigation needed."
    }
    irrigation = irrigation_map.get(crop, "Use moderate irrigation depending on soil moisture.")

    return {
        "emoji": emoji,
        "fertilizer": fertilizer,
        "irrigation": irrigation
    }

# ----------------- Engine Class -----------------

class CropRecommendationEngine:
    def __init__(self):
        self.model = model

    def recommend(self, data: dict) -> Dict[str, Any]:
        row = find_mapping_row(
            data["district"],
            data["season"],
            data["soil_type"],
            data["altitude_zone"]
        )

        X = np.array(build_feature_vector_from_row(row)).reshape(1, -1)

        probs = self.model.predict_proba(X)[0]
        classes = self.model.classes_

        paired = sorted(
            zip(classes, probs),
            key=lambda x: x[1],
            reverse=True
        )

        filtered = rule_based_filter(
            paired,
            data["season"],
            data["soil_type"],
            data["altitude_zone"],
            data["irrigation"]
        )


        final_output = []

        for rec in filtered[: data.get("top_k", 3)]:
            extra = enrich_crop_recommendation(rec["crop"], rec["score"])

            final_output.append({
                "crop": rec["crop"],
                "score": rec["score"],
                "reasons": rec["reasons"],
                "emoji": extra["emoji"],
                "fertilizer": extra["fertilizer"],
                "irrigation": extra["irrigation"]
            })

        return {
            "final_recommendations": final_output
        }




"""# ----------------- Quick CLI test -----------------
if __name__ == "__main__":
    # quick demo
        demo = predict_topk_from_inputs("Dehradun", "Kharif", "Loamy", "Mid-Hills", "rainfed", top_k=3)
for rec in demo["final_recommendations"]:
        extra = enrich_crop_recommendation(rec["crop"], rec["score"])
        rec.update(extra)

import json 
print(json.dumps(demo, indent=2, ensure_ascii=False)) 
print("Run server: uvicorn hybrid_inference_TEST_api:app --reload")"""
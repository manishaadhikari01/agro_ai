final_remedy_dict = {

    # ---------------------------------------------
    # 1. GENERIC HEALTHY CLASSES
    # ---------------------------------------------
    "healthy": "The plant is healthy. Ensure proper watering, sunlight, and nutrient management.",

    # Crop-specific healthy labels (PlantVillage / PlantDoc)
    "Apple___healthy": "Healthy plant. Maintain proper pruning, irrigation and nitrogen balance.",
    "Blueberry___healthy": "Healthy plant. Maintain acidic soil pH (~5.0), good drainage and mulching.",
    "Cherry_(including_sour)___healthy": "Healthy plant. Keep soil moist and prune regularly.",
    "Corn_(maize)___healthy": "Healthy maize. Ensure spacing, weed control, and nitrogen supply.",
    "Grape___healthy": "Healthy vines. Maintain pruning and disease-preventive sprays.",
    "Orange___healthy": "Healthy citrus. Maintain micronutrient spray and protect from psyllids.",
    "Peach___healthy": "Healthy tree. Prune annually and avoid overhead watering.",
    "Pepper,_bell___healthy": "Healthy plant. Maintain warm conditions and avoid overwatering.",
    "Potato___healthy": "Healthy plant. Use certified seeds and avoid waterlogging.",
    "Raspberry___healthy": "Healthy plant. Maintain weed-free rows and proper trellising.",
    "Soybean___healthy": "Healthy crop. Maintain row spacing and prevent aphid colonization.",
    "Squash___healthy": "Healthy plant. Mulch around roots and avoid wetting leaves.",
    "Strawberry___healthy": "Healthy plant. Keep leaves dry, remove runners, and mulch.",
    "Tomato___healthy": "Healthy tomato. Maintain staking, pruning and regular fertilizing.",

    # ---------------------------------------------
    # 2. PLANT DISEASE REMEDIES (PlantVillage + PlantDoc)
    # ---------------------------------------------
    "Apple___Apple_scab": "Remove infected leaves. Apply fungicides like Captan or Mancozeb early season.",
    "Apple___Black_rot": "Remove mummified fruits. Prune cankers and apply copper fungicide.",
    "Apple___Cedar_apple_rust": "Remove nearby juniper hosts. Apply sulfur fungicides monthly.",
    
    "Cherry_(including_sour)___Powdery_mildew": "Apply sulfur-based fungicides and improve airflow.",

    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot": "Use resistant cultivars. Spray strobilurin/triazole fungicides.",
    "Corn_(maize)___Common_rust_": "Apply fungicides at VT–R1 stage when rust first appears.",
    "Corn_(maize)___Northern_Leaf_Blight": "Use crop rotation and apply mancozeb or propiconazole fungicide.",

    "Grape___Black_rot": "Remove infected fruit clusters. Apply myclobutanil fungicide.",
    "Grape___Esca_(Black_Measles)": "Avoid pruning during wet conditions; remove infected wood.",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": "Apply copper fungicide and ensure vineyard ventilation.",

    "Orange___Haunglongbing_(Citrus_greening)": "Remove infected trees. Control psyllid insects and provide micronutrients.",

    "Peach___Bacterial_spot": "Spray copper-based bactericides. Avoid overhead irrigation.",

    "Pepper,_bell___Bacterial_spot": "Apply copper sprays and use pathogen-free seeds.",

    "Potato___Early_blight": "Remove infected leaves. Apply chlorothalonil at early stages.",
    "Potato___Late_blight": "Apply systemic fungicides immediately. Destroy infected plants.",

    "Squash___Powdery_mildew": "Apply neem oil or sulfur spray. Improve field ventilation.",

    "Strawberry___Leaf_scorch": "Remove infected leaves and apply fungicidal sprays.",

    "Tomato___Bacterial_spot": "Apply copper fungicides. Remove diseased leaves.",
    "Tomato___Early_blight": "Prune heavily and apply chlorothalonil every 10–14 days.",
    "Tomato___Late_blight": "Immediate fungicide application; remove infected plants.",
    "Tomato___Leaf_Mold": "Increase ventilation and use sulfur spray.",
    "Tomato___Septoria_leaf_spot": "Remove bottom leaves and apply protectant fungicides.",
    "Tomato___Spider_mites Two-spotted_spider_mite": "Apply neem oil or miticides.",
    "Tomato___Target_Spot": "Use resistant varieties and apply preventive fungicides.",
    "Tomato___Yellow_Leaf_Curl_Virus": "Control whiteflies and remove infected plants.",
    "Tomato___mosaic_virus": "Remove infected plants. Sterilize tools and avoid tobacco exposure.",

    # ---------------------------------------------
    # 3. PEST24 PEST REMEDIES (generalized)
    # ---------------------------------------------
    # These follow generic naming like: "pestname", "pest category", or mapped class names.

    "Aphid": "Use neem oil, insecticidal soap, or release ladybugs to reduce aphid populations.",
    "Whitefly": "Apply yellow sticky traps, neem oil, and introduce parasitic wasps.",
    "Thrips": "Use blue sticky traps, neem oil, and avoid excessive nitrogen.",
    "Leafhopper": "Use systemic insecticides and weed management to break breeding cycles.",
    "Armyworm": "Handpick larvae, apply BT (Bacillus thuringiensis), or light traps.",
    "Cutworm": "Use pheromone traps, apply soil insecticides, and remove plant debris.",
    "Stem_borer": "Use pheromone traps, destroy infected stems, apply systemic insecticides.",
    "Fruit_fly": "Use protein bait traps and remove infested fruits.",
    "Weevil": "Use pheromone traps, clean crop residues, and apply soil insecticide.",
    "Grasshopper": "Use biological insecticides (Metarhizium), and remove weeds.",
    "Spider_mite": "Spray neem oil, keep humidity high, and apply miticides.",
    "Leafminer": "Remove mined leaves. Use neem oil or abamectin spray.",
    "Mealybug": "Use cotton swabs dipped in alcohol or neem oil spray.",
    "Caterpillar": "Handpick larvae, apply BT toxin-based sprays.",
    "Moth": "Use pheromone traps and nighttime light traps.",

    # If Pest24 has class names like 'pest0001', etc.
    "unknown_pest": "Apply neem oil, insecticidal soap, and maintain field hygiene.",

    # ---------------------------------------------
    # 4. FALLBACK REMEDY
    # ---------------------------------------------
    "_default": "Inspect plant manually. Use neem oil for pests or copper fungicide for fungal infections."
}

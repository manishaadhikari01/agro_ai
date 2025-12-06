import os
import torch
from transformers import pipeline, AutoModelForCausalLM, AutoTokenizer
from huggingface_hub import InferenceClient

# ===============================================================
# 🤖 Hugging Face Conversational Agent for Agro Chatbot
# Supports both online (Inference API) and offline (local model)
# ===============================================================

# Load environment variables (optional)
HF_TOKEN = os.getenv("hf_MpBMQtsEkCOsyUoCJOxzeMfUKSSrXHpQnyKEN", None)
USE_OFFLINE = os.getenv("USE_OFFLINE", "true").lower() == "true"

# ------------------------------
# 🌐 ONLINE MODE (Hugging Face Inference API)
# ------------------------------
def use_online_model():
    """
    Uses Hugging Face Inference API (hosted model) for responses.
    Best for when internet is available.
    """
    try:
        model_id = "tiiuae/falcon-7b-instruct"  # You can switch to LLaMA, Falcon, etc.
        client = InferenceClient(model=model_id, token=HF_TOKEN)

        async def online_reply(prompt: str) -> str:
            response = client.text_generation(
                prompt,
                max_new_tokens=200,
                temperature=0.6,
                repetition_penalty=1.2
            )
            return response.strip()

        return online_reply

    except Exception as e:
        print("⚠️ Online HF model failed, switching to offline:", e)
        return use_offline_model()

# ------------------------------
# 💻 OFFLINE MODE (Local Transformers Pipeline)
# ------------------------------
def use_offline_model():
    """
    Uses a locally downloaded model for offline responses.
    Great for rural/no-internet deployments.
    """
    model_name = "facebook/blenderbot-400M-distill"  # lightweight conversational model

    print(f"🔁 Loading offline model: {model_name} ...")
    try:
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        model = AutoModelForCausalLM.from_pretrained(model_name)
        pipe = pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            device=0 if torch.cuda.is_available() else -1
        )

        async def offline_reply(prompt: str) -> str:
            result = pipe(prompt, max_new_tokens=150, temperature=0.7, do_sample=True)
            return result[0]["generated_text"].strip()

        print("✅ Offline model loaded successfully")
        return offline_reply

    except Exception as e:
        print("❌ Failed to load offline model:", e)

        async def fallback(prompt: str) -> str:
            return "Sorry, I’m having trouble processing that query right now."

        return fallback

# ------------------------------
# 🔄 Model Selection Logic
# ------------------------------
if USE_OFFLINE or not HF_TOKEN:
    get_hf_response = use_offline_model()
else:
    get_hf_response = use_online_model()

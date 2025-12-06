"""
Utility helper functions for the chatbot agent.
"""
import json
import hashlib

def canonical_record(user_id: str, query: str, reply: str) -> bytes:
    """
    Create a canonical JSON byte representation of a chat record
    """
    payload = json.dumps(
        {"user_id": user_id, "query": query, "reply": reply},
        ensure_ascii=False, separators=(",", ":"), sort_keys=True
    )
    return payload.encode("utf-8")

def sha256_hex(data: bytes) -> str:
    """
    Return SHA256 hex digest of given bytes
    """
    return hashlib.sha256(data).hexdigest()


from datetime import datetime


def format_chat_history(history: list) -> str:
    """
    Convert a list of (user, assistant) tuples into a single formatted string
    for LLM context or prompt chaining.

    Example input:
        [
            ("Hello", "Hi, how can I help you?"),
            ("What is crop rotation?", "Crop rotation is...")
        ]
    """
    formatted = ""
    for user_msg, assistant_msg in history:
        formatted += f"User: {user_msg}\n"
        formatted += f"Assistant: {assistant_msg}\n"
    return formatted


def get_timestamp() -> str:
    """
    Returns current timestamp in ISO8601 format — useful for logging.
    """
    return datetime.utcnow().isoformat()

CROP_BY_SEASON = {
    "rainy": ["rice", "maize", "soybean", "pigeon pea", "groundnut"],
    "summer": ["millet", "sorghum", "sunflower", "okra"],
    "winter": ["wheat", "mustard", "chickpea", "potato"]
}

def heuristic_enrich(query: str, reply: str) -> str:
    q = query.lower()
    if "rainy" in q or "monsoon" in q:
        tips = ", ".join(CROP_BY_SEASON["rainy"])
        reply += f"\n\n🌧️ Monsoon-friendly crops: {tips}. Ensure raised beds and good drainage to avoid waterlogging."
    if "fertilizer" in q and "rice" in q:
        reply += "\n\n💡 Rice tip: Basal NPK 10:26:26 with split urea doses at tillering and panicle initiation; adjust by soil test."
    return reply

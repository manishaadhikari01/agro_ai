import hashlib
import json

def sha256_hex(data: str) -> str:
    """
    Return SHA-256 hex digest of a string.
    """
    return hashlib.sha256(data.encode("utf-8")).hexdigest()


def canonical_record(user_id: str, query: str, reply: str) -> str:
    """
    Create a canonical JSON string for hashing.
    This ensures consistent formatting across DB, Fabric, and Polygon.
    """
    record = {
        "user_id": user_id,
        "query": query,
        "reply": reply
    }
    # sort_keys=True ensures deterministic JSON structure
    return json.dumps(record, sort_keys=True)

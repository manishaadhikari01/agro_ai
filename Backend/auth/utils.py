from datetime import datetime, timedelta
import jwt
import os
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALGO = "HS256"

ACCESS_TOKEN_MIN = 15
REFRESH_TOKEN_DAYS = 7

def create_access_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "type": "access",
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_MIN)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)

def create_refresh_token(user_id: str) -> tuple[str, datetime]:
    expires = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_DAYS)
    payload = {
        "sub": user_id,
        "type": "refresh",
        "exp": expires
    }
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGO)
    return token, expires

def hash_token(token: str) -> str:
    return pwd_context.hash(token)

def verify_token(token: str, hashed: str) -> bool:
    return pwd_context.verify(token, hashed)

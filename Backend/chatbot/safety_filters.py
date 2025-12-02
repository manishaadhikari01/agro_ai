# backend/chatbot/safety_filters.py
import re

def clean_input(text: str) -> str:
    """Remove potential PII and unsafe words"""
    text = re.sub(r'\b\d{10}\b', '[PHONE]', text)
    text = re.sub(r'[A-Z]{5}\d{4}[A-Z]', '[PAN]', text)
    text = re.sub(r'\b\d{12}\b', '[AADHAAR]', text)
    return text

def generate_text(prompt: str) -> str:
    return f"[Dummy Offline Bot] Backend is running. You said: {prompt}"

def get_bot_reply(query: str) -> str:
    return generate_text(query)


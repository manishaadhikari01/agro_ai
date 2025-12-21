# backend/chatbot/langchain_orchestrator.py
from chatbot.hf_agent import get_hf_response
from chatbot.retriever import retrieve_context
from chatbot.safety_filters import clean_input

async def run_chatbot_pipeline(user_query: str) -> str:
    query = clean_input(user_query)
    context = retrieve_context(query)

    prompt = f"""You are an agricultural assistant helping Indian farmers.
Use the following context if relevant:
{context}

Question: {query}
Answer in simple and local-friendly English or Hindi.Keep the answers as short as you can without removing necessary information."""

    response = await get_hf_response(prompt)
    return response

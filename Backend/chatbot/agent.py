# backend_fastapi/chatbot/agent.py

# backend_fastapi/chatbot/agent.py

import os
from langchain_community.llms import HuggingFacePipeline
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline

model_name = "tiiuae/falcon-7b-instruct"  # or "tiiuae/falcon-7b-instruct"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto")

pipe = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    max_new_tokens=500,
    temperature=0.7
)

llm = HuggingFacePipeline(pipeline=pipe)    
# --- Chatbot logic function ---
def get_bot_reply(query: str) -> str:
    """Generate a chatbot reply using the Hugging Face model."""
    try:
        result = llm.invoke(query)

        # LangChain returns a string directly
        print(f"User: {query}\nBot: {result}")
        return result
    except Exception as e:
        print(f"❌ Error: {e}")
        return "Sorry, I'm having trouble generating a response right now."

# backend/chatbot/retriever.py
from langchain_community.embeddings import SentenceTransformerEmbeddings
from langchain_community.vectorstores import FAISS
import os

embeddings = SentenceTransformerEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

if os.path.exists("data/vector_store"):
    vector_db = FAISS.load_local("data/vector_store", embeddings)
else:
    vector_db = None

def retrieve_context(query: str):
    if not vector_db:
        return ""
    docs = vector_db.similarity_search(query, k=3)
    return "\n".join([d.page_content for d in docs])

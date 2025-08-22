"""
📚 Knowledge Base for Foundry Manufacturing District
Specialized knowledge storage and retrieval for cognitive cities
"""

from fastapi import FastAPI
import uvicorn

app = FastAPI(title="Foundry Knowledge Base", version="1.0.0")

@app.get("/")
async def root():
    return {"message": "📚 Foundry Knowledge Base for Cognitive Cities"}

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "foundry-knowledge-base"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
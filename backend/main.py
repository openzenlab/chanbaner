from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import json
import re
import time
import logging
from collections import defaultdict

app = FastAPI(title="Koan Orchestrator", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rate limiting
request_counts = defaultdict(list)
RATE_LIMIT = 60  # requests per minute

class KoanRequest(BaseModel):
    user_text: str
    hints: Optional[List[str]] = []

class KoanResponse(BaseModel):
    mirror: str
    koan: str
    micro_practice: str
    quote: Optional[str] = None
    policy_note: str

# Crisis keywords for safety filter
CRISIS_KEYWORDS = [
    "绝望", "自伤", "无意义", "想死", "自杀", "结束生命", "活不下去",
    "despair", "self-harm", "meaningless", "suicide", "end life"
]

# Few-shot templates
INTENT_TEMPLATES = {
    "seeking": {
        "koan": "未起求心前，谁在要？",
        "practice": "只数三息；起评判即从一再来。",
        "quote": "念起即觉。"
    },
    "clinging_form": {
        "koan": "境来谁见？离见者境自立否？",
        "practice": "聆听三种声，只知'声'。",
        "quote": "回光即是道。"
    },
    "scattered": {
        "koan": "念与念间，谁在知？",
        "practice": "数息至三，失数即从一。"
    },
    "emptiness_fixation": {
        "koan": "空空何所空？知空者安在？",
        "practice": "双掌相触二十秒，只知触。"
    },
    "ego_focus": {
        "koan": "我在何处？请于一吸一呼呈上。",
        "practice": "鼻尖触觉三息。"
    }
}

def check_rate_limit(client_ip: str) -> bool:
    now = time.time()
    # Clean old requests
    request_counts[client_ip] = [req_time for req_time in request_counts[client_ip] 
                                if now - req_time < 60]
    
    if len(request_counts[client_ip]) >= RATE_LIMIT:
        return False
    
    request_counts[client_ip].append(now)
    return True

def has_crisis_keywords(text: str) -> bool:
    text_lower = text.lower()
    return any(keyword in text_lower for keyword in CRISIS_KEYWORDS)

def create_mirror(user_text: str) -> str:
    # Remove judgment words and create neutral reflection
    judgment_words = ["好", "坏", "对", "错", "应该", "不应该", "必须", "糟糕", "完美"]
    
    # Simple neutral paraphrase
    text = user_text.strip()
    for word in judgment_words:
        text = text.replace(word, "")
    
    # Keep it concise
    if len(text) > 50:
        text = text[:47] + "..."
    
    return f"你说：{text}"

def generate_koan_response(user_text: str, hints: List[str]) -> KoanResponse:
    # Check for crisis keywords first
    if has_crisis_keywords(user_text):
        return KoanResponse(
            mirror="听到你的困难。",
            koan="",
            micro_practice="深呼吸三次，寻求专业帮助。",
            quote="",
            policy_note="如需帮助，请联系心理健康热线：400-161-9995"
        )
    
    # Create mirror
    mirror = create_mirror(user_text)
    
    # Select template based on hints or default
    intent = hints[0] if hints and hints[0] in INTENT_TEMPLATES else "scattered"
    template = INTENT_TEMPLATES[intent]
    
    return KoanResponse(
        mirror=mirror,
        koan=template["koan"],
        micro_practice=template["practice"],
        quote=template.get("quote"),
        policy_note="此为引导练习，非悟境评判。"
    )

@app.post("/koan/generate", response_model=KoanResponse)
async def generate_koan(request: KoanRequest, req: Request):
    client_ip = req.client.host
    
    # Rate limiting
    if not check_rate_limit(client_ip):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    start_time = time.time()
    
    try:
        response = generate_koan_response(request.user_text, request.hints or [])
        
        # Log metrics only (no PII)
        duration = time.time() - start_time
        logging.info(f"Request processed: {duration:.3f}s, {len(request.user_text)} chars")
        
        return response
        
    except Exception as e:
        logging.error(f"Error processing request: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": time.time()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
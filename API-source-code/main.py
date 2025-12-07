from fastapi import FastAPI, Request
from datetime import datetime, timezone

app = FastAPI()

@app.get("/")
async def root(request: Request):
    client_ip = request.client.host
    timestamp = datetime.now(timezone.utc).isoformat()

    return {
        "timestamp": timestamp,
        "ip": client_ip
    }

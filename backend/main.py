actions = []
doc = []
from typing import Annotated
import json
from fastapi import (
	FastAPI,
	WebSocket,
	Cookie,
	Query,
	WebSocketException,
	WebSocketDisconnect,
	status,
	Depends
)
from manager import ConnectionManager

app = FastAPI()
manager = ConnectionManager()

@app.get("/ping")
async def pong():
	return {"message": "pong"}

async def get_cookie_or_token(
	websocket: WebSocket,
	session: Annotated[str | None, Cookie()] = None,
	token: Annotated[str | None, Query()] = None,
):
	if session is None and token is None:
		raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION)
	return session or token

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(
	websocket: WebSocket,
	# cookie_or_token: Annotated[str, Depends(get_cookie_or_token)],
	client_id: int,
):
	await manager.connect(websocket)
	try:
		while True:
			data = await websocket.receive_json()
			print(data)
			await manager.broadcast({
				"message": data,
				"user": client_id
			}, websocket)
			actions.append(data)
			if data["action"] == 1:
				doc.insert(data['position'], data['character'])
			elif data["action"] == -1:
				doc.pop(data['position'])
			print(*doc, sep='')

	except WebSocketDisconnect:
		await manager.disconnect(websocket)
		print(f"Client #{client_id} left chat")
		doc.clear()
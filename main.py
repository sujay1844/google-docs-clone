from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from manager import ConnectionManager

app = FastAPI()
manager = ConnectionManager()

@app.get("/ping")
async def pong():
	return {"message": "pong"}

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
	await manager.connect(websocket)
	try:
		while True:
			data = await websocket.receive_json()
			await manager.boardcast(websocket, data)
			print(data)
	except WebSocketDisconnect:
		manager.disconnect(websocket)
		await manager.boardcast(websocket, {"message": f"User {client_id} left the chat"})
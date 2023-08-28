from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from manager import ConnectionManager
import time

app = FastAPI()
manager = ConnectionManager()

@app.get("/ping")
async def pong():
	return {"message": "pong"}

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
	await manager.connect([client_id, websocket])
	try:
		while True:
			data = await websocket.receive_json()
			# do transformation and other stuff here
			time.sleep(2)
			print(data)
			await manager.broadcast({
				"change": data["change"],
				"revision": data["revision"],
			})
	except WebSocketDisconnect:
		manager.disconnect([client_id, websocket])
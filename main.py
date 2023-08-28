from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from manager import ConnectionManager

app = FastAPI()
manager = ConnectionManager()

@app.get("/ping")
async def pong():
	return {"message": "pong"}

@app.websocket("/{client_id}/ws")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
	await manager.connect([client_id, websocket])
	try:
		while True:
			data = await websocket.receive_json()
			# do transformation and other stuff here
			print(data)
			await manager.boardcast({
				"change": data["change"],
				"revision": data["revision"],
			})
	except WebSocketDisconnect:
		manager.disconnect([client_id, websocket])
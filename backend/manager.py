from fastapi import WebSocket

class ConnectionManager:
	def __init__(self):
		self.connections: list[WebSocket] = []
	
	async def connect(self, websocket: WebSocket):
		await websocket.accept()
		self.connections.append(websocket)
	
	async def disconnect(self, websocket: WebSocket):
		self.connections.remove(websocket)
		# await websocket.close()

	async def send_personal_message(self, message: str, websocket: WebSocket):
		await websocket.send_text(message)

	async def broadcast(self, message: str, websocket: WebSocket):
		for connection in self.connections:
			if connection != websocket:
				print("broadcasting")
				await connection.send_json(message)
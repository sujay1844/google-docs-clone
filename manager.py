from fastapi import WebSocket

class ConnectionManager:
	def __init__(self):
		self.connections: list[WebSocket] = []

	async def connect(self, websocket: WebSocket):
		await websocket.accept()
		self.connections.append(websocket)
	
	def disconnect(self, websocket: WebSocket):
		self.connections.remove(websocket)
	
	async def boardcast(self, websocket:WebSocket, data: dict):
		for connection in self.connections:
			if connection == websocket: continue
			await connection.send_json(data)
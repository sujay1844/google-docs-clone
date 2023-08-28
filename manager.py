from fastapi import WebSocket

class ConnectionManager:
	def __init__(self):
		self.connections: list[list[int, WebSocket]] = []

	async def connect(self, connection: list[int, WebSocket]):
		await connection[1].accept()
		self.connections.append(connection)
	
	def disconnect(self, connection: list[int, WebSocket]):
		self.connections.remove(connection)
	
	async def boardcast(self, data: dict):
		for client_id, websocket in self.connections:
			await websocket.send_json(data)
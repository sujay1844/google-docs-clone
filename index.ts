import express from "express";
import http from "http";
import { Server } from "socket.io";
import cors from "cors";

const PORT = 8080;

const app = express();
app.use(cors()); // Enable CORS for Express

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all origins
    methods: ["GET", "POST"], // Allow specific methods
  },
});

app.get("/", (req, res) => {
  res.send("WebSocket server is running");
});

io.on("connection", (socket) => {
  console.log("Client connected", socket.id);
  socket.emit("welcome", "Welcome to the WebSocket server!");
  socket.emit("welcome", "Your id: " + socket.id);
  socket.on("delta", (data) => {
    console.log(`Received message: ${JSON.stringify(data)}`);
    io.emit("welcome", `Received message: ${JSON.stringify(data)}`);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected", socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

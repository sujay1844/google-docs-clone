import { applyChange, type Change } from "./changes";
import { doc, newDoc } from "$lib/store";

let localDoc: string;
const unsubscribe = doc.subscribe(value => {
	localDoc = value;
});

// random 2 digit number
const id = Math.floor(Math.random() * 100);

const WS_URL = `ws://localhost:8000/ws/${id}`;
export let socket: WebSocket;
export function initSocket() {
	socket = new WebSocket(WS_URL);
	socket.onopen = () => {
		console.log("Socket opened");
	};
	socket.onclose = () => {
		console.log("Socket closed");
	};
	socket.onmessage = (event) => {
		console.log("Message received", event.data);
		const change: Change = JSON.parse(event.data);
		doc.set(applyChange(localDoc, change));
		newDoc.set(localDoc);
	};
	socket.onerror = (e) => {
		console.log("Error occured", e);
	}
}
export function send(data: Change) {
	socket.send(JSON.stringify(data));
}
<script lang="ts">
	import { doc, newDoc } from "$lib/store";
	import { type Change, getChange, applyChange } from "$lib/changes";
	import { onMount } from "svelte";

	const id = Math.floor(Math.random() * 100);

	const WS_URL = `ws://localhost:8000/ws/${id}`;
	let socket: WebSocket;
	function initSocket() {
		socket = new WebSocket(WS_URL);
		socket.onopen = () => {
			console.log("Socket opened");
		};
		socket.onclose = () => {
			console.log("Socket closed");
		};
		socket.onmessage = (event) => {
			const change: Change = JSON.parse(event.data).message;
			$doc = applyChange($doc, change);
			$newDoc = $doc;
		};
		socket.onerror = (e) => {
			console.log("Error occured", e);
		}
	}
	onMount(initSocket);

	
	function handleInput() {
		const change: Change | null = getChange($doc, $newDoc);

		if(change){
			socket.send(JSON.stringify(change));
			$doc = $newDoc;
		}

	}

</script>

<textarea bind:value={$newDoc} on:input={handleInput} />

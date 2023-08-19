<script lang="ts">
	import { doc, newDoc } from "$lib/store";
	import { type Change, getChange, applyChange } from "$lib/changes";
	import { onMount } from "svelte";

	const id = Math.floor(Math.random() * 100);
	let pendingChanges: Change[] = [];
	let currentRevision = 0;

	const URL = `localhost:8000`;
	let socket: WebSocket;
	onMount(async () => {
		try {
			const res = await fetch(`http://${URL}/doc`);
			const data = await res.json();
			$doc = data.doc;
			$newDoc = $doc;
			currentRevision = data.revision;
		} catch (err) {
			console.log(err);
		}
		socket = new WebSocket(`ws://${URL}/ws/${id}`);
		socket.onopen = () => {
			console.log("Socket opened");
		};
		socket.onclose = () => {
			console.log("Socket closed");
		};
		socket.onmessage = (event) => {
			const data = JSON.parse(event.data);
			console.log(data);
			if (data.message == "new change"){
				const change: Change = data.change;
				$doc = applyChange($doc, change);
				$newDoc = $doc;
			} else if (data.message == "change applied") {
				pendingChanges = pendingChanges.filter(change => data.change != change);
				currentRevision = data.revision;
			}
		};
		socket.onerror = (e) => {
			console.log("Error occured", e);
		}
	});

	
	function handleInput() {
		const change: Change | null = getChange($doc, $newDoc);

		if(change){
			change.revision = currentRevision;
			socket.send(JSON.stringify(change));
			pendingChanges.push(change);
			$doc = $newDoc;
		}

	}

</script>

<textarea bind:value={$newDoc} on:input={handleInput} />

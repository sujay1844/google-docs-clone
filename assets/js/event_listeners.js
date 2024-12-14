import { channel } from "./document_socket";
import { quill } from "./quill";

quill.on("text-change", (delta, _, source) => {
  if (source !== "user") return;
  channel.push("delta", { delta: delta, revision: 0 });
});

channel.on("delta", ({ delta }) => {
  console.log("received delta", delta);
  quill.updateContents(delta);
});

channel.on("ack", ({ revision }) => {
  console.log("received ack", revision);
});

import { channel } from "./document_socket";
import { quill } from "./quill";
import { pendingOperations } from "./queue";

let currentRevision = 0;

quill.on("text-change", (delta, _, source) => {
  if (source !== "user") return;
  pendingOperations.add(delta);
  channel.push("delta", { delta, revision: currentRevision });
});

channel.on("delta", ({ delta, revision }) => {
  const transformedDelta = pendingOperations.transform(delta);
  quill.updateContents(transformedDelta);
  currentRevision = revision;
});

channel.on("ack", ({ delta }) => {
  pendingOperations.remove(delta);

  // Send the next delta in the queue
  const nextDelta = pendingOperations.peek();
  if (nextDelta) {
    channel.push("delta", { delta: nextDelta, revision: currentRevision });
  }
});

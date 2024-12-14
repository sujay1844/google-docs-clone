import { channel } from "./document_socket";
import { quill } from "./quill";
import { pendingOperations } from "./queue";

quill.on("text-change", (delta, _, source) => {
  if (source !== "user") return;
  pendingOperations.add(delta);
  channel.push("delta", { delta, revision: 0 });
});

channel.on("delta", ({ delta, revision }) => {
  _ = revision;

  const transformedDelta = pendingOperations.transform(delta);
  quill.updateContents(transformedDelta);
});

channel.on("ack", ({ delta }) => {
  pendingOperations.remove(delta);

  // Send the next delta in the queue
  const nextDelta = pendingOperations.peek();
  channel.push("delta", { delta: nextDelta, revision: 0 });
});

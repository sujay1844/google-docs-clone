import { channel } from "./document_socket";
import { quill } from "./quill";
import { pendingOperations } from "./queue";
import { marked } from "marked";

marked.use({ gfm: true });

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

// Update preview when the document is updated
quill.on("text-change", () => {
  // get current content from quill
  const currentContent = quill.getText();
  const preview = document.getElementById("preview");
  preview.innerHTML = marked.parse(currentContent);
});

// Fill the editor with the document content for initial load
const content = window.props.document_content;
quill.updateContents({
  ops: [{ insert: content }],
});

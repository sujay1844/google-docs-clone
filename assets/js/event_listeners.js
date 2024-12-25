import { channel } from "./document_socket";
import { deltaToOperation, operationToDelta, quill } from "./quill";
import { pendingOperations } from "./queue";
import { marked } from "marked";
import { emojify } from "node-emoji";

marked.use({ gfm: true });
const parseMarkdown = (str) => {
  const emojiRenderer = (match) => emojify(match);
  str = str.replace(/(:.*:)/g, emojiRenderer);
  return marked.parse(str);
};

let currentRevision = window.props.revision;

quill.on("text-change", (delta, _, source) => {
  if (source !== "user") return;
  const operation = deltaToOperation(delta);
  pendingOperations.add(operation);
  channel.push("operation", { operation, revision: currentRevision });
});

channel.on("operation", ({ operation, revision }) => {
  const transformedOperation = pendingOperations.transform(operation);
  const delta = operationToDelta(transformedOperation);
  quill.updateContents(delta);
  currentRevision = revision;
});

channel.on("ack", ({ operation, revision, new_revision }) => {
  pendingOperations.remove(operation);

  // Send the next delta in the queue
  const nextOperation = pendingOperations.peek();
  if (nextOperation) {
    channel.push("operation", {
      operation: nextOperation,
      revision: currentRevision,
    });
  }
  currentRevision = new_revision;
});

// Update preview when the document is updated
quill.on("text-change", () => {
  // get current content from quill
  const currentContent = quill.getText();
  const preview = document.getElementById("preview");
  preview.innerHTML = parseMarkdown(currentContent);
});

// Fill the editor with the document content for initial load
const content = window.props.document_content;
quill.updateContents({
  ops: [{ insert: content }],
});

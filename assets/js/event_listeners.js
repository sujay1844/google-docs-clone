import { channel } from "./document_socket";
import { quill, Delta } from "./quill";
import { marked } from "marked";
import { emojify } from "node-emoji";

marked.use({ gfm: true });

const parseMarkdown = (str) =>
  marked.parse(str.replace(/(:[a-z0-9_+-]+:)/gi, (m) => emojify(m)));

const decodeUtf8FromBase64 = (b64) => {
  const binary = atob(b64);
  const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
};

const newOpId = () =>
  `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;

let currentRevision = window.props.revision;
let pending = null;     // Delta in flight, awaiting echo from server
let pendingId = null;   // Server echoes this id back so we can recognize our own op
let buffer = null;      // Local edits composed since `pending` was sent

const send = () => {
  pendingId = newOpId();
  channel.push("operation", {
    delta: pending,
    revision: currentRevision,
    id: pendingId,
  });
};

quill.on("text-change", (delta, _old, source) => {
  if (source !== "user") return;
  const d = new Delta(delta);
  if (pending) {
    buffer = buffer ? buffer.compose(d) : d;
  } else {
    pending = d;
    send();
  }
});

channel.on("operation", ({ delta, revision, id }) => {
  if (id && id === pendingId) {
    currentRevision = revision;
    pendingId = null;
    if (buffer) {
      pending = buffer;
      buffer = null;
      send();
    } else {
      pending = null;
    }
    return;
  }

  let remote = new Delta(delta);
  if (pending) {
    const newRemote = pending.transform(remote, false);
    pending = remote.transform(pending, true);
    remote = newRemote;
  }
  if (buffer) {
    const newRemote = buffer.transform(remote, false);
    buffer = remote.transform(buffer, true);
    remote = newRemote;
  }
  quill.updateContents(remote, "api");
  currentRevision = revision;
});

channel.on("error", ({ reason }) => {
  console.error("server rejected operation:", reason);
});

const updatePreview = () => {
  const preview = document.getElementById("preview");
  preview.innerHTML = parseMarkdown(quill.getText());
};
quill.on("text-change", updatePreview);

quill.setContents(
  new Delta().insert(decodeUtf8FromBase64(window.props.document_content)),
  "api",
);
updatePreview();

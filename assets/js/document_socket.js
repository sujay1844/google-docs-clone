import { Socket } from "phoenix";
import Quill from "quill";

let socket = new Socket("/socket", { params: { token: window.userToken } });
socket.connect();

const id = document.getElementById("document-id").innerText;
const channel = socket.channel("document:" + id, {});

const quill = new Quill("#editor", {
  theme: "snow",
  modules: {
    toolbar: [["bold", "italic", "underline"]],
  },
});

quill.on("text-change", (delta, _, source) => {
  if (source !== "user") return;
  channel.push("delta", { body: delta, revision: 0 });
});

channel.on("delta", ({ body }) => {
  console.log("received delta", body);
  quill.updateContents(body);
});

channel.on("ack", ({ revision }) => {
  console.log("received ack", revision);
});

channel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined successfully", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join", resp);
  });

export default socket;

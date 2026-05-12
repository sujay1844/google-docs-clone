import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

const meta = document.querySelector("meta[name='csrf-token']");
if (meta) {
  const liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: { _csrf_token: meta.getAttribute("content") },
  });
  liveSocket.connect();
  window.liveSocket = liveSocket;
}

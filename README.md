# Google Docs Clone

This project is a collaborative text editor which allows multiple users to edit text documents in real-time, with changes being synchronized across all clients.

- Frontend: The frontend text editor is powered by Quill.js, a powerful, rich text editor. Used here because it provides consistent APIs for obtaining and applying deltas to the document.
- Backend: The server-side logic is handled by Phoenix, which provides real-time communication via Channels (web-sockets). SQLite is used as a database to store operations on each document.

# How it works: Operational Transformation Algorithm

Operational Transformation (OT) is a foundational technique for maintaining consistency in collaborative text editors. It enables multiple users to simultaneously edit shared documents by ensuring that operations (e.g., insert, delete) from different users are applied in a consistent order across all instances.

1. **Core Operations**: OT handles two primary operations:

   - Insert: Adds content at a specific position.
   - Delete: Removes content from a specific position.

2. **Consistency Model**: OT ensures,

   - Convergence: All users see the same document state after all operations are applied.
   - Causality Preservation: Operations are applied respecting their causal order.
   - Intention Preservation: Intended effects of operations are maintained despite concurrent edits

3. **Transformations**: When operations conflict (e.g., two users edit the same text simultaneously), OT adjusts them using transformation functions. These functions modify operations so they integrate smoothly with concurrent changes, preserving the effects of all operations where possible.

> Reference: David Sun, Steven Xia, Chengzheng Sun, and David Chen. 2004. Operational transformation for collaborative word processing. In Proceedings of the 2004 ACM conference on Computer supported cooperative work (CSCW '04). Association for Computing Machinery, New York, NY, USA, 437–446. https://doi.org/10.1145/1031607.1031681

# Getting Started

If you have docker installed, you can run the following command to start the server:

```bash
docker-compose up
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To start your Phoenix server locally, you need to have Elixir and Erlang installed. You can follow the instructions [here](https://elixir-lang.org/install.html).

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Ready to run in production? [Check the deployment guides](https://hexdocs.pm/phoenix/deployment.html).

# Further improvements

- Add user authentication
- Implement consistent undo and redo using MVSD(Multi-Version Single-Display)
- Improve responsiveness on mobile devices
- Display cursor positions of other users in real-time
- Export documents as PDF

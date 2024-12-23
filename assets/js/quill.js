import Quill from "quill";

const quill = new Quill("#editor", {
  theme: "bubble",
  modules: {
    toolbar: [],
  },
});

const deltaToOperation = (delta) => {
  const operation = {
    type: "noop",
    position: 0,
    content: "",
    length: 0,
  };
  const ops = delta.ops;
  for (const op of ops) {
    if (op.retain) {
      operation.position += op.retain;
    } else if (op.insert) {
      operation.type = "insert";
      operation.content += op.insert;
    } else if (op.delete) {
      operation.type = "delete";
      operation.length += op.delete;
    }
  }
  return operation;
};

const operationToDelta = (operation) => {
  if (operation.type === "noop") {
    return {
      ops: [],
    };
  } else if (operation.type === "insert") {
    return {
      ops: [{ retain: operation.position }, { insert: operation.content }],
    };
  } else if (operation.type === "delete") {
    return {
      ops: [{ retain: operation.position }, { delete: operation.length }],
    };
  }
};

export { quill, deltaToOperation, operationToDelta };

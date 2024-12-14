class OperationQueue {
  constructor(key) {
    this.key = key;
    this.queue = this.loadQueue();
  }

  loadQueue() {
    const data = localStorage.getItem(this.key);
    return data ? JSON.parse(data) : [];
  }

  saveQueue() {
    localStorage.setItem(this.key, JSON.stringify(this.queue));
  }

  remove(delta) {
    this.queue = this.queue.filter((item) => item !== delta);
    this.saveQueue();
  }

  peek() {
    return this.queue[0];
  }

  add(item) {
    this.queue.push(item);
    this.saveQueue();
  }

  transform(operation) {
    // Transform the operation against all other operations in the queue
    operation = this.queue.reduce(
      (acc, item) => transform(acc, item),
      operation,
    );

    // Transform pending operations against the new operation
    this.queue = this.queue.map((item) => transform(item, operation));

    this.saveQueue();
    return operation;
  }
}

function transform(op1, op2) {
  _ = op2;
  return op1;
}

const id = document.getElementById("document-id").innerText;
export const pendingOperations = new OperationQueue(`document:${id}`);
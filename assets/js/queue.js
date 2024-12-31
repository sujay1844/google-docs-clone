import _ from "lodash";

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
    this.queue = this.queue.filter((item) => !_.isEqual(item, delta));
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

function transform(old, new_) {
  if (old.type === "insert") {
    if (new_.position < old.position) {
      return new_;
    } else if (new_.position === old.position) {
      // WARN: Might not be correct. Intended for testing.
      return new_;
    } else if (new_.position > old.position) {
      return {
        ...new_,
        position: new_.position + old.length,
      };
    }
  } else if (old.type === "delete") {
    if (new_.position <= old.position) {
      return new_;
    } else if (new_.position > old.position) {
      return {
        ...new_,
        position: new_.position - old.length,
      };
    }
  }
  console.error("Unsupported operation type");
  console.error("Old: ", old);
  console.error("New: ", new_);
  throw new Error("Unsupported operation type");
}

const id = window.props.document_id;
export const pendingOperations = new OperationQueue(`document:${id}`);

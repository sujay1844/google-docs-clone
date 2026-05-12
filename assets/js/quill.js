import Quill from "quill";

const Delta = Quill.import("delta");

const quill = new Quill("#editor", {
  theme: "bubble",
  modules: {
    toolbar: [],
  },
});

export { quill, Delta };

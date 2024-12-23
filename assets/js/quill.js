import Quill from "quill";

const quill = new Quill("#editor", {
  theme: "bubble",
  modules: {
    toolbar: [],
  },
});

export { quill };

import Quill from "quill";

export const quill = new Quill("#editor", {
  theme: "snow",
  modules: {
    toolbar: [["bold", "italic", "underline"]],
  },
});

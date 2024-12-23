import Quill from "quill";

const quill = new Quill("#editor", {
  theme: "bubble",
  modules: {
    toolbar: [],
  },
});

const content = window.props.document_content;
quill.updateContents({
  ops: [{ insert: content }],
});

export { quill };

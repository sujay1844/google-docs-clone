import Quill from "quill";

const quill = new Quill("#editor", {
  theme: "snow",
  modules: {
    toolbar: [["bold", "italic", "underline"]],
  },
});

const content = window.props.document_content;
quill.updateContents({
  insert: content,
});

export { quill };

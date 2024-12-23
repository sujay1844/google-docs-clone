import Quill from "quill";

const quill = new Quill("#editor", {
  modules: {
    toolbar: [],
  },
});

const content = window.props.document_content;
quill.updateContents({
  ops: [{ insert: content }],
});

export { quill };

defmodule GoogleDocsCloneWeb.DocumentHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use GoogleDocsCloneWeb, :html

  embed_templates "document_html/*"
end

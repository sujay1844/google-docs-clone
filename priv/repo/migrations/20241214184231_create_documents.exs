defmodule GoogleDocsClone.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add :id, :string, primary_key: true
      add :content, :string

      timestamps(type: :utc_datetime)
    end
  end
end

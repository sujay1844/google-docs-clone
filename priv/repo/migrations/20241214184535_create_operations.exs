defmodule GoogleDocsClone.Repo.Migrations.CreateOperations do
  use Ecto.Migration

  def change do
    create table(:operations) do
      add :document_id, references(:documents, on_delete: :delete_all, type: :string)
      add :revision, :integer
      add :type, :string
      add :position, :integer
      add :content, :string
      add :length, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:operations, [:document_id])
  end
end

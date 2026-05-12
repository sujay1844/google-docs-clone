defmodule GoogleDocsClone.Repo.Migrations.RewriteOperationsAsDeltas do
  use Ecto.Migration

  def change do
    drop_if_exists table(:operations)

    create table(:operations) do
      add :document_id, references(:documents, on_delete: :delete_all, type: :string),
        null: false

      add :revision, :integer, null: false
      add :delta, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:operations, [:document_id, :revision])

    # Backfill rows that pre-date the revision column.
    execute(
      "UPDATE documents SET revision = 0 WHERE revision IS NULL",
      "SELECT 1"
    )
  end
end

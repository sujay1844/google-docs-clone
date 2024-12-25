defmodule GoogleDocsClone.Repo.Migrations.AddRevisionToDocument do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :revision, :integer
    end
  end
end

defmodule GupIndexManager.Repo.Migrations.CreatePublications do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :json, :text
      add :publication_id, :string
      add :attended, :boolean, default: false, null: false

      timestamps()
    end
  end
end

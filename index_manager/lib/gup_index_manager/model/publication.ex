defmodule GupIndexManager.Model.Publication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "publications" do
    field :attended, :boolean, default: false
    field :deleted, :boolean, default: false
    field :json, :string
    field :publication_id, :string

    timestamps()
  end

  @doc false
  def changeset(publication, attrs) do
    publication
    |> cast(attrs, [:json, :publication_id, :attended, :deleted])
    |> validate_required([:json, :publication_id, :attended])
  end

  def find_by_publication_id(publication_id) do
    GupIndexManager.Model.Publication
    |> GupIndexManager.Repo.get_by(publication_id: publication_id)
    |> case do
      nil -> %GupIndexManager.Model.Publication{}
      publication -> publication

    end
  end
end
# iex(26)> GupIndexManager.Repo.get_by(GupIndexManager.Model.Publication, publication_id: "gup_317922fff")

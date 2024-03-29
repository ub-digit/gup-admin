defmodule GupIndexManager.Model.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field :json, :string
    timestamps()

  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:json])
    |> validate_required([:json])
  end
  def find_by_id(id) when is_nil(id), do: %GupIndexManager.Model.Person{}
  def find_by_id(id) do
    GupIndexManager.Repo.get(GupIndexManager.Model.Person, id)
    |> case do
      nil -> %GupIndexManager.Model.Person{}
      person -> person
    end
  end
end

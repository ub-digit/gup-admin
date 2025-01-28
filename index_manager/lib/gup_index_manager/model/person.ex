defmodule GupIndexManager.Model.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field :json, :string
    field :deleted, :boolean, default: false
    field :deleted_at, :utc_datetime
    timestamps()

  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:json, :deleted, :deleted_at])
    |> validate_required([:json])
  end
  def find_by_id(id) when is_nil(id), do: %GupIndexManager.Model.Person{}
  def find_by_id(id) when is_binary(id), do: find_by_id(String.to_integer(id))
  def find_by_id(id) do
    GupIndexManager.Repo.get(GupIndexManager.Model.Person, id)
    |> case do
      nil -> %GupIndexManager.Model.Person{}
      person -> person
    end
  end
end

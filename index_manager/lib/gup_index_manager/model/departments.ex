defmodule GupIndexManager.Model.Department do
  use Ecto.Schema
  import Ecto.Changeset

  schema "departments" do
    field :json, :string
    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:json])
    |> validate_required([:json])
  end


  def find_department_by_id(id) when is_nil(id), do: %GupIndexManager.Model.Department{}
  def find_department_by_id(id) do
    GupIndexManager.Model.Department
    |> GupIndexManager.Repo.get_by(id: id)
    |> case do
      nil ->
        %GupIndexManager.Model.Department{}
      department ->
        department
    end
  end
end

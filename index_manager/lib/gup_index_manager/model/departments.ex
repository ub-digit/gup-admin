defmodule GupIndexManager.Model.Department do
  use Ecto.Schema
  import Ecto.Changeset

  schema "departments" do
    field :json, :string
    field :id, :integer
    field :is_faculty, :boolean, default: false
    field :parent_id, :integer
    timestamps()
  end

  def changeset(department, attrs) do
    department
    |> cast(attrs, [:id, :json, :inserted_at, :updated_at, :is_faculty, :parent_id])
    |> validate_required([:id, :json])
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

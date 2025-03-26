defmodule GupIndexManager.Model.Department do
  use Ecto.Schema
  import Ecto.Changeset

  schema "departments" do
    field :json, :string
    field :department_id, :integer

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [:json, :department_id])
    |> validate_required([:json, :department_id])
  end

  def find_department_by_department_id(department_id) do
    GupIndexManager.Model.Department
    |> GupIndexManager.Repo.get_by(department_id: department_id)
    |> case do
      nil -> %GupIndexManager.Model.Department{}
      department -> department
    end
  end
end
# iex(26)> GupIndexManager.Repo.get_by(GupIndexManager.Model.Publication, publication_id: "gup_317922fff")

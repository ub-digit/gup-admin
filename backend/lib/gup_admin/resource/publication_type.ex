defmodule GupAdmin.Resource.PublicationType do
  # Return the list of publication types
  def get_publication_types do
    GupAdmin.Model.PublicationType.publication_types()
  end

  def show(id) do
    GupAdmin.Model.PublicationType.publication_types()
    |> Enum.find(fn type -> type["id"] == id end)
  end

end

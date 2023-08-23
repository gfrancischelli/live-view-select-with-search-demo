defmodule Demo.Art.Movie do
  use Ecto.Schema

  schema "movies" do
    field :title, :string
  end
end

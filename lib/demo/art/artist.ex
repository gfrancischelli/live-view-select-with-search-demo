defmodule Demo.Art.Artist do
  alias Demo.Art.Movie

  use Ecto.Schema

  schema "artists" do
    field :name, :string
    belongs_to :favorite_movie, Movie
  end
end

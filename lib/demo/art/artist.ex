defmodule Demo.Art.Artist do
  alias Demo.Art.Movie

  use Ecto.Schema

  schema "artists" do
    field :name, :string
    field :rate, :integer
    belongs_to :favorite_movie, Movie

    many_to_many :favorite_movies, Movie,
      join_through: "artists_movies",
      on_replace: :delete,
      unique: true
  end
end

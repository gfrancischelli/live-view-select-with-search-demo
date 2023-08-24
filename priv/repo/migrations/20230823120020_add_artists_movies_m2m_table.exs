defmodule Demo.Repo.Migrations.AddArtistsMoviesM2mTable do
  use Ecto.Migration

  def change do
    create table(:artists_movies) do
      add :movie_id, references(:movies)
      add :artist_id, references(:movies)
    end

    create unique_index(:artists_movies, [:movie_id, :artist_id])
  end
end

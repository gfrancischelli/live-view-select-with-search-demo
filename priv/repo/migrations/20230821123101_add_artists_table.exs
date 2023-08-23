defmodule Demo.Repo.Migrations.AddArtistsTable do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string
      add :favorite_movie_id, references(:movies)
    end
  end
end

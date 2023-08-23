defmodule Demo.Repo.Migrations.AddMoviesTable do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string
    end

    create unique_index(:movies, [:title])
  end
end

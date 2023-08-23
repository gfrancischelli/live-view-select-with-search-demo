# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Demo.Repo.insert!(%Demo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Demo.Repo
alias Demo.Art.Movie

Demo.Repo.insert_all(Movie, [
  %{title: "The Devil Queen"},
  %{title: "City of God"},
  %{title: "Central Station"},
  %{title: "Brainstorm"},
  %{title: "A Dog's Will"},
  %{title: "Madam Satan"},
  %{title: "The Red Light Bandit"},
])

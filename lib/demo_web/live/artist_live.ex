defmodule DemoWeb.ArtistLive do
  use DemoWeb, :live_view

  import DemoWeb.CoreComponents
  import DemoWeb.Components.SearchSelect

  import Ecto.Changeset
  import Ecto.Query

  alias Demo.Repo
  alias Demo.Art.Artist
  alias Demo.Art.Movie

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_movies(socket)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    artist =
      if id = params["id"] do
        Repo.get!(Artist, String.to_integer(id))
      else
        %Artist{}
      end

    form = artist |> change() |> to_form()

    {:noreply, assign(socket, artist: artist, form: form)}
  end

  defp assign_movies(socket) do
    if connected?(socket) do
      query = select(Movie, [m], {m.title, m.id})
      assign(socket, movies: Repo.all(query))
    else
      assign(socket, movies: [])
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header><%= Phoenix.Naming.humanize(@live_action) %> Artist</.header>

    <.simple_form for={@form} class="w-full" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Name" />
      <.search_select options={@movies} field={@form[:favorite_movie_id]} />
      <:actions>
        <.button>Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  @required_fields [:name, :favorite_movie_id]

  @impl true
  def handle_event("validate", %{"artist" => params}, socket) do
    changeset = to_changeset(socket.assigns.artist, params)
    {:noreply, assign(socket, :form, to_form(%{changeset | action: :validate}))}
  end

  @impl true
  def handle_event("save", %{"artist" => params}, socket) do
    case save(socket.assigns.artist, params) do
      {:ok, artist} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artist saved")
         |> push_patch(to: ~p"/artists/#{artist}/edit")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp to_changeset(artist, params) do
    artist
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  defp save(artist, params) do
    artist |> to_changeset(params) |> Repo.insert_or_update()
  end
end

defmodule DemoWeb.ComponentLive do
  use DemoWeb, :live_view
  import DemoWeb.CoreComponents

  import DemoWeb.Components.SearchSelect

  def render(%{live_action: :dropdown} = assigns) do
    ~H"""
    <.dropdown id="my-dropdown">
      Click to expand
      <:expanded>
        I'm expanded hoooray
        <ul class="list-disc list-inside">
         <li>Thanks to slots</li>
         <li>Rich html works 🚀</li>
        </ul>
      </:expanded>
    </.dropdown>

    <.simple_form :let={f} for={%{}} as={:story} class="w-full">
      <.input field={f[:field]}/>
    </.simple_form>
    """
  end

  @artists ["Charlie Brown Jr", "Anderson Leonardo", "Gilberto Gil"]
  @movies ["Isle of Flowers", "City of God", "Bacurau"]

  def render(%{live_action: :searchselect} = assigns) do
    assigns = assigns
    |> assign_new(:form, fn ->to_form(%{"artist" => "Charlie Brown Jr"}) end)
    |> assign(movies: @movies, artists: @artists)

    ~H"""
    <.header>Art Form</.header>

    <.simple_form for={@form} class="w-full" phx-change="validate">
      <.search_select field={@form[:movie]} options={@movies} placeholder="Select your favorite movie 🎬"/>
      <.search_select field={@form[:artist]} options={@artists} placeholder="Select your favorite music artist 🎸"/>
    </.simple_form>
    """
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, :form, to_form(params))}
  end
end

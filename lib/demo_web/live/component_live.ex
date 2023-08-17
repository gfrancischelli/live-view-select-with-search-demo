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

  def render(%{live_action: :searchselect} = assigns) do
    assigns = assign(assigns, :form, to_form(%{"artist" => "Charlie Brown Jr"}))
    ~H"""
    <.header>Art Form</.header>

    <.simple_form for={@form} class="w-full">
      <.search_select field={@form[:movie]} placeholder="Select your favorite movie 🎬"/>
      <.search_select field={@form[:artist]} placeholder="Select your favorite music artist 🎸"/>
    </.simple_form>
    """
  end
end

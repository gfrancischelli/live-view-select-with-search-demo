defmodule DemoWeb.ComponentLive do
  use DemoWeb, :live_view
  import DemoWeb.CoreComponents

  def render(%{live_action: :dropdown} = assigns) do
    ~H"""
    <.dropdown id="my-dropdown">
      Click to expand
      <:expanded>
        I'm expanded hoooray
      </:expanded>
    </.dropdown>

    <.simple_form :let={f} for={%{}} as={:story} class="w-full">
      <.input field={f[:field]}/>
    </.simple_form>
    """
  end

  def render(assigns) do
    ~H"""
    <%= inspect(assigns, pretty: true) %>
    """
  end
end

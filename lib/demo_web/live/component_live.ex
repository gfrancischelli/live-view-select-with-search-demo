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
    ~H"""
    <.simple_form :let={f} for={%{}} as={:story} class="w-full">
      <.search_select field={f[:field]} options={[1, 2, 3]}/>
    </.simple_form>
    """
  end
end

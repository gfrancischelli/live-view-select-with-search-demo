defmodule DemoWeb.Components.SearchSelect do
  use DemoWeb, :live_component
  import DemoWeb.CoreComponents

  def search_select(assigns) do
    assigns =
      assigns
      |> assign(id: assigns.field.id, name: assigns.field.name, form: assigns.field.form)
      |> assign_new(:label, fn -> Phoenix.Naming.humanize(assigns.field.field) end)

    ~H"""
    <.live_component module={__MODULE__} {assigns} />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={@id} phx-feedback-for={@name}>
      <.label><%= @label %></.label>
      <.dropdown id={"#{@id}-dropdown"}>
        <:closed>Please select</:closed>

        <input class={["outline-0 w-full text-zinc-900 sm:text-sm sm:leading-6"]} />

        <:expanded>
          Nothing to see here 👀
        </:expanded>
     </.dropdown>
    </div>
    """
  end
end

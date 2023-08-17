defmodule DemoWeb.Components.SearchSelect do
  use DemoWeb, :live_component
  import DemoWeb.CoreComponents

  alias Phoenix.LiveView.JS

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
    assigns = assign(assigns, :dd_id, assigns.id <> "-dropdown")

    ~H"""
    <div id={@id} phx-feedback-for={@name}>
      <.label><%= @label %></.label>
      <.dropdown id={@dd_id} on_open={focus_search_input(@id)} phx-blur={nil}>
        <:closed>Please select</:closed>

        <input
          class={["search outline-0 w-full text-zinc-900 sm:text-sm sm:leading-6"]}
          phx-blur={close_dropdown(@dd_id)}
        />

        <:expanded>
          Nothing to see here 👀
        </:expanded>
      </.dropdown>
    </div>
    """
  end

  def focus_search_input(id) do
    JS.focus(to: "##{id} input.search")
  end
end

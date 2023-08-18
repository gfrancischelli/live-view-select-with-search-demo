defmodule DemoWeb.Components.SearchSelect do
  use DemoWeb, :live_component
  import DemoWeb.CoreComponents

  alias Phoenix.LiveView.JS

  attr :placeholder, :string, default: "Select"

  attr :options, :list, required: true

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def search_select(assigns) do
    assigns =
      assigns
      |> assign(id: assigns.field.id, name: assigns.field.name, form: assigns.field.form)
      |> assign_new(:label, fn -> Phoenix.Naming.humanize(assigns.field.field) end)
      |> assign_new(:value, fn -> assigns.field.value end)

    ~H"""
    <.live_component module={__MODULE__} {assigns} />
    """
  end

  def render(assigns) do
    assigns = assign(assigns, :dd_id, assigns.id <> "-dropdown")

    ~H"""
    <div id={@id} phx-feedback-for={@name} phx-hook="SelectComponent">
      <.proxy_input {assigns} />
      <.label><%= @label %></.label>
      <.dropdown id={@dd_id} on_open={focus_search_input(@id)} phx-blur={nil}>
        <:closed>
          <%= if value_empty?(@field.value) do %>
            <span class="text-zinc-600"><%= @placeholder %></span>
          <% else %>
            <%= @field.value %>
          <% end %>
        </:closed>

        <input
          phx-click-away={close_dropdown(@dd_id)}
          phx-keydown={JS.exec("phx-click-away")}
          phx-key="Tab"
          phx-target={@myself}
          class={["search outline-0 w-full text-zinc-900 sm:text-sm sm:leading-6"]}
        />

        <:expanded class="!px-2">
          <button
            :for={option <- @options}
            tabindex="-1"
            type="button"
            phx-click={select_option(@field, option)}
            class="block w-full text-left px-2 hover:bg-cyan-50 rounded-md pointer-cursor"
          >
            <%= option %>
          </button>
        </:expanded>
      </.dropdown>
    </div>
    """
  end

  defp proxy_input(assigns) do
    ~H"""
    <select class="hidden" name={@field.name}>
      <option value=""></option>
      <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
    </select>
    """
  end

  defp value_empty?(value) do
    value == "" or value == nil
  end

  # JS Dispatches

  defp select_option(field, option) do
    JS.dispatch("select-option", to: "select[name=#{field.name}]", detail: option)
  end

  def focus_search_input(id) do
    JS.focus(to: "##{id} input.search")
  end
end

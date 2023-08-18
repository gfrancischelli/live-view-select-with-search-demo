defmodule DemoWeb.Components.SearchSelect do
  use DemoWeb, :live_component
  import DemoWeb.CoreComponents

  alias Phoenix.LiveView.JS

  @max_filtered_options 10

  attr :placeholder, :string, default: "Select"
  attr :search_debounce, :integer, default: 100

  attr :options, :list, required: true

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def search_select(assigns) do
    assigns =
      assigns
      |> assign(id: assigns.field.id, name: assigns.field.name, form: assigns.field.form)
      |> assign(search: "")
      |> assign_new(:label, fn -> Phoenix.Naming.humanize(assigns.field.field) end)
      |> assign_new(:value, fn -> assigns.field.value end)

    ~H"""
    <.live_component module={__MODULE__} {assigns} />
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_filtered_options()}
  end

  @impl true
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

        <form>
          <input
            phx-click-away={close_dropdown(@dd_id)}
            phx-keydown={JS.exec("phx-click-away")}
            phx-key="Tab"
            phx-change="search"
            phx-target={@myself}
            phx-debounce={@search_debounce}
            name="search"
            autocomplete="off"
            placeholder={@field.value || @placeholder}
            value={@search}
            class="outline-0 w-full text-zinc-900 placeholder:text-zinc-500 sm:text-sm sm:leading-6"
          />
        </form>

        <:expanded class="!px-2">
          <button
            :for={option <- @filtered_options}
            tabindex="-1"
            type="button"
            phx-click={select_option(@field, option)}
            class="block w-full text-left px-2 hover:bg-cyan-50 rounded-md pointer-cursor"
          >
            <%= option %>
          </button>

          <.empty_state :if={@filtered_options == []} />
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
    JS.focus(to: "##{id} input[name='search']")
  end

  @impl true
  def handle_event("search", %{"search" => search_text}, socket) do
    {:noreply, socket |> assign(search: search_text) |> assign_filtered_options(search_text)}
  end

  defp assign_filtered_options(socket, search_text \\ nil) do
    %{options: options, field: field} = socket.assigns

    filtered_options =
      options
      |> Stream.reject(
        &(&1 == field.value or (search_text != nil and not contains_normalized?(&1, search_text)))
      )
      |> Enum.take(@max_filtered_options)

    assign(socket, filtered_options: filtered_options)
  end

  defp contains_normalized?(a, b) do
    String.contains?(String.downcase(a), String.downcase(b))
  end
end

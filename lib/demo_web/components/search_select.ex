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
      |> assign(:errors, Enum.map(assigns.field.errors, &translate_error(&1)))
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
     |> assign_value_label()
     |> assign_filtered_options()}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :dd_id, assigns.id <> "-dropdown")

    ~H"""
    <div id={@id} phx-feedback-for={@name} phx-hook="SelectComponent">
      <.proxy_input {assigns} />
      <.label><%= @label %></.label>
      <.dropdown
        id={@dd_id}
        on_open={focus_search_input(@id)}
        phx-blur={nil}
        error={@field.form.source.action && @field.errors != []}
      >
        <:closed>
          <%= if value_empty?(@field.value) do %>
            <span class="text-zinc-600"><%= @placeholder %></span>
          <% else %>
            <%= @value_label %>
          <% end %>
        </:closed>

        <form>
          <input
            role="combobox"
            aria-autocomplete="list"
            aria-owns={"#{@name}-results"}
            aria-label={"#{@label} Search"}
            phx-click-away={close_dropdown(@dd_id)}
            phx-keydown={JS.exec("phx-click-away")}
            phx-key="Tab"
            phx-change="search"
            phx-target={@myself}
            phx-debounce={@search_debounce}
            name="search"
            id={@id <> "search"}
            autocomplete="off"
            placeholder={@value_label || @placeholder}
            value={@search}
            class="outline-0 w-full text-zinc-900 placeholder:text-zinc-500 sm:text-sm sm:leading-6"
          />
        </form>

        <:expanded class="!px-2">
          <ul id={"#{@name}-results"} role="listbox">
            <li
              :for={{opt_label, opt_id} <- @filtered_options}
              id={"suggestion-#{opt_id}"}
              data-value={opt_id}
              role="option"
              phx-hover={JS.set_attribute({"data-ui-active", "true"}, to: "suggestion-#{opt_id}")}
              phx-click={select_option(@field, opt_id)}
              class="px-2 data-[ui-active]:bg-cyan-50 rounded-md cursor-pointer"
            >
              <%= opt_label %>
            </li>
          </ul>

          <.empty_state :if={@filtered_options == []} />
        </:expanded>
      </.dropdown>

      <.error :for={msg <- @errors}><%= msg %></.error>
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
    JS.dispatch("select-option", to: "select[name='#{field.name}']", detail: option)
  end

  def focus_search_input(id) do
    input_selector = "##{id} input[name='search']"

    JS.dispatch("clear-search", to: input_selector)
    |> JS.focus(to: input_selector)
  end

  @impl true
  def handle_event("search", %{"search" => search_text}, socket) do
    {:noreply, socket |> assign(search: search_text) |> assign_filtered_options(search_text)}
  end

  defp assign_filtered_options(socket, search_text \\ nil) do
    %{options: options, field: field} = socket.assigns

    filtered_options =
      options
      |> Stream.reject(fn option ->
        option_id(option) == field.value or
          (search_text != nil and not contains_normalized?(option_label(option), search_text))
      end)
      |> Enum.take(@max_filtered_options)

    assign(socket, filtered_options: filtered_options)
  end

  defp contains_normalized?(a, b) do
    String.contains?(String.downcase(a), String.downcase(b))
  end

  defp assign_value_label(socket) do
    %{options: options, field: field} = socket.assigns

    if match?([{_label, _value} | _tail], options) do
      option = fetch_selected_option(field, options)
      assign(socket, :value_label, option_label(option))
    else
      assign(socket, :value_label, field.value)
    end
  end

  # Returns the option for the association in changeset with cardinality 1.
  defp fetch_selected_option(field, options) do
    id = field.value |> field_value_to_id() |> to_string()

    Enum.find(options, fn
      {_label, opt_id} -> to_string(opt_id) == id
      opt_id -> to_string(opt_id) == id
    end)
  end

  defp field_value_to_id(value) do
    case value do
      "" -> nil
      nil -> nil
      %{id: id} -> id
      val when is_binary(val) or is_bitstring(val) or is_integer(val) or is_atom(val) -> val
    end
  end

  defp option_label({label, _id}), do: label
  defp option_label(value), do: value
  defp option_id({_label, id}), do: id
  defp option_id(value), do: value
end

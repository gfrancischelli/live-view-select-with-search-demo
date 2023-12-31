defmodule DemoWeb.Components.SearchSelect do
  use DemoWeb, :live_component
  import DemoWeb.CoreComponents

  alias Phoenix.LiveView.JS

  @max_filtered_options 10

  attr :placeholder, :string, default: "Select"
  attr :search_debounce, :integer, default: 100

  attr :options, :any, default: :async
  attr :option_label, :atom, default: nil
  attr :load_options, :any, default: nil

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def search_select(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@field.id} {assigns} />
    """
  end

  def update_options(id, options) when is_list(options) do
    send_update(__MODULE__, id: id, async_options: options)
  end

  @impl true
  def update(%{async_options: async_options}, socket) do
    {:ok,
     socket
     |> assign(:options, async_options)
     |> assign_selected_option()
     |> assign_filtered_options()}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:lazy?, fn -> assigns.options == :async end)
     |> assign(:options, if(assigns.options == :async, do: [], else: assigns.options))
     |> assign(name: assigns.field.name, search: "")
     |> assign_new(:label, fn -> Phoenix.Naming.humanize(assigns.field.field) end)
     |> assign(:errors, Enum.map(assigns.field.errors, &translate_error(&1)))
     |> assign(:dd_id, assigns.field.id <> "-dropdown")
     |> assign(:multiple?, is_list(assigns.field.value))
     |> assign(:value, fn -> assigns.field.value end)
     |> assign_selected_option()
     |> assign_filtered_options()
     |> then(&assign(&1, :on_select, on_select(&1.assigns)))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="group/select"
      phx-feedback-for={@name}
      phx-hook="SelectComponent"
      phx-click-away={close_dropdown(@dd_id)}
      data-js-on-select={@on_select}
      data-js-field={@field.field}
    >
      <.proxy_input multiple?={@multiple?} field={@field} options={@selected_option} />
      <.label><%= @label %></.label>
      <.dropdown
        id={@dd_id}
        on_open={focus_search_input(@id)}
        on_blur={nil}
        error={@field.form.source.action && @field.errors != []}
      >
        <:closed :if={not @multiple?}>
          <%= if value_empty?(@field.value) do %>
            <span class="text-zinc-600"><%= @placeholder %></span>
          <% else %>
            <%= option_label(@selected_option) %>
          <% end %>
        </:closed>

        <div class="flex items-center flex-wrap gap-0.5">
          <.option_pill
            :for={{label, id} <- List.wrap(@selected_option)}
            :if={@multiple?}
            id={id}
            label={label}
            phx-click={JS.dispatch("remove-option")}
          />
          <input
            role="combobox"
            aria-autocomplete="list"
            aria-owns={"#{@name}-results"}
            aria-label={"#{@label} Search"}
            phx-keydown={JS.exec("phx-click-away", to: "##{@id}")}
            phx-change={JS.dispatch("do-search")}
            phx-key="Tab"
            phx-target={unless(@lazy? and @load_options == nil, do: @myself)}
            phx-debounce={@search_debounce}
            name="search"
            id={@id <> "search"}
            autocomplete="off"
            placeholder={!@multiple? && (option_label(@selected_option) || @placeholder)}
            value={@search}
            class={
              [
                "outline-0 text-zinc-900 placeholder:text-zinc-500 sm:text-sm sm:leading-6",
                if(@multiple?, do: "inline w-auto pl-1", else: "w-full"),
                # Only display when input is open or no option is selected
                @multiple? && "hidden group-data-[ui-open]/dropdown:block [&:nth-child(1)]:block"
              ]
            }
          />
        </div>

        <:expanded class="!px-2">
          <.loading_indicator />

          <div class="group-data-[ui-loading]/select:hidden">
            <ul id={"#{@name}-results"} role="listbox" class="group/listbox">
              <li
                :for={{{opt_label, opt_id}, index} <- Enum.with_index(@filtered_options)}
                id={"suggestion-#{@name}-#{opt_id}"}
                data-ui-active={index == 0}
                data-value={opt_id}
                role="option"
                phx-click={select_option(opt_id)}
                class="px-2 data-[ui-active]:bg-cyan-50 rounded-md cursor-pointer"
              >
                <%= opt_label %>
              </li>
            </ul>

            <.empty_state :if={@filtered_options == []} />
          </div>
        </:expanded>
      </.dropdown>

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp loading_indicator(assigns) do
    ~H"""
    <.delay_loading>
      <.spinner />
    </.delay_loading>
    """
  end

  defp proxy_input(assigns) do
    assigns =
      assigns
      |> assign(:value, field_value_to_id(assigns.field.value))
      |> assign(:name, select_name(assigns.field))

    ~H"""
    <select multiple={@multiple?} class="hidden" name={@name}>
      <option value=""></option>
      <%= Phoenix.HTML.Form.options_for_select(List.wrap(@options), @value) %>
    </select>
    """
  end

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :rest, :global, include: [:"phx-click"]

  defp option_pill(assigns) do
    ~H"""
    <span class="rounded bg-indigo-500 py-0.5 px-1.5 text-white inline-flex items-center gap-1">
      <span><%= @label %></span>
      <button tabindex="-1" type="button" class="grid" data-value={@id} {@rest}>
        <.icon name="hero-x-mark h-3.5 w-3.5" />
      </button>
    </span>
    """
  end

  defp select_name(field) do
    field.name <> if(is_list(field.value), do: "[]", else: "")
  end

  defp value_empty?(value) do
    value == "" or value == nil or value == []
  end

  # JS Dispatches
  defp on_select(%{multiple?: multiple?, id: id, dd_id: dd_id}) do
    if multiple?, do: focus_search_input(id), else: close_dropdown(dd_id)
  end

  defp select_option(option) do
    JS.dispatch("select-option", detail: %{id: option})
  end

  def focus_search_input(id) do
    input_selector = "##{id} input[name='search']"

    %JS{}
    |> JS.focus(to: input_selector)
    |> JS.dispatch("do-search", to: input_selector)
  end

  @impl true
  def handle_event("search", %{"search_text" => search_text}, socket) do
    {:noreply,
     socket
     |> assign_options_from_loader(search_text)
     |> assign_filtered_options(search_text)}
  end

  defp assign_options_from_loader(socket, search_text) do
    with %{assigns: %{load_options: loader}} when loader != nil <- socket do
      assign(socket, :options, loader.(search_text))
    end
  end

  defp assign_filtered_options(socket, search_text \\ nil)

  defp assign_filtered_options(%{assigns: %{options: :async}} = socket, _search) do
    socket
  end

  defp assign_filtered_options(socket, search_text) do
    %{options: options, field: field} = socket.assigns

    selected_ids =
      field.value
      |> List.wrap()
      |> Enum.map(&field_value_to_id/1)

    filtered_options =
      options
      |> Stream.reject(fn option ->
        (option_id(option) |> to_string()) in selected_ids or
          (search_text != nil and not contains_normalized?(option_label(option), search_text))
      end)
      |> Enum.take(@max_filtered_options)

    assign(socket, filtered_options: filtered_options)
  end

  defp contains_normalized?(a, b) do
    String.contains?(String.downcase(a), String.downcase(b))
  end

  defp assign_selected_option(%{assigns: %{option_label: nil}} = socket) do
    %{options: options, field: field} = socket.assigns
    assign(socket, :selected_option, fetch_selected_option(field, options))
  end

  defp assign_selected_option(%{assigns: %{option_label: option_label}} = socket) do
    %{field: field} = socket.assigns

    selection =
      case field do
        %{value: [bin | _tail]} when is_binary(bin) ->
          field
          |> get_in([Access.key(:form), Access.key(:data), Access.key(field.field)])
          |> field_value_to_option_tuple(option_label)

        %{value: value} ->
          field_value_to_option_tuple(value, option_label)
      end

    assign(socket, :selected_option, selection)
  end

  defp field_value_to_option_tuple(value, option_label) do
    case value do
      %{^option_label => label, :id => id} ->
        {label, id}

      [_head | _tail] ->
        value
        |> Enum.map(&field_value_to_option_tuple(&1, option_label))
        |> Enum.reject(&is_nil/1)

      %Ecto.Changeset{action: action, data: data} when action != :replace ->
        field_value_to_option_tuple(data, option_label)

      _ ->
        nil
    end
  end

  defp fetch_selected_option(field, [head | _tail]) when not is_tuple(head) do
    # The value is equal to the label
    {field.value, field.value}
  end

  defp fetch_selected_option(%{value: value}, options) when is_list(value) do
    ids = Enum.map(value, fn val -> val |> field_value_to_id() |> to_string() end)

    Enum.filter(options, fn option -> (option |> option_id() |> to_string()) in ids end)
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
      "" ->
        nil

      nil ->
        nil

      %{id: id} ->
        to_string(id)

      val when is_binary(val) or is_bitstring(val) or is_integer(val) or is_atom(val) ->
        to_string(val)

      %Ecto.Changeset{action: action, data: %{id: id}} when action != :replace ->
        to_string(id)

      value when is_list(value) ->
        Enum.map(value, &field_value_to_id/1)

      %Ecto.Association.NotLoaded{__field__: field} ->
        raise("Association #{field} must be loaded.")

      _ ->
        nil
    end
  end

  defp option_label(list) when is_list(list), do: nil
  defp option_label({label, _id}), do: label
  defp option_label(value), do: value

  defp option_id(list) when is_list(list), do: nil
  defp option_id({_label, id}), do: id
  defp option_id(value), do: value
end

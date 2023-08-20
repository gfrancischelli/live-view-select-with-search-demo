const INPUT_EVENT = new Event("input", { bubbles: true });

export const SelectComponent = {
  mounted() {
    const select = this.el.querySelector("select")
    const searchInput = this.el.querySelector("input[name='search']")
    const listBox = this.el.querySelector("[role='listbox']")

    select.addEventListener(`select-option`, (event) => {
      select_option(select, event.detail);
    });

    this.el.addEventListener("clear-search", () => {
      searchInput.value = ""
      searchInput.dispatchEvent(INPUT_EVENT)
    });

    listBox.addEventListener("mouseover", (event) => {
      const option = event.toElement;

      if (option instanceof HTMLLIElement) {
        clear_active_results(listBox)
        option.setAttribute("data-ui-active", true)
        searchInput.setAttribute("aria-activedescendant", option.id)
      }
    });

    searchInput.addEventListener("keydown", (event) => {
      switch (event.key) {
        case "ArrowUp":
          event.preventDefault()
          set_next_active_option(listBox, "up", searchInput)
          break;
        case "ArrowDown":
          event.preventDefault()
          set_next_active_option(listBox, "down", searchInput)
          break;
        case "Enter":
          event.preventDefault();
          const active_option = get_active_option(listBox);
          if (active_option) {
            select_option(select, active_option.getAttribute("data-value"))
            this.liveSocket.execJS(searchInput, searchInput.getAttribute("phx-click-away"))
          }
          break;
      }
    });
  }
}

function get_active_option(listBox) {
  return listBox.querySelector("[data-ui-active]")
}

function set_next_active_option(listBox, direction, searchInput) {
  const active_option = get_active_option(listBox)

  let new_active_option;

  if (direction == "down") {
    new_active_option = active_option?.nextElementSibling || listBox.querySelector("[role='option']:first-child")
  }

  if (direction == "up") {
    new_active_option = active_option?.previousElementSibling || listBox.querySelector("[role='option']:last-child")
  }

  active_option?.removeAttribute("data-ui-active")
  new_active_option?.setAttribute("data-ui-active", true)
  searchInput.setAttribute("aria-activedescendant", new_active_option?.id)
}

function clear_active_results(listbox) {
  for (const el of listbox.querySelectorAll("[data-ui-active]")) {
    el.removeAttribute("data-ui-active");
  }
}

function select_option(select, option_text) {
  const option = document.createElement("option");

  option.selected = true;
  option.value = option_text;
  option.text = option_text;

  select.add(option);

  select.dispatchEvent(INPUT_EVENT);
}

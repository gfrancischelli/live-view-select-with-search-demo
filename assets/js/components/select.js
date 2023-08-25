const INPUT_EVENT = new Event("input", { bubbles: true });

export const SelectComponent = {
  mounted() {
    const hook = this;

    this.select = this.el.querySelector("select")
    this.listBox = this.el.querySelector("[role='listbox']")
    this.searchInput = this.el.querySelector("input[name='search']")

    this.select.addEventListener("select-option", (event) => {
      this.select_option(event.detail.id);
    });

    this.el.addEventListener("remove-option", (event) => {
      this.remove_option(event.target.getAttribute("data-value"));
    });

    this.el.addEventListener("clear-search", () => {
      this.searchInput.value = ""
      this.searchInput.dispatchEvent(INPUT_EVENT)
    });

    this.listBox.addEventListener("mouseover", (event) => {
      const option = event.toElement;

      if (option instanceof HTMLLIElement) {
        this.clear_active_results()
        option.setAttribute("data-ui-active", true)
        this.searchInput.setAttribute("aria-activedescendant", option.id)
      }
    });

    this.searchInput.addEventListener("keydown", (event) => {
      switch (event.key) {
        case "ArrowUp":
          event.preventDefault()
          this.set_next_active_option("up")
          break;
        case "ArrowDown":
          event.preventDefault()
          this.set_next_active_option("down")
          break;
        case "Enter":
          event.preventDefault();
          const active_option = this.get_active_option();
          if (active_option) hook.select_option(active_option.getAttribute("data-value"));
          break;
        case "Backspace":
          if (this.searchInput.value == "" && event.repeat == false) {
            this.remove_last_active_option();
          }
          break;
        case "Escape":
          this.liveSocket.execJS(this.el, this.el.getAttribute("phx-click-away"));
          break;
      }
    });
  },
  remove_option(value) {
    this.select.querySelector(`option[selected][value='${value}']`).remove()
    this.select.dispatchEvent(INPUT_EVENT);
    const cmd = this.el.getAttribute("data-js-on-select")
    if (cmd) this.liveSocket.execJS(this.el, cmd)
  },
  remove_last_active_option() {
    if (this.select.type == "select-multiple") {
      const length = this.select.selectedOptions.length;
      if (length != 0) {
        this.select.selectedOptions[length - 1].remove();
        this.select.dispatchEvent(INPUT_EVENT);
      }
    }
  },
  select_option(value) {
    const option = document.createElement("option");

    option.selected = true;
    option.value = value;

    this.select.add(option);
    this.select.dispatchEvent(INPUT_EVENT);

    this.searchInput.value = ""

    const cmd = this.el.getAttribute("data-js-on-select")
    if (cmd) this.liveSocket.execJS(this.el, cmd)
  },
  get_active_option() {
    return this.listBox.querySelector("[data-ui-active]");
  },
  clear_active_results() {
    for (const el of this.listBox.querySelectorAll("[data-ui-active]")) {
      el.removeAttribute("data-ui-active");
    }
  },
  set_next_active_option(direction) {
    const active_option = this.get_active_option()

    let new_active_option;

    if (direction == "down") {
      new_active_option = active_option?.nextElementSibling ||
        this.listBox.querySelector("[role='option']:first-child")
    }

    if (direction == "up") {
      new_active_option = active_option?.previousElementSibling ||
        this.listBox.querySelector("[role='option']:last-child")
    }

    active_option?.removeAttribute("data-ui-active")
    new_active_option?.setAttribute("data-ui-active", true)

    this.searchInput.setAttribute("aria-activedescendant", new_active_option?.id)
  }
}

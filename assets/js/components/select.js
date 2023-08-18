const INPUT_EVENT = new Event("input", { bubbles: true });

export const SelectComponent = {
  mounted() {
    const select = this.el.querySelector("select")
    const searchInput = this.el.querySelector("input[name='search']")

    select.addEventListener(`select-option`, (event) => {
      select_option(select, event.detail);
    });

    this.el.addEventListener("clear-search", () => {
      searchInput.value = ""
      searchInput.dispatchEvent(INPUT_EVENT)
    });
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

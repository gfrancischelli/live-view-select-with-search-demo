const INPUT_EVENT = new Event("input", { bubbles: true });

export const SelectComponent = {
  mounted() {
    const select = this.el.querySelector("select")

    select.addEventListener(`select-option`, (event) => {
      select_option(select, event.detail);
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

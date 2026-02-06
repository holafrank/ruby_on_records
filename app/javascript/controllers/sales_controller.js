import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["itemsContainer"];

  connect() {
    this.itemCount = document.querySelectorAll(".item-fields").length;
  }

  addItem(event) {
    event.preventDefault();

    this.itemCount++;
    const time = new Date().getTime();
    const template = `
      <div class="item-fields grid" style="color: #1343a0; font-size: 18px;  padding: 0.2rem;">
        <div>
          <label for="sale_items_attributes_${time}_disk_id">Disco</label>
          <select name="sale[items_attributes][${time}][disk_id]"
                  id="sale_items_attributes_${time}_disk_id"
                  class="form-select">
            <option value="">Seleccione un disco...</option>
            ${this.getDiskOptions()}
          </select>
        </div>

        <div>
          <label for="sale_items_attributes_${time}_amount">Cantidad</label>
          <input type="number"
                 value="1"
                 min="1"
                 name="sale[items_attributes][${time}][amount]"
                 id="sale_items_attributes_${time}_amount"
                 class="form-input">
        </div>

        <div>
          <label>&nbsp;</label>

          <button
            type="button"
            class="secondary"
            data-action="click->sales#removeItem"
            data-item-id="<%= item_form.object.id if item_form.object.persisted? %>"
            data-item-persisted="<%= item_form.object.persisted? %>"
            style="
              color: #b92621;
              font-family: monospace;
              font-size: 18px;
              background: transparent;
              border: transparent;
              cursor: pointer;
              text-decoration: underline;
            "
          >
            Eliminar
          </button>
        </div>

      </div>
    `;

    this.itemsContainerTarget.insertAdjacentHTML("beforeend", template);
  }

  removeItem(event) {
    const button = event.currentTarget;
    const itemField = button.closest(".item-fields");
    const isPersisted = button.dataset.itemPersisted === "true";
    const itemId = button.dataset.itemId;

    if (isPersisted && itemId) {
      // Item existente en BD - marcar para destrucción
      const destroyField = itemField.querySelector(".destroy-field");
      if (destroyField) {
        // Cambiar valor a "1" para marcar eliminación
        destroyField.value = "1";
        // Ocultar el item pero mantenerlo en el DOM
        itemField.style.display = "none";
        // Cambiar texto del botón (opcional)
        button.textContent = "Restaurar";
        button.dataset.action = "click->sales#restoreItem";
      }
    } else {
      // Item nuevo - eliminar del DOM
      if (this.itemsContainerTarget.children.length > 1) {
        itemField.remove();
      }
    }
  }

  restoreItem(event) {
    const button = event.currentTarget;
    const itemField = button.closest(".item-fields");
    const destroyField = itemField.querySelector(".destroy-field");

    if (destroyField) {
      // Cambiar valor a "0" para restaurar
      destroyField.value = "0";
      // Mostrar el item
      itemField.style.display = "";
      // Cambiar texto del botón
      button.textContent = "Eliminar";
      button.dataset.action = "click->sales#removeItem";
    }
  }

  getDiskOptions() {
    // Obtener opciones del primer select existente
    const firstSelect = document.querySelector('select[name*="disk_id"]');
    if (firstSelect) {
      // Clonar las opciones excluyendo la primera (blank)
      const options = Array.from(firstSelect.options);
      return options
        .slice(1)
        .map(
          (option) => `<option value="${option.value}">${option.text}</option>`,
        )
        .join("");
    }
    return "";
  }
}

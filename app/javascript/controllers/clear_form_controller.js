import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  clear() {
    this.element.reset(); // Clears the form fields
  }
}
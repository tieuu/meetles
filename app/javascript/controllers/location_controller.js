import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ 'location' ];

  refresh(event) {
    console.log(event);
  }
}

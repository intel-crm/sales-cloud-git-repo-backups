import { LightningElement, track } from "lwc";

export default class CoreIpsSearchComponent extends LightningElement {
  @track searchKey;

  handleChange(event) {
    /* eslint-disable no-console */
    console.log("event.target.value ::: Search key " + event.target.value);
    this.searchKey = event.target.value;
    /* eslint-disable no-console */
    event.preventDefault();
    const searchEvent = new CustomEvent("change", {
      detail: this.searchKey
    });
    this.dispatchEvent(searchEvent);
  }
}
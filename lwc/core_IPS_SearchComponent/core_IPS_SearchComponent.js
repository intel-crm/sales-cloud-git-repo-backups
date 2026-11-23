import { LightningElement, api, track } from "lwc";
import MIN_CHAR_MSG from '@salesforce/label/c.Core_IPS_MinCharMsg';

export default class Core_IPS_SearchComponent extends LightningElement {
  @api isRequiredField;
  @api label;
  @api placeholder;
  
  @track searchKey;
  @track searchKeyLenMsg;
  searchKeyCharlenErrMsg = MIN_CHAR_MSG;

 connectedCallback() {

  if(this.placeholder === undefined || this.placeholder === null || this.placeholder === "") {
    this.placeholder = "Search...";
  }
 }

  handleChange(event) {
    /* eslint-disable no-console */
    console.log("event.target.value ::: Search key " + event.target.value);
    this.searchKey = event.target.value;
    /* eslint-disable no-console */
    if(this.searchKey !== undefined && this.searchKey !== null) {
      if(this.searchKey.length<3) {
        this.searchKeyLenMsg = true;
      } else {
        this.searchKeyLenMsg = false;
      }
      if(this.searchKey.length<1) {
        this.searchKeyLenMsg = false;
      }
    } else {
      this.searchKeyLenMsg = true;
    }
    event.preventDefault();
    const searchEvent = new CustomEvent("change", {
      detail: this.searchKey
    });
    this.dispatchEvent(searchEvent);
  }

  handleFocusOut() {
    const focusOutEvent = new CustomEvent("focusout", {
      detail: this.searchKey
    });
    this.dispatchEvent(focusOutEvent);
  }
}
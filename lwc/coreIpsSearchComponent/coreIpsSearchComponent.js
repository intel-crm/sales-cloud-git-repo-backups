import { LightningElement, track,api } from "lwc";

export default class CoreIpsSearchComponent extends LightningElement {
  @api projectfromparent; //come from its parent lwc
  @track searchKey;

  handleChange(event) {
    /* eslint-disable no-console */
    //console.log("event.target.value ::: Search key " + event.target.value);
    this.searchKey = event.target.value;
    /* eslint-disable no-console */
    event.preventDefault();
    const searchEvent = new CustomEvent("change", {
      detail: this.searchKey
    });
    this.dispatchEvent(searchEvent);
  }
  get sendProject(){
    this.searchKey = ((this.searchKey == "" || this.searchKey == undefined) ? (this.projectfromparent) : (this.searchKey))
    //console.log('searchKey----',this.searchKey);
   // console.log('projectfromparent----',this.projectfromparent);
        return this.searchKey;
  }
  renderedCallback() {
    console.log('getPrject renderedCallback in final childcmp----',this.projectfromparent);
  }
}
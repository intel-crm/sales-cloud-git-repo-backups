import { LightningElement, track } from "lwc";

export default class SearchComponent extends LightningElement {
  @track searchKey;
  @track projrequired;

  handleChange(event) {
    /* eslint-disable no-console */
    //console.log('Search Event Started ');
    console.log("event.target.value ::: Search key " + event.target.value);
    this.searchKey = event.target.value;
    /* eslint-disable no-console */
    event.preventDefault();
    const searchEvent = new CustomEvent("change", {
      detail: this.searchKey
    });
    this.dispatchEvent(searchEvent);
  }

  handleonfocus(event){
    console.log('Inside onfocus')
    // console.log('handleonfocus project combo',this.projrequired);
    // this.projrequired = this.template.querySelector('.projectcombobox');
    // const projst = new CustomEvent("removereq",{
    //   detail: this.projrequired
    // });
    // this.dispatchEvent(projst);
    
  }
  
}
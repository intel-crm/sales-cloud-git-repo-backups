import { LightningElement, api, track } from "lwc";

export default class CoreIpsRecordList extends LightningElement {
  @api record;
  @api fieldname;
  @api iconname;

  @track recordtest;

  handleSelect(event) {
    const selectedRecord = new CustomEvent("select", {
      detail: this.record.Id
    });
    /* eslint-disable no-console */
    /* fire the event to be handled on the Parent Component */
    this.dispatchEvent(selectedRecord);
  }

  connectedCallback() {
    let splittedText = [];
    let splitResult = this.record;
    console.log('Account ID 22',this.record)
    splittedText = this.fieldname.split('.');
    if(splittedText.length>0) {
      for(let i=0;i<splittedText.length;i++){
        splitResult = splitResult[splittedText[i]];
      }
      this.recordtest = splitResult;
      console.log('Account records', this.recordtest)
    } else {
      this.recordtest = this.record[this.fieldname];
      console.log('Account ID 22',this.recordtest)
    }
  }

  // renderedCallback(){
  // console.log('Account ID 37',recordtest)
  // }
}
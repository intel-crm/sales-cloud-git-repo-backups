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
    splittedText = this.fieldname.split('.');
    if(splittedText.length>0) {
      for(let i=0;i<splittedText.length;i++){
        splitResult = splitResult[splittedText[i]];
      }
      this.recordtest = splitResult;
    } else {
      this.recordtest = this.record[this.fieldname];
    }
  }
}
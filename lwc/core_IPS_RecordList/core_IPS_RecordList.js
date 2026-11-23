import { LightningElement, api, track } from "lwc";

export default class Core_IPS_RecordList extends LightningElement {
  @api record;
  @api fieldname;
  @api iconname;

  @api extraField1Label;
  @api extraField1;
  @track extraField1Value;
  @api extraField2Label;
  @api extraField2;
  @track extraField2Value;

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
      if(this.extraField1Label !== undefined && this.extraField1Label !== null && this.extraField1Label !== '' ) {
        let splittedText1 = [];
        splitResult = this.record;
        splittedText1 = this.extraField1.split('.');
        if(splittedText1.length>0) {
          for(let i=0;i<splittedText1.length;i++){
            splitResult = splitResult[splittedText1[i]];
          }
          this.extraField1Value = splitResult;
        } else {
          this.extraField1Value = this.record[this.extraField1];
        }
      }
      if(this.extraField2Label !== undefined && this.extraField2Label !== null && this.extraField2Label !== '' ) {
        let splittedText2 = [];
        splitResult = this.record;
        splittedText2 = this.extraField2.split('.');
        if(splittedText2.length>0) {
          for(let i=0;i<splittedText2.length;i++){
            splitResult = splitResult[splittedText2[i]];
          }
          this.extraField2Value = splitResult;
        } else {
          this.extraField2Value = this.record[this.extraField2];
        }
      }
    } else {
      this.recordtest = this.record[this.fieldname];
      if(this.extraField1Label !== undefined && this.extraField1Label !== null && this.extraField1Label !== '' ) {
        let splittedText1 = [];
        splitResult = this.record;
        splittedText1 = this.extraField1.split('.');
        if(splittedText1.length>0) {
          for(let i=0;i<splittedText1.length;i++){
            splitResult = splitResult[splittedText1[i]];
          }
          this.extraField1Value = splitResult;
        } else {
          this.extraField1Value = this.record[this.extraField1];
        }
      }
      if(this.extraField2Label !== undefined && this.extraField2Label !== null && this.extraField2Label !== '' ) {
        let splittedText2 = [];
        splitResult = this.record;
        splittedText2 = this.extraField2.split('.');
        if(splittedText2.length>0) {
          for(let i=0;i<splittedText2.length;i++){
            splitResult = splitResult[splittedText2[i]];
          }
          this.extraField2Value = splitResult;
        } else {
          this.extraField2Value = this.record[this.extraField2];
        }
      }
    }
  }
}
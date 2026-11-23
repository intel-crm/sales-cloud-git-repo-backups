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
  //Added by Chetan on 16-10-2024 -(TWC745-5178) As Part of Adding Account id to Account search  
  @api extraField3Label;
  @api extraField3;
  @track extraField3Value
 

  @track recordtest;

  handleSelect(event) {
    const selectedRecord = new CustomEvent("select", {
      detail: this.record.Id
    });
    /* eslint-disable no-console */
    /* fire the event to be handled on the Parent Component */
    this.dispatchEvent(selectedRecord);
  }

 @track isLightingportal = false;
  connectedCallback() {
   if(window.location.href.includes('IPS')) {
      this.isLightingportal = true;
   }
   // console.log('connectedcallback recrodlist');
    let splittedText = [];
    let splitResult = this.record;
    splittedText = this.fieldname?.split('.');
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
     //Added by Chetan on 16-10-2024 -(TWC745-5178) As Part of Adding Account id to Account search  
      if(this.extraField3Label !== undefined && this.extraField3Label !== null && this.extraField3Label !== '' ) {
        let splittedText3 = [];
        splitResult = this.record;
        splittedText3 = this.extraField3.split('.');
        if(splittedText3.length>0) {
          for(let i=0;i<splittedText3.length;i++){
            splitResult = splitResult[splittedText3[i]];
          }
          this.extraField3Value = splitResult;
        } else {
          this.extraField3Value = this.record[this.extraField3];
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
      //Added by Chetan on 16-10-2024 -(TWC745-5178) As Part of Adding Account id to Account search  
      if(this.extraField2Labe3 !== undefined && this.extraField2Labe3 !== null && this.extraField2Labe3 !== '' ) {
        let splittedText3 = [];
        splitResult = this.record;
        splittedText3 = this.extraField3.split('.');
        if(splittedText3.length>0) {
          for(let i=0;i<splittedText3.length;i++){
            splitResult = splitResult[splittedText3[i]];
          }
          this.extraField3Value = splitResult;
        } else {
          this.extraField3Value = this.record[this.extraField3];
        }
      }

    }
    //to handle not appliacle automatically
    /*let countNotApplicable =  sessionStorage.getItem('NotApplicableCount');
    
    countNotApplicable++;
    if(countNotApplicable == 1){
      const selectedRecord = new CustomEvent("select", {
        detail: null
      });
      // eslint-disable no-console 
      //fire the event to be handled on the Parent Component 
     
      this.dispatchEvent(selectedRecord);
    }
    sessionStorage.setItem("NotApplicableCount", countNotApplicable );*/
  }
}
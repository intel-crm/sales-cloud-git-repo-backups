import { LightningElement, track, api } from "lwc";
import findRecords from "@salesforce/apex/CustomLookupController.findRecords";

export default class CustomLookup extends LightningElement {

  @api selectedRecord;
  @api iconname;
  @api queryString;
  @api searchfieldName;
  @api recordsToSearch;
  @api queryExecutionRequired; 
  @api  projrequired;

  @track searchKey;
  
  @track isRecordsPresent = true;
  @track selectedRecordFieldlabel;
  @track records;
  @track error;

  connectedCallback() {
    let splittedText = [];
    
    /*if((this.queryExecutionRequired === undefined || this.queryExecutionRequired === null) && (this.queryString !== undefined && this.queryString !== null) ) {
      this.queryExecutionRequired = true;
      console.log('line 27 ' );
    } else {
      this.queryExecutionRequired = false;console.log('line 29 ' );
    }*/
    
    if (this.selectedRecord !== undefined && this.selectedRecord !== null) {
      let splitResult = this.selectedRecord;
      splittedText = this.searchfieldName.split('.');
      if (splittedText.length > 0) {
        for (let i = 0; i < splittedText.length; i++) {
          splitResult = splitResult[splittedText[i]];
        }
        this.selectedRecordFieldlabel = splitResult;
      } else {
        this.selectedRecordFieldlabel = this.selectedRecord[this.searchfield];
      }
    }
  }

  handlelookup(){
    console.log('handlelookup called ' );
    console.log('this.queryExecutionRequired ', this.queryExecutionRequired);
    console.log('this.searchfieldName ', this.searchfieldName);
    console.log('this.queryString ', this.queryString);
    console.log('this.iconname ', this.iconname);
    if ((this.queryExecutionRequired || this.queryExecutionRequired === "true") && this.searchKey !== undefined && this.searchKey !== null && this.queryString !== undefined && this.queryString !== null) {
      console.log("event.target.value ::: Search key  in main comp ::: " + this.searchKey);
      findRecords({
        searchKey: this.searchKey,
        queryString: this.queryString
      })
        .then(result => {
          if (result !== undefined && result !== null) {
            this.records = result;
            this.error = undefined;
            this.isRecordsPresent = true;
          } else {
            this.isRecordsPresent = false;
          }
        })
        .catch(error => {
          this.error = error;
          this.isRecordsPresent = false;
        });
    } else {
      console.log('handlelookup called ', this.queryExecutionRequired );
      if(!this.queryExecutionRequired || this.queryExecutionRequired === "false" ) {
        let key = (this.searchKey !== undefined && this.searchKey !== null && this.searchKey.length>0) ? this.searchKey.toLowerCase() : null;  
        this.records = this.recordsToSearch.filter((item) => item.Name.toLowerCase().includes(key));
        if(this.records !== undefined && this.records !== null && this.records.length>0) {
          this.isRecordsPresent = true;
        } else {
          this.isRecordsPresent = false;
        }
      }
    }
  }
  handleOnchange(event) {
    this.searchKey = event.detail.value;
    clearTimeout(this.timeoutId); // no-op if invalid id
    this.timeoutId = setTimeout(this.handlelookup.bind(this), 500); // Adjust as necessary
    
  }

handleremovereq(event){
  this.projrequired = event.detail.value;
  console.log('projrequired 91',this.projrequired);
  const sendtoform1 = new CustomEvent("removereqform1",{
  detail: this.projrequired
      });
      this.dispatchEvent(sendtoform1);
}

  handleSelect(event) {
    const selectedRecordId = event.detail;
    this.isRecordsPresent = false;
    /* eslint-disable no-console*/
    this.selectedRecord = this.records.find(
      record => record.Id === selectedRecordId
    );
    /* fire the event with the value of RecordId for the Selected RecordId */
    const selectedRecordEvent = new CustomEvent("selectedrec", {
      detail: {
        recordId: selectedRecordId,
        record: this.selectedRecord
      }
    });
    let splittedText = [];
    if (this.selectedRecord !== undefined && this.selectedRecord !== null) {
      let splitResult = this.selectedRecord;
      //console.log('split1' + splitResult);
      splittedText = this.searchfieldName.split('.');
      //console.log('split' + splittedText);
      if (splittedText.length > 0) {
        for (let i = 0; i < splittedText.length; i++) {
          splitResult = splitResult[splittedText[i]];

        }
        this.selectedRecordFieldlabel = splitResult;
      } else {
        this.selectedRecordFieldlabel = this.selectedRecord[this.searchfield];
      }
    }
    this.dispatchEvent(selectedRecordEvent);
  }

  handleRemove(event) {
    console.log('handleRemove called in custom lookup');
    event.preventDefault();
    this.isRecordsPresent = false;
    this.selectedRecord = undefined;
    this.records = undefined;
    this.error = undefined;
    /* fire the event with the value of undefined for the Selected RecordId */
    const selectedRecordEvent = new CustomEvent("selectedrec", {
      detail: {
        recordId: undefined,
        record: undefined
      }
    });
    this.dispatchEvent(selectedRecordEvent);
  }

  removeSelected() {
    this.isRecordsPresent = false;
    this.selectedRecord = undefined;
    this.records = undefined;
    this.error = undefined;
    /* fire the event with the value of undefined for the Selected RecordId */
    const selectedRecordEvent = new CustomEvent("selectedrec", {
      detail: {
        recordId: undefined,
        record: undefined
      }
    });
    this.dispatchEvent(selectedRecordEvent);
  }
  @api
  removeText(){
    alert('remove called');
    var inputComponent = this.template.querySelector('combobox-id-5');
    inputComponent.value = '';
  }
}
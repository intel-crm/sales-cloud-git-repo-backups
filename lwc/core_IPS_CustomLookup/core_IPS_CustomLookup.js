import { LightningElement, track, api } from "lwc";
import RECORDS_LIMIT from '@salesforce/label/c.Core_IPS_RecordsLimit';
import NO_RECORDS_FOUND from '@salesforce/label/c.Core_IPS_NoRecFoundMsg';
import findRecords from "@salesforce/apex/Core_IPS_CustomLookupController.findRecords";
import findTotalRecords from "@salesforce/apex/Core_IPS_CustomLookupController.findTotalRecords";

export default class Core_IPS_CustomLookup extends LightningElement {

    @api selectedRecord;
    @api iconname;
    @api queryString;
    @api searchfieldName;
    @api recordsToSearch;
    @api queryExecutionRequired;
    @api countQueryString;
    @api isSosl;

    @api isRequiredField;
    @api label;
    @api placeholder;

    @api extraField1Label;
    @api extraField1;
    @api extraField2Label;
    @api extraField2;

    @track searchKey;
    @track isRecordsPresent = true;
    @track selectedRecordFieldlabel;
    @track records;
    @track error;
    @track isRecordLoading = false;
    @track isMoreRecordLoading = false;
    
    totalRecords;
    limit;
    position = 0; 
    scrollBottom = 0;
    flagOnScroll = false;
    scrollableDiv;
    @track margintopforspinner;
    @track isRequiredFieldErrMsg = false;
    
    rec_limit = parseInt(RECORDS_LIMIT, 10);
    noRecordsErr = NO_RECORDS_FOUND;

    connectedCallback() {
        let splittedText = [];
        if ((this.queryExecutionRequired === undefined || this.queryExecutionRequired === null)) {
            this.queryExecutionRequired = true;
        }
        if(this.isSosl === undefined || this.isSosl === null || this.isSosl ==='' ) {
            this.isSosl = false;
        }
        if(this.isRequiredField === undefined || this.isRequiredField === null ) {
            this.isRequiredField = false;
        } else if(this.isRequiredField === "false") {
            this.isRequiredField = false;
        } else if(this.isRequiredField === "true") {
            this.isRequiredField = true;
            this.margintopforspinner = "margin-top:0.7rem;";
        } else {
            this.isRequiredField = false;
            this.margintopforspinner = "margin-top:0rem;";
        }
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

    handlelookup() {
        //console.log("Time to find records count ");
        //console.time();
        this.limit = this.rec_limit;
        console.log("this.searchKey ", this.searchKey);
        console.log("this.queryString ", this.queryString);

        if ((this.queryExecutionRequired || this.queryExecutionRequired === "true") && this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '' && this.searchKey !== ' ' && this.queryString !== undefined && this.queryString !== null) {
            console.log("event.target.value ::: Search key  in main comp ::: " + this.searchKey);
            this.isRecordLoading = true;
            //setTimeout(function() { console.log('Loading...');}, 300);
          
            if(this.countQueryString !== undefined && this.countQueryString !== null && this.countQueryString !== '') {
                findTotalRecords({ searchKey: this.searchKey, query: this.countQueryString })
                .then(result => {
                    console.log("result after count:::::::::", result);
                    this.totalRecords = result;
                    this.errors = undefined;
                })
                .catch(error => {
                    console.log("result after count:::::::::", error);
                    this.errors = error;
                    this.totalRecords = 0;
                });
            } else {
                this.totalRecords = 100;
            }
            
        
            findRecords({
                searchKey: this.searchKey,
                queryString: this.queryString,
                recordLimit: this.limit,
                isSosl: this.isSosl
            })
                .then(result => {
                    if (result !== undefined && result !== null) {
                        this.records = result;
                        this.error = undefined;
                        this.isRecordsPresent = true;
                        this.position = 0;
                        this.flagOnScroll = false;
                        if(this.scrollableDiv !== undefined && this.scrollableDiv !== null) {
                            this.scrollableDiv.scrollTop = 0; 
                        }
                        //setTimeout(function() { console.log('Loaded...');}, 500);
                        console.log('this.records length ', this.records.length);
                        if(this.records.length<1) {
                            this.isRecordsPresent = false;    
                        }
                        this.isRecordLoading = false;
                    } else {
                        this.isRecordsPresent = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Core_IPS_CustomLookup ::: error in loading records in custom lookup ', error);
                    this.isRecordsPresent = false;
                });
               
        } else {
            if (!this.queryExecutionRequired || this.queryExecutionRequired === "false") {
                let key = (this.searchKey !== undefined && this.searchKey !== null && this.searchKey.length > 0) ? this.searchKey.toLowerCase() : null;
                this.records = this.recordsToSearch.filter((item) => item.Name.toLowerCase().includes(key));
                if (this.records !== undefined && this.records !== null && this.records.length > 0) {
                    this.isRecordsPresent = true;
                } else {
                    this.isRecordsPresent = false;
                }
            }
        }
        if(this.searchKey === undefined || this.searchKey === null || this.searchKey === '' || this.searchKey === ' ') {
            this.records = undefined;
        }
        //console.timeEnd();
        //console.log("Time to execute handle lookup ");
      
    }
    handleOnchange(event) {
        this.searchKey = event.detail.value;
        console.log('this.searchKey in main '+ this.searchKey);
        //clearTimeout(this.timeoutId); // no-op if invalid id

        //this.timeoutId = setTimeout(this.handlelookup.bind(this), 500); // Adjust as necessary
        if(this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '') {
            console.log('this.searchKey ', this.searchKey.length );
            if(this.isRequiredField) {
                if(this.isRequiredFieldErrMsg) {
                    this.margintopforspinner = "margin-top: -0.3rem;";
                    if(this.searchKey.length > 2) {
                        this.margintopforspinner = "margin-top: 0rem;";
                    }
                } else {
                    if(this.searchKey.length < 3) {
                        this.margintopforspinner = "margin-top: 0.3rem;";
                    } else {
                        this.margintopforspinner = "margin-top:0.7rem;";
                    }
                }
            } else {
                if(this.searchKey.length < 3) {
                    this.margintopforspinner = "margin-top:-0.5rem;";
                } else {
                    this.margintopforspinner = "margin-top:0rem;";
                }
                if(this.searchKey.length < 1) {
                    this.records = undefined;
                    this.isRecordsPresent = true;
                }
            }

            if(this.searchKey.length > 2) {
                //this.handlelookup();
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(this.handlelookup.bind(this), 500);
            }
        } else {
            this.isRecordsPresent = true;
            this.records = undefined;
        }

    }

    handleFocusOut() {
        let key = this.searchKey;
        if(key === undefined || key === null || key === '') {
            //console.log('This field is Required message displayed');
            this.isRequiredFieldErrMsg = true;
            this.margintopforspinner = "margin-top: -0.3rem;";
        }
        if(key !== undefined && key !== null && key !== '' && key.length > 0 ) {
            //console.log('This field is Required message not displayed displayed');
            this.isRequiredFieldErrMsg = false;
            this.margintopforspinner = "margin-top: 0.3rem;";
        }
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

    @api
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

    onScrollHandle(event) {
        if(this.countQueryString !== undefined && this.countQueryString !== null && this.countQueryString !== '') {
        let newScrollValue = event.target.scrollTop;
        this.scrollableDiv = event.target;
        if(newScrollValue > this.position  ) {
          this.scrollBottom = event.target.scrollHeight - event.target.offsetHeight;
          if(parseInt(newScrollValue, 10) >= this.scrollBottom-1 && this.flagOnScroll === false ) {
            this.flagOnScroll = true;
            if (this.limit<this.totalRecords) {
              this.limit = ((this.limit + this.rec_limit)>this.totalRecords)?(this.limit + (this.totalRecords-this.limit)):this.limit + this.rec_limit;
              console.log('Load More... ', this.limit);
              this.isMoreRecordLoading = true;
              setTimeout(function() { console.log('Loading...');}, 500);
              findRecords({
                searchKey: this.searchKey,
                queryString: this.queryString,
                recordLimit: this.limit,
                isSosl: this.isSosl
              })
                .then(result => {
                  if (result !== undefined && result !== null) {
                    this.records = result;
                    this.error = undefined;
                    this.isRecordsPresent = true;
                    this.flagOnScroll = false;
                    setTimeout(function() { console.log('Loaded...');}, 500);
                    this.isMoreRecordLoading = false;
                  } else {
                    this.isRecordsPresent = false;
                  }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Core_IPS_CustomLookup ::: error in loading records in custom lookup ', error);
                    this.isRecordsPresent = false;
                });
            }
    
          }
        }
        this.position = newScrollValue;
      }
    }
}
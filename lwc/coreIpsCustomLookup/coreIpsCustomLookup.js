import { LightningElement, track, api } from "lwc";
import findRecords from "@salesforce/apex/Core_IPS_CustomLookupController.findRecords";

export default class CoreIpsCustomLookup extends LightningElement {

    @api selectedRecord;
    @api iconname;
    @api queryString;
    @api searchfieldName;
    @api recordsToSearch;
    @api queryExecutionRequired;

    @track searchKey;
    @track isRecordsPresent = true;
    @track selectedRecordFieldlabel;
    @track records;
    @track error;

    connectedCallback() {
        let splittedText = [];
        if((this.queryExecutionRequired === undefined || this.queryExecutionRequired === null)) {
            this.queryExecutionRequired = true;
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

    handleOnchange(event) {
        this.searchKey = event.detail.value;
        console.log('this.queryExecutionRequired ', this.queryExecutionRequired);
        if ((this.queryExecutionRequired || this.queryExecutionRequired === "true") && this.searchKey !== undefined && this.searchKey !== null && this.queryString !== undefined && this.queryString !== null) {
            console.log("coreIpsCustomLookup ::: event.target.value ::: Search key ::: ", this.searchKey);
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
                console.error('coreIpsCustomLookup ::: error in loading records in custom lookup ', error);
                this.isRecordsPresent = false;
            });
        } else {
            if(this.queryExecutionRequired === "false" || !this.queryExecutionRequired) {
                let key = (this.searchKey !== undefined && this.searchKey !== null && this.searchKey.length>0) ? this.searchKey.toLowerCase() : null;  
                this.records = this.recordsToSearch.filter((item) => item[this.searchfieldName].toLowerCase().includes(key));
                if(this.records !== undefined && this.records !== null && this.records.length>0) {
                    this.isRecordsPresent = true;
                } else {
                    this.isRecordsPresent = false;
                }
            }
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
}
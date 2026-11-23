//customLookup.js
import { LightningElement, track, api } from 'lwc';
import findAccountRecords from '@salesforce/apex/Core_MDF_LWC_AccountUserController.findAccountRecords';
export default class customLookupV1 extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectName = 'Account';
    @api searchfield = 'Name';

    /*constructor(){
        super();
        this.iconname = "standard:account";
        this.objectName = 'Account';
        this.searchField = 'Name';
    }*/

    //To fetch all accounts on entered string on account search box
    handleOnchange(event){
        //event.preventDefault();
        const searchKey = event.detail.value; //event.detail.value
        window.console.log('search key new - '+searchKey);
        //this.records = null;
        /* eslint-disable no-console */
        //console.log(searchKey);

        /* Call the Salesforce Apex class method to find the Records */
        findAccountRecords({
            searchKey : searchKey, 
            objectName : this.objectName, 
            searchField : this.searchfield
        })
        .then(result => {
            this.records = result;
            window.console.log('this.records - '+this.records);
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec.Name+' - '+rec.Core_MDF_Parent_Fund_Account__r.Name;
                window.console.log('rec.Name - '+rec.Core_MDF_Parent_Fund_Account__r.Name); 
                window.console.log('rec.Name - '+rec.Name); 
            }
            this.error = undefined;
            //console.log(' records ', this.records);
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });
    }
     // Event to select account from populated list
    handleSelect(event){
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail : { recordId : selectedRecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    //Event to remove selected account
    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}
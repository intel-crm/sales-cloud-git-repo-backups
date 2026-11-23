import { LightningElement, track,wire } from 'lwc';

import { CurrentPageReference } from "lightning/navigation";
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

const CASE_COMMENT_LIST = [{

  
    fieldName: 'Core_IPS_Comment_Authored_By_Name__c',
    
},
{
   
    fieldName: 'Core_IPS_Comment_Authored_By_Email__c',
    type: 'email'
},
{
   
    fieldName: 'CreatedDate'
},
{
   
    fieldName: 'Core_IPS_Rich_Comment__c', 
    type: 'richtext' 
}];


export default class caseComments extends LightningElement {

    @track searchId;
    @track searchText;


    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 5;
    heightInRem = 12;
    
    @track dataToShow;
    @track isDataAvailable = false;
    @track columns = CASE_COMMENT_LIST;
    @track mapRecordId;

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {
        this.getRecords();
        console.log('caseCommentList ::: connectedCalback called');

    }

    getRecords() {
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        console.log('Record ID', this.mapRecordId);
        this.queryString = 'SELECT id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid, CreatedDate, Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_Name__c from Core_IPS_Case_Comments__c where Core_IPS_Case__c = \''+ this.mapRecordId  + '\''; 
        console.log('Record ID', this.queryString);
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    
                    this.dataToShow = data;
                    this.isDataAvailable = true;
                }
                console.log('dataToShow', this.dataToShow);
            })
            .catch(error => {
                console.error('caseCommentList ::: Error in loading records. Error : ', JSON.stringify(error));
            })
    }

    onChangeHandler(event){
        this.searchText = event.target.value;
    }
    onSearch() {
        
    }
    onReset(){
        this.searchText = '';
    }

}
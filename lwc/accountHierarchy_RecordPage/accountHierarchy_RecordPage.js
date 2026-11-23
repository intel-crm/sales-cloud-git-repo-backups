import { LightningElement, api, wire, track} from 'lwc';
import getSalesforceBaseurl from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchSalesforceBaseURL';
import accountsHierarchy from '@salesforce/label/c.Core_MDF_AccountsHierarchy';
import applicationErrorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Account.Id','Account.Name','Account.RecordType.DeveloperName','Account.Core_MDF_CoMarketing_Ultimate_Account__c',
                'Account.Core_MDF_CoMarketing_Ultimate_Account__r.Name'];

export default class AccountHierarchy_RecordPage extends LightningElement {

    @api recordId;// Record Page Id
    @api salesforceBaseurl;
    @track ultimateAccountId;
    @track ultimateAccountName;
    //@track isRecordPage = true;
    @track coMarketingRecordType = false;
    label = {accountsHierarchy, applicationErrorMsg, applicationErrorTitle};
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account({data, error}){
        if(data){
            // For Comarketing Accounts Only
            if(data.fields.RecordType.value.fields.DeveloperName.value === 'Core_MDF_Co_Marketing'){
                // Getting Ultimate Account and Name for passing into Child Tree grid Component
                this.ultimateAccountId = data.fields.Core_MDF_CoMarketing_Ultimate_Account__c.value;
                this.ultimateAccountName = data.fields.Core_MDF_CoMarketing_Ultimate_Account__r.value.fields.Name.value;
                this.coMarketingRecordType = true;
            }
        }
        else if(error){
            this.displayErrorMessageOnServerException();
        }
    }
    
    connectedCallback(){ 
        // Getting Salesforce Base URL
        this.getsfdcBaseUrl();
    }

    // Method to fetch Salesforce Base Url
    getsfdcBaseUrl(){
        // getting salesforce Org's base URL
        getSalesforceBaseurl()
        .then(sfdcBaseURL => {
            this.salesforceBaseurl = sfdcBaseURL;
            this.error = undefined;
        })
        .catch(error =>{
            this.error = error;
            this.salesforceBaseurl = undefined;
            this.displayErrorMessageOnServerException();
        })
    }

     /* Displaying Errors As a toast Message On Server Side Exception */
     displayErrorMessageOnServerException(){
        const evt = new ShowToastEvent({
            title: this.label.applicationErrorTitle,
            message: this.label.applicationErrorMsg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}
import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSalesforceBaseurl from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchSalesforceBaseURL';
import getAccountDetails from '@salesforce/apex/Core_MDF_AccountHierarchyController.getAccountDetails';
import accountsHierarchy from '@salesforce/label/c.Core_MDF_AccountsHierarchy';
import applicationErrorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import nodeVisibilityWarningLabel from '@salesforce/label/c.Core_MDF_AccountHierarchyWarning_Label';
import refreshButton from '@salesforce/label/c.Core_MDF_Refresh';
import refreshButtonInfo from '@salesforce/label/c.Core_MDF_AccountHierarchyRefreshInfo';

export default class AccountHierarchy_DetailPage extends LightningElement {

    @api recordId;// Record Page Id
    @api salesforceBaseurl;// For storing Saleforce Base Url
    @track ultimateAccountId; // For Account's Ultimate Account Id
    @track ultimateAccountName; // For Account's Ultimate Account name
    @track coMarketingRecordType = false;// Render Only for Co-Marketing Accounts
    label = {accountsHierarchy, applicationErrorMsg, applicationErrorTitle, nodeVisibilityWarningLabel, refreshButton, refreshButtonInfo};

    connectedCallback(){ 
        // Getting Salesforce Base URL
        this.getsfdcBaseUrl();
        // Getting Current Account detail
        this.getCurrentAccountData();
    }

    //On click of refresh button, fetch the latest details from child cmp
    refreshGrid(){
        this.template.querySelector('c-account-hierarchy_-tree-grid').fetchAllChildAccounts();   
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

    // Method to fetch current Account field
    getCurrentAccountData(){
        // getting current Account's data
        getAccountDetails({accountId : this.recordId})
        .then(account => {
            if(account !== null && account !== undefined && account.length>0 &&
                 account[0].RecordType.DeveloperName === 'Core_MDF_Co_Marketing'){
                this.ultimateAccountId = account[0].Core_MDF_CoMarketing_Ultimate_Account__c;
                this.ultimateAccountName = account[0].Core_MDF_CoMarketing_Ultimate_Account__r.Name;
                this.coMarketingRecordType = true;
            }
        })
        .catch(error =>{
            console.log('Inside getCurrentAccountData Error',error);
            this.error = error;
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
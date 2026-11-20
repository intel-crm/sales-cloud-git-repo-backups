import { LightningElement, wire, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import getUltimateAccountList from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchUltimateAccounts';
import getSalesforceBaseurl from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchSalesforceBaseURL';
import getAllAccounts from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchAllAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import coMarketingAccounts from '@salesforce/label/c.Core_MDF_CoMarketingAccounts';
import accountsHierarchy from '@salesforce/label/c.Core_MDF_AccountsHierarchy';
import intelAccounts from '@salesforce/label/c.Core_MDF_IntelAccounts';
import searchAccounts from '@salesforce/label/c.Core_MDF_SearchAccounts';
import loadingLabel from '@salesforce/label/c.Core_MDF_Loading';
import applicationErrorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import nodeVisibilityWarningLabel from '@salesforce/label/c.Core_MDF_AccountHierarchyWarning_Label';
import { NavigationMixin } from 'lightning/navigation';
import checkUserPermissionSet from '@salesforce/apex/Core_MDF_AccountHierarchyController.checkUserPermissionSet';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import submitPartnerScore from '@salesforce/apex/Core_MDF_AccountHierarchyController.submitPartnerScore';
import Core_MDF_Partnership_Score_Duplicate_Error from '@salesforce/label/c.Core_MDF_Partnership_Score_Duplicate_Error';
import Core_MDF_Partnership_Score_Duplicate_Record_Exists from '@salesforce/label/c.Core_MDF_Partnership_Score_Duplicate_Record_Exists';
import Core_MDF_Partnerscore_Score_Title from '@salesforce/label/c.Core_MDF_Partnerscore_Score_Title';

export default class AccountHierarchyView extends NavigationMixin(LightningElement) {
    @track accountsToDisplay;// Holding only those accounts that is going to be displayed on a given page
    @track allUltimateAccounts = [];// Object to hold All Ultimate Accounts; this wont change 
    @track totalDisplayedAccounts;//Count of total Accounts being displayed
    @api salesforceBaseurl; // salesforce base url
    @track showPaginator = true;
    @track showSearchBox = true;
    @api recordId;
    showPopupToCreatePartnerScore = false;
    accountId;
    showSpinner = true; // Showing spinner on page load, Once Accounts are fetched Spinner would be hidden
    showSetPartnerScoreButton;
    showSpinnerForPartnerScore = false;
    showPopupToScoreDetails = false;
    @track allAccessibleAccounts = [];
    label = { coMarketingAccounts, accountsHierarchy, intelAccounts, searchAccounts, loadingLabel, applicationErrorMsg, applicationErrorTitle, nodeVisibilityWarningLabel, Core_MDF_Partnership_Score_Duplicate_Error, Core_MDF_Partnership_Score_Duplicate_Record_Exists, Core_MDF_Partnerscore_Score_Title };
    partnerScoreDuplicateId;

    async connectedCallback() {
        // Getting Salesforce Base URL
        this.getsfdcBaseUrl();
        // Fetching all the Ultimate Accounts
        await this.fetchAllUltimateAccounts();
        // Fetching all accounts user is having access to
        this.fetchAllAccounts();
    }

    // Method to fetch Salesforce Base Url
    getsfdcBaseUrl() {
        // getting salesforce Org's base URL
        getSalesforceBaseurl()
            .then(sfdcBaseURL => {
                this.salesforceBaseurl = sfdcBaseURL;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.salesforceBaseurl = undefined;
                this.showSpinner = false;
                this.displayErrorMessageOnServerException(this.label.applicationErrorTitle, this.label.applicationErrorMsg, 'error');
            })
    }

    /*Method to fetch All the Ultimate Accounts from Apex method*/
    async fetchAllUltimateAccounts() {

        await getUltimateAccountList()
            .then(accounts => {
                this.accountsToDisplay = accounts;
                this.allUltimateAccounts = accounts;
                this.totalDisplayedAccounts = accounts.length;
                if (this.totalDisplayedAccounts == 0) {
                    this.showPaginator = false;
                    this.showSearchBox = false;
                }
                // this.showSpinner = false;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.totalDisplayedAccounts = 0;
                this.accountsToDisplay = undefined;
                this.showSpinner = false;
                this.showSearchBox = false;
                this.displayErrorMessageOnServerException(this.label.applicationErrorTitle, this.label.applicationErrorMsg, 'error');
            });
    }

    /*Displaying Records on the Page depending upon Page size*/
    handleRecordsOnPageChange(event) {
        // Setting accountsToDisplay attribute
        this.accountsToDisplay = event.detail;
    }

    //getting All Accounts
    fetchAllAccounts() {
        getAllAccounts({ ultimateAccountIdList: this.allUltimateAccounts })
            .then(accounts => {
                this.allAccessibleAccounts = accounts;
            })
            .catch(error => {
                this.error = error;
               console.log('error'+error.body + error.body.message);
                this.showSpinner = false;
                this.showSearchBox = false;
                
            });
        this.showSpinner = false;
    }

    /* Getting Searched Account records and displaying in component and calling Paginator's function */
    fetchSearchedRecords(event) {
        var searchTextAcctName = '';
        // Getting the Searched input value
        searchTextAcctName = event.target.value;
        // display all ultimate Accounts when no scearc text is entered
        if (searchTextAcctName === '' || searchTextAcctName === undefined) {
            this.accountsToDisplay = this.allUltimateAccounts;
        }
        else {
            // Filtering the all accounts list on searched text and returning it          
            var filteredAccounts = this.allAccessibleAccounts.filter(function (account) {
                return account.Name.toLowerCase().includes(searchTextAcctName.toLowerCase())
            });
            let filteredUltimateAccount = '';
            let filteredUltimateAccountsToDisplay = [];
            //iterating over all filtered accounts to get their ultimate accounts
            if (filteredAccounts.length > 0) {
                for (var index = 0; index < filteredAccounts.length; index++) {
                    //checking for child accounts 
                    if (filteredAccounts[index].Core_MDF_CoMarketing_Ultimate_Account__c != null && filteredAccounts[index].Core_MDF_CoMarketing_Ultimate_Account__c != '' && filteredAccounts[index].Core_MDF_CoMarketing_Ultimate_Account__c != 'undefined') {
                        filteredUltimateAccount = { Id: filteredAccounts[index].Core_MDF_CoMarketing_Ultimate_Account__c, Name: filteredAccounts[index].Core_MDF_CoMarketing_Ultimate_Account__r.Name };
                    }
                    //checking for ultimate accounts
                    if (filteredAccounts[index].Core_MDF_CoMarketingActive__c === true && filteredAccounts[index].RecordType.DeveloperName != 'Core_MDF_Co_Marketing') {
                        filteredUltimateAccount = { Id: filteredAccounts[index].Id, Name: filteredAccounts[index].Name };
                    }
                    //checking for repeated ultimate accounts and adding ultimate accounts to display
                    if (filteredUltimateAccount != null && (filteredUltimateAccountsToDisplay.filter(x => x.Id === filteredUltimateAccount.Id).length === 0)) {
                        filteredUltimateAccountsToDisplay = [...filteredUltimateAccountsToDisplay, filteredUltimateAccount];
                    }
                }
            }
            // If the filtered accounts is not empty then display those accounts
            if (filteredUltimateAccountsToDisplay != null && filteredUltimateAccountsToDisplay.length > 0 && filteredUltimateAccountsToDisplay != 'undefined') {
                //To sort Accounts after search
                filteredUltimateAccountsToDisplay.sort(function (a, b) {
                    return a.Name.localeCompare(b.Name);
                });
                this.accountsToDisplay = filteredUltimateAccountsToDisplay;
            }
            else {
                this.accountsToDisplay = [];
            }
        }
        this.totalDisplayedAccounts = this.accountsToDisplay.length;
        // Calling Paginator function to handle Pagination when a search is made       
        this.template.querySelector("c-paginator").handlePaginationOnSearch(this.accountsToDisplay, this.totalDisplayedAccounts);

    }

    /* Displaying Errors As a toast Message On Server Side Exception */
    displayErrorMessageOnServerException(title, message, messageVariant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: messageVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    //on click of view Details, navigate to account record page in a new tab
    navigateToRecordViewPage(event) {
        let accountId = event.target.dataset.name;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");//to open in a new tab
        });
    }

    //To Close the popup on click of close button
    closePartnerScoreCreateModal() {
        this.showPopupToCreatePartnerScore = false;
    }

    //To Open the popup for partner score record creation
    navigateToPartnerScoreCreateModal(event) {
        this.accountId = event.target.dataset.name;//accountId to prepopulate during partner score record creation
        this.showPopupToCreatePartnerScore = true;//boolean flag to open the popup(create partner score record from account)
    }

    //To display the "Set Score" button based on User's custom permission
    @wire(checkUserPermissionSet, { userId: Id })
    wiredUserPermissions(response) {
        if (response.data) {
            this.showSetPartnerScoreButton = true; // Enable the button if the return is TRUE
        } else if (response.data === false) {
            this.showSetPartnerScoreButton = false; // Disbale the Button if the return is FALSE
        }

    }
    //To Close the popup on click of close button
    closePartnerScoreViewReportModal() {
        this.showPopupToScoreDetails = false;
    }

    //this method is called on click of submit from create partner score popup
    submitPartnershipScore(event) {
        event.preventDefault();
        this.showSpinnerForPartnerScore = true;
        let partnerScoremaintenanceObj = {};
        let toastMessageVariant = '';
        let title;
        let message;
        //If value is not selected for any of the fields, display 'complete this field' error, else add it to the partnerScoremaintenanceObj
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (element.value === null || element.value === '') {
                element.reportValidity();
            } else if (element.value) {
                partnerScoremaintenanceObj[element.fieldName] = element.value;
            }
        });

        //submitPartnerScoreWrapper to pass as an argument to apex method
        if (Object.keys(partnerScoremaintenanceObj).length === 5) {
            let submitPartnerScoreWrapper = {
                accountId: partnerScoremaintenanceObj.Core_MDF_Account_Id__c,
                programId: partnerScoremaintenanceObj.Core_MDF_Channel_Program_Id__c,
                year: partnerScoremaintenanceObj.Core_MDF_Year_nm__c,
                quarter: partnerScoremaintenanceObj.Core_MDF_Quarter_nm__c,
                partnerScoreNumber: partnerScoremaintenanceObj.Core_MDF_Partnership_Score_Nbr__c
            }
            //apex method call
            submitPartnerScore({ partnerScoreWrapper: submitPartnerScoreWrapper })
                .then(result => {
                    if (result.isSuccess) {
                        title = 'Partnership Score';
                        toastMessageVariant = 'success';
                        this.showPopupToCreatePartnerScore = false; // close the create partner score popup
                        this.showSpinnerForPartnerScore = false; // stop the spinner
                        this.displayErrorMessageOnServerException(title, result.message, toastMessageVariant);
                    } else if (result.isDuplicate) {
                        //to display the popup in case of duplicate record existence
                        this.partnerScoreDuplicateId = result.partnerScoreDuplicateId;
                        this.showSpinnerForPartnerScore = false;
                        this.showPopupToCreatePartnerScore = false;
                        this.showPopupToScoreDetails = true;
                    } else {
                        //for partner score's min and max value
                        toastMessageVariant = 'error';
                        title = 'Error';
                        this.showSpinnerForPartnerScore = false;
                        let message = '';
                        let exceptionerrors = result.message;
                        /**
                         * Sample error message - exception errore Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,
                         * Score cannot exceed 8 and should not be less than zero: [Core_MDF_Partnership_Score_Nbr__c]
                         */
                        if (exceptionerrors != null && exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {

                            var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 1);
                            var err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
                            message = err.substring(err.indexOf(',') + 1);
                            
                        } else {
                            message = exceptionerrors;
                        }
                        this.displayErrorMessageOnServerException(title, message, toastMessageVariant);
                    }
                })

        } else {
            this.displayErrorMessageOnServerException('Error', 'Please fill out all the fields', 'error');
            this.showSpinnerForPartnerScore = false;
        }

    }

    //this method is used to navigate to the partner score report page on click of 'Go to report'
    navigateToScoreDetails() {

        this.showPopupToScoreDetails = false;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.partnerScoreDuplicateId,
                objectApiName: 'Core_MDF_Partnership_Score__c',
                actionName: 'view'
            },
            
        }).then(url => {
            window.open(url, "_blank");//to open in a new tab
        });
    }


}
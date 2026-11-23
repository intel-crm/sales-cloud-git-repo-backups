import { LightningElement, track, wire, api } from 'lwc';
import fetchAccountRecordTypes from '@salesforce/apex/UCD_AccountRecordTypeController.fetchAccountRecordTypes';
import { NavigationMixin } from 'lightning/navigation';

export default class newButton_POC extends NavigationMixin(LightningElement) {
    @track value = '';
    @track options = [];
    @track selectedOption;
    @track displayRecordTypes = true;
    @track showModalPopUp = true;
    @track dataLoaded = false;
    @track showError = false;

    INTEL_ACCOUNT = 'Mastered_Account';
    ERROR_MSG = 'We encountered a problem, Please contact your system administrator.';

    connectedCallback() {
        if (this.showModalPopUp) {
            fetchAccountRecordTypes()
                .then(result => {
                    this.options = result;
                    let selectedOption;

                    this.options.forEach(function (element) {
                        if (element.checked) {
                            selectedOption = element.recordTypeId;
                        }
                    });

                    this.selectedOption = selectedOption;

                    if (this.options.length === 1) {
                        this.dataLoaded = true;
                        this.submitDetails();
                    } else {
                        this.dataLoaded = true;
                    }
                })
                .catch(error => {
                    this.dataLoaded = true;
                    this.showError = true;
                })
        }
        else {
            console.log('inside else');
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'newaccount__c'
              }
            });
        }
    }

    handleRadioChange(event) {
        this.selectedOption = event.target.value;
    }

    submitDetails() {
        let recordTypeSelected = [];
        let selectedOption = this.selectedOption;

        this.options.forEach(function (element) {
            if (element.recordTypeId === selectedOption) {
                recordTypeSelected = element;
            }
        });

        if (recordTypeSelected.recordTypeValue === this.INTEL_ACCOUNT) {
            this.navigateToSBR(recordTypeSelected.recordTypeId);
        } else {
            this.navigateToNewRecordPage(recordTypeSelected.recordTypeId);
        }
    }

    navigateToNewRecordPage(recordTypeId) {
        // Opens the new Account record modal
        // to create an Account.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                count: '1',
                nooverride: '1',
                useRecordTypeCheck: '1',
                recordTypeId: recordTypeId,
            }
        })
    }

    navigateToSBR(recordTypeId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'New_Account_SBR',
            },
            state: {
                "c__recordTypeId": recordTypeId
            },
        });
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            }
        });
    }
}
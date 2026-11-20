import { LightningElement, track, wire, api } from 'lwc';
import fetchAccountRecordTypes from '@salesforce/apex/UCD_AccountRecordTypeController.fetchAccountRecordTypes';
import { NavigationMixin } from 'lightning/navigation';

export default class ucd_ACM_AccountRecordType_SBR extends NavigationMixin(LightningElement) {
    @track value = '';
    @track options = [];
    @track selectedOption;
    @track displayRecordTypes = true;
    @track dataLoaded = false;
    @track showError = false;
    IntelSBR = 'Intel_SBR';
    INTEL_ACCOUNT = 'Mastered_Account';
    ERROR_MSG = 'We encountered a problem, Please contact your system administrator.';

    connectedCallback() {
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
                    this.dataLoaded = false;
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

    handleRadioChange(event) {
        this.selectedOption = event.target.value;
    }

    submitDetails() {
        //this.displayRecordTypes = false;
        let recordTypeSelected = [];
        let selectedOption = this.selectedOption;
        this.options.forEach(function (element) {
            if (element.recordTypeId === selectedOption) {
                recordTypeSelected = element;
            }
        });
        if (recordTypeSelected.recordTypeValue === this.IntelSBR) {
            this.navigateToSBR();
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

    navigateToSBR() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'New_Account_SBR'            
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
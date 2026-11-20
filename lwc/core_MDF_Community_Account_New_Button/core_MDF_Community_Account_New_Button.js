import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkAccountObjectCreatePermission from '@salesforce/apex/Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission';
import newButtonLabel from '@salesforce/label/c.Core_MDF_New';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import applicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';

export default class Core_MDF_Community_Account_New_Button extends NavigationMixin(LightningElement) {
    hasCreateAccess = false;
    customLabels = { newButtonLabel, applicationErrorTitle, applicationErrorMessage };

    connectedCallback() {
        this.checkCreateAccessOnAccount();
    }

    //check the create access on Account Object for the logged in user
    checkCreateAccessOnAccount() {
        checkAccountObjectCreatePermission({ objectName: 'Account' })
            .then(response => {
                if (response) {
                    this.hasCreateAccess = true;
                }
            }).catch(error => {
                console.log('Erorr in Core_MDF_Community_Account_New_Button - checkCreateAccessOnAccount', error);
                const toastEvent = new ShowToastEvent({
                    title: this.customLabels.applicationErrorTitle,
                    message: this.customLabels.applicationErrorMessage,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            })
    }

    //This method is called on click of New Button
    handleNewButonClick() {
        this.navigateToNewRecordPage();
    }

    // Opens the new Account record modal to create an Account.
    navigateToNewRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                nooverride: '1'
            }
        })
    }
}
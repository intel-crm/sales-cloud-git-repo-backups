import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id'; 
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name'; 
import ADDRESS_VERIFICATION from '@salesforce/schema/Account_Create_Request__c.IsAddressVerified__c';
import REQUEST_STATUS from '@salesforce/schema/Account_Create_Request__c.Status__c';
import profilesLabel from '@salesforce/label/c.UCD_ACM_Address_Verification_Message';

export default class Ucd_ACM_AccountAddressVerificationMessage extends LightningElement {
    @api recordId;
    @track addressVerification;
    @track requestStatus;
    @api objectApiName = 'Account_Create_Request__c'
    userId = Id;
    userRoleName;
    userProfileName;
    profilesForMsg;

    @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                console.log('Address Profile ',data.fields.Profile.value.fields.Name.value);
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ADDRESS_VERIFICATION, REQUEST_STATUS] })
    wiredRecord({ error, data }) {
        if (data) {
            this.addressVerification = getFieldValue(data, ADDRESS_VERIFICATION);
            this.requestStatus = getFieldValue(data, REQUEST_STATUS);
            console.log('Export Compliance field : ',JSON.stringify(getFieldValue(data, ADDRESS_VERIFICATION)));
        }
        if (error) {
            console.log('error: ' + JSON.stringify(error));
        }
    }

    connectedCallback() {
        this.profilesForMsg = profilesLabel.split(',');
        this.checkAccountAddressIsVerified();
    }
    checkAccountAddressIsVerified(){
        setTimeout(() => {
            const storageKey = 'ucdAcmAddrToast_' + this.recordId;
            const previousStatus = sessionStorage.getItem(storageKey);
            const currentStatus = this.requestStatus;
            // Suppress the toast only at the moment of approval (status just changed
            // from a pre-approval state to In Process/Approved during the flow redirect).
            // When the user comes back later to an already approved/in-process record,
            // previousStatus is null or already In Process/Approved, so the toast still shows.
            const justApproved = (currentStatus === 'In Process' || currentStatus === 'Approved')
                && previousStatus !== null
                && previousStatus !== 'In Process'
                && previousStatus !== 'Approved';
            sessionStorage.setItem(storageKey, currentStatus);
            if(this.addressVerification && !justApproved && this.profilesForMsg.includes(this.userProfileName)){
                this.showMessage();
            }
        }, 1000);
    }
    showMessage(){
        const evt = new ShowToastEvent({
            title: 'Account Request Address is Verified. ',
            variant: 'success',
            mode : 'dismissible'
        });
        this.dispatchEvent(evt);
        setTimeout(() => {
        }, 5000);
    }
}
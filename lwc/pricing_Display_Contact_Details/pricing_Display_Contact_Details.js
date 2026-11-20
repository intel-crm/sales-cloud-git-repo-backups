import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import user from '@salesforce/schema/User';
import userId from '@salesforce/user/Id';
import accountName from '@salesforce/schema/User.Account.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TITLE_TEXT = 'Success!';
const MSG_TEXT = 'Nickname has been saved successfully';
const VAR_TEXT = 'success';
const MODE = 'dismissable';

export default class Pricing_Display_Contact_Details extends LightningElement {
    @api recordId;
    @track currentUserId = userId;
    @track isReset = false;
    @track isSpinner = false;
    @track isCancelSpinner = false;
    @track communityNickname;

    @wire(getRecord, {
        recordId: userId,
        fields: [accountName]
    })
    record;

    get accountNameValue() {
        console.log('record id',this.record);
        console.log('account name==',getFieldValue(this.record.data, accountName))
        return (this.record && this.record.data)
            ? getFieldValue(this.record.data, accountName)
            : '';
    }

    handleChange(event) {
        this.communityNickname = event.target.value;
    }

    handleError(event) {
        this.isSpinner = false;
    }

    handleSave(event) {
        if(this.communityNickname !== "" && event.target.value !== null) {
            this.isSpinner = true;
        }
        this.isReset = false;
    }

    handleSuccess(event) {
        console.log('isreset==>',this.isReset);
        this.isSpinner = false;
        this.isCancelSpinner = false;
        if(this.isReset === false) {   
            const toastMessage = new ShowToastEvent({
                title: TITLE_TEXT,
                message: MSG_TEXT,
                variant: VAR_TEXT,
                mode: MODE
            });
            this.dispatchEvent(toastMessage);
        }
    }

    handleReset(event) {
        this.isCancelSpinner = true;
        this.isReset = true;
        const inputFields = this.template.querySelectorAll(
        'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.name === "CommunityNickname") {
                    field.reset();
                }
            });
        }
    }
   
}
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import getAccountHierarchy from '@salesforce/apex/uCDPartnerGrouping.getAccountHierarchy';
import createInboundRecords from '@salesforce/apex/uCDPartnerGrouping.createInboundRecords';

export default class UCDHierarchy extends LightningElement {

    @track showOpidNameInput = false;
    @track value = '';
    @track options = [];
    @api recordId;
    @track accounts;
    @track selectedAccountId;
    @track opidName = '';
    @track showErrorMessage = false;
    @api showaccounthierarchy;
    @api childrecords;
    @track comments = '';
    @api showopidname;
    @api selectedparentaccountid;
    @api childerror;
    @api handleback;
    @api picklistValue;
    @track isModalOpen = false;
    @track showFinalComponent = false;
    


    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            console.log('handleback-->', this.handleback);
            console.log('record id in child account hierarchy', this.recordId);
            console.log('record id in child account hierarchy', this.childrecords);
            console.log('showopidname-->', this.showopidname);
            console.log('selectedparentaccountid-->', this.selectedparentaccountid);
        }
    }
    handleClick(){
        console.log('handleback inside method-->', this.handleback);
        this.handleback(false);
    }
    handleCommentInput(event) {
        this.comments = event.target.value;
        const allInputFields = this.template.querySelectorAll('lightning-input');
        const commentField = this.showopidname ? allInputFields[1] : allInputFields[0];
        commentField.reportValidity();
    }

    handleOpidNameInput(event) {
        this.opidName = event.target.value;
        this.template.querySelector('lightning-input').reportValidity();
    }
    closePopUp() {
        this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
    }

    handleProceedClick() {
        const isOpidNameOnlySpaces = this.opidName && this.opidName.trim() === '';
        const isCommentsOnlySpaces = this.comments && this.comments.trim() === '';
        const opidNameNotProvided = this.showopidname && (!this.opidName || isOpidNameOnlySpaces);
        const commentsNotProvided = !this.comments || isCommentsOnlySpaces;
        const firstInputValue = this.showopidname ? this.opidName : this.comments;
        const customErrorMessage = this.showopidname ? "Please provide an 1PID name." : "Please provide Comments.";
        const isFirstInputValueOnlySpaces = firstInputValue && firstInputValue.trim() === '';
        console.log('isFirstInputValueOnlySpaces-->',isFirstInputValueOnlySpaces);
        console.log('opidNameNotProvided-->',opidNameNotProvided);
        console.log('commentsNotProvided-->',commentsNotProvided);
        
        if(opidNameNotProvided || !this.selectedparentaccountid || commentsNotProvided){
            const inputFields = this.template.querySelectorAll('lightning-input');
            this.isModalOpen = true;
            console.log('inputFields[0]:', inputFields[0]);
            console.log('inputFields[1]:', inputFields[1]);
            if(inputFields[0]) {
                if(isFirstInputValueOnlySpaces) {
                    inputFields[0].setCustomValidity(customErrorMessage);
                }
                else{
                    inputFields[0].setCustomValidity('');
                }
                inputFields[0].reportValidity();
            }
            if(inputFields[1]) {
                if(isCommentsOnlySpaces) {
                    inputFields[1].setCustomValidity('Please provide Comments.');
                }
                else{
                    inputFields[1].setCustomValidity('');
                }
                inputFields[1].reportValidity();
            }
            this.showErrorMessage = this.selectedparentaccountid ? false : true;
            console.log('this.showErrorMessage:', this.showErrorMessage);
            return;
        }
        createInboundRecords({ accountId: this.selectedparentaccountid ,opidName: this.opidName, picklistValue: this.picklistValue, comments: this.comments})
            .then(() => {
                this.showFinalComponent = true;
            /*this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'A request is created successfully. You will be notified once the request processing is complete.',
                variant: 'success',
                mode: 'dismissable'
            }));*/
            })
            .catch(error => {
                console.error('Error while creating inbound record:', error);
            });
    }
    handleClose() {
        //this.isModalOpen = false;
    }
}
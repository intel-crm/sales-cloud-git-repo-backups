import { LightningElement, api, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/uCDPartnerGrouping.getPicklistValues';
import getAccountHierarchy from '@salesforce/apex/uCDPartnerGrouping.getAccountHierarchy';
import createInboundRecords from '@salesforce/apex/uCDPartnerGrouping.createInboundRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';

const LINE_OF_BUSINESS = 'Line of Business';

export default class uCDPartnerGrouping extends LightningElement {
    @track value = '';
    @track options = [];
    @api recordId;
    @track accounts;
    @api childAccounts;
    @api inactiveOPIDAssociation;
    @api selectedAccountId;
    @api showOpidNameInput = false;
    @track opidName = '';
    @track showErrorMessage = false;
    @track showAccountHierarchy = false;
    @api error;

    @track showNewAcreComponent = false;
    @track showPicklistError = false;
    handleClick() {
        this.showNewAcreComponent = true;
        console.log('this.showNewAcreComponent', this.showNewAcreComponent);
        console.log('this.recordId in child calling:', this.recordId);
        console.log('this.value in child calling:', this.value);
        getAccountHierarchy({ recordId: this.recordId, picklistValue: this.value,  showFullHierarchy: this.showNewAcreComponent})
            .then(result => {
                this.childAccounts = result;
                this.error = undefined;
                if(this.value == LINE_OF_BUSINESS) {
                    this.showOpidNameInput = true;
                }
                else {
                    this.showOpidNameInput = false;
                }
                console.log('showOpidNameInput:', this.showOpidNameInput);
                console.log('result:', result);
                console.log('child account:', this.childAccounts);
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
                console.error('Error fetching account values:', error);
            });
    }
    // handleBackClick() {
    //     console.log('showNewAcreComponent 1-->', this.showNewAcreComponent);
    //     this.showNewAcreComponent = false;
    //     console.log('showNewAcreComponent 2-->', this.showNewAcreComponent);
    // }

    handleBackClickInParent(newValue) {
        this.showNewAcreComponent = newValue;
    }

    // Method to pass down to child
    get handleBackClick() {
        return this.handleBackClickInParent.bind(this);
    }
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            console.log('record id', this.recordId);
        }
    }

    @wire(getPicklistValues, { objectName: 'UCD_Partner_Grouping_Method__mdt', fieldName: 'UCD_PAG_Grouping_Method__c'})
    wiredPicklistValues({ error, data }) {
    console.log('this.recordId-->'+this.recordId);
    console.log('this.data-->'+this.data);
        if (data) {
            this.options = data.map(item => {
                return { label: item, value: item };
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    
    
    handleChange(event) {
        this.value = event.detail.value;
        this.accounts = undefined;
        this.selectedAccountId = undefined;
        this.template.querySelector('lightning-combobox').reportValidity();
        this.showErrorMessage = false;
    }
    handleSave() {
        if(!this.value){
            this.template.querySelector('lightning-combobox').reportValidity();
            return;
        }
        getAccountHierarchy({ recordId: this.recordId, picklistValue: this.value,  showFullHierarchy: this.showNewAcreComponent})
            .then(result => {
                this.accounts = result;
                this.error = undefined;
                if(this.value == LINE_OF_BUSINESS) {
                    this.showOpidNameInput = true;
                }
                else {
                    this.showOpidNameInput = false;
                }
                console.log("result -> ", result);
                console.log("result[0].id --> ", result[0].Id);
                this.selectedAccountId = result[0].Id;
                console.log("this.selectedAccountId --> ", this.selectedAccountId);
            })
            .catch(error => {
                this.showPicklistError = true;
                this.error = error;
                this.accounts = undefined;
                console.error('Error fetching account values:', error);
            });
    }

    handleRadioChange(event) {
        this.selectedAccountId = event.target.value;
        this.showErrorMessage = false;
        console.log('Selected Account ID:', this.selectedAccountId);
    }

    handleOpidNameInput(event) {
        this.opidName = event.target.value;
        this.template.querySelector('lightning-input').reportValidity();
    }
    closePopUp() {
        this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
    }
    handleProceedClick() {
        if((!this.opidName && this.showOpidNameInput) || !this.selectedAccountId){
            const opidNameInputField = this.template.querySelector('lightning-input');
            if(opidNameInputField) {
                opidNameInputField.reportValidity();
            }
            this.showErrorMessage = this.selectedAccountId ? false : true;
            console.log('this.showErrorMessage:', this.showErrorMessage);
            return;
        }
        createInboundRecords({ accountId: this.selectedAccountId ,opidName: this.opidName})
            .then(() => {
            this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'A request will be created for Relinking. You will be notified once the request is complete.',
                variant: 'success',
                mode: 'dismissable'
            }));
            })
            .catch(error => {
                console.error('Error while creating inbound record:', error);
            });
    }
}
import { LightningElement, track ,wire} from 'lwc';

import getPriceRulesBRE from "@salesforce/apex/Pricing_QuoteLineController.getPriceRulesBRE";
import updatePriceRules from "@salesforce/apex/Pricing_QuoteLineController.updatePriceRules";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Pricing_PriceRulesBRE_Table extends LightningElement {

    COLS = [
        { label: 'Account', fieldName: 'AccountName', editable: false },
            { label: 'Product', fieldName: 'Pricing_Product__r.Name', editable: false },
            { label: 'Quantity', fieldName: 'Pricing_Quantity__c',type: 'Number', editable: true }
      ];
    @track priceRulesRecords;
    @track draftValues;
    wiredResult;

    @wire(getPriceRulesBRE)
    wiredContacts({ data, error }) {
        if (data) {
            this.wiredResult = data.map(row => ({
                ...row,
                AccountName: row.Account__c ? row.Account__r.Name : ''
            }));;
            console.log('data:'+JSON.stringify(data));
            this.priceRulesRecords = data.map(row => ({
                ...row,
                AccountName: row.Account__c ? row.Account__r.Name : ''
            }));
        } else if (error) {4
            console.log('data:'+JSON.stringify(error));
            console.error(error);
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;

        updatePriceRules({ priceRulesToUpdate: updatedFields })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated',
                    variant: 'success'
                }));
                this.draftValues = [];
                return refreshApex(this.priceRulesRecords);
            })
            .catch(error => {
            
            });
    }

    @track isModalOpen = false;

    picklist1;
    picklist2;
    notes;
    lookupId;

    picklistOptions = [
        { label: 'Application', value: 'Application' },
        { label: 'Product', value: 'Product' },
        { label: 'Pricing Start Date', value: 'Pricing Start Date' }
    ];

    OperatorOptions = [
        { label: 'Equals', value: 'Equals' },
        { label: 'Does not equal', value: 'Does not equal' },
        { label: 'Contains', value: 'Contains' }
    ];

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handlePicklist1Change(event) {
        this.picklist1 = event.detail.value;
    }

    handleOperatorOptionChange(event) {
        this.picklist2 = event.detail.value;
    }

    handleNotesChange(event) {
        this.notes = event.target.value;
    }

    /*handleLookup(event) {
        this.lookupId = event.detail.recordId;
    }*/

    handleSavebutton() {
        // Do your record creation logic here
        console.log('Lookup:', this.lookupId);
        console.log('Picklist 1:', this.picklist1);
        console.log('Picklist 2:', this.picklist2);
        console.log('Notes:', this.notes);

        this.closeModal();
    }


}
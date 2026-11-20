import { LightningElement, wire, api} from 'lwc';

import { updateRecord} from 'lightning/uiRecordApi';
import getVatFileNames from '@salesforce/apex/Core_MDF_Vat_Utility.getVatFileNames';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FILENAME_FIELD from '@salesforce/schema/ContentDocument.Title';
import APPROVEDFILENAME from '@salesforce/schema/Core_MDF_Claim_VAT_Info__c.Core_MDF_Approved_File_Name_Txt__c';
import APPROVEDFILEID from '@salesforce/schema/Core_MDF_Claim_VAT_Info__c.Core_MDF_Approved_File_Id__c';
import ID_FIELD from '@salesforce/schema/Core_MDF_Claim_VAT_Info__c.Id';



const COLS = [
    { label: 'Document Name', fieldName: 'Title'},
];
export default class Core_MDF_VatFiles extends LightningElement {

    @api recordId;

    columns = COLS;
    draftValues = [];

    @wire(getVatFileNames, { recordId: '$recordId' })
    vatfiles;

    handleclick(){
        var el = this.template.querySelector('lightning-datatable');
        console.log(el);
        var selected = el.getSelectedRows();
        const vatfields = {}; 
        if(selected.length > 0)
        {
            vatfields[APPROVEDFILEID.fieldApiName] = selected[0].Id;
            vatfields[APPROVEDFILENAME.fieldApiName] = selected[0].Title;
            vatfields[ID_FIELD.fieldApiName] = this.recordId;

            const recordInput = { fields : vatfields};

            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Payment Document is selected',
                        variant: 'success'
                    })
                );

                const closeQA = new CustomEvent('close');
                this.dispatchEvent(closeQA);
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a document',
                    variant: 'error'
                })
            );
        }
        
        
    }

    
}
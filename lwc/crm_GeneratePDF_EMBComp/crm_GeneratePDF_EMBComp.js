import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import generatePdfAndReturnBase64 from '@salesforce/apex/CRM_GeneratePDF_EMBController.getPdfBase64';
import checkMandatoryFields from '@salesforce/apex/CRM_ExecutiveMeetingBrief_Utility.checkMandatoryFields';
import attachFiletoExecutiveMeetingBrief from '@salesforce/apex/CRM_GeneratePDF_EMBController.attachFiletoExecutiveMeetingBrief';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import BRIEF_NAME_FIELD from '@salesforce/schema/Executive_Meeting_Brief__c.Core_Executive_Meeting_Brief_Name__c';

export default class crm_GeneratePDF_EMBComp extends LightningElement {
    @api recordId;
    @track loading = false;

    // Wire service to get record data
    @wire(getRecord, { recordId: '$recordId', fields: [BRIEF_NAME_FIELD] })
    record;

    get recordName() {
        return getFieldValue(this.record.data, BRIEF_NAME_FIELD) || this.recordId;
    }

    async handleValidate() {
        this.loading = true;
        
        try {
            // First, check mandatory fields
            const validationResult = await checkMandatoryFields({ recordId: this.recordId });
            if (validationResult === 'SUCCESS') {
                // If validation passes, proceed with PDF generation
                await this.generatePdf();
            } else {
                // If validation fails, show error toast
                const missingFields = validationResult.replace(/.*fields:/, '');
                this.showErrorToast('Required Fields Missing', `Please fill out the mandatory fields before proceeding: ${missingFields}`);
                this.loading = false;
            }
        } catch (error) {
            this.showErrorToast('Validation Error', `Error during validation: ${error.body?.message || error.message}`);
            this.loading = false;
        }
    }

    async generatePdf() {
        try {
            const base64 = await generatePdfAndReturnBase64({ recordId: this.recordId });
            if (base64) {
                const link = document.createElement('a');
                link.href = 'data:application/pdf;base64,' + base64;
                link.download = 'Briefing for ' + this.recordName + '.pdf';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);

                await attachFiletoExecutiveMeetingBrief({ recordId: this.recordId, base64: base64 });
                
                this.showSuccessToast();
            } else {
                this.showErrorToast('PDF Generation Error', 'No PDF URL returned.');
                this.loading = false;
            }
        } catch (error) {
            this.showErrorToast('PDF Generation Error', error.body?.message || 'Error generating PDF.');
            this.loading = false;
        }
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'PDF download completed successfully',
                variant: 'success'
            })
        );
        this.closeQuickAction();
        eval("$A.get('e.force:refreshView').fire();");
    }

    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error'
            })
        );
        this.closeQuickAction();
    }
    
    handleCancel() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
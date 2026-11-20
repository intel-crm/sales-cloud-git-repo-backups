import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeBatch from '@salesforce/apex/Core_IPS_BES_ReProcessFailedHandler.executeBatch';


export default class Core_IPS_BES_ReProcessFailedRecords_LWC extends LightningElement {

    @track selectedObject = '';
    @track reprocessDays = '';
    @track batchId;
    @track isBatchProcessed = false;
    @track isExecuteBatchError = false;
    
    objectOptions = [
        { label: 'Case', value: 'Case' },
        { label: 'Comments', value: 'Core_IPS_Case_Comments__c' },
        { label: 'Attachments', value: 'Core_IPS_Case_Attachments__c' }
    ];

    handleObjectChange(event){
         console.log(event.target.value);
         this.selectedObject = event.target.value;
    }

    handleNumberKeyChange(event){
         console.log(event.target.value);
         this.reprocessDays = event.target.value;
    }

    handleReprocess() {
        // Add your reprocess logic here
        console.log('Reprocessing with Object:', this.selectedObject, 'and Reprocess Days:', this.reprocessDays);
        if(this.selectedObject == '' || this.selectedObject == undefined || this.reprocessDays == '' || this.reprocessDays == undefined){
            console.log('inside if condition');
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please complete all fields!!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }

        executeBatch({ objectAPIName: this.selectedObject,
                     numOfDays: this.reprocessDays })
        .then(result => {
             console.log('executebatch result ' + result);
             this.batchId = result;
             this.isBatchProcessed = true;
            
             const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Records Started Processing Batch Id is '+ this.batchId,
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);


        }).catch(error =>{
           console.log('error in execute batch ' + error.message);
            this.isExecuteBatchError = true;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'something Went Wrong ' + error.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        })

        console.log('outside if condtion');

    }

    handleCancel() {
        // Add your cancel logic here
        window.location.href = 'lightning/page/home';
        console.log('Cancellation action');
    }

    handleGoToApexJob(){
        window.location.href = '/lightning/setup/AsyncApexJobs/home';
        console.log('Redirection succesfull');
    }



}
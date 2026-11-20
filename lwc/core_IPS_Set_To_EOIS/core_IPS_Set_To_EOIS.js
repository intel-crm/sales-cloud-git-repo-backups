import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import { refreshApex } from '@salesforce/apex';
import Core_EOIS from '@salesforce/schema/Core_IPS_Supported_Product__c.Core_EOIS__c';
import Core_Flag_Status from '@salesforce/schema/Core_IPS_Supported_Product__c.Core_Flag_Status__c';
import Supported_product_Id from '@salesforce/schema/Core_IPS_Supported_Product__c.Id';
const FIELDS = [Core_EOIS, Core_Flag_Status,Supported_product_Id];

export default class Core_IPS_Set_To_EOIS extends LightningElement {
@api recordId; // get the current record id
@track Core_EOIS;
@track Core_Flag_Status;
@track Supported_product_Id_Field;

// Wire method to get the data of fields
@wire( getRecord, { recordId: '$recordId', fields: FIELDS } )
    wiredRecord({ error, data }) {
        if ( error ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Record',
                    message,
                    variant: 'error',
                }),
            );
        } else if ( data ) {
            console.log( 'Record is ' + JSON.stringify( data ) );
            this.Core_EOIS = data.fields.Core_EOIS__c.value;
            this.Core_Flag_Status = data.fields.Core_Flag_Status__c.value;
            this.Supported_product_Id_Field = data.fields.Id.value;
        }
    }
  
// invoke method to call Lightning Quick Action
@api invoke() {
        // If current status is EOIS = TRUE
        if ( this.Core_EOIS === true ) {
            LightningAlert.open({
                message: 'Supported Product is already set to EOIS. No change will be made.',
                label:'Alert',
                theme: 'inverse',
            }).then((result) => {
                console.log('---result---' +result);
            }); 
        }
        else if ( this.Core_EOIS === false ){
            LightningConfirm.open({
                   message: '**WARNING** Setting the Access Flag to EOIS (End Of Interactive Support) can only be undone by KTBR! Are you sure you want to set this Supported Product\'s Access Flag to EOIS?',
                   label:'Confirmation',
                   theme: 'inverse',
            })
            .then((result) => {
                console.log('---result---' + result);
                if(result === true){
                   const fields = {};
                   fields[Supported_product_Id.fieldApiName] = this.recordId;
                   fields[Core_Flag_Status.fieldApiName] = 'EOIS';
                   fields[Core_EOIS.fieldApiName] = true; 

                   const recordInput = { fields }
                   console.log('---recordInput---' +recordInput);

                   updateRecord(recordInput)
                       .then(() =>{
                            this.dispatchEvent(
                                 new ShowToastEvent({
                                     title: 'Success!',
                                     message: 'Access flag Status updated successfully',
                                     variant: 'success'
                                  })
                            )
                       })
                       .catch(error =>{
                            this.dispatchEvent(
                                   new ShowToastEvent({
                                       title: 'Error!',
                                       message: 'Something went wrong while updating Supported Product',
                                       variant: 'error'
                                    })
                            )
                        }) 
                                       
                }
            });  
        }
}
}
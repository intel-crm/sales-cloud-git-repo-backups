import { LightningElement,api,track,wire  } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import Core_Status from '@salesforce/schema/Core_IPS_Map_Par_Line_Item__c.Core_Status__c';
import Par_Line_Item_Id from '@salesforce/schema/Core_IPS_Map_Par_Line_Item__c.Id';

const FIELDS = [Core_Status, Par_Line_Item_Id];

export default class Core_IPS_InActive_Product_Access_LineItem_LEX extends LightningElement {
    
@api recordId; // get the current record id
@track Core_Status;
@track Par_Line_Item_Id;

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
            this.Core_Status = data.fields.Core_Status__c.value;
        }
    }

// invoke method to call Lightning Quick Action
@api invoke(){
   if(this.Core_Status === 'INACTIVE'){
         LightningAlert.open({
               message: 'Only ACTIVE line items can be made INACTIVE. No change made.',
               label:' Alert' ,
               theme: 'inverse',
               
         }).then((result) => {
         }); 
    }

    else if(this.Core_Status === 'PENDING'){
        LightningAlert.open({
            message: 'Please approve or reject PENDING line items through the approval process.',
            label:'Alert',
            theme: 'inverse',
      }).then((result) => {
      });
    }

    else{
        LightningConfirm.open({
            message: 'Are you sure you want to set the Line Item Status to "Inactive"?',
            label:' Confirmation',
            theme: 'inverse',
        }).then((result) => {
            if(result === true){
              const fields = {};
              fields[Par_Line_Item_Id.fieldApiName] = this.recordId;
              fields[Core_Status.fieldApiName] = 'INACTIVE';

              const recordInput = { fields }
              updateRecord(recordInput)
                .then(() =>{
                     this.dispatchEvent(
                          new ShowToastEvent({
                              title: 'Success!',
                              message: 'Line Item Status updated successfully',
                              variant: 'success'
                           })
                     )
                })
                .catch(error =>{
                    console.log('---error---' +JSON.stringify(error));
                    this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'Error!',
                               message: error.body.output.fieldErrors.Core_IPS_Map_Par_Line_Item__c[0].message,
                               variant: 'error'
                            })
                    )
                }) 
            }

       });
    }

}

}
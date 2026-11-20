import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import Core_IPS_General_Public_Product_Label from '@salesforce/label/c.Core_IPS_General_Public_Product';
import Core_EOIS from '@salesforce/schema/Core_IPS_Supported_Product__c.Core_EOIS__c';
import Core_Flag_Status from '@salesforce/schema/Core_IPS_Supported_Product__c.Core_Flag_Status__c';
import Supported_product_Id from '@salesforce/schema/Core_IPS_Supported_Product__c.Id';
import Core_IPS_Public_Product from '@salesforce/schema/Core_IPS_Supported_Product__c.Core_IPS_Public_Product__c';
const FIELDS = [Core_EOIS, Core_Flag_Status,Supported_product_Id,Core_IPS_Public_Product];

export default class Core_IPS_Set_To_General_LEX extends LightningElement {

@api recordId; // get the current record id
@track Core_EOIS;
@track Core_Flag_Status;
@track Supported_product_Id_Field;
@track Core_IPS_Public_Product;
@track Core_IPS_General_Public_Product_Label;
//label= { Core_IPS_General_Public_Product_Label };

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
            console.log( '---label---' + Core_IPS_General_Public_Product_Label );
            this.Core_EOIS = data.fields.Core_EOIS__c.value;
            this.Core_Flag_Status = data.fields.Core_Flag_Status__c.value;
            this.Supported_product_Id_Field = data.fields.Id.value;
            this.Core_IPS_Public_Product = data.fields.Core_IPS_Public_Product__c.value;
        }
    }

// invoke method to call Lightning Quick Action
@api invoke(){
        // If current status EOIS = TRUE
       if(this.Core_EOIS === true){
             LightningAlert.open({
                   message: 'Once set to EOIS, you cannot clear the EOIS value from a Supported Product.',
                   label:' Alert' ,
                   theme: 'inverse',
                   
             }).then((result) => {
                console.log('---result---' +result);
             }); 
        }

        else if(this.Core_IPS_Public_Product === true){
            LightningAlert.open({
                message: 'Supported Product is already set as General (ALL Access!). No change will be made',
                label:'Alert',
                theme: 'inverse',
          }).then((result) => {
             console.log('---resultalert---' +result);
          });
        }

        else{
            LightningConfirm.open({
                message: '**WARNING** \n Setting the Access Flag to General (ALL Access!) will open up access to every IPS active customer allowing them to potentially create Cases with this Supported Product! This setting cannot be undone! \n\nAre you sure you want to set this Supported Product\'s Access Flag to General (ALL Access!)?',
                label:' Confirmation!!!',
                theme: 'warning',
            }).then((result) => {
                console.log('---resultconfirm---' + result);
                if(result === true){
                  const fields = {};
                  fields[Supported_product_Id.fieldApiName] = this.recordId;
                  fields[Core_Flag_Status.fieldApiName] = 'General (ALL Access!)';
                  fields[Core_IPS_Public_Product.fieldApiName] = true; 

                  const recordInput = { fields }
                  console.log('---recordInput---' +JSON.stringify(recordInput));
                  console.log('---fields---' +JSON.stringify(fields));
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
                        console.log('---error---' +JSON.stringify(error));
                        this.dispatchEvent(
                               new ShowToastEvent({
                                   title: 'Error!',
                                   message: error.body.output.fieldErrors.Core_IPS_Public_Product__c[0].message + '.  ' 
                                            + error.body.output.fieldErrors.Core_IPS_Public_Product__c[1].message,
                                   variant: 'error'
                                })
                        )
                    }) 
                }

           });
        }

}
}
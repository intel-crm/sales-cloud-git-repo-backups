import { LightningElement,api,track } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import getFieldsOfSelectedRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getFieldsOfSelectedRecords';

export default class Core_MDF_Approval_Details extends LightningElement {

   
   @track recdId;
@track accorOrDetail;
@track formFactor;
formFactor = formFactorPropertyName;
@api phoneordesktop;
@api
    //getter method
    get recId() {
        console.log('Entered'+this.__recId);
        
        return this._recId;

    }
    //setter method
    set recId(value) {
       if(value){
           console.log('Entered Inside  First set'+value);
            this._recId = value;
            this.recdId = value;
       }else{
            this._recId = undefined;
       }
}

   connectedCallback(){
       console.log('@@@@@'+this.phoneordesktop);
       console.log('****'+this.formFactor);
    if(this.formFactor == 'Large'){
        this.accorOrDetail = false;
    }else{
        this.accorOrDetail = true;
    }
   console.log('smallorLarge'+accorOrDetail);
   this.fetchFieldsOfDetailRecord();
   }
   fetchFieldsOfDetailRecord(){
    console.log('Entered Inside toggle');
    
   getFieldsOfSelectedRecords({recordId:this.recdId})
    .then(data => {
        this.fieldsToDisplay = JSON.parse(data);
        this.error = undefined;
        console.log('$$$ recordToDisplay'+ this.fieldsToDisplay)
    })
    .catch(error => {
        this.error = error;
        this.recordToDisplay = undefined;
    }); 
}
}
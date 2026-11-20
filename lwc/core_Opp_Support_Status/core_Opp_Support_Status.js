import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getStatus from '@salesforce/apex/Core_Opportunity_Support_statusupdate.getStatusValue';
import updateOnMS from '@salesforce/apex/Core_Opportunity_Support_statusupdate.updateOnMS';
import status from '@salesforce/schema/Core_Opportunity_Support__c.Core_Status__c';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from "@salesforce/apex";

export default class Core_Opp_Support_Status extends LightningElement {
 @api recordId;
 @track oppSupportStatus='';
 @track recordTypeId;
 @track statusValues;
 @track supportStatus;
 @track result;
 @track changestatus = false ;
 @track  wiredgetstatusdata ;
 @wire(getStatus, {recId: '$recordId'})
 getStatus(value){
  this.wiredgetstatusdata = value;
  const {error, data} = value;
 //getStatus({error, data}){
        if(data != undefined){
            for(var key in data){
              this.oppSupportStatus = data[key];
              this.recordTypeId = key;
            }
        }
}

 @wire(getPicklistValues,
        {
            recordTypeId:  '$recordTypeId', 
            fieldApiName: status
        }
        
    )

    picklistResults({ error, data }) {
    if (data) {
      this.statusValues = data.values;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.ratings = undefined;
    }
  }

handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    } 

handleChange(event){
      this.supportStatus=event.target.value;
      this.changestatus = true;
      
}

async saveRecord(event){
  if((this.supportStatus == '' || this.supportStatus == null || this.supportStatus == undefined ) && (this.oppSupportStatus=='Submitted')){
            const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Status Field is required',
            variant: 'error',
            mode: 'dismissable'
           });
           this.dispatchEvent(evt);
      }
      else{
        if(this.changestatus == false){
          this.supportStatus = this.oppSupportStatus;
        }
      try{
          this.result = await updateOnMS({ recordId : this.recordId , statusvalue : this.supportStatus});
          await refreshApex(this.wiredgetstatusdata);
          if(this.result == false){
            const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Opportunity Support Status Changed Successfully.',
            variant: 'success',
            mode: 'dismissable'
           });
           this.dispatchEvent(evt);
          }
          else{
            const evt = new ShowToastEvent({
            title: 'Error',
            message: 'You are not allowed to change status.',
            variant: 'error',
            mode: 'dismissable'
           });
           this.dispatchEvent(evt);
          }
         
    }catch(error){
      console.log('inside catch');
            const evt = new ShowToastEvent({
            title: 'Error',
            message: error.body.message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
     this.dispatchEvent(new CloseActionScreenEvent());
     eval("$A.get('e.force:refreshView').fire();");
    
      }
    
}

}
import { LightningElement,wire,api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue } from "lightning/uiRecordApi";
import Parent_ID from '@salesforce/schema/Account.ParentId'
import deactivated from '@salesforce/schema/Account.Core_Deactivated__c';

const FIELDS = [Parent_ID,deactivated];

export default class uCD_ACM_Deactivation_Toast_Message extends LightningElement {
    @api recordId;
    @wire(getRecord,{recordId:'$recordId',fields:FIELDS})
    account;
    loadFields({data}){
        if(data){
            const isChecked = getFieldValue(data,deactivated);
            if(isChecked==true){
                const event = new ShowToastEvent({
                    title:'Error Message',
                    message:'You cannot inactivate unified account with active child account reference',
                    variant:'error'
                });
                this.dispatchEvent(event);
            }
        }
    }

    //@wire(getFieldValue,{recordId:'$recordId',fieldApiName:FIELDS})

        }
import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import syncAccountChanges from'@salesforce/apex/UCD_ACM_SyncAccountChangesPOC.syncAccountChanges';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import Acct_masteredName from '@salesforce/schema/Account.Core_Data_Simplified_Account_Nm__c';
import Acct_newMasteredName from '@salesforce/schema/Account.New_Simplified_Account_Name__c';
import Acct_LocalLang from '@salesforce/schema/Account.Core_Data_Simplified_Local_Language_Nm__c';
import Acct_newLocalLang from '@salesforce/schema/Account.New_Simplified_Local_Language_Name__c';
import Acct_businessPartnerId from '@salesforce/schema/Account.Core_Business_Partner_Id__c';
import Acct_newBusinessPartnerId from '@salesforce/schema/Account.New_Business_Partner_Id__c';
import RECORD_TYPE_ID from '@salesforce/schema/Account.RecordTypeId'

const fields = [Acct_masteredName,Acct_newMasteredName,Acct_LocalLang,Acct_newLocalLang,Acct_businessPartnerId,Acct_newBusinessPartnerId, RECORD_TYPE_ID];

export default class uCD_ACM_AccountChangeReview extends LightningElement {
        @api recordId;
        isDisplayPage = true;
        @track showSpinner = false;
        @wire(getRecord, {
            recordId: "$recordId",
            fields
        })
        account;
        @wire(getObjectInfo, { objectApiName: 'Account' })
            objectInfo;

        /*@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Acct_CustAggrType })
        setPicklistOptions({error, data}) {
            if (data) {
                console.log('data--> ',data);
                this.aggregationType = data.values;
             }
        }
        renderedCallback(){
            unifiedDataValues({accountId:this.recordId}).then(response => {
                this.cpe = response.customerProcessEngg;
                this.cwl = response.complianceWatchList;
                this.isDisplayPage = true;
            })
            .catch(error => {
                console.log('Error is --> ',error);
                this.error = error;
            })
        }*/

        get masterAccountName() {
            return getFieldValue(this.account.data, Acct_masteredName);
        }

        get newMasterAccountName() {
            return getFieldValue(this.account.data, Acct_newMasteredName);
        }

        get localName() {
            return getFieldValue(this.account.data, Acct_LocalLang);
        }

        get newLocalName() {
            return getFieldValue(this.account.data, Acct_newLocalLang);
        }

        get businessId() {
            return getFieldValue(this.account.data, Acct_businessPartnerId);
        }

        get newBusinessId() {
            return getFieldValue(this.account.data, Acct_newBusinessPartnerId);
        }



        onApprove(event) {
            console.log(' Check getRecord : ',this.account);
            console.log('check : ',this.account.data.recordTypeInfo.name);
            console.log(' Check Id : ',this.account.data.id);

            if(this.account.data.recordTypeInfo.name === 'Intel Account' || this.account.data.recordTypeInfo.name === 'End Customer Deal Account') {
                //call apex to sync changes.
                syncAccountChanges({ accountId: this.account.data.id })
                .then(result => {

                    /*this.account.data.fields.Core_Business_Partner_Id__c.value = result.Core_Business_Partner_Id__c;
                    this.account.data.fields.Core_Data_Simplified_Account_Nm__c.value = result.Core_Data_Simplified_Account_Nm__c;
                    this.account.data.fields.Core_Data_Simplified_Local_Language_Nm__c.value = result.Core_Data_Simplified_Local_Language_Nm__c;
                    this.account.data.fields.New_Business_Partner_Id__c.value = result.New_Business_Partner_Id__c;
                    this.account.data.fields.New_Simplified_Account_Name__c.value = result.New_Simplified_Account_Name__c;
                    this.account.data.fields.New_Simplified_Local_Language_Name__c.value = result.New_Simplified_Local_Language_Name__c;
                    */
                    refreshApex(this.account);

                    const event = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'Success: Record is updated',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Toast Error',
                        message: error.message + ' Error updating record',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                });
                /*syncAccountChanges({ accountRecord: this.account })
                .then(result => {
                    const event = new ShowToastEvent({
                        title: 'Toast message',
                        message: 'Success: Record is updated',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Toast Error',
                        message: 'Error updating record',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                })*/
            } else {
                //show message
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Record type is not Intel OR ECD',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
        }
}
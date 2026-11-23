import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NewUnifiedId from '@salesforce/schema/UCD_Account_Change_Review__c.New_Unified_ID__c';
import getAccounts from "@salesforce/apex/uCD_ACM_AccountChangeReviewController.getAccounts";
const fields = [NewUnifiedId];
export default class UCD_ACM_AcctChangeReview extends LightningElement {
    @api
    recordId;
    accrecId;
    newbpid;
    isDisplayPage = false;
    accountList=[];
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields
        
    })
    UCD_Account_Change_Review__c;
    get NewUnifiedId() {
        console.log('this.account.data--> ',this.UCD_Account_Change_Review__c);
        console.log('bpid',getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId));
        return getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId);
    }
    navigateToDetail(event) {
        this.accrecId = event.target.value;
        console.log('event+++'+this.accrecId);
        this.sfdcBaseURL = window.location.origin;
        let acctUrl = this.sfdcBaseURL + "/" + this.accrecId;
        window.open(acctUrl);
      }
    
    renderedCallback(){
      console.log('testRequest'+getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId));
      if(getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId) != null && getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId) != ''){
        getAccounts({strNewUnifiedId:getFieldValue(this.UCD_Account_Change_Review__c.data, NewUnifiedId)}).then(response => {
            this.accountList= response;
            //if(this.accountList.length != 0){
            this.isDisplayPage = true;
            console.log('this.accountList'+response);
           // }
        })
        .catch(error => {
            console.log('Error is --> ',error);
            this.error = error;
            
        })
    }
    }
}
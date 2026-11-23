import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import displayAccountPreviewSection from '@salesforce/apex/Core_AccountLayoutController.displayAccountPreviewSection';
import Core_Sales_Group_Preview__c from '@salesforce/schema/Account.Core_Sales_Group_Preview__c';
import Core_Account_Owner_Preview__c from '@salesforce/schema/Account.Core_Account_Owner_Preview__c';
import Core_Account_Category_Preview__c from '@salesforce/schema/Account.Core_Account_Category_Preview__c';
import Core_Account_Primary_Coverage_Preview__c from '@salesforce/schema/Account.Core_Account_Primary_Coverage_Preview__c';
import Core_GTM_Model_Preview__c from '@salesforce/schema/Account.Core_GTM_Model_Preview__c';
const fields = [Core_Sales_Group_Preview__c, Core_Account_Owner_Preview__c, Core_Account_Category_Preview__c,Core_GTM_Model_Preview__c,Core_Account_Primary_Coverage_Preview__c];
export default class AccountHiddenFieldComp extends LightningElement {
    @api
    recordId;
    @track valueFromAPex;
    @track isExpanded = true;

    @wire(getRecord, {
        recordId: "$recordId",
        fields
     })account;

    @wire(getObjectInfo, { objectApiName: 'Account' })
        objectInfo;

        get salesGroupReview() {
            console.log('this.account.data--> ',this.account);
            console.log('bpid',getFieldValue(this.account.data, Core_Sales_Group_Preview__c));
            return getFieldValue(this.account.data, Core_Sales_Group_Preview__c);
        }
        get accountOwnerPreview() {
            console.log('this.account.data--> ',this.account);
            console.log('bpid',getFieldValue(this.account.data, Core_Account_Owner_Preview__c));
            return getFieldValue(this.account.data, Core_Account_Owner_Preview__c);
        }
        get semiAccountCategoryPreview() {
            console.log('this.account.data--> ',this.account);
            console.log('bpid',getFieldValue(this.account.data, Core_Account_Category_Preview__c));
            return getFieldValue(this.account.data, Core_Account_Category_Preview__c);
        }
        get accountPrimaryCoveragePreview() {
            console.log('this.account.data--> ',this.account);
            console.log('bpidforcovergae',getFieldValue(this.account.data, Core_Account_Primary_Coverage_Preview__c));
            return getFieldValue(this.account.data, Core_Account_Primary_Coverage_Preview__c);
        }
        get gtmModelReview() {
            console.log('this.account.data--> ',this.account);
            console.log('bpid',getFieldValue(this.account.data, Core_GTM_Model_Preview__c));
            return getFieldValue(this.account.data, Core_GTM_Model_Preview__c);
        }
        connectedCallback(){
            console.log('69',this.valueFromAPex);
            displayAccountPreviewSection()
            .then(result => {
        console.log('76',this.valueFromAPex);
        console.log('166',result);
          
          if(result==false)
          {
            this.valueFromAPex = false;
          }
          else
          {
            this.valueFromAPex = true; 
          }
        //alert(this.valueFromAPex);
        console.log('value',result);
        })
        .catch((error) => {
            this.error = error;
            console.log('error',this.error);
        });
        console.log('dummy',this.dummy);
        }
        
    
      
        toggleSection() {
            this.isExpanded = !this.isExpanded;
        }    
}
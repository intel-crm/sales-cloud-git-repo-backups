import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import displayAccountPreviewSection from '@salesforce/apex/Core_AccountLayoutController.displayAccountPreviewSection';
import getFieldPermissions  from '@salesforce/apex/Core_AccountLayoutController.getFieldPermissions';
import Core_Sales_Group_Preview__c from '@salesforce/schema/Account.Core_Sales_Group_Preview__c';
import Core_Account_Owner_Preview__c from '@salesforce/schema/Account.Core_Account_Owner_Preview__c';
import Core_Account_Category_Preview__c from '@salesforce/schema/Account.Core_Account_Category_Preview__c';
import Core_Account_Primary_Coverage_Preview__c from '@salesforce/schema/Account.Core_Account_Primary_Coverage_Preview__c';
const fields = [Core_Sales_Group_Preview__c, Core_Account_Owner_Preview__c, Core_Account_Category_Preview__c,Core_Account_Primary_Coverage_Preview__c];
export default class preview_Hide_Unhide_Fields_on_Account extends LightningElement {
@api
recordId;
@track valueFromAPex;
@track valueOnClickOfEdit=false;
@track fieldPermissions;
@track salesGroupPreviewBool=false;
@track accountOwnerPreviewBool=false;
@track accountCategoryPreviewBool=false;
@track accountPrimaryCoverageBool=false;
@track isUpdateable;

isLoading = false;
@wire(getRecord, {
recordId: "$recordId",
fields
})account;

@wire(getObjectInfo, { objectApiName: 'Account' })
objectInfo;

loadFieldPermissions() {
    getFieldPermissions({ objectApiName: 'Account' })
        .then(result => {
            this.fieldPermissions = result;
      console.log('permission',this.fieldPermissions);
    this.handleMapValues();
    })
        .catch(error => {
            // Handle error
        });
}
handleMapValues() {
    for (let fieldName in this.fieldPermissions) {
        if (this.fieldPermissions.hasOwnProperty(fieldName)) {
            this.isUpdateable = this.fieldPermissions[fieldName];
             console.log( fieldName, this.isUpdateable);
        }
        if(fieldName === 'Core_Sales_Group_Preview__c'.toLowerCase() &&  this.isUpdateable)
        {
          this.salesGroupPreviewBool=true;
        }
        if(fieldName  === 'Core_Account_Owner_Preview__c'.toLowerCase() && this.isUpdateable)
        {
          this.accountOwnerPreviewBool=true;
        }
        if(fieldName  === 'Core_Account_Category_Preview__c'.toLowerCase() && this.isUpdateable )
        {
          this.accountCategoryPreviewBool=true;
        }
        if(fieldName  === 'Core_Account_Primary_Coverage_Preview__c'.toLowerCase() && this.isUpdateable)
        {
          this.accountPrimaryCoverageBool=true;
        }
        

    }
     
}

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

connectedCallback(){
    console.log('69',this.valueFromAPex);
    this.loadFieldPermissions();

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

handleSubmit(event){
    this.isLoading = true;
}
handleSuccess(event) {
    this.valueFromAPex=true;
    this.valueOnClickOfEdit=false;
    this.isLoading = false;
        
    
}
    
handleEdit(event){
this.valueOnClickOfEdit=true;
this.valueFromAPex=false;
}
backToFirstPage(event){
        this.valueFromAPex=true;
        this.valueOnClickOfEdit=false;
    }
}
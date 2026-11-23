import { LightningElement ,api,track,wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getUserRegionUITheme from '@salesforce/apex/Core_SalesSupportRequest_ITController.getUserRegionUITheme';

export default class Core_SalesSupportRequest_IT extends NavigationMixin(LightningElement) {
     objectPrefix = 'a0s';
     recordTypeId = '012o0000000pEji';
     opportunityNameFieldId = '00No000000CnaeH';    
    @api recordId;
    @track userRegion = '';
    @track UITheme = '';

@wire(getUserRegionUITheme,{})
userDetails({error,data}){
    if(data){
        console.log('data'+data+data[0]+data[1]);
        this.userRegion = data[0];
        this.UITheme = data[1];
        console.log('this.userRegion'+this.userRegion);
        console.log('this.UITheme'+this.UITheme);

    }
}

    handle(){

        if(this.UITheme == 'Theme3' && this.recordId != '' ){
        redirectUrl1 = '/' + this.objectPrefix + '/e?retURL=%2F' + objectPrefix + '%2Fo&RecordType=' + recordTypeId;              
        redirectUrl = redirectUrl1 + '&CF' + opportunityNameFieldId + '=' + encodeURIComponent(sOpportunityName) + '&CF' + opportunityNameFieldId + '_lkid=' + sOpportunityId +'&' + '00No000000CnaeD=' + this.userRegion;
        console.log('redirectUrl1'+redirectUrl1);
        console.log('redirectUrl'+redirectUrl);
      
       window.location = redirectUrl;
       console.log('redirectUrl'+redirectUrl);
      }
      else{
            const defaultValues = encodeDefaultFieldValues({
                Core_IT_Intel_Geo__c: this.userRegion,
                Core_Opportunity__c : this.recordId,  
            });
    
            console.log('defaultValues'+defaultValues);
    
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Core_Sales_Support_Request__c',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: defaultValues
                }
            });
        }
       
    }


}
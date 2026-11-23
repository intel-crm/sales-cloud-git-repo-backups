import { LightningElement,api } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Core_IPS_Project__c.Name';
import Project_id from '@salesforce/schema/Core_IPS_Project__c.Core_IPS_Project_ID__c';
import Project_Des from '@salesforce/schema/Core_IPS_Project__c.Core_Project_Description__c';
import Interested_check from '@salesforce/schema/Core_IPS_Project__c.Core_IPS_EnableMemberasInterestedParties__c';
import Details_check from '@salesforce/schema/Core_IPS_Project__c.Core_IPS_Remove_Notification_Details__c';
import MPNDA from '@salesforce/schema/Core_IPS_Project__c.Core_MPNDA__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Core_IPS_EditForm extends NavigationMixin(LightningElement) {
@api recordId;
@api objectApiName;
nameField = NAME_FIELD;
projectIdField=Project_id;
projectdescField=Project_Des;
interestedparties=Interested_check;
Details=Details_check;
mpnda=MPNDA;
closeWindow=true;
constructor() {

    super();

    console.log('RecordId : ',this.recordId);

   

}
connectedCallback(){
    
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        // eslint-disable-next-line no-console
        console.log('id ===> '+newURL.get('recordId'));
        this.recordId = newURL.get('recordId');
        console.log('recordId--'+this.recordId);
       
        
    
} 
handleDialogClose(){
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
}   
handleSave(){
    const evt = new ShowToastEvent({
        title: 'Record Saved',
        message: 'Project Saved successfully',
        variant: 'success',
        });
        this.dispatchEvent(evt);
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
}
handleNavigateBack() {
    console
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
}
}
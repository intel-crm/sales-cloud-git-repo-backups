import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import Customer_Feedback_Report_Id from '@salesforce/label/c.Customer_Feedback_Report_Id';
//import Account_Feedback_Report_Id from '@salesforce/label/c.Account_Feedback_Report_Id';
import CST_Reports_Folder_Id from '@salesforce/label/c.CST_Reports_Folder_Id';

export default class Core_cstFeedbackReportsLWC extends NavigationMixin(LightningElement) {

connectedCallback() {
    console.log('Inside connectedcallback feedback');
     this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: CST_Reports_Folder_Id,
            objectApiName: 'Report',
            actionName: 'view'
        }
    });
    
}
}
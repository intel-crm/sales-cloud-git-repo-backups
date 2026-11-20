import { LightningElement,api,track } from 'lwc';
import SUBJECT from '@salesforce/schema/Case.Subject';
import DESCRIPTION from '@salesforce/schema/Case.Core_Issue_Description__c';

export default class Core_IPS_DescriptionView_Lex extends LightningElement {
    @api recordId;
    objectApiName='Case';
    @track caseDescriptionfields = [SUBJECT,DESCRIPTION];
}
//SFDX Test Deployment 24082026-WW35.1--only single comment
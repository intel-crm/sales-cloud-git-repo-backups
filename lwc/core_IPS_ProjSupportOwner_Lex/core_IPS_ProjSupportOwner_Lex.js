import { LightningElement,api,wire,track } from 'lwc';
import getIntelSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.getIntelSupportOwner';
import getPartnerSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.getPartnerSupportOwner';
import updateSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.updateSupportOwner';
import { CloseActionScreenEvent } from 'lightning/actions';
import {NavigationMixin} from 'lightning/navigation'; 
const columns = [
    { label: 'FirstName', fieldName: 'FirstName', type: 'text' },
    { label: 'LastName', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'UserId', fieldName: 'UserId', type: 'email' },
];
export default class Core_IPS_AddProjSupportOwner_Lex extends NavigationMixin {
}
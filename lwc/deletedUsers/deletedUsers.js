import { LightningElement, track } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Contact.Name';

export default class DeletedUsers extends LightningElement {
     // Expose a field to make it available in the template
     nameField = NAME_FIELD;

     // Flexipage provides recordId and objectApiName
     @track recordId;
     @track objectApiName;
}
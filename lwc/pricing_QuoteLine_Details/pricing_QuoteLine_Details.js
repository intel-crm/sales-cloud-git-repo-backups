import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import isCreateable from '@salesforce/apex/Pricing_QuoteLineController.isCreateable';

export default class Pricing_QuoteLine_Details extends NavigationMixin(LightningElement) {
  @track isLoading = false;
  @api recordId;
  @track hasCreateAccess;

  @wire(isCreateable)
  getCreateAccess({ error, data }) {
    if (data) {
      this.hasCreateAccess = data;
    } else if (error) {
      console.error('Error:', error);
    }
  }

  // Handles loading event
  handleLoading() {
    this.isLoading = true;
  }

  // Handles done loading event
  handleDoneLoading() {
    this.isLoading = false;
  }

  // createNewQuoteLine() {
  //   this.createNewQL = true;
  // }
}
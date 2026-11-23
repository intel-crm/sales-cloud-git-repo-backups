import { LightningElement, wire, api,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class PricingAIComponent extends NavigationMixin (LightningElement) {
   @api quoteLineId = '';
   @track showDetails;
   @track showSpinner=false;
   @track selectedRecordId=null;
   @track isNotNavigation = true;
   currentPageReference;
   @track sfdcBaseURL;

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      this.currentPageReference = currentPageReference;
         if (this.currentPageReference.state.c__qline !== undefined) {
            this.isNotNavigation = false;
            this.urlStateParameters = currentPageReference.state;
            setTimeout(function () {
               this.showSpinner = true;
               //this.showDetails = true;
               this.quoteLineId = this.urlStateParameters.c__qline;
               this.showDetails = true;
               this.selectedRecordId = this.urlStateParameters.c__qline;
               this.showSpinner = false;
            }.bind(this), 500);
            this.showDetails = false;
            this.showSpinner = false;
         }
      
   }

   connectedCallback(){
      this.showDetails = false;
      this.sfdcBaseURL = window.location.origin+'/lightning/n/Price_Recommendation';
   }

   handleValueChange(){
      this.showDetails = false;
   }


   handleQuoteLineSelection(event){
      if(this.isNotNavigation === true) {
         console.log('inside selection event==>');
         this.quoteLineId = event.detail.recordId;
         this.showSpinner = true;
         this.callAPI();
      }   

   }
   callAPI(){
      this.showDetails = true;
      this.showSpinner = false;
   }

  
   handleCancel(event) {
      if(this.isNotNavigation === false ) {
          window.open( this.sfdcBaseURL, '_self');
      }
   }


}
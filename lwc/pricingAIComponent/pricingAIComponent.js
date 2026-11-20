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
      console.log('page reference==>',currentPageReference.state);
         if (this.currentPageReference.state.c__qline !== undefined) {
            //this.currentPageReference = currentPageReference;
            this.isNotNavigation = false;
            console.log('inside page reference',currentPageReference);
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
      
       console.log('isnavigation in wire====>',this.isNotNavigation);
   }

   connectedCallback(){
      console.log('inside connected callback==> AI');
      this.showDetails = false;
      this.sfdcBaseURL = window.location.origin+'/lightning/n/Price_Recommendation';
      console.log('url==>',this.sfdcBaseURL);
   }

   handleValueChange(){
      this.showDetails = false;
   }


   handleQuoteLineSelection(event){
      console.log('isNavigation==>',this.isNotNavigation); 
      console.log('quote line selection==>',event.detail.recordId); 
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
import { LightningElement,track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeRecordCache from '@salesforce/apex/PMP_ClearCacheOnSpecificRecordController.removeRecordCache';

export default class PMP_ClearCacheOnSpecificRecord extends NavigationMixin(LightningElement) {
   @track currentPageReference;
   response;
   objName;
   recId;
   parameters = {};
   

   @wire(CurrentPageReference)
   setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    get recordId() {
        return this.currentPageReference?.state?.c__recordId;
    }
   connectedCallback() {
          const param1 = 'recordId';
          const param2 = 'obj';
          this.parameters = this.getQueryParameters();
          this.recId = this.getRecordID(window.location.href, param1);
          this.objName = this.getObjName(window.location.href, param2);
         

         console.log('parameters------>',this.parameters);
      
         removeRecordCache({recordId:this.recId, objectName:this.objName}).then(response => {
               this.response = response;
               console.log('response: ' +this.response);
               if(this.response){
                  const evt = new ShowToastEvent({
                  title: 'Success!',
                  message: 'Cleared Cache',
                  variant: 'success',
                  mode: 'dismissable',
                  duration:'5000',
                  key: 'info_alt'
                  });
               this.dispatchEvent(evt);
               // IPA2.0 + US TWC4497-1631
               // if(this.objName == 'OfferingDetail'){
               //    this.navigateToOfferingListView();
               // } else if (this.objName == 'Event'){
               //    this.navigateToEventListView();
               // } else if(window.location.href.indexOf("pmp-partner-offering") === -1 && !(this.objName == 'Event')){
               //    this.navigateToOfferingLightingView();
               // }  else 
               if(window.location.href.indexOf("pmp-marketplace-event") === -1) {
                  this.navigateToEventLightingView();
               }      
            }
         }).catch(error => {
            console.log('Error: ' +error.body.message);
            const evt = new ShowToastEvent({
                  title: 'Error!',
                  message: 'Error in clearing cache',
                  variant: 'error',
                  mode: 'dismissable',
                  duration:'5000',
                  key: 'info_alt'
                  });
               this.dispatchEvent(evt);
         });
   }
   // IPA2.0 + US TWC4497-1631
      // navigateToOfferingListView(){
      //    this[NavigationMixin.Navigate]({
      //                   type: 'standard__webPage',
      //                   attributes: {
      //                      url: '/pmp-partner-offering/PMP_Partner_Offering__c',
      //                   }
      //                });
      // }
      navigateToEventListView(){
         this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                           url: '/pmp-marketplace-event/PMP_Marketplace_Event__c',
                        }
                     });
      }
      // IPA2.0 + US TWC4497-1631
      // navigateToOfferingLightingView(){
      //    this[NavigationMixin.Navigate]({
      //                   type: 'standard__webPage',
      //                   attributes: {
      //                      url: '/lightning/r/PMP_Partner_Offering__c/' + this.recordId + '/view'
      //                      ,
      //                   }
      //                });
      // }
       navigateToEventLightingView(){
         this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                           url: '/lightning/r/PMP_Marketplace_Event__c/' + this.recordId + '/view'
                           ,
                        }
                     });
      }
      getRecordID(url,param1){
         return new URL(url).searchParams.get(param1);
      }
      getObjName(url,param2){
         return new URL(url).searchParams.get(param2);
      }
      getQueryParameters(){
         var params = {};
         var search = window.location.href;
         console.log('search--->',search);
         /*var search = location.search.substring(1);
         console.log('search--->',search);
         if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }*/
        return params;
      }
   }
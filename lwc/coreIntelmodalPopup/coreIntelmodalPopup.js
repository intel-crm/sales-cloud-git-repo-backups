import { LightningElement,track,api,wire } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import currentUserId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';


//const FIELDS = [ 'Order.Id', 'Order.Type', 'Order.Status','Order.SBQQ__Quote__c','Order.Pricebook2.Name'];
const FIELDS = [ 'Order.Type','Order.Pricebook2.Name','Order.Status','Order.Sales_End_Customer_Account__c','Order.SBQQ__Quote__c',
'Order.Sales_End_Customer_Account__r.ParentId', 'Order.SBQQ__Quote__r.SBQQ__Account__c','Order.SBQQ__Quote__r.SBQQ__PriceBook__r.Name'];

export default class CoreIntelmodalPopup extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
    @track isModalOpen = false;
		@api recordId;
		@api toastKeys;
    @api toastTitle;
    @api toastMessage;
		@api runInSystemMode;
    @api orderType;
    @api priceBook;
    @api quote;
    @api isChanged;
    @api quotePriceBook;
    @api orderStatus;
    check;
    @api fieldName = 'Pricebook2.Name';
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
	  order;
    channelName = '/event/ToastEvent__e';
    subscription = {};

    connectedCallback() {
        this.toastKeys = this.toastKeys ? this.toastKeys.split(',').map(key => key.trim()) : '';
				const ci = this;
				const toastCallback = function(response) {
						let toastData = response['data']['payload'];
            let finalMsg = '';
        
						if(
								toastData && 
								toastData['Key__c'] &&
                (ci.toastKeys.includes(toastData['Key__c'])||ci.recordId==toastData['Key__c']) &&
								(
                    ci.runInSystemMode ||
                    (toastData['CreatedById'] === currentUserId)
                )
						){
								ci.toastTitle = toastData['Title__c'];
								ci.toastMessage = toastData['Message__c'];
               
								ci.isModalOpen = true;
				}
				}
				subscribe(this.channelName, -1, toastCallback).then(response => {
            console.log('Subscribed to Platform Event Toast');
            this.subscription = response;
        });
        onError(error => {
            console.log('Error in Platform Event Toast'+error);
            console.log('@@error:'+error);
        });
    }
    handleOnLoad(){
      this.orderType=this.order.data.fields.Type.value; 
      this.priceBook=this.order.data.fields.Pricebook2.value.fields.Name.value;
      this.quote=this.order.data.fields.SBQQ__Quote__c.value; 
      this.orderStatus=this.order.data.fields.Status.value; 
      this.quotePriceBook=this.order.data.fields.SBQQ__Quote__r.value.fields.SBQQ__PriceBook__r.value.fields.Name.value;
      console.log('@@pricebook->>'+this.quotePriceBook);
      if(this.orderType==='Sample Order' && this.quote!==null && this.orderStatus==='Draft' && this.quotePriceBook!=='OEM'){
        console.log('Inside if');
        this.isChanged=true;
      }
      return this.isChanged;
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
            console.log('Un-Subscribed from Platform Event Toast');
            console.log('response->>'+response);
        });
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}
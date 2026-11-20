/*********************************************************************************************************************
Version       : 1.0
Created Date  : Apr 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Puja Ingale        3-Apr-2021             PricebookOverrideLWC LWC Component
* ---------------------------------------------------------------------------------------------------------*/
import { LightningElement,api,wire } from 'lwc';
/*import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import setPricebook from '@salesforce/apex/Sales_PriceBookOverrideController.setPricebook';
import priceBookError from '@salesforce/label/c.Sales_PriceBook_Error'; 				//For changing the Pricebook on the order, please remove the order products first.
import quotePriceBookError from '@salesforce/label/c.Sales_Quote_PriceBook_Error'; 		//You cannot change the Pricebook for this order since there is a associated Quote. If you want to change the pricebook, please change the Pricebook in the Quote and then remove all the order products.
import successTxt from '@salesforce/label/c.Sales_Order_Success';                       //Success title
import errorMsg from '@salesforce/label/c.Sales_Error_Message';     
import SalesPricebookHTML from '@salesforce/label/c.Sales_Pricebook_HTML';                       //Success title
import SalesPricebookErrHTML from '@salesforce/label/c.Sales_PricebookErr_HTML';  
import SalesChangedPricebookSuccess from '@salesforce/label/c.Sales_ChangedPricebookSuccess';  



//Error title

const FIELDS = [ 'Order.Id', 'Order.Pricebook2Id', 'Order.OrderItemCount__c','Order.SBQQ__Quote__c'];
*/
export default class SalesPriceBookOverride extends LightningElement {

	/*@api recordId;
	@api showModal;
	@api pricebookId;
	@api orderProductCount;
	@api quote;
	@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
	order;

	/*if (data) {
		this.record = data;
		this.error = undefined;
	} else if (error) {
		this.error = error;
		this.record = undefined;
	}*/

/*
	label = {
        successTxt,	
        errorMsg,
		priceBookError,
		quotePriceBookError,
		SalesPricebookHTML,
		SalesPricebookErrHTML,
		SalesChangedPricebookSuccess

	};

	handleOnLoad(){
		//INITIALIZATION
        console.log('In handleOnLoad');
        console.log(this.order.data);                                                             
		this.pricebookId=this.order.data.fields.Pricebook2Id.value; 
		this.orderProductCount = this.order.data.fields.OrderItemCount__c.value; 
		this.quote = this.order.data.fields.SBQQ__Quote__c.value;
		if(this.orderProductCount == 0 && this.quote==null){                      
			this.showModal=true;
		}else{
			this.showModal=false;
		}

		if(this.orderProductCount != 0 && this.quote==null){
			this.closeQuickAction();
			this.fireToastEvent(this.label.errorMsg,this.label.priceBookError,'error','sticky');
		}
		if(this.quote!=null){
			this.closeQuickAction();
			this.fireToastEvent(this.label.errorMsg,this.label.quotePriceBookError,'error','sticky');	
		}			
	}

	handleYes(){
		console.log('Submit PricebookId: '+this.pricebookId);
		setPricebook ({ objId: this.recordId, pId:this.pricebookId })
			.then(() =>{
				this.closeQuickAction();
				this.fireToastEvent('Success!',this.label.SalesChangedPricebookSuccess,'success','dismissable');
				this.reloadPage();
		})
			.catch((error) => {
				this.fireToastEvent('Error!',error.body.message,'error','sticky');
		});
	}

	handleNo(){
		this.closeQuickAction();
	}

	handleChange(event){
		this.pricebookId=event.target.value;  
		console.log('Change PricebookId: '+this.pricebookId);
	}

	fireToastEvent(title,message,variant,mode){
		const event = new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: mode
		});
		this.dispatchEvent(event);
	}

	reloadPage(){
		location.reload(true);
			/*setTimeout(function() {
					eval("$A.get('e.force:refreshView').fire();");
			}, 2000);*/
	/*}

	closeQuickAction() {
		const closeModal = new CustomEvent('close');
		// Dispatches the event.
		this.dispatchEvent(closeModal);
	}
}


//import onLoadDataProvider from '@salesforce/apex/Sales_PriceBookOverrideController.onLoadDataProvider';
/*onLoadDataProvider ({ objId: this.recordId })
					.then((result) =>{
					this.pricebookId=result.Pricebook2Id;
					this.orderProductCount=result.OrderItemCount__c;
					console.log('Init: Pricebook Id: '+this.pricebookId);
					console.log('Init: OrderProduct Count: '+this.orderProductCount);
			})
					.catch((error) => {
					this.closeQuickAction();
					this.fireToastEvent('Error!',error.body.message,'error','sticky');
			}); */
}
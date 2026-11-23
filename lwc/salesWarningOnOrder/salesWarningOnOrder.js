/*
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------- 
* Srishty Sharma           22-Jan-2020              US862469:Price & Quantity Logic of a Order Product for different types of orders
*
*/
import { LightningElement,track,api } from 'lwc';
import { subscribe, onError } from 'lightning/empApi'; //streaming api to subscribe to change data capture event
//import validateQuantity from '@salesforce/apex/Sales_DisplayWarning.validateQuantity'; // apex method import
//import recalculatePrice from '@salesforce/apex/Sales_RecalculatePrice.recalculatePriceChange';//apex method import
import recalculation_Success from '@salesforce/label/c.sales_Recalculation_Success_Msg';
import orderProduct_Count from '@salesforce/label/c.sales_Orderproduct_count_error_on_order_on_recalculation';
import no_recalculation_Msg from '@salesforce/label/c.sales_No_Recalculation_Required_Msg';
import error_Txt from '@salesforce/label/c.Sales_Error_Message';
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import priceMismatch from '@salesforce/label/c.Sales_UnitPrice_Mismatch_Error';
import infoText from '@salesforce/label/c.sales_Info_Text_Msg';
import SalesRecalculatePriceHTML from '@salesforce/label/c.Sales_RecalculatePrice_HTML';
import SalesWarning from '@salesforce/label/c.Sales_Warning';
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';
import SalesOrderSuccess from '@salesforce/label/c.Sales_Order_Success';
import salesInfoTextMsg from '@salesforce/label/c.sales_Info_Text_Msg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Sales_DisplayWarning extends LightningElement {
		@api objectApiName;//to get the object id from URL
		@api recordId;//to get the record id from URL
		@api isWarningChanged = false;
		@api returnMsg ;
		@api displayWarning;
		@track showWarning = false;
		@track reasonCheck = false;
    	@track warningMessage;
		channelName = '/data/';

		label = {
			SalesErrorMessage,SalesOrderSuccess,salesInfoTextMsg,successTxt,recalculation_Success,orderProduct_Count,no_recalculation_Msg,error_Txt,priceMismatch,infoText,SalesWarning,SalesRecalculatePriceHTML
		};  
		
		connectedCallback() {
				if (this.objectApiName.endsWith('__c')) {
            // Custom object
            this.channelName = this.channelName + this.objectApiName.substring('0', this.objectApiName.length-3) + '__ChangeEvent';
        }
        else {
            // Standard object
            this.channelName = this.channelName + this.objectApiName + 'ChangeEvent';
        }
				const ci = this
				const changeDataCallback = function(response) { //callback function for change data capture event
						let modifiedRecords = response['data']['payload']['ChangeEventHeader']['recordIds'];//Retreiving the modified record ids from event data
						if(modifiedRecords.includes(ci.recordId)){ 
								ci.validateQuantityOnOrder();
								//calling the js method to call apex method once change data capture event is received
								console.log('Im here');	
						}
				}
				subscribe(this.channelName, -1, changeDataCallback).then(response => { //subscribed to change data capture
            console.log('Subscribed to Platform Event Change Data');

        });
        onError(error => {
            console.log('Error in Platform Event Change Data'+JSON.stringify(error));
            console.log(error);
        });
        		ci.validateQuantityOnOrder();
				console.log('Im here on error');
				
		}
    //method to call price mismatch warning and maintenance date logic
		/*validateQuantityOnOrder(){
		
				//validateQuantity({ orderId: this.recordId, messageVal:'Warning'}) //calling apex method
				validateQuantity({ orderId: this.recordId, selectedField: 'Display' })
						.then(result => {
						this.warningMessage = result;
						if(this.warningMessage!=null){
							//checking if the message returned from apex is matching the price mismatch warning text
							if(this.warningMessage.includes(this.label.priceMismatch)){
								this.reasonCheck=true;//showing the recalculate hyperlink 
								console.log('Inside warning append>>');
							}
							else{
								this.reasonCheck=false;
							}
								this.showWarning = true;
						}
						else{
								this.reasonCheck=false;
								this.showWarning = false;
								
						}
						this.error = undefined;
				})
						.catch(error => {
						this.error = error;
						this.warningMessage = undefined;
				});
				
				
		}
		//method to recalculate the unit price when user click on the hyperlink
		recalculate(){
			validateQuantity({ orderId: this.recordId,selectedField: 'Recalculate'}) //calling apex method
						.then(result => {
							this.returnMsg = result;
							console.log('Message returned'+this.returnMsg);
							//checking if the message returned from apex is matching the price mismatch warning text
							if(this.returnMsg!=null && this.returnMsg.includes('Success')){
								//this.reasonCheck=true;
								console.log('Inside warning append>>');
								this.reasonCheck=false;
								this.showWarning = false;
								this.fireToastEvent(this.label.successTxt,this.label.recalculation_Success,'success','sticky');//firing the toast message 
								this.reloadPage();
							}
							else if(this.returnMsg!=null && this.returnMsg.includes('No product')){
								//this.reasonCheck=true;
								console.log('Inside warning append>>');
								this.reasonCheck=false;
								this.showWarning = false;
								this.fireToastEvent(this.label.infoText,this.label.orderProduct_Count,'info','sticky');//firing the toast message 
								this.reloadPage();
							}
							else{
								this.reasonCheck=true;
								this.showWarning = true;
								//this.fireToastEvent(this.label.infoText,this.label.no_recalculation_Msg,'info','sticky');
							}
							
						})
						.catch(error => {
							this.fireToastEvent(this.label.error_Txt,error.body.message,'error','sticky');//displaying error 
							this.error = error;
							//this.warningMessage = undefined;
					});				
			console.log('clicked');
			// call apex method here
			//pass current page record id
		//	this.reloadPage();
			
		}*/
		
		reloadPage(){
			location.reload(true);
			/*setTimeout(function() {
			   eval("$A.get('e.force:refreshView').fire();");
	   }, 2000); */
	}
	//toast method to display success or error
	fireToastEvent(title,message,variant,mode){
		const event = new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: mode
		});
		this.dispatchEvent(event);
	}

		/*validateMaintainceDate(){
			console.log('Inside method=>@@@@');
			validateMaintainenceDate({ orderId: this.recordId }) //calling apex method
						.then(result => {
						this.warningMessage = result;
						if(this.warningMessage!=null){
								this.showWarning = true;
						}
						else{
								this.showWarning = false;
						}
						this.error = undefined;
				})
						.catch(error => {
						this.error = error;
						this.warningMessage = undefined;
				});
		}*/
   
}
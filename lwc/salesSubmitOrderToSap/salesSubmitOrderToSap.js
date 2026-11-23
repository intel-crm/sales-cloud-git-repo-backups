import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSapOrderStatus from '@salesforce/apex/Sales_SapIntegrationUtility.updateSapOrderStatus';
import verifyOrder from '@salesforce/apex/Sales_SapIntegrationUtility.verifyOrder';
import Sales_DialogMsg from '@salesforce/label/c.Sales_DialogMsg';
import Sales_yes from '@salesforce/label/c.Sales_YesMessage';
import Sales_no from '@salesforce/label/c.Sales_NoMessage';
import Sales_Confirmation from '@salesforce/label/c.Sales_Confirmation';
import updateOrderStatusToFailure from '@salesforce/apex/Sales_SapIntegrationUtility.updateOrderStatusToFailure';
import apexExceptionMessageParser from '@salesforce/apex/Sales_CancelOrderController.apexExceptionMessageParser';
export default class SalesSubmitOrderToSap extends LightningElement {

		@api recordId;
		@track orderIds = [];
		@track isvisiblemodal= true;
		@track buttonClicked=false;
		label={
			Sales_no,
			Sales_yes,
			Sales_Confirmation,
		    Sales_DialogMsg
		};
		connectedCallback() {
				console.log('13 '+this.checkActivate);
				this.orderIds.push(this.recordId);
        //this.doVerifyOrder();
    }
	handleYes(event){
		this.buttonClicked=true;
		this.isvisiblemodal = false;
		this.doVerifyOrder();
	}
	handleNo(event){
		this.isvisiblemodal = false;
		this.closeQuickAction();
	}
		doVerifyOrder(){
			verifyOrder({ orderIds: this.orderIds })
						.then((result) =>{
						this.submitOrderToSap();
				})
						.catch((error) => {
						this.closeQuickAction();
						//let errorMessage=error.body.message
						if((error.body.message).includes('_EXCEPTION,')){
							apexExceptionMessageParser({ errorMsg: error.body.message })
							.then((result) => {
								//	this.closeQuickAction();  
								this.fireToastEvent('Error!',result,'error','sticky');
							})
							.catch((error) => {
								//	this.closeQuickAction();  
								this.fireToastEvent('Error!',error.body.message,'error','sticky');
							});
						}else{
							//this.closeQuickAction();  
							this.fireToastEvent('Error!',error.body.message,'error','sticky');
						}
						//this.fireToastEvent('Error!',error.body.message,'error','sticky');
				});
		}
	
		
	submitOrderToSap(){
		updateSapOrderStatus({ orderIdList: this.orderIds })
					.then((result) =>{
					if(result){
							this.closeQuickAction();
							this.fireToastEvent('Failure!','Order Submission Failed','error','dismissable');
							this.reloadPage();
					}
					else{
							this.closeQuickAction();
							console.log('56');
							this.fireToastEvent('Success!','Order Submitted to SAP','success','dismissable');
							this.reloadPage();
					}
				})
					.catch((error) => {
						let errorMessage=error.body.message
						if(!errorMessage.includes('successfully')){
							this.closeQuickAction();
							this.fireToastEvent('Error!',error.body.message,'error','dismissable');
							this.updateStatusFailure(error.body.message);
						}else{
							this.closeQuickAction();
							this.fireToastEvent('Success!',error.body.message,'success','dismissable');
							this.updateStatusFailure(error.body.message);
						}
					});
				}
		
				updateStatusFailure(errorMessage){
					if(!errorMessage.includes('Invalid')){
							updateOrderStatusToFailure({ orderId: this.recordId, message:errorMessage})
									.then((result) =>{
									console.log('result'+result);
							})
									.catch((error) => {
									console.log('error'+error);
							});
							this.reloadPage();
					}
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
				setTimeout(function() {
						//eval("$A.get('e.force:refreshView').fire();");
						location.reload(true);
				}, 2000);
				/*window.setTimeout(function(){ 
						location.reload(true);
				}, 2000);*/
		}
		
		closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
}
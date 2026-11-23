import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateContractStatus from "@salesforce/apex/Sales_ContractStatusUpdate.updateStatus";

export default class SalesupdateContractStatus extends LightningElement {
		@api recordId;

		connectedCallback() {
				console.log('@@recordId' + this.recordId);
				this.checkContractStatus();


		}

		checkContractStatus(){
				updateContractStatus({ RecordId: this.recordId})    //pass record Id
						.then((res) => {

						if(res=='Renewal Failed'){
								this.closeQuickAction();
								this.fireToastEvent('error',res+' - Please check comments', 'failure', 'dismissable');   
								this.reloadPage();		
						}
						else if(res=='Renewal Completed'){
								this.closeQuickAction();
								this.fireToastEvent('Success',res, 'success', 'dismissable');   
								this.reloadPage();
						}
						else if(res=='InProgress'){
								this.closeQuickAction();
								this.fireToastEvent('Success','Quote creation is in progress', 'success', 'dismissable');   
								this.reloadPage();
						}
						else if(res=='Renewal False'){
								this.closeQuickAction();
								this.fireToastEvent('error','Renewed quoted should be true.', 'error', 'dismissable');  
						}else if(res=='Renewal already completed'){
									this.closeQuickAction();
								this.fireToastEvent('Success','Renewal already completed.', 'success', 'dismissable');  
						}
						console.log('res>>'+res);
				})
						.catch((error) => {
						this.closeQuickAction();
						this.fireToastEvent('Error', '', 'error', 'sticky');
				});
		}
		fireToastEvent(title, message, variant, mode) {
				const event = new ShowToastEvent({
						title: title,
						message: message,
						variant: variant,
						mode: mode
				});
				this.dispatchEvent(event);
		}

		reloadPage() {
				setTimeout(function () {
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
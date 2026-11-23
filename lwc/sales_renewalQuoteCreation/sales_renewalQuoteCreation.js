import { LightningElement, track,api  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Sales_Succes from '@salesforce/label/c.Sales_Succes';
import Sales_failure from '@salesforce/label/c.Sales_failure';
import Sales_ContractRenewalSuccess from '@salesforce/label/c.Sales_ContractRenewalSuccess';
import Sales_ConfirmationTitle from '@salesforce/label/c.Sales_ConfirmationTitle';
import productCheck from '@salesforce/apex/Sales_ValidateProduct.checkProductInactive';
import VALIDATEACCOUNT from '@salesforce/apex/Sales_ValidateProduct.validateAccount';  //sahil added
import Sales_AccountErrorOnContRenew from '@salesforce/label/c.Sales_AccountErrorOnContRenew';//sahil added

export default class Sales_renewalQuoteCreation extends LightningElement {
    @api recordId;
    @api isvisiblemodal;
    @track res;
	@track isLoaded=false;
    @track childTrack=false;
    @track confirmDigCheck=false;
    @track errorMsg=false;
	

    label = {
        Sales_Succes,Sales_failure,Sales_ConfirmationTitle,Sales_ContractRenewalSuccess
    }
   
    connectedCallback() {
        this.verifyAccount();
	}	

verifyAccount(){
VALIDATEACCOUNT({ contId: this.recordId}).then((result)=>{
            console.log('Account Deactivated checkbox: '+result);
            if(result==true){
                this.showNotification('Error',Sales_AccountErrorOnContRenew, 'error','sticky');
				this.closeQuickAction();		               
            }
			else{		
					this.verifyProduct();
			}
           

        }).catch((error)=>{
            console.log('Error message '+error);
			this.closeQuickAction();
        });
		
}
	
verifyProduct(){
 productCheck({ recordId: this.recordId, childCheck: this.childTrack}) //apex method invoked
        .then((result) => {
            console.log('Product check '+result);
            if (result=='success') {
                	this.isLoaded=true;
                this.showNotification(this.label.Sales_Succes,this.label.Sales_ContractRenewalSuccess, 'success','pester');
                this.closeQuickAction();
                this.reload();
            }
            else if(result=='failure'){
								this.isLoaded=true;
                console.log('confirmDigCheck '+this.confirmDigCheck);
                this.confirmDigCheck=true;
                console.log('confirmDigCheck '+this.confirmDigCheck);
            }
            else{
								this.isLoaded=true;
                this.errorMsg=true;
                this.res=result;
                //this.closeQuickAction();
               // this.showNotification(this.label.Sales_failure,result, 'error','pester');
                //this.reload();
            }
         
           

        })
        .catch((error) => {
            this.closeQuickAction();
            this.showNotification(this.label.Sales_failure,'error', 'error','pester');
        })		
}
callFromChild(event){
    this.childTrack=true;
		this.isLoaded=false;
    productCheck({ recordId: this.recordId , childCheck: this.childTrack}) //apex method invoked
    .then((result) => {
        console.log('r2: '+result.slice('\n'));
        console.log('result '+result);
        console.log('r2: '+result.slice('\n'));
        if (result=='success') {
            console.log('sucesss');
					//this.closeQuickAction();
						this.isLoaded=true;
            this.showNotification(this.label.Sales_Succes,'Contract renewal process is initiated.', 'success','pester');
         
           this.reload();
        }
        else if(result=='failure'){
						this.isLoaded=true;
            console.log('confirmDigCheck '+this.confirmDigCheck);
            this.confirmDigCheck=true;
            console.log('confirmDigCheck '+this.confirmDigCheck);
        }
        else{
						this.isLoaded=true;
            this.errorMsg=true;
            this.res=result.slice('\n');
            console.log('res '+this.res);
            //this.closeQuickAction();
           // this.showNotification(this.label.Sales_failure,result, 'error','pester');
            //this.reload();
        }
     
       

    })
    .catch((error) => {
        this.closeQuickAction();
        this.showNotification(this.label.Sales_failure,'error', 'error');
    })
}
reload() {
    setTimeout(function () {
        location.reload(true);
    }, 3000);
}

showNotification(title, msg, variant,mode) {
    const event = new ShowToastEvent({
        title: title,
        message: msg,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(event);
}

closeQuickAction() {
    const closeModal = new CustomEvent('close');
    // Dispatches the event.
    this.dispatchEvent(closeModal);
}
closeAction() {
		
    const closeModal = new CustomEvent('close');
    // Dispatches the event.
    this.dispatchEvent(closeModal);
    this.reload();
}
closeEvent(event){
	
    this.dispatchEvent(new CustomEvent('close'));
   
   }
    
}
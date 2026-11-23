import { LightningElement, api  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Pcc_RebateClaim_Temp_Guidance extends NavigationMixin(LightningElement) {
 @api objectApiName;

 @ api invoke(){
        this.navigateToDefaultPage();
    }
   
navigateToDefaultPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.objectApiName, 
                actionName: 'home' 
            },
        });
         setTimeout(() => {
            window.location.reload();
        }, 5);
    }
    
    handleBack(){
        const event= new CustomEvent('backtofirstmodal');
        this.dispatchEvent(event);
    }
}
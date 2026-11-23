import { LightningElement ,track,api} from 'lwc';
import Sales_yes from '@salesforce/label/c.Sales_YesMessage';
import Sales_no from '@salesforce/label/c.Sales_NoMessage';
import Sales_Confirmation from '@salesforce/label/c.Sales_Confirmation';
import Sales_ConfirmationDialogMsg from '@salesforce/label/c.Sales_ConfirmationDialogMsg';




export default class Sales_ConfirmDialog extends LightningElement{
    @track isvisiblemodal= true;
    @api contractrecordid;
    @api diableButton=false;
    eventType='';
    //handles button clicks
    label={
        Sales_no,
        Sales_yes,
        Sales_Confirmation,
        Sales_ConfirmationDialogMsg
    };
    @api handleYes(event){
      
           // const close = new CustomEvent("close");

            //this.dispatchEvent(close);
            let ev = new CustomEvent('childmethod'
                                    );
                this.dispatchEvent(ev);   
            console.log('in child close');
        this.isvisiblemodal = false;
        this.diableButton=true;
       
        }

    handleNo(event){
        this.isvisiblemodal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    reloadPage(){

        setTimeout(function() {
                        location.reload(true);
        }, 2000);
}


}
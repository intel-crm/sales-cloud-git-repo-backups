import { LightningElement,api,track } from 'lwc';
import validatePriceChange from '@salesforce/apex/Sales_DisplayWarning.validatePriceChange'; // apex method import
import recalculation_Success from '@salesforce/label/c.sales_Recalculation_Success_Msg';
import orderProduct_Count from '@salesforce/label/c.sales_Orderproduct_count_error_on_order_on_recalculation';
import no_recalculation_Msg from '@salesforce/label/c.sales_No_Recalculation_Required_Msg';
import error_Txt from '@salesforce/label/c.Sales_Error_Message';
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import infoText from '@salesforce/label/c.sales_Info_Text_Msg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Sales_PriceRecalculation extends LightningElement {
    @api objectApiName;//to get the object id from URL
    @api recordId;//to get the record id from URL
    @track orderId = [];

    label = {
        successTxt,recalculation_Success,orderProduct_Count,no_recalculation_Msg,error_Txt,infoText
        //,salesRecalculationSuccessMsg,
        //salesOrderproductcounterroronorderonrecalculation,salesNoRecalculationRequiredMsg,SalesErrorMessage,SalesOrderSuccess,salesInfoTextMsg
    };    

    connectedCallback() {
        this.orderId.push(this.recordId);
        this.recalculate();
    }

    recalculate() {
        validatePriceChange({ orderId: this.recordId, msg: 'Recalculate' ,newOrdMap: ''}) //calling apex method
            .then(result => {
                this.warningMessage = result;
                console.log('Message returned' + this.warningMessage);
                //checking if the message returned from apex is matching the price mismatch warning text
                if (this.warningMessage != null && this.warningMessage.includes('Success')) {
                    this.closeQuickAction();
                    this.fireToastEvent(this.label.successTxt, this.label.recalculation_Success, 'success', 'sticky');//firing the toast message 
                    this.reloadPage();
                }
                else if(this.warningMessage != null && this.warningMessage.includes('No product')){
                    this.closeQuickAction();
                    this.fireToastEvent(this.label.infoText,this.label.orderProduct_Count, 'info', 'sticky');
                    //this.reloadPage();
                }
                else{
                    this.closeQuickAction();
                    this.fireToastEvent(this.label.infoText,this.label.no_recalculation_Msg, 'info', 'sticky');
                }
            })
            .catch(error => {
                this.closeQuickAction();
                this.fireToastEvent(this.label.error_Txt, error.body.message, 'error', 'sticky');//displaying error 
                this.error = error;
                //this.warningMessage = undefined;
            });
        console.log('clicked');
    }

    reloadPage() {
        location.reload(true);
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

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
}
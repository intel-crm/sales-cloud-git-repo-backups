import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import oemRollBack from '@salesforce/apex/Pricing_BulkSalesRepActionController.getQuoteLinetoRollback';
import recallMsg from '@salesforce/label/c.Pricing_QuoteLine_Recall_Msg';

export default class Pricing_Quote_OEMRollback_Component extends LightningElement {

    @api recordId;

    connectedCallback(){
        this.callRollbackAction();
    }

    callRollbackAction(){
        oemRollBack({quoteId : this.recordId})
                    .then(result => {
                        if(result == 'Success'){
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: 'Quote line(s) recalled Successfully !',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                        }
                        else{
                            const event = new ShowToastEvent({
                                title: 'Information',
                                message: recallMsg,
                                variant: 'info',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(event);
                        }
                        this.closeAction();
                    })
                    .catch(error => {
                        console.log(JSON.stringify(error));
                        var msg = error.body.message.includes('Pricing_BulkSalesRepActionController') ? 'Your role does not allow you to perform this action.' : error.body.message; 
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: msg,
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.closeAction();
                    });
    }

    closeAction(){
        const closeActionEvt = new CustomEvent("CloseRollback");
        this.dispatchEvent(closeActionEvt);
    }
}
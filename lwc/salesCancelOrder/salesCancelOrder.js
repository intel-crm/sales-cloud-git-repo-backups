/*********************************************************************************************************************
Version       : 1.0
Created Date  : Mar 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        24-Mar-2021             salesCancelOrder LWC Component
* ---------------------------------------------------------------------------------------------------------*/
import { LightningElement,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
/*import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//CONTROLLER CLASSES
//import setStatusOrderCancelled from '@salesforce/apex/Sales_CancelOrderController.setStatusOrderCancelled';
//import apexExceptionMessageParser from '@salesforce/apex/Sales_CancelOrderController.apexExceptionMessageParser';
import updateOrderRecallStatus from '@salesforce/apex/Sales_SapIntegrationUtility.updateOrderRecallStatus';
//LABELS
import successTxt from '@salesforce/label/c.Sales_Order_Success';                       //Success title
import errorMsg from '@salesforce/label/c.Sales_Error_Message';                         //Error title
import orderCancelledMsg from '@salesforce/label/c.Sales_Order_Cancelled_Msg';          //Order Cancelled successfully.
import orderCantCancelActiveNonCommercialMsg from '@salesforce/label/c.Sales_CantCancelActivatedNonCommercial';           //Activated Non Commercial Order cannot be cancelled.
import orderAlreadySAPCancelledMsg from '@salesforce/label/c.Sales_SAPOrderAlreadyCancelled';                   //Order has already been cancelled by SAP.
import orderAlreadyCancelledMsg from '@salesforce/label/c.Sales_OrderAlreadyCancelled';                      //Order has already been cancelled.
import orderSAPCancelledMsg from '@salesforce/label/c.Sales_OrderCancelledBySAP';                        //Order Cancelled from SAP successfully.
import Sales_CantCancelSapResubmissionInProgress from '@salesforce/label/c.Sales_CantCancelSapResubmissionInProgress';  //SAP Resubmission in Progress Orders cannot be cancelled
import cantCancelShippedOrder from '@salesforce/label/c.Sales_ShippedOrder_ErrMsg';
import cancelOrderFailed from '@salesforce/label/c.Sales_OrdCancelationFailed';
import SalesCancelOrderHTML from '@salesforce/label/c.Sales_CancelOrder_HTML';
import SalesCancelOrder1HTML from '@salesforce/label/c.Sales_CancelOrder1_HTML';
import SalesOrderSubmitHTML from '@salesforce/label/c.Sales_OrderSubmit_HTML';

const FIELDS = [ 'Order.Id', 'Order.Sales_Cancelled_Reason_Dsc__c','Order.Sales_SAP_OrderCancelledReason__c' ,'Order.Sales_status__c', 'Order.Status', 'Order.Type'];
*/
export default class SalesCancelOrder extends LightningElement {
@api recordId;
/*
@api changedcancellationReason;
@api metatdataCancellationReason;
@api orderStatus;
@api Stage;
@api orderType;
@api changedcancellationReasonPicklist;
@api showModal;
@api errorMessages;
@api selectedCancelledReason;
@track selectedOption;
@track myoptions=[];

@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
order;

label = {
        successTxt,
        orderCancelledMsg,
        orderCantCancelActiveNonCommercialMsg,
        orderAlreadySAPCancelledMsg,
        orderAlreadyCancelledMsg,
        orderSAPCancelledMsg,
        errorMsg,
        cantCancelShippedOrder,
        cancelOrderFailed,
        SalesCancelOrderHTML,
        SalesCancelOrder1HTML,
        SalesOrderSubmitHTML,
        Sales_CantCancelSapResubmissionInProgress

};

handleOnLoad(){
        //INITIALIZATION
        if(this.order.data!=undefined){
                this.recordId=this.order.data.fields.Id.value;                                                  
                this.orderStatus=this.order.data.fields.Sales_status__c.value;                                  
                this.Stage=this.order.data.fields.Status.value;                                                 
                this.orderType=this.order.data.fields.Type.value;                                               
                this.cancellationReason=this.order.data.fields.Sales_Cancelled_Reason_Dsc__c.value;             

                if((this.Stage=='Draft' && this.orderStatus!='Order Cancelled' && this.orderStatus!='SAP Resubmission In Progress') || (this.Stage=='Activated' && this.orderStatus=='Order created successfully' &&
                        this.orderType!='Non Commercial Order' && this.orderStatus!='SAP Order Shipped')){
                        this.showModal=true;
                }else{
                        this.showModal=false;
                }

                //Scenarios Check
                if(this.showModal==false){                                                      
                        if(this.Stage=='Draft' && this.orderStatus=='Order Cancelled' ){//Only if the showModal isn't True.
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.errorMsg,this.label.orderAlreadyCancelledMsg,'error','sticky');
                        }
                        else if(this.Stage==='Activated' && this.orderType==='Non Commercial Order' ){
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.errorMsg,this.label.orderCantCancelActiveNonCommercialMsg,'error','sticky');
                        }      
                        else if(this.Stage==='Activated' && this.orderStatus==='Order Cancelled by SAP'){
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.errorMsg,this.label.orderAlreadySAPCancelledMsg,'error','sticky');
                        }else if(this.Stage==='Activated' && this.orderStatus==='SAP Order Shipped'){
                                this.closeQuickAction();
                                this.fireToastEvent(this.label.errorMsg,this.label.cantCancelShippedOrder,'error','sticky');
                        }

                        else if(this.Stage=='Draft' && this.orderStatus=='SAP Resubmission In Progress' && this.orderType!='Non Commercial Order'){
                               this.closeQuickAction(); 
                               this.fireToastEvent(this.label.errorMsg,this.label.Sales_CantCancelSapResubmissionInProgress,'error','sticky');
                        }
                }
                
        }
}


/*handleSubmit(event){
        if(this.Stage=='Draft' && this.orderStatus!='Order Cancelled' && this.changedcancellationReason!=undefined){
                setStatusOrderCancelled ({ objId: this.recordId, cancelReason: this.changedcancellationReason})
                
                .then(() =>{
                this.closeQuickAction();
                this.fireToastEvent(this.label.successTxt,this.label.orderCancelledMsg,'success','dismissable');
                this.reloadPage();        
                })
                .catch((error) => {
                this.fireToastEvent(this.label.errorMsg,error.body.message,'error','sticky');
                });

        }

        else if(this.Stage=='Activated' && this.orderType!='Non Commercial Order' && this.orderStatus!='Order Cancelled by SAP' &&  this.orderStatus!='SAP Order Shipped'){
                //const fields = event.detail.fields;
                if(this.changedcancellationReasonPicklist!=undefined){
                        updateOrderRecallStatus ({ orderId: this.recordId,cancelReason : this.changedcancellationReasonPicklist})
                        .then((result) =>{
                                
                                if(!result){
                                        this.closeQuickAction();
                                        this.fireToastEvent(this.label.errorMsg,this.label.cancelOrderFailed,'error','dismissable');
                                }else if(result){
                                        this.closeQuickAction();
                                        this.fireToastEvent(this.label.successTxt,this.label.orderCancelledMsg,'success','dismissable');
                                }
                                this.reloadPage();
                        })
                        .catch((error) => {  
                        this.errorMessages=error.body.message;
                        if(this.errorMessages.includes('_EXCEPTION')){
                                apexExceptionMessageParser({ errorMsg: this.errorMessages })
                                .then((result) => {
                                        this.closeQuickAction();  
                                        this.fireToastEvent(this.label.errorMsg,result,'error','sticky');
                                })
                                .catch((error) => {
                                        this.closeQuickAction();  
                                        this.fireToastEvent(this.label.errorMsg,error.body.message,'error','sticky');
                                });
                        }else{
                                this.closeQuickAction();  
                                this.fireToastEvent(this.label.errorMsg,error.body.message,'error','sticky');
                        }                                
                        });
                }
        }
                
}*/
        


/*handleCancel(){
        this.closeQuickAction();
}

handleCancelReasonChange(event){
    this.changedcancellationReason=event.target.value;  
}

handleMetadataReason(event){
        this.metatdataCancellationReason = event.target.value;
        this.changedcancellationReasonPicklist =   this.metatdataCancellationReason;
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
                        location.reload(true);
        }, 2000);
                //location.reload(true);
                /*setTimeout(function() {
eval("$A.get('e.force:refreshView').fire();");
}, 2000); */
//}

/*closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
        }

get activatedOrders(){
        if(this.Stage=='Activated' && this.orderType!=='Non Commercial Order' && this.orderStatus!=='Order Cancelled by SAP'){
                return false;
        }
        else{
                return true;
        }
}*/

}
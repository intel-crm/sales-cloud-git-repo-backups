import { LightningElement, wire, api, track} from 'lwc';
/*import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import fetchSoldToDetails from "@salesforce/apex/Sales_OrderController.fetchSoldToDetails";
import fetchEndCustDetails from "@salesforce/apex/Sales_OrderController.fetchEndCustDetails";
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import successMsg from '@salesforce/label/c.Sales_Order_Success_Msg';

import SalesNoncommercialOrderErr from '@salesforce/label/c.Sales_NoncommercialOrderErr';
import SalesNewOrderHTML from '@salesforce/label/c.Sales_New_OrderHTML';
import SalesSoldToAccInfoHTML from '@salesforce/label/c.Sales_SoldToAccInfo_HTML';
import SalesShipToAccInfoHTML from '@salesforce/label/c.Sales_ShipToAccInfoHTML';
import SalesEndCustInfoHTML from '@salesforce/label/c.Sales_EndCustInfo_HTML';




//import SalesNoncommercialOrderErr from '@salesforce/label/c.Sales_NoncommercialOrderErr';


import errorMsg from '@salesforce/label/c.Sales_Error_Message';
import noncommercialStockingError from '@salesforce/label/c.Sales_NonCommercial_Stocking_Error_Msg';
import { getRecord } from 'lightning/uiRecordApi';
//import createOrderProducts from '@salesforce/apex/Sales_CloneOrderwithProductController.insertOrderProducts';
const FIELDS = ['Order.Sales_Airbill_Number_Txt__c','Order.SBQQ__PaymentTerm__c','Order.AccountId',
'Order.Sales_Shipment_Number_Txt__c','Order.Status','Order.Sales_status__c','Order.Type','Order.Sales_Order_Reason__c','Order.Description',
'Order.Sales_Disty_Channel_Txt__c','Order.Sales_SoldTo_Street_Dsc__c','Order.Sales_SoldTo_City_Txt__c','Order.Sales_SoldTo_Province_Txt__c','Order.Sales_Payment_Terms__c',
'Order.Sales_SoldTo_Country_Txt__c','Order.Sales_Sales_Org_Txt__c','Order.Sales_SoldTo_Street2_Dsc__c','Order.Sales_SoldTo_State_Txt__c','Order.Sales_SoldTo_Zip_Txt__c',
'Order.Sales_Ship_To_Account__c','Order.Sales_Ship_Date_Dt__c','Order.Sales_ShipTo_Street_Dsc__c','Order.Sales_ShipTo_City_Txt__c','Order.Sales_ShipTo_Province_Txt__c','Order.Sales_ShipTo_Country_Txt__c',
'Order.Sales_Req_Ship_Date_Dt__c','Order.Sales_ShipTo_Street2_Dsc__c','Order.Sales_ShipTo_State_Txt__c','Order.Sales_ShipTo_Zip_Txt__c','Order.Sales_Shipping_Instructions_Dsc__c','Order.Sales_End_Customer_Account__c',
'Order.Sales_End_Customer_Street_Dsc__c','Order.Sales_End_Customer_City_Txt__c','Order.Sales_End_Customer_Province_Txt__c','Order.Sales_End_Customer_Country_Txt__c','Order.Sales_End_Customer_Street2_Dsc__c',
'Order.Sales_End_Customer_State_Txt__c','Order.Sales_End_Customer_Zip_Txt__c','Order.Sales_Header_Special_Instructions_Dsc__c','Order.Pricebook2Id','Order.Sales_End_Cust_PO_Txt__c',
'Order.Sales_Incoterms_Txt__c','Order.Sales_Shipping_Condition_Txt__c','Order.Sales_PO_Number_Txt__c','Order.Sales_Cost_Center__c','Order.Sales_Invoice_Number_Txt__c',
'Order.SBQQ__PriceCalcStatus__c','Order.SBQQ__PriceCalcStatusMessage__c','Order.OriginalOrderId',
'Order.OpportunityId','Order.SBQQ__OrderBookings__c','Order.PoDate','Order.PoNumber','Order.Sales_End_Customer_Account_2_Txt__c','Order.Sales_End_Customer_Region_Txt__c','Order.Sales_ShipTo_Account_2_Txt__c',
'Order.Sales_Ship_To_Acct_Id__c','Order.Sales_Ship_to_Region_Txt__c','Order.Sales_SoldTo_Account_2_Txt__c','Order.EndDate',
'Order.SBQQ__Quote__c','Order.Sales_Corporate_Order__c','Order.TotalAmount','Order.OrderReferenceNumber','Order.OrderItemCount__c','Order.Sales_Sold_To_Acct_Id__c','Order.Sales_Sold_To_Account__c',
'Order.SBQQ__TaxAmount__c','Order.Sales_End_Cust_Acct_Id__c','Order.Sales_Order_Sub_Type__c','Order.Sales_Cancelled_Quote_No__c'];
*/
export default class Sales_CloneOrderwithProductController extends LightningElement{
    /*@api selectval;
    @api recordId;
    @api orderStatus;
    @api accountVal;
    @api isSuccess = false;
    @api isAccounthidden = false;
    @api orderItemCount ;
    @api orderType;
    @api isSoldtoChanged = false;
    @api isEndCustomerChanged = false;
    @api endCustomerAccList;
    @api soldToAccList;
    @api shipToAccList;
    @api soldToAccountValue;
    @api accountIdValue;
    @api orderTypeValue;
    @api isShiptoChanged =false;
    @api endCustAccountValue;
    @api orderSubTypeValue;
    @api shipToChangedValue;
    @api soldToChangedValue;
    @api endCustomerOnChangeValue;
    @api accountIdNonComm;
    //@api endCustomerId ;
    @track loading = false; 
    iserror = false;
    isnotNonCommercial;
    @api orderReasonValue;
    @wire(getRecord, { recordId: '$recordId', fields:FIELDS})
    order;
    label = {
        successTxt,
        successMsg,
        SalesNoncommercialOrderErr,
        SalesNewOrderHTML,
        SalesSoldToAccInfoHTML,
        SalesShipToAccInfoHTML,
        SalesEndCustInfoHTML
    };
    handleCancel(){
         // navigate to order record page
         this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Order', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    navigateToObjectHome() {
        this.selectval=null;
        // Navigate to the Order object home page.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order',
                actionName: 'home',
            }
        });
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }
  
   /*handleSuccess(event){
        this.loading = false; 
        if(this.selectval!=null){
            this.orderItemCount = this.order.data.fields.OrderItemCount__c.value; 
        var orgId = this.recordId;
        var recId = event.detail.id;
        if(this.selectval=='option1' && this.orderItemCount!=0){
            console.log('inside creating Order pridtcs');
            createOrderProducts({newRecId : recId, originalRecId : orgId})
            .then(result => {
                if(result != 'success'){
                    this.isSuccess = false;
                    const evt = new ShowToastEvent({
                        variant:'error',
                        title: 'Error',
                        message: result,
                    });
                    this.dispatchEvent(evt);
                }else if(result == 'success'){
                    this.isSuccess = true;
                    console.log('Order record',event.detail.id);
                    const evt = new ShowToastEvent({
                        variant:'success',
                        title: this.label.successTxt,
                        message: this.label.successMsg,
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                    let errorMessage = 'Error!!';
                    if ( error.body.message) {
                        errorMessage =error.body.message;
                    }
                    this.showToast('An Error has occurred', errorMessage, 'error');
                })   
        }
        else if(this.selectval=='option2' || this.orderItemCount==0){
            this.isSuccess = true;
            const evt = new ShowToastEvent({
                variant:'success',
                title: this.label.successTxt,
                message: this.label.successMsg,
            });
            this.dispatchEvent(evt);
        }
          // navigate to order record page
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: 'Order', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}*/

/*get subOrderTypeValue(){
    if(this.order.data!=undefined){
        if(this.order.data.fields.Type.value !== 'Non Commercial Order'){
            this.isnotNonCommercial = true;
            return '';
        }else{
            return this.order.data.fields.Sales_Order_Sub_Type__c.value;
        }
    }
}

get isnotNonCommercial(){
    if(this.order.data!=undefined){
        if(this.order.data.fields.Type.value !== 'Non Commercial Order'){
            return true;
        }else{
            return false;
        }
    }
}
    handleChange(event) {//check if order is non commercial and set Order sub type as mandatory 
        this.orderTypeValue = event.target.value;
        if(this.orderTypeValue !== 'Non Commercial Order'){
            this.isnotNonCommercial = true;
            
        }else if(this.orderTypeValue == 'Non Commercial Order'){
            this.isnotNonCommercial = false;
        }
        
    }

    handleOrderReasonChange(event){
        this.orderReasonValue = event.target.value;
    }

    handleSubTypeChange(event){
        this.orderSubTypeValue = event.target.value;
    }

    get subTypeRequired(){
        if (this.orderTypeValue=='Non Commercial Order') {
            this.isnotNonCommercial = false;
            return true;
        }
        else {
            return false;
        }
    }

    handleError(event){
        this.loading = false;// added as part of US1016244
    }

    handleSubmit(event){
        // added as part of US1016244
        
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Status = 'Draft';
        fields.Sales_status__c = 'Draft Order';
        
        console.log('this.accountIdValue-->'+this.accountIdValue);
        if(this.orderSubTypeValue == 'Partner license order' || this.orderSubTypeValue =='Evaluation license order'){
            fields.AccountId = this.accountIdNonComm;
            if(this.selectval=='option1' && this.orderItemCount!=0){//cloning without products--> we are not cloning pricebook, will update it from trigger
                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
            }
            if(this.accountIdNonComm!=undefined){
                this.loading = false;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }else if(this.orderTypeValue == undefined && this.orderReasonValue == undefined && this.orderSubTypeValue  == undefined && this.endCustomerOnChangeValue == undefined 
                && this.soldToChangedValue== undefined){
                fields.AccountId = this.order.data.fields.AccountId.value;
                console.log('on submit changes2 =>');
                console.log('Pricebookkk 12==>'+this.order.data.fields.Pricebook2Id.value);
                if(this.selectval=='option1' && this.orderItemCount!=0){
                    fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                }
                console.debug('Pricebook==>'+this.order.data.fields.Pricebook2Id.value);
                console.debug('this.accountIdValue==>'+this.accountIdValue);
                //if(this.accountIdValue!=undefined){
                    this.loading = true;
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                //}
            }
        else{
            console.log('on handle Validate Changes');
            //for Stocking Orders
            if((this.order.data.fields.Sales_Order_Reason__c.value == 'Stocking Order' || this.orderReasonValue == 'Stocking Order') 
            && (this.orderTypeValue!='Non Commercial Order' || this.order.data.fields.Type.value!='Non Commercial Order')){
    
            if(this.isSoldtoChanged == true){
                this.iserror = false;
                fetchSoldToDetails({ acct: this.soldToChangedValue, selectedField: 'Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c'})
                    .then(retResult => {
                    if(retResult !== null && retResult !== undefined && retResult.length > 0) {
                        this.soldToAccountValue = retResult[0].ParentId;
                        this.accountIdValue = this.soldToAccountValue;
                        console.log('Inside MEthod191soldToAccountValue ==>>@@'+this.soldToAccountValue);
                    }
                })
                .catch((error) => {  
                    this.iserror = true;
                });
            }
            else{       
                this.iserror = false;
                fetchSoldToDetails({ acct: this.order.data.fields.Sales_Sold_To_Account__c.value, selectedField: 'Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c'})
                    .then(retResult => {
                    if(retResult !== null && retResult !== undefined && retResult.length > 0) {
                        this.soldToAccountValue = retResult[0].ParentId;
                        this.accountIdValue = this.soldToAccountValue;
                        console.log('Inside MEthod191soldToAccountValue ==>>@@'+this.soldToAccountValue);
                        fields.AccountId = this.accountIdValue;
                    
                        if(this.selectval=='option1' && this.orderItemCount!=0){
                            fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;       
                        }
                        if(this.accountIdValue!=undefined){
                            this.loading = true;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }
                    }
                })
                .catch((error) => {  
                    this.iserror = true;
                });
            }
                if(this.iserror == false && this.accountIdValue!=undefined){
                    fields.AccountId = this.accountIdValue;
                    console.debug('Pricebook==>'+this.order.data.fields.Pricebook2Id.value);
                    if(this.selectval=='option1' && this.orderItemCount!=0){
                        fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;       
                    }
                    if(this.accountIdValue!=undefined){
                        this.loading = true;
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                    }
                }
            }
    
            //for Non Stocking Orders
            else if((this.order.data.fields.Sales_Order_Reason__c.value=='Non Stocking Order' || this.orderReasonValue === 'Non Stocking Order') 
                && (this.orderTypeValue!='Non Commercial Order' || this.order.data.fields.Type.value!='Non Commercial Order')){
    
                if(this.isEndCustomerChanged == true){
                    this.iserror = false;
                    fetchEndCustDetails({endCst :this.endCustomerOnChangeValue})
                    .then(endResult => {
                        if(endResult !== null && endResult !== undefined && endResult.length > 0) {
                            this.endCustAccountValue = endResult[0].ParentId;
                            this.accountIdValue = this.endCustAccountValue;
                            console.log('End customer sfdc1>>'+this.accountIdValue);
                            fields.AccountId = this.accountIdValue;
                            if(this.selectval=='option1' && this.orderItemCount!=0){
                                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                            }
                            if(this.accountIdValue!=undefined){
                                this.loading = true;
                                this.template.querySelector('lightning-record-edit-form').submit(fields);
                            }
                        }
                    })
                    .catch((error) => {  
                        this.iserror = true;
                    }); 
                }
                else{
                    this.iserror = false;
                    fetchEndCustDetails({endCst :this.order.data.fields.Sales_End_Customer_Account__c.value})
                    .then(endResult => {
                        if(endResult !== null && endResult !== undefined && endResult.length > 0) {
                            this.endCustAccountValue = endResult[0].ParentId;
                            this.accountIdValue = this.endCustAccountValue;
                            console.log('End customer sfdc2>>'+this.accountIdValue);
                            fields.AccountId = this.accountIdValue;
                            if(this.selectval=='option1' && this.orderItemCount!=0){
                                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                            }
                            if(this.accountIdValue!=undefined){
                                console.log('this.accountIdValue-->'+this.accountIdValue);
                                this.loading = true;
                                this.template.querySelector('lightning-record-edit-form').submit(fields);
                            }
                        }
                    })
                    .catch((error) => {  
                        this.iserror = true;
                    }); 
                }
                    if(this.iserror == false && this.accountIdValue!=undefined){
                        fields.AccountId = this.accountIdValue;
                        console.debug('Pricebook==>'+this.order.data.fields.Pricebook2Id.value);
                        if(this.selectval=='option1' && this.orderItemCount!=0){
                            fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                        }
                        if(this.accountIdValue!=undefined){
                            this.loading = true;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }
                    }
            }
    
            else if((this.order.data.fields.Sales_Order_Reason__c.value=='Stocking Order' || this.orderReasonValue == 'Stocking Order') 
                && (this.orderTypeValue == 'Non Commercial Order' || this.order.data.fields.Type.value=='Non Commercial Order')){
            console.log('Inside error mesgaale');
            this.iserror = true;
            const evt = new ShowToastEvent({
                variant:'error',
                title: this.label.errorMsg,
                message: this.label.SalesNoncommercialOrderErr,//this.label.noncommercialStockingError,
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            }
    
            else if((this.order.data.fields.Sales_Order_Reason__c.value=='Non Stocking Order' || this.orderReasonValue === 'Non Stocking Order') 
            && (this.orderTypeValue=='Non Commercial Order' || this.order.data.fields.Type.value=='Non Commercial Order')
            && (this.orderSubTypeValue == 'FPGA university program license request' || order.data.fields.Sales_Order_Sub_Type__c.value=='FPGA university program license request' ||
            this.orderSubTypeValue == 'Evaluation license order' || order.data.fields.Sales_Order_Sub_Type__c.value=='Evaluation license order')){
               
                if(this.isEndCustomerChanged == true){
                    this.iserror = false;
                    fetchEndCustDetails({endCst :this.endCustomerOnChangeValue})
                    .then(endResult => {
                        if(endResult !== null && endResult !== undefined && endResult.length > 0) {
                            this.endCustAccountValue = endResult[0].ParentId;
                            this.accountIdValue = this.endCustAccountValue;
                            console.log('End customer sfdc>5>'+this.accountIdValue);
                            fields.AccountId = this.accountIdValue;
                            if(this.selectval=='option1' && this.orderItemCount!=0){
                                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                            }
                            if(this.accountIdValue!=undefined){
                                this.loading = true;
                                this.template.querySelector('lightning-record-edit-form').submit(fields);
                            }
                        }
                    })
                    .catch((error) => {  
                        this.error = error;
                    }); 
    
                }else{
                    this.iserror = false;
                    fetchEndCustDetails({endCst :this.order.data.fields.Sales_End_Customer_Account__c.value})
                    .then(endResult => {
                        if(endResult !== null && endResult !== undefined && endResult.length > 0) {
                            this.endCustAccountValue = endResult[0].ParentId;
                            this.accountIdValue = this.endCustAccountValue;
                            console.log('End customer sfdc4>>'+this.accountIdValue);
                            fields.AccountId = this.accountIdValue;
                            if(this.selectval=='option1' && this.orderItemCount!=0){
                                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                            }
                            if(this.accountIdValue!=undefined){
                                this.loading = true;
                                this.template.querySelector('lightning-record-edit-form').submit(fields);
                            }
                        }
                    })
                    .catch((error) => {  
                        this.error = error;
                    });
                }

                    if(this.iserror == false && this.accountIdValue!=undefined){
                        fields.AccountId = this.accountIdValue;
                        console.debug('Pricebook==>'+this.order.data.fields.Pricebook2Id.value);
                        if(this.selectval=='option1' && this.orderItemCount!=0){
                            fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                        }
                        if(this.accountIdValue!=undefined){
                            this.loading = true;
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }
                    }
            }
            /*if(this.iserror == false && this.accountIdValue!=undefined){
                fields.AccountId = this.accountIdValue;
                console.log('on submit changes3 =>');
                console.debug('Pricebook==>'+this.order.data.fields.Pricebook2Id.value);
                fields.Pricebook2Id = this.order.data.fields.Pricebook2Id.value;
                
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }*/
                   //Added by Shivam -- Focuses on Top of the Modal before we save, benefit for Error Banner Focus
            /*const topDiv = this.template.querySelector('[data-id="focusOnErrorBannerId"]');
            topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
            }
    }

    handleAccountIdChangeforNonComm(event){
        this.accountIdNonComm = event.target.value;
        console.log('accountIdNonComm==>'+this.accountIdNonComm);
        
    }

    get endCustomerId(){
        if(this.order.data!=undefined){
            return this.order.data.fields.Sales_End_Customer_Account__c.value;
        }
    }

    get shipToId(){
        if(this.order.data!=undefined){
            return this.order.data.fields.Sales_Ship_To_Account__c.value;
        }
    }
    get makeSoldTorequired() {
        if((this.order.data.fields.Sales_Order_Reason__c.value=='Stocking Order' || 
        this.orderReasonValue === 'Stocking Order') && (this.orderTypeValue=='Non Commercial Order' || 
            this.order.data.fields.Type.value=='Non Commercial Order')){
                return true;
        } else {
            return false;
        }
    }

    get soldToId(){
        if(this.order.data!=undefined){
            return this.order.data.fields.Sales_Sold_To_Account__c.value;
        }
    }

    get getQuoteDetails(){
        this.orderStatus = this.order.data.fields.Sales_status__c.value;

        if(this.orderStatus === 'Order Cancelled' || this.orderStatus === 'Order Cancelled by SAP'){
            return this.order.data.fields.Sales_Cancelled_Quote_No__c.value;  
        }else{
            return this.order.data.fields.SBQQ__Quote__c.value;
        }
    }

    get checkorderType(){
        if(this.orderTypeValue=='Non Commercial Order' || this.order.data.fields.Type.value=='Non Commercial Order' ||
        this.orderTypeValue=='Licensed Tool Order' || this.order.data.fields.Type.value=='Licensed Tool Order'){
            return true;
        }
        else{
            return false;
        }
    }


    get showAccountField(){
        if(this.orderSubTypeValue == 'Partner license order' || this.orderSubTypeValue =='Evaluation license order'){
            return true;
        }else{
            return false;
        }
     }

     get endCustrequired(){
        if((this.order.data.fields.Sales_Order_Reason__c.value=='Non Stocking Order' || this.orderReasonValue === 'Non Stocking Order') && ((this.orderTypeValue=='Licensed Tool Order' || this.order.data.fields.Type.value=='Licensed Tool Order') || ((this.orderTypeValue=='Sample Order' || this.order.data.fields.Type.value=='Sample Order')) || ((this.orderTypeValue=='Non Commercial Order' || this.order.data.fields.Type.value=='Non Commercial Order')
        && (this.orderSubTypeValue == 'FPGA university program license request' || this.order.data.fields.Sales_Order_Sub_Type__c.value=='FPGA university program license request'))))
        {
            return true;
        }else{
            return false;
        }
     }

    handleSoldTochange(event){
        if(event.detail.value[0] !== undefined){
            this.isSoldtoChanged = true;
           // if(this.isSoldtoChanged == true){
                this.soldToChangedValue = event.target.value;
                if(this.soldToChangedValue !== undefined){
                    fetchSoldToDetails({ acct: this.soldToChangedValue, selectedField: 'Core_Direct_Shipping_Condition_Nm__c,Core_Direct_Shipping_Instruction_Txt__c,Core_Direct_Incoterm_Dsc__c'})
                        .then(returnedResult => {
                            if (returnedResult !== null && returnedResult !== undefined && returnedResult.length > 0) {
                                this.soldToAccList = returnedResult;
                                this.isSoldtoChanged = true;
                            }
                        
                        })
                        .catch((error) => {  
                            this.error = error;  
                            this.accList = undefined;  
                        });
              //  } 
               /* else{
                    this.handleResetAccount();
                }*/   
           /* }
            
        }else{
            this.handleResetAccount();
            //this.isSoldtoChanged = false;
        }
    }

    handleShipTochange(event){
        if(event.detail.value[0] !== undefined){
            this.isShiptoChanged = true;
            if(this.isShiptoChanged == true){
                this.shipToChangedValue = event.target.value;
               // if(this.shipToChangedValue !== undefined){
                    fetchSoldToDetails({ acct: this.shipToChangedValue, selectedField: 'Core_Direct_Shipping_Condition_Nm__c,Core_Direct_Shipping_Instruction_Txt__c,Core_Direct_Incoterm_Dsc__c'})
                        .then(returnedResult => {
                            if (returnedResult !== null && returnedResult !== undefined && returnedResult.length > 0) {
                                this.shipToAccList = returnedResult;
                                this.isShiptoChanged == true
                            }
                        })
                        .catch((error) => {  
                            this.error = error;  
                        });
               // } 
               /* else{
                    this.handleResetShipAccount();
                }*/   
            /*}
           
        }else{
            this.handleResetShipAccount();
            //this.isShiptoChanged = false;
            }
        }

    handleEndCustomerOnChange(event){
        console.log('event.targent for endcust==>'+ event.detail.value[0]);
        if(event.detail.value[0] !== undefined){
            this.isEndCustomerChanged = true;
            if(this.isEndCustomerChanged == true){
                
                this.endCustomerOnChangeValue = event.target.value;
                    console.log('this.endCustomerOnChangeValue=>'+this.endCustomerOnChangeValue);
                        //get End customer Account details expect for sample order
                  //  if(this.endCustomerOnChangeValue !== undefined){   
                        fetchEndCustDetails({endCst :this.endCustomerOnChangeValue})
                        .then(endResult => {
                            if(endResult !== null && endResult !== undefined && endResult.length > 0) {
                                console.log('End customer List'+endResult);
                                this.endCustomerAccList = endResult;
                                this.isEndCustomerChanged = true;
                                //this.endCustomerId = endResult[0].ParentId;
                            }
                        })
                        .catch((error) => {  
                            this.error = error;  
                        });
                   // }
                   /* else{
                        this.handleResetEndAccount();
                    }*/    
                /*}
                
    }else{
        console.log('resetting values');
        this.handleResetEndAccount();
        //this.isEndCustomerChanged = false;
    }
}

handleResetAccount(){
    this.template.querySelectorAll('lightning-input-field[data-id="soldto"]').forEach(element => {
         element.value = null;
       });

 }

 handleResetEndAccount(){
     this.template.querySelectorAll('lightning-input-field[data-id="endCust"]').forEach(element => {
         element.value = null;
       });

 }
 handleResetShipAccount(){
    this.template.querySelectorAll('lightning-input-field[data-id="shipto"]').forEach(element => {
        element.value = null;
      });

}*/

}
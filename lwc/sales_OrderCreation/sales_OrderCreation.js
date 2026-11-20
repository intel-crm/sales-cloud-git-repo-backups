import { LightningElement, wire, api, track } from 'lwc';
/*import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import successTxt from '@salesforce/label/c.Sales_Order_Success';
import successMsg from '@salesforce/label/c.Sales_Order_Success_Msg';
import findRecords from "@salesforce/apex/Sales_OrderController.findRecords";
import fetchSoldToDetails from "@salesforce/apex/Sales_OrderController.fetchSoldToDetails";
import fetchEndCustDetails from "@salesforce/apex/Sales_OrderController.fetchEndCustDetails";
import stockingSoldToError from '@salesforce/label/c.Sales_StockingSoldToErrorMessage';
import nonStockingEndCustError from '@salesforce/label/c.Sales_NonStocking_END_Customer';
import noncommercialStockingError from '@salesforce/label/c.Sales_NonCommercial_Stocking_Error_Msg';
import partnerLicError from '@salesforce/label/c.Sales_Account_Mandatory';
import errorMsg from '@salesforce/label/c.Sales_Error_Message';
import getPickListValues from '@salesforce/apex/Sales_OrderController.getPickListValues';
import getFieldLabel from '@salesforce/apex/Sales_OrderController.getFieldLabel';
import Sales_NonCommercialOrder from '@salesforce/label/c.Sales_NonCommercialOrder';
import Sales_SampleOrder from '@salesforce/label/c.Sales_SampleOrder';
import Sales_LicenceToolOrder from '@salesforce/label/c.Sales_LicenceToolOrder';
import sales_Amend_error from '@salesforce/label/c.Sales_Non_Commercial_Error';
import SalesSubTypeCorporate from '@salesforce/label/c.Sales_SubTypeCorporate';
import SalesNoRecordsFound from '@salesforce/label/c.Sales_NoRecordsFound';
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';
import SalesNewOrderHTML from '@salesforce/label/c.Sales_New_OrderHTML';
import SalesOrderInfoHTML from '@salesforce/label/c.Sales_OrderInfo_HTML';
import SalesSoldToAccInfoHTML from '@salesforce/label/c.Sales_SoldToAccInfo_HTML';
import SalesShipToAccInfoHTML from '@salesforce/label/c.Sales_ShipToAccInfoHTML';
import SalesEndCustInfoHTML from '@salesforce/label/c.Sales_EndCustInfo_HTML';
import SalesSaveOrderHTML from '@salesforce/label/c.Sales_SaveOrder_HTML';


import { loadStyle } from 'lightning/platformResourceLoader';
import Orderstylingsheet from '@salesforce/resourceUrl/OrderCreation';

//let rendered = false;*/
export default class Sales_OrderCreation extends LightningElement {
   /* @api orderType;
    @track reasonCheck = false;
    @track isAttributeRequired = true;
    @track key;
    @api selectVal;
    @api soldSfdcAcc;
    @api shipSfdcAcc;
    @api endSfdcAcc;
    @api reason = '';
    @api selectedSubType;
    @api shipToAccId;
    @api soldToAccId;
    @api endCustAccId;
    @api orderReason = '';
    @api accountVal;
    @api startDate = '';
    /* @api countryVal;
     @api stateval;
     @api shipCountry;
     @api shipState;
     @api endCountry;
     @api endState;*/
    /*@api accId;
    @api soldAccount;
    @api shipAccount;
    @api endAccount;
    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @api selectedRecordId;
    @api fieldName = 'Sales_Order_Reason__c';
    @api effectiveDate = 'EffectiveDate';
    @api objectName = 'Order';
    @api objectApiName = 'Account';
    @api feildapi = 'BillingCountryCode';
    @api iconName = 'standard:account';
    @api lookupLabel = 'Account Name';
    @track message;
    @track options;
    @track loading = false; 
    isNonCommercial = false;
    isSampleOrd = false;
    isPartner = false;
    isAccounthidden = false;
    redirect = true;
    saveNew = true;
    resetpage = false;
    checkBoxFieldValue = false;
    isRenewal = false;
    iserror = false;
    isrequired = false;
    isendRequired = false;
    isSubTypeRequired = false;
    isCostCenterRequired = false;
    isEnter = false;
    isNonStocking = false;
    isSoldToPresent = false;
    isShipToPresent = false;
    isEndCustPresent = false;
    label = {
        successTxt,
        successMsg,
        stockingSoldToError,
        nonStockingEndCustError,
        noncommercialStockingError,
        partnerLicError,
        errorMsg,
        sales_Amend_error,
        SalesSubTypeCorporate,
        SalesNoRecordsFound,
        SalesErrorMessage,
        SalesNewOrderHTML,
        SalesOrderInfoHTML,
        SalesSoldToAccInfoHTML,
        SalesShipToAccInfoHTML,
        SalesEndCustInfoHTML,
        SalesSaveOrderHTML


    };
    connectedCallback() {
        loadStyle(this, OrderCreation);

    }
    renderedCallback() {

        Promise.all([
            loadStyle(this, Orderstylingsheet)
        ]).then(() => {
            console.log('Files loaded');
        })
            .catch(error => {
                console.log(error.body.message);
                
            });

    }

//console.log(error.body.message);

    //Cancel button logic
    navigateToObjectHome() {
        // Navigate to the Order object home page.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order',
                actionName: 'home'
            }
        });
    }
    // renderedCallback(){
    //     if(rendered){
    //         this.orderReason = 'Non Stocking Order';
    //         rendered = false;
    //     }
    // }
		

    //Record Creation 
    handleSuccess(event) {
        //this.loading = false; //Added as part of US1016244
        console.log('this.iserror>>' + this.iserror);
        //if(this.iserror!=true){
        const evt = new ShowToastEvent({
            variant: 'success',
            title: this.label.successTxt,
            message: this.label.successMsg,
        });
        this.dispatchEvent(evt);
        console.log('this.redirect>>' + this.redirect);
        if (this.redirect == true) {
            var recId = event.detail.id;
            console.log('Order record', event.detail.id);
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
        //}
        if (this.resetpage == true) {
            //this.handleReset();
            eval("$A.get('e.force:refreshView').fire();");
        }
    }

    //Save and new Logic
    saveAndNewClick() {
        console.log('Inside save and new')
        this.redirect = false;
        this.template.querySelector('lightning-record-edit-form');
        // eval("$A.get('e.force:refreshView').fire();");
        this.resetpage = true;
    }

    //Reset the field values
    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleResetAccount() {

        this.template.querySelectorAll('lightning-input-field[data-id="soldto"]').forEach(element => {
            element.value = null;
        });

    }

    handleResetEndAccount() {
        this.template.querySelectorAll('lightning-input-field[data-id="endCust"]').forEach(element => {
            element.value = null;
        });

    }

    handleResetSoldAccount() {
        this.template.querySelectorAll('lightning-input-field[data-id="shipto"]').forEach(element => {
            element.value = null;
        });

    }

     handleError(event){
         this.loading = false;// added as part of US1016244
         console.log('Error>>'+JSON.stringify(event.detail));
         console.log('Error1>>'+JSON.stringify(event.detail.detail));
         /*const evt = new ShowToastEvent({
             title: 'Error!',
             message: event.detail.detail,
             variant: 'error',
            // mode:'dismissable'
         });
         this.dispatchEvent(evt);*/
     //}

    // handleChange(){

    // }
    //Order type change event 
    // connectedCallback() {
    /*handleChange(event) {//check if order is non commercial and set Order sub type as mandatory 
        /*var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date+' '+time;
        console.log('@@date:'+dateTime)*/
        /*this.selectVal = event.target.value;
        console.log('Type>>' + this.selectVal);
        this.orderType = this.selectVal;
        //console.log('Order reason line 166'+this.orderReason);
        // rendered = true;
        this.options = null;
        this.connectedCallback();
        if (this.selectVal === 'Sample Order' && this.orderReason === 'Non Stocking Order') {
            if (this.shipAccount !== undefined) {
                this.isEndCustPresent = true;
                this.endCustAccId = this.shipToAccId;
                this.endAccount = this.shipAccount;
                //this.endCustAccId = this.shipToAccId;
                //console.log('End cust details>>'+this.endAccount);

                // console.log('Inside type change>>'+this.endCustAccId);
                this.endSfdcAcc = this.shipSfdcAcc;
            }
        }

        if ((this.selectVal === Sales_SampleOrder)) {//&& (this.orderReason === 'Stocking Order' || this.orderReason === ''))
            //console.log('Order reason line 180'+this.orderReason);
            // this.reason = 'Non Stocking Order';
            // console.log('line 179'+this.reason);
            this.isNonStocking = false;
        }
        if ((this.selectVal === Sales_LicenceToolOrder)) {//&& (this.orderReason === 'Stocking Order' || this.orderReason === ''){
            this.isNonStocking = false;
        }
        //    this.reason = 'Non Stocking Order';
        //     console.log('line 184'+this.reason);
        // }

        if (this.selectVal === Sales_NonCommercialOrder) {
            // if(this.orderReason === 'Stocking Order' || this.orderReason === ''){
            // this.reason = 'Non Stocking Order';
            // console.log('Order reason line 189'+this.orderReason);
            // console.log('reason line 190'+this.reason);
             this.isNonStocking = true;
            //}
            this.isNonCommercial = false;
            if (this.orderReason === 'Non Stocking Order') {
                this.isNonStocking = true;
            }


        } else {
            this.isNonCommercial = true;
            //this.isNonStocking = false;
        }


        //}
    }

    //Subtype change event logic
    handleChangeVal(event) {
        //if(this.selectedSubType!=undefined){
        this.selectedSubType = event.target.value;
        console.log('this.selectedSubType>>' + this.selectedSubType);
        if (this.selectedSubType === 'Partner license order' || this.selectedSubType === 'Evaluation license order') {
            this.isPartner = true;
            this.isSampleOrd = false;
            /* this.handleResetAccount();
             this.handleResetEndAccount();
             this.handleResetSoldAccount();*/
        /*}
        else {
            this.isPartner = false;
            this.isSampleOrd = false;
        }
   // }
    }

    onLeave(event) {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        console.log('selectedRecordId>>' + event.target.dataset.key)
        this.selectedValue = event.target.dataset.name;
        console.log('selectedValue>>' + event.target.dataset.name)
        this.searchKey = "";
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        /* var key = event.detail;
         console.log('Key:'+key);    */
        /*const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    /* handleOnKeyPress(component,event,helper){
         if(component.which===13){
          console.log('Inside on key press Enter event ');  
          this.isEnter = true;
          console.log('Enter val'+this.isEnter);
         
         }
         else{
          this.isEnter = false; 
         }
     }*/
/*
    removeRecordOnLookup(event) {
        //  event.preventDefault();   
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        // this.onSeletedRecordUpdate();  
    }

    getLookupResult() {
        findRecords({ searchKey: this.searchKey })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = this.label.SalesNoRecordsFound;
                } else {
                    this.recordsList = result;
                    console.log('Record List' + this.recordsList);
                    console.log('Record List>>' + this.recordsList.data);
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = undefined;
                const evt = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            });
    }

    onSeletedRecordUpdate() {
        if (this.selectedRecordId != null) {
            console.log('@@Account val' + this.selectedRecordId);
            this.accountVal = this.selectedRecordId;
            const passEventr = new CustomEvent('recordselection', {
                detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
            });
            this.dispatchEvent(passEventr);
        }
    }

    //Ship to account detais
    handleShipChange(event) {
        // this.handleResetAccount();
        console.log("You selected an Ship account: " + event.detail.value[0]);
        if (event.detail.value[0] !== undefined) {
            this.shipToAccId = event.detail.value[0];
            //var acc = this.shipToAccId;
            console.log('Ship to account ' + this.shipToAccId);
            this.accId = this.shipToAccId;
            //  this.handleResetSoldAccount();
            //get Ship to account detais
            fetchSoldToDetails({ acct: this.shipToAccId, selectedField: 'Core_Direct_Shipping_Condition_Nm__c,Core_Direct_Shipping_Instruction_Txt__c,Core_Direct_Incoterm_Dsc__c' })
                .then(returnedResult => {
                    if (returnedResult !== null && returnedResult !== undefined && returnedResult.length > 0) {
                        // this.accList = returnedResult;
                        // this.acc= this.accList[0];
                        this.shipAccount = returnedResult[0];
                        this.shipSfdcAcc = returnedResult[0].ParentId;
                        this.isShipToPresent = true;
                        console.log('Sold sfdc>>' + this.shipSfdcAcc);
                        if (this.selectVal === 'Sample Order' && this.orderReason === 'Non Stocking Order') {
                            this.endAccount = returnedResult[0];
                            this.endSfdcAcc = this.shipSfdcAcc;
                            this.endCustAccId = this.shipToAccId;
                            this.isEndCustPresent = true;
                            console.log('Sample order ship to method>>' + this.endCustAccId);

                        }
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.shipAccount = undefined;
                    const evt = new ShowToastEvent({
                        title: this.label.SalesErrorMessage,
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });


        }
        else {

            this.handleResetSoldAccount();
            this.isShipToPresent = false;
        }
    }

    //Sold to account Details
    handleSoldChange(event) {
        console.log("You selected an Sold account: " + event.detail.value[0]);
        if (event.detail.value[0] !== undefined) {
            this.soldToAccId = event.detail.value[0];

            //get Sold to Account details
            fetchSoldToDetails({ acct: this.soldToAccId, selectedField: 'Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c' })
                .then(retResult => {
                    if (retResult !== null && retResult !== undefined && retResult.length > 0) {
                        this.soldAccount = retResult[0];
                        console.log('this.soldAccount>>' + this.soldAccount);
                        this.soldSfdcAcc = retResult[0].ParentId;
                        console.log('Billing >>>' + this.soldAccount.BillingState);
                        console.log('Sold sfdc>>' + this.soldSfdcAcc);
                        this.isSoldToPresent = true;

                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.soldAccount = undefined;
                    const evt = new ShowToastEvent({
                        title: 'Error!',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });


        }
        else {

            this.handleResetAccount();
            this.isSoldToPresent = false;
        }
    }

    //End customer Account details
    handleEndChange(event) {
        console.log("You selected an End customer account: " + event.detail.value[0]);
        if (event.detail.value[0] !== undefined) {
            this.endCustAccId = event.detail.value[0];
            //  if(this.orderReason !== 'Stocking Order'){
            this.isSampleOrd = false;
            //get End customer Account details expect for sample order
            fetchEndCustDetails({ endCst: this.endCustAccId })
                .then(endResult => {
                    if (endResult !== null && endResult !== undefined && endResult.length > 0) {
                        this.endAccount = endResult[0];
                        console.log('End customer record' + this.endAccount);
                        this.endSfdcAcc = endResult[0].ParentId;
                        console.log('End customer sfdc>>' + this.endSfdcAcc);
                        this.isEndCustPresent = true;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.endAccount = undefined;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });


            /* }
             else if(this.orderReason === 'Stocking Order'){
                 this.isSampleOrd = true;
             }*/
  /*      }
        else {
            this.handleResetEndAccount();
            this.isEndCustPresent = false;
        }
    }

    //Based on Order reason to enable or disable fields
    handleOrderReasonChange(event) {
        this.orderReason = event.target.value;
        console.log('Order reason val ' + event.target.value);

        if (this.orderReason === 'Stocking Order') {
            // this.handleResetEndAccount();
            this.isSampleOrd = false;
            this.isNonStocking = false;
        }
        else if (this.orderReason === 'Non Stocking Order') {
            //console.log('isSampleOrd>> '+isSampleOrd);


            if (this.selectVal === Sales_NonCommercialOrder) {
                this.isNonStocking = true;
            }
            else if (this.selectVal === Sales_SampleOrder) {
                if (this.shipAccount !== undefined) {
                    this.endCustAccId = this.shipToAccId;
                    this.endAccount = this.shipAccount;
                    this.endSfdcAcc = this.shipSfdcAcc;
                    this.isEndCustPresent = true;
                    this.isSampleOrd = false;
                    this.isNonStocking = false;
                }
            }
            else if (this.selectVal === Sales_LicenceToolOrder) {
                this.isNonStocking = false;
                //this.isEndCustPresent=true;
                // this.isSampleOrd = false ;
            }

        }
    }

    //Custom Picklist Code 
    connectedCallback() {
        //   this.picklistValues = picklist.split(';');

        getPickListValues({
            objApiName: this.objectName,
            fieldName: this.fieldName
        })
            .then(data => {
                this.options = data;

                //    this.options.unshift({label:'Select', value:'select'});
                console.log('Record -->' + JSON.stringify(this.options));
                this.orderReason = 'Non Stocking Order';
            })
            .catch(error => {
                this.displayError(error);
            });
        getFieldLabel({
            objName: this.objectName,
            fieldName: this.fieldName
        })
            .then(data => {
                this.fieldLabelName = data;
            })
            .catch(error => {
                this.displayError(error);
            });
    }

    handleDate() {
        var today = new Date();
        var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date + ' ' + time;
        this.startDate = dateTime;
        console.log('@@date:' + dateTime)
        return dateTime;
    }
    //method to set account value at the time of submition
    handleSubmit(event) {
        this.iserror = false;
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;

        console.log('Feilds -->' + JSON.stringify(fields));
        console.log('@@Selected val>>' + this.selectedRecordId);
        console.log('@@Order Type>>' + this.selectVal);
        console.log('@@Order sub Type>>' + this.selectedSubType);
        console.log('Inside handle submit');
        console.log('Inside Error check method');
        var today = new Date();
        var date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date + ' ' + time;
        this.startDate = dateTime;
        console.log('@@startdate:-' + this.startDate);
        this.effectiveDate = this.startDate;
        console.log('@@effectivedate:-' + this.effectiveDate);

        fields.Sales_Order_Reason__c = this.orderReason;
        fields.Type = this.selectVal;
        fields.Sales_Order_Sub_Type__c = this.selectedSubType ; 
        /*
        //For Partner License order  OOTB Account is set to Sf account with partner role FPGA
        if (this.orderReason === 'Non Stocking Order' && this.selectVal === 'Non Commercial Order' && (this.selectedSubType === 'Partner license order' || this.selectedSubType === 'Evaluation license order') && this.accountVal != null) {  //this.selectedRecordId != null
            console.log('Inside partner check method')
            this.iserror = false;
            //console.log('@@Selected val>>' + this.selectedRecordId);
            //this.accountVal = this.selectedRecordId;
            fields.AccountId = this.accountVal;
            //fields.Sales_Order_Reason__c = this.orderReason;
            console.log('@@Account val>>' + this.accountVal);
            // this.saveNew = true;
        }
        else */
    /*    if (this.orderReason === 'Stocking Order' && this.selectVal === 'Non Commercial Order') {
            this.iserror = true;
            this.loading = false;
            const evt = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.noncommercialStockingError,
                variant: 'error',
                // mode:'dismissable'
            });
            this.dispatchEvent(evt);
        } 
        /*
        else if (this.orderReason === 'Non Stocking Order' && this.selectVal === 'Non Commercial Order' && (this.selectedSubType === 'Partner license order' || this.selectedSubType === 'Evaluation license order') && this.accountVal == null ) { //this.selectedRecordId == null   //&& this.isEnter === false
            this.iserror = true;
            const evt = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.partnerLicError,
                variant: 'error',
                // mode:'dismissable'
            });
            this.dispatchEvent(evt);

        }
        */
      /*  else if (this.orderReason === 'Non Stocking Order' && this.selectVal === 'Non Commercial Order' && this.selectedSubType === 'Amend Non Commercial' && this.selectedRecordId == null) {//&& this.isEnter === false
            this.iserror = true;
            const evt = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.sales_Amend_error,
                variant: 'error',
                // mode:'dismissable'
            });
            this.dispatchEvent(evt);

        }*/
      /*  else if (this.orderReason === 'Non Stocking Order' && this.selectVal === 'Non Commercial Order' && this.selectedSubType === 'Corporate Order' && this.selectedRecordId == null) {//&& this.isEnter === false
            this.iserror = true;
            this.loading = false;
            const evt = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.SalesSubTypeCorporate,
                variant: 'error',
                 //mode:'sticky'
            });
            this.dispatchEvent(evt);

        }

        /* else if(this.selectVal === 'Non Commercial Order' && (this.selectedSubType === 'Partner license order' || this.selectedSubType === 'Evaluation license order') && this.selectedRecordId==null && this.isEnter === true){
             this.iserror = true;
             console.log('Inside partner lic enter handle'+this.iserror);
         }*/


        //For stocking order  OOTB Account is set to Sap Sold to account

        /*if (this.orderReason === 'Stocking Order' && (this.selectVal != 'Non Commercial Order') && this.soldSfdcAcc != null) {
            this.iserror = false;
            console.log('@@Sold to account>>' + this.soldSfdcAcc);
            this.accountVal = this.soldSfdcAcc;
            // fields.AccountId = this.soldToAccId ;
            fields.AccountId = this.accountVal;
            // fields.Sales_Order_Reason__c = this.orderReason;
            console.log('@@Account val>>' + this.accountVal);
            // this.saveNew = true;
        }

        else if (this.orderReason === 'Stocking Order' && (this.selectVal != 'Non Commercial Order') && (this.soldToAccId == null || this.soldSfdcAcc == null)) {
            this.iserror = true;
            this.loading = false;
            const evt = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.stockingSoldTOError,
                variant: 'error',
                // mode:'dismissable'
            });
            this.dispatchEvent(evt);
        }

        //For non-stocking order  OOTB Account is set to Sap End cust account
        if (this.orderReason === 'Non Stocking Order' && (this.selectVal != 'Non Commercial Order') && (this.selectedSubType != 'Partner license order' || this.selectedSubType != 'Evaluation license order') && this.endSfdcAcc != null && this.endCustAccId != null) {
            console.log('Inside Non stocking end cust method');
            this.iserror = false;
            console.log('@@End cust account>>' + this.endSfdcAcc);
            console.log('Sap End cust' + this.endCustAccId);
            this.accountVal = this.endSfdcAcc;
            fields.AccountId = this.accountVal;
            // fields.Sales_Order_Reason__c = this.orderReason;
            console.log('@@Account val>>' + this.accountVal);
        }

        else if (this.orderReason === 'Non Stocking Order' && (this.selectVal != 'Non Commercial Order') && (this.endCustAccId == null || this.endSfdcAcc == null)) {
            this.iserror = true;
            this.loading = false;
            const evt1 = new ShowToastEvent({
                title: this.label.errorMsg,
                message: this.label.nonStockingEndCustError,
                variant: 'error',
                // mode:'dismissable'
            });
            this.dispatchEvent(evt1);
        }

        //For University program and Amend Non-commercial OOTB Account is set to Sap End cust account
        if (((this.selectedSubType === 'FPGA university program license request') || (this.selectedSubType === 'Amend Non Commercial')) && this.endSfdcAcc != null && (this.orderReason === 'Non Stocking Order')) {
            this.iserror = false;
            this.accountVal = this.endSfdcAcc;
            fields.AccountId = this.accountVal;
            // fields.Sales_Order_Reason__c = this.orderReason;
            console.log('@@Account val>>' + this.accountVal);
        }

        else if (this.orderReason === 'Non Stocking Order' && ((this.selectedSubType === 'FPGA university program license request') || (this.selectedSubType === 'Amend Non Commercial')) && (this.endCustAccId == null || this.endSfdcAcc == null)) {
            
            this.iserror = true;
            this.loading = false;
            const evt1 = new ShowToastEvent({
                variant: 'error',
                title: this.label.errorMsg,
                message: this.label.nonStockingEndCustError,
            });
            this.dispatchEvent(evt1);
        }
        
        if (this.iserror != true) {
            this.loading = true; //Added as part of US1016244
            console.log('During submitting -->' + JSON.stringify(fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        //Added by Shivam -- Focuses on Top of the Modal before we save, benefit for Error Banner Focus
        const topDiv = this.template.querySelector('[data-id="focusOnErrorBannerId"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });

    }

    get makeSoldTorequired() {
        if (this.orderReason === 'Stocking Order' && this.selectVal != 'Non Commercial Order') {
            return this.isrequired = true;
        } else {
            return this.isrequired = false;
        }
        return;
    }

    get endRequired() {
        if (this.orderReason === 'Non Stocking Order' && this.selectVal != 'Non Commercial Order') {
            return this.isendRequired = true;
        } else {
            return this.isendRequired = false;
        }
        return;
    }

    get subTypeRequired() {
        if (this.selectVal === 'Non Commercial Order') {
            return this.isSubTypeRequired = true;
        } else {
            return this.isSubTypeRequired = false;
        }
        return;
    }
    get checkorderType() {
        if (this.orderType === 'Non Commercial Order' || this.orderType === 'Licensed Tool Order') {
            return true;
        }
        else {
            return false;
        }
    }
    get costCenterRequired() {
        if (this.selectVal === 'Non Commercial Order' || this.orderType === 'Licensed Tool Order') {
           // return this.isCostCenterRequired = true;
           return true
        } else {
            //return this.isCostCenterRequired = false;
            return false
        }
       // return;
    }*/

}
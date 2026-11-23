import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import OpptyLineItem_OBJINFO from '@salesforce/schema/OpportunityLineItem';
import WIPNameJS from '@salesforce/schema/OpportunityLineItem.Core_Write_In_Product_Name__c';
import GroupJS from '@salesforce/schema/OpportunityLineItem.Core_Group__c';
import StatusJS from '@salesforce/schema/OpportunityLineItem.Core_Status__c';
import QuantityJS from '@salesforce/schema/OpportunityLineItem.Quantity';
import PWQtyJS from '@salesforce/schema/OpportunityLineItem.Core_PW_Quantity__c';
import UnitPriceJS from '@salesforce/schema/OpportunityLineItem.UnitPrice';
import PWSalesPriceJS from '@salesforce/schema/OpportunityLineItem.Core_PW_Sales_Price__c';
import LosCancelReasonJS from '@salesforce/schema/OpportunityLineItem.Core_Loss_Cancel_Reason__c';
import LosCancelDetailsJS from '@salesforce/schema/OpportunityLineItem.Core_Loss_Cancel_Details__c';
import VendorJS from '@salesforce/schema/OpportunityLineItem.Core_Vendor__c';
/*import AdvTechJS from '@salesforce/schema/OpportunityLineItem.Core_Advanced_Technology__c';*/
import CompetitorJS from '@salesforce/schema/OpportunityLineItem.Core_Competitor__c';
import CompProdJS from '@salesforce/schema/OpportunityLineItem.Core_Competitor_Product__c';
import CompProdTextJS from '@salesforce/schema/OpportunityLineItem.Core_OtherCompetitor_Product_Txt__c';
import BUMappingRecJS from '@salesforce/schema/OpportunityLineItem.Core_BU_Mapping_record__c';
import updateLineItem from '@salesforce/apex/core_updateOpptyLineItemLWC.updateOpptyLineItemRecord';
import getRecords from '@salesforce/apex/core_updateOpptyLineItemLWC.getRecords';
import customCSS from '@salesforce/resourceUrl/toastCSS';
import { loadStyle } from 'lightning/platformResourceLoader';
import plpcWarningMessage from '@salesforce/label/c.CRM_WarningMessage_WA_to_PLPC'; //TWC3123-6413
import qtyStaticText from '@salesforce/label/c.CRM_OLI_Qty_Static_Text';//TWC4767-5062

const productionLostCancelledStatus = ['Production Lost','Production Cancelled']; //TWC3123-6413

export default class core_ReadOnly_FieldSet_Form extends NavigationMixin(LightningElement) {

    @track OpportunityLineItems;
    @track error;
    @api recordId;
    opptDetailfromOLI= {};
    @api showEditField;
    @track isLoading = false;
    @api invokedFromAura;
    @track OpporttyType;
    @track opptyLineItemRec;
    @track show6QPSWarning = false;
    @track warningMsg6QPS;
    @track DesignOrDeal=false;
    @track isPCCenabled =true;
    errorMessageToDisplay = '';
    @track userChangedNull=false;
    @track userChangedNullPW=false;

    //storing Static text in a custom Label (External String)
    qtyStaticTextBody = qtyStaticText.split(" ; ")[0];
    qtyStaticTextHyperLinkText = qtyStaticText.split(" ; ")[1];
    qtyStaticTextHyperLink = qtyStaticText.split(" ; ")[2];
    //end

    activeSections =  [];
    OpportunityTypeVal;
    OpportunityRecordType ='';
    OpportunityCoverage ='';

    toDisableQty = false;
    isPCCOppty = '';
    QLRecord = '';
    QLStatus = '';   

    @track isCSSLoaded = false;

    renderedCallback() {

        if (this.isCSSLoaded) return;
        this.isCSSLoaded = true;
        loadStyle(this, customCSS).then(() => {
            //console.log('css loaded successfully');
        }).catch(error => {
           // console.log('error to load css');
        });
    }
   
  @wire(getRecords, { recordId: '$recordId'})
  OpptDetailfromOLI({ error, data }) {
        if (data) {
            this.opptDetailfromOLI = data;
            this.OpportunityRecordType =this.opptDetailfromOLI.Opportunity.RecordType.DeveloperName;
            this.OpportunityCoverage = this.opptDetailfromOLI.Opportunity.Core_Opportunity_Coverage_Nm__c;

            //TWC3123-5771 Start - Enable/Disable Quantity field based on Associated QuoteLine status/PCC Opportunity
            this.isPCCOppty = this.opptDetailfromOLI.Core_IsPCCOpportunity_cb__c;
            this.QLRecord = this.opptDetailfromOLI.SBQQ__QuoteLine__c;
            if(!(this.QLRecord == undefined)){
                this.QLStatus = this.opptDetailfromOLI.SBQQ__QuoteLine__r.Pricing_Status_Nm__c;
            }

            if(this.isPCCOppty == true){
                this.isPCCenabled = true;
                if(this.QLRecord!= undefined && this.QLStatus!=undefined && this.QLStatus == 'Rejected'){
                    this.toDisableQty = false;
                }
                else if(this.QLRecord == undefined){
                    this.toDisableQty = false;
                }
                else if(this.QLRecord!= undefined && this.QLStatus!=undefined && this.QLStatus != 'Rejected'){
                    this.toDisableQty = true;
                }
            }
            //TWC3123-5771 End

        	
            if(this.OpportunityRecordType == 'Core_Design_Opportunity')
            {                  
                this.DesignOrDeal = true;  
                this.isPCCenabled = false;
                this.activeSections =  ['A','B','C','D'];         
            }        
            else
            {            
                if(this.OpportunityCoverage=='Intel-Led Opportunity' || (this.OpportunityCoverage=='Partner-Led Opportunity'&& !this.isPCCOppty)){
                    this.isPCCenabled = false;
                    this.activeSections =  ['A','B','D'];
                }
                else{     
                    this.isPCCenabled = true;
                    this.activeSections =  ['E','A','B','D'];
                }                
            }

        } else if (error) {
            console.error('Error fetching object data:', error);
        }
    }
 
    handleEdit(event) 
    {
        this.showEditField = !this.showEditField;
    }
 
    handleCancelButtonClick(event) 
    {
        this.showEditField = false;
        
        location.reload();
        this.showOrHideStyle = 'slds-hide'    
    }
 
    handleWIPName(event) 
    {
        this.WIPNameValue = event.target.value;
        this.WIPNameJS = this.WIPNameValue;
    }
 
    handleGroup(event) 
    {
        this.GroupValue = event.target.value;
        this.GroupJS = this.GroupValue;
    }

    //TWC3123-6413- (WW37)warning confirmation if the status is being changed from "Win Approved" to "Production Cancelled/Production Lost"
    handleStatus(event) 
    {
        this.StatusValue = event.target.value;
        const oldStatus = this.opptDetailfromOLI.Core_Status__c;
        if(oldStatus == 'Win Approved' && productionLostCancelledStatus.includes(this.StatusValue)){
            const event = new ShowToastEvent({
                message: plpcWarningMessage ,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
        }
        this.StatusJS = this.StatusValue;
    }
    //TWC3123-6413-END

    handleQuantity(event) 
    {
        this.QuantityValue = event.target.value;
        this.QuantityJS = this.QuantityValue;
        if(this.QuantityJS=='' || this.QuantityJS==undefined){
            this.userChangedNull = true;
            this.QuantityJS  = null;
        }
        else{
            this.userChangedNull = false;
        }
        if(this.DesignOrDeal){
        this.show6QPSWarning = true;
        }
        this.warningMsg6QPS = 'Warning : Scheduled Quantity and Revenue Values for your 6QPS will be recalculated based on Updated Design Win Qty';



    }
 
    handlePWQty(event) 
    {
        this.PWQtyValue = event.target.value;
        this.PWQtyJS = this.PWQtyValue;
        //Added to avoid 'value provided is invalid for action parameter 'pwqty' of decimal
        if((this.PWQtyJS=='' || this.PWQtyJS==undefined)){
            this.PWQtyJS  = null;
            this.userChangedNullPW = true;
        }
        else{
            this.userChangedNullPW = false;
        }
        if(this.DesignOrDeal){
             this.show6QPSWarning = true;
        }
        this.warningMsg6QPS = 'Warning : Scheduled Quantity and Revenue Values for your 6QPS will be recalculated based on Updated Production Win Qty';
    }
 
    handleUnitPrice(event) 
    {
        this.UnitPriceValue = event.target.value;
        this.UnitPriceJS = this.UnitPriceValue;
        if(this.UnitPriceJS=='' || this.UnitPriceJS==undefined){
            this.userChangedNull = true;
            this.UnitPriceJS  = null;
        }
        else{
            this.userChangedNull = false;
        }
    }
 
    handlePWSalesPrice(event) 
    {
        this.PWSalesPriceValue = event.target.value;
        this.PWSalesPriceJS = this.PWSalesPriceValue;
        //Added to avoid 'value provided is invalid for action parameter 'pwsalesprice' of decimal
        if(this.PWSalesPriceJS=='' || this.PWSalesPriceJS==undefined){
            this.userChangedNullPW = true;
            this.PWSalesPriceJS  = null;
        }
        else{
            this.userChangedNullPW = false;
        }
    }

    handleLossCancelReason(event)
    {
        this.LossCancelReasonValue = event.target.value;
        this.LossCancelReasonJS = this.LossCancelReasonValue;

       if((this.LossCancelReasonValue=='Customer Discontinued Project' ||this.LossCancelReasonValue=='Entered in Error' || this.LossCancelReasonValue=='POP Unobtainable' || 
        this.LossCancelReasonValue=='Design Reg. Product Swap' || this.LossCancelReasonValue=='Failed Audit') && (this.StatusValue == 'Lost' || this.StatusValue == 'Cancelled') && 
         this.OpportunityCoverage=='Intel-Led Opportunity' ){//TWC3123-6699 modified value for api change

        this.template.querySelector('lightning-input-field.competitorTag').value = 'None';
        this.template.querySelector('lightning-input-field.competitorProdTag').value = 'None';

     /*    this.template.querySelectorAll('lightning-input-field').forEach(element => {

       if (element.fieldName === 'Core_Competitor__c' || element.fieldName === 'Core_Competitor_Product__c' ) {
            
            element.value = 'None';

        }});*/


        }else{
            this.template.querySelector('lightning-input-field.competitorTag').value = '';
        this.template.querySelector('lightning-input-field.competitorProdTag').value = '';
        
    }

        
    }
 
    handleLossCancelDetails(event) 
    {
        this.LossCancelDetailsValue = event.target.value;
        this.LossCancelDetailsJS = this.LossCancelDetailsValue;
    }
 
    handleVendor(event) 
    {
        this.VendorValue = event.target.value;
        this.VendorJS = this.VendorValue;
    }
 
    /*handleAdvTech(event) 
    {
        this.AdvTechValue = event.target.value;
        this.AdvTechJS = this.AdvTechValue;
    }*/
 
    handleCompetitor(event) 
    {
        this.CompetitorValue = event.target.value;
        this.CompetitorJS = this.CompetitorValue;

      // console.log('0----'+this.template.querySelectorAll('lightning-input.competitorProduct'));
       // this.template.querySelector('lightning-input.competitorProduct').value = 'None';

        if(event.detail.value == 'None' || event.detail.value == 'Other'){
        this.template.querySelectorAll('lightning-input-field').forEach(element => {

        if (element.fieldName === 'Core_Competitor_Product__c') {
            
            element.value = 'None';

        }});
        }
        
    }
 
    handleCompProd(event) 
    {
        this.CompProdValue = event.target.value;
        this.CompProdJS = this.CompProdValue;
    }

    handleCompProdTxt(event) 
    {
        this.CompProdTextValue = event.target.value;
        this.CompProdTextJS = this.CompProdTextValue;
    }
 
    handleBUMappingRec(event) 
    {
        this.BUMappingRecValue = event.target.value;
        this.BUMappingRecJS = this.BUMappingRecValue;
    }
 
    handleSave() 
    {
            if(this.show6QPSWarning)
                {
                    this.showQPSToast(this.warningMsg6QPS);
                }
        this.isLoading = true;
        updateLineItem({
                recordId: this.recordId,
                wipname: this.WIPNameJS,
                groupname: this.GroupJS,
                status: this.StatusJS,
                qty: this.QuantityJS,
                pwqty: this.PWQtyJS,
                unitprice: this.UnitPriceJS,
                pwsalesprice: this.PWSalesPriceJS,
                losscancelreason: this.LossCancelReasonJS,
                losscanceldetails: this.LossCancelDetailsJS,
                vendor: this.VendorJS,
                /*advtech: this.AdvTechJS,*/
                competitor: this.CompetitorJS,
                compprodval: this.CompProdJS,
                othercompprod: this.CompProdTextJS,
                bumappingrec: this.BUMappingRecJS,
                isUserChangedNull: this.userChangedNull,
                isUserChangedNullPW: this.userChangedNullPW
            })
            .then((result) => {
                this.isLoading = false;
                this.OpportunityLineItems = result;
                this.error = undefined;

                const evnt = new ShowToastEvent({
                    title : 'Success',
                    message : 'Record is saved successfully',
                    variant : 'Success',
                    mode : 'dismissable'
                    });
                    this.dispatchEvent(evnt);
                    eval("$A.get('e.force:refreshView').fire();");
                    if(this.invokedFromAura){
                        this.navigateToPreviousPage();
                    }
                    this.showEditField = false;
            })
            .catch((error) => {
                
                this.isLoading = false;
                this.errorMessageToDisplay = '';
                this.error = error;   
                console.log('Inside catch oops error'+this.error);
                if(this.error.body) {
                    console.log('Inside error body'+this.error.body);
                    console.log('Inside error body type'+typeof this.error.body);
                    if (Array.isArray(this.error.body)) {
                        console.log('Inside array.isarray:'+this.error.body);
                        this.errorMessageToDisplay += this.error.body.map(e => e.message).join(', ');
                    }
                    else if(typeof this.error.body === 'object'){
                        let fieldErrors = this.error.body.fieldErrors;
                        let pageErrors = this.error.body.pageErrors;
                        let duplicateResults = this.error.body.duplicateResults;
                        let exceptionError = this.error.body.message;
                        console.log('Fielderror is:'+fieldErrors);
                        console.log('Page errors is:'+pageErrors);
                        console.log('Duplicateresults is:'+duplicateResults);
                        console.log('Exceptionerror is:'+exceptionError);
        
                        if(exceptionError && typeof exceptionError === 'string') {
                            this.errorMessageToDisplay += exceptionError;
                        }
                        
                        if(fieldErrors){
                            for(var fieldName in fieldErrors){
                                let errorList = fieldErrors[fieldName];
                                for(var i=0; i < errorList.length; i++){
                                    console.log('Field error status code is:'+errorList[i].statusCode);
                                    console.log('Field error message is:'+errorList[i].message);
                                    this.errorMessageToDisplay +=  errorList[i].message + ' \n';
                                }
                                console.log('Fieldmsg is:'+this.errorMessageToDisplay);
                            }
                        }
                
                        if(pageErrors && pageErrors.length > 0){
                            for(let i=0; i < pageErrors.length; i++){
                                console.log('Page error status code is:'+pageErrors[i].statusCode);
                                console.log('Page error message is:'+pageErrors[i].message);
                                this.errorMessageToDisplay +=  pageErrors[i].message+ ' \n';
                            }
                        }
                
                        if(duplicateResults && duplicateResults.length > 0){
                            this.errorMessageToDisplay += 'duplicate result error';
                        }
                    }  
                }
                // handles errors from the lightning record edit form
                if(this.error.message){
                    this.errorMessageToDisplay += this.error.message;
                }
                if(this.error.detail){
                    this.errorMessageToDisplay += this.error.detail;
                }
                //newly added end
                const evnt = new ShowToastEvent({
                title : 'Review the errors on this page',
                message : this.errorMessageToDisplay,
                variant : 'Error',
                mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
                }); 
            this.show6QPSWarning = false;
        
    }
          

    //invoked when Submit button in core_OverrideEditButtonOpporunityProdouct is clicked
    @api submitFromAura()
    {
        this.isLoading = true;
        this.handleSave();
    }
 
    //invoked when Cancel button in core_OverrideEditButtonOpporunityProdouct is clicked
    @api cancelFromAura()
    {
        this.navigateToPreviousPage();
    }
    
    navigateToPreviousPage()
    {
        window.history.back();
    }
    
    //show 6QPS Warning Toast if PW Sales Price,PW Quantity or Quantity modified
    showQPSToast(msg) 
    {
        const event = new ShowToastEvent({
            title: '6QPS Warning',
            message: msg,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}
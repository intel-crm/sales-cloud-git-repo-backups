import { LightningElement,api,track,wire } from 'lwc';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getAllQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.fetchAllQuoteLines';
import createRecords from '@salesforce/apex/PSG_RequestDPA.createDPARequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';
//const FIELDS = ['SBQQ__Quote__c.Name', 'SBQQ__Quote__c.SBQQ__Status__c'];

export default class Psg_createDPArequest extends LightningElement {
    @api recordId = 'a9Y2D000000CxAcUAK';
    @track createDPAAction = false;
    @track requestButtonLabel;
    @track quoteLineList = [];
    @track quoteList = [];
    @track updatedFields=[];
    @track selectedline=[];


    @track columns = [
    {label:'Line #',fieldName:'Name',editable: false,sortable: true}, 
    {label:'* OPN',fieldName:'core_cpq_opn__c',editable: false,sortable: true},
    {label:'LBound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true},
    {label:'UBound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true},
    {label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:true},   
    {label:'Broken Cost',fieldName:'price_brokencost_amt__c',editable: true,sortable: true,required:false},

    {label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true},  
    
    {label:'Pricing Type',fieldName:'core_cpq_quote_line_type_txt__c',editable: false,sortable: true},


   /* 
   {label:'Distributor Margin %',fieldName:'core_cpq_distributor_margin_pct__c',editable: true,sortable: true,required:true},
    {label:'Broken Cost',fieldName:'price_brokencost_amt__c',editable: true,sortable: true,required:false},
    {label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:false},
    {label:'Requested Resale',fieldName:'price_requested_resale_amt__c',editable: true,sortable: true,required:false},
    {label:'Std/Fwd Cost',fieldName:'price_std_fwd_cost_amt__c',editable: true,sortable: true,required:false},
    {label:'Production Start Date',fieldName:'core_cpq_production_dt__c',editable: true,sortable: true,required:true},
    {label:'Pricing Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',editable: false,sortable: true,required:false},
    {label:'Pricing End Date',fieldName:'core_cpq_pricing_end_date_dt__c',editable: false,sortable: true,required:false},
    {label:'PSG Reg #',fieldName:'core_cpq_reg_number_txt__c',editable: true,sortable: true,required:false},
    {label:'Product Family',fieldName:'core_cpq_product_family_txt__c',editable: true,sortable: true,required:false},
    {label:'Contracted Price',fieldName:'core_cpq_contracted_price__c',editable: true,sortable: true,required:false},

    
    {label:'Altera Reg Number',fieldName:'core_cpq_altera_reg_txt__c',editable: this.isEditable,sortable: true,required:false}*/];
    requestButtonLabel = 'CreateDPA';
    //Accordion Sections
    @track activeSections = ['quoteDetails','quoteLinesDetails']; 
    //Quote Details Section
    @track draftValues =[];
    @track quoteColumnsLocked = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_distystatus_txt__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false},
        {fname:'core_cpq_approved_on_dt__c',editable:false},
        {fname:'core_cpq_end_customer_disty_nm__c',editable:true},
        //{fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        //{fname:'core_cpq_ultimate_quote_number_nbr',editable:false},//added
        
    ];
    
    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
        }
    }*/
    connectedCallback() {
        this.fetchQuoteLineDetails();
    }
    fetchQuoteLineDetails(){
        
        getAllQuoteLines({quoteId: this.recordId})  
        .then(result=>{ 
        this.showSpinner = false; 
        console.log('call 1');
        this.qlList=[];
        console.log('result '+JSON.stringify(result.quoteLineList));
        console.log('call 2');
        this.quoteList = JSON.parse(JSON.stringify(result.quoteList));
        this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        
        //Pagination
        }) 
        .catch(error=>{  
        this.qlList=[];
        this.showSpinner=false;
        this.showToast('Error Loading QuoteLines',JSON.stringify(error),'error');
        console.log('Error Updating Records',JSON.stringify(error),'error');
        }) 
    }
    requestUpdate(){
        this.createDPAAction = true;
    }   
    //Accordian section selection
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }
    handleRowAction(event){
        let row = event.detail.row;
        console.log('rowID::'+JSON.stringify(row));
    }
    //send createDPArequest
    sendRequestUpdate(){
        
        //quoteData
        let updatedFields =  this.template.querySelector('lightning-datatable').draftValues; 
        let selectedline= this.template.querySelector('lightning-datatable').getSelectedRows();
       // let listdata =  this.template.querySelector('lightning-datatable').quoteLineList; 
        let DPAmap=new Map;
        
        console.log("Selected Line"+JSON.stringify(selectedline));
        console.log("updatedFields->>>>>>>>>>"+JSON.stringify(updatedFields));
       // console.log("Size--->>>>>>>>>>"+JSON.stringify(listdata.length));


        for (let index = 0; index < selectedline.length; index++) {
            if(selectedline[index].Id==updatedFields[index].Id)
                DPAmap.set(selectedline[index].Id,JSON.stringify(updatedFields[index]));
            //console.log('ANS->>>>>'+DPAmap);
        }
        console.log("DPA----->>>>"+DPAmap);
        DPAmap.forEach(function(value, key, map)
        {
            console.log('Key -> ' + key + '  value -> ' +JSON.stringify( value));
        });


        /*for (let index = 0; index < this.updatedFields.length; index++) {
            console.log('onchangeHandle 1');
            console.log(this.updatedFields[index].core_cpq_dollar_change_flag_cb__c);
        }*/

        console.log("length->>>>>>>>>>>>>>>>"+updatedFields.length);
        console.log('aaaaaaaaaaaaaaa '+JSON.stringify(this.draftValues[0]));
        /*for (let index = 0; index < this.draftValues.length; index++) {
            console.log('onchangeHandle 1');
            console.log(this.draftValues[index]);
        }*/
        createRecords({selectedLineList:selectedline,attWrapList:updatedFields})
                .then(data => {
                    this.disableSave=false;
                    console.log('inserted!');
                   // this.showToast('Success','success');
                    //this.navigateToHomePage();
                    //refreshApex(this.quoteObjRec);
                })
       // const updatedFields = event.detail.draftValues;
       // console.log(updatedFields);
       
        /*var quote = this.quoteRec;
        var quoteMap = {};
        var quoteData = this.template.querySelectorAll('lightning-input-field');
        quoteData.forEach(function(element){
            (quoteMap[quote.Id])[element.fieldName] = element.value;
        })
        console.log(quote);
        console.log(quoteMap);
        //QlData
        var el = this.template.querySelector('Id');
        console.log(el);
        var selected = el.getSelectedRows();
        console.log(selected);
        //this.createDPAAction = false;*/
    }
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('Updated itemsDraft',(updatedFields));
        //save last saved copy
       /* this.lastSavedData = JSON.parse(JSON.stringify(this.draftValues));
        for (let index = 0; index < this.draftValues.length; index++) {
            this.draftValues[index].SBQQ__Quote__c = this.recordId;
            console.log('this.recordId '+this.recordId);
        }*/


    }

    cancelRequestUpdate(){
        this.createDPAAction = false;
    }
    
}
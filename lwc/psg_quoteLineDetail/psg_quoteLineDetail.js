import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';

export default class psg_quoteLineDetail extends NavigationMixin(LightningElement) {
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT }) objectInfo;

    keyIndex = 0;
    @track itemList = [ { id: 0, class:'class0' } ];
    @track showSpinner = false;
    @api qlList=[];
    @api qlEditList=[];
    @api deleteList=[];
    @api isEdit;
    @api lockRecord;
    @api lockPartialRecord;
    @api inProgressQuote = false;
    @api requestDPAFlag =  false;//added for DPA
    @api requestALNFlag =  false;//added for DPA
    @api isCpQuote= false;
    @api pendingvisblity=false;
    @api isDraft = false;
    @api recordId;
    @api temptrue;
    @api tempfalse = false;
    @api isNewStatus = false;
    @api showNewSearchOptions = false;
    @api enableAddSearchOptions = false;
    @track currentDistributor;

    @track qlColumns=[
        {fname:'core_cpq_product_nm__c',required:true,label:'Product/Part#'},
        {fname:'core_cpq_requested_qty__c',required:true,label:'EAU Quantity'},
        {fname:'core_cpq_years_nbr__c',required:true,label:'# Years',value:'1'},
        {fname:'price_requested_resale_amt__c',required:false,label:'Requested Resale'},
        {fname:'core_cpq_production_dt__c',required:true,label:'Production Start Date'},
        {fname:'core_cpq_reg_number_txt__c',required:false,label:'PSG Reg #'},
        {fname:'core_cpq_competitor_name_nm__c',required:false,label:'Competitor Name'},
        {fname:'core_cpq_competitor_part_txt__c',required:false,label:'Competitor Part'},
        {fname:'price_competitor_price_amt__c',required:false,label:'Competitor Price'},    
    ];

    @track qlLockedColumns=[
        {fname:'Name',editable:true,label:'Line #'},
        //{fname:'core_cpq_dollar_change_flag_cb__c',editable:true,label:'$Change Flag'},
        {fname:'SBQQ__Product__c',editable:true,required:true,label:'Product/Part#'},
        //{fname:'core_cpq_quote_line_type_txt__c',editable:false,label:'Line Type'},
        //{fname:'core_cpq_lower_bound_qty_qty__c',editable:true,label:'Lower Bound Quantity'},
        //{fname:'core_cpq_upper_bound_qty_nbr__c',editable:true,label:'Upper Bound Quantity'},
        {fname:'core_cpq_requested_qty__c',editable:true,required:true,label:'EAU Quantity'},
        {fname:'core_cpq_years_nbr__c',editable:true,required:true,label:'# Years'},
        //{fname:'core_cpq_price_eligibility_date_dt__c',editable:false,label:'Price Eligibility Date'},
        //{fname:'core_cpq_pricing_start_date_dt__c',editable:true,label:'Pricing Start Date'},
        //{fname:'core_cpq_pricing_end_date_dt__c',editable:true,label:'Pricing End Date'},
        {fname:'price_requested_resale_amt__c',editable:true,required:false,label:'Requested Resale'},
        {fname:'core_cpq_production_dt__c',required:true,label:'Production Start Date'},
        //{fname:'price_suggested_resale_amt__c',editable:false,label:'Suggested Resale'},
        //{fname:'price_disty_cost_nbr__c',editable:false,label:'Disty Cost'},
        //{fname:'price_broken_cost_amt__c',editable:false,label:'Broken Cost'},
        {fname:'core_cpq_reg_number_txt__c',editable:true,required:false,label:'PSG Reg #'}  
    ];
    @api
    validateopn(){
        console.log('inside quotelinedetail validate');
        return this.template.querySelector('c-psg_quoteline-lightning-datatable').validateopn();
    }
    savequote(){
        const selectEvent = new CustomEvent('savequote', {
            detail: this.draftValues
        });
        this.dispatchEvent(selectEvent);
    }
    @api
    sendValidationResult(data){
        console.log('enter send validation result1');
        this.template.querySelector('c-psg_quoteline-lightning-datatable').sendValidationResult(data);
    }
    @api
    opencolumnsupdaterequest(){
        this.showSpinner = true;
        console.log('opencolumnsupdaterequest1');
        this.template.querySelector('c-psg_quoteline-lightning-datatable').opencolumnsupdaterequest();
        this.showSpinner = false;
    }
    //added for DPA
    @api
    opencolumnsDPArequest(){
        this.showSpinner = true;
        console.log('opencolumnsDPArequest123');
        this.template.querySelector('c-psg_quoteline-lightning-datatable').opencolumnsDPArequest();
        this.showSpinner = false;
    }
    @api
    closeupdaterequest(){
        this.template.querySelector('c-psg_quoteline-lightning-datatable').closeupdaterequest();
    }
    //added for DPA
    @api
    closedparequest(){
        this.template.querySelector('c-psg_quoteline-lightning-datatable').closedparequest();
    }
    
    connectedCallback(){
        //this.inProgressQuote = true;
        this.temptrue = true;
        //console.log('inside quote line details call back '+this.isQuoteLineEditable);
    }

    addnewquoteline(event){
        //event.preventDefault();
        console.log('addnewquoteline quotelinedetail');
        const selectEvent = new CustomEvent('addnewquoteline', {detail: event.detail});
        this.dispatchEvent(selectEvent);
    }
    handleCloseUpdateRequest(event){
        console.log('handleCloseUpdateRequest1');
        const selectEvent = new CustomEvent('closeupdaterequest', {
            detail: true
        });
        this.dispatchEvent(selectEvent);
    }

    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'PSG Quote Line - Submitted');
    } 

    addRow() {
        var isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal) {
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex, class: 'class'+this.keyIndex }];
            this.itemList = this.itemList.concat(newItem);
        }
    }
    @api
    sendupdaterequest(quoteMap,status){
        const returnValue = this.template.querySelector('c-psg_quoteline-lightning-datatable').sendupdaterequest(quoteMap,status);
        console.log('quoteMap '+JSON.stringify(quoteMap));
    }
    //added for DPA
    @api
    senddparequest(quoteMap,status,quoteType){
        const returnValue = this.template.querySelector('c-psg_quoteline-lightning-datatable').senddparequest(quoteMap,status,quoteType);
        console.log('quoteMap '+JSON.stringify(quoteMap));
    }
    //added for ALN
    @api
    sendalnrequest(quoteMap,status,quoteType){
        const returnValue = this.template.querySelector('c-psg_quoteline-lightning-datatable').sendalnrequest(quoteMap,status,quoteType);
        console.log('quoteMapALN '+JSON.stringify(quoteMap));
    }
    
    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    deleteRow(event) {
        console.log('delete id>',event.target.accessKey);
        //this.deleteList.push(event.target.accessKey);
        this.qlEditList = this.qlEditList.filter(function (element) {
            return element.Id !== event.target.accessKey;
        });
        deleteRecord(event.target.accessKey)
        .then(() => {
            this.showToast('Success','Quote Line was deleted','success');

        })
        .catch(error => {
            this.showToast('Error deleting record',error.body.message,'error');
        });
    }

    showToast(errTitle,msg,type){
        this.dispatchEvent(
            new ShowToastEvent({
                title: errTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }

    @api handleQLSubmit() {
        /*var isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
            console.log('elem>>',JSON.stringify(element));
        });*/
        if(this.isEdit){
            for(var i=0;i<this.qlEditList.length;i++){
                var inputCls='.'+this.qlEditList[i].Name;
                var qliRecs=this.template.querySelectorAll(inputCls);
                console.log(JSON.stringify(qliRecs));
                var qlRec={
                    sobjectType: 'SBQQ__QuoteLine__c',
                    Id:this.qlEditList[i].Id,
                    SBQQ__Quote__c:this.qlEditList[i].SBQQ__Quote__c
                };
                qliRecs.forEach(function(element){
                    qlRec[element.fieldName]=element.value;
                    console.log('test '+element.fieldName+'values '+element.value);
                })
                console.log(qlRec);
                this.qlList.push(qlRec);
            }
        }
        for(var i=0;i<this.itemList.length;i++){
            var inputCls='.'+this.itemList[i].class;
            var qliRecs=this.template.querySelectorAll(inputCls);
            var qlRec={
                sobjectType: 'SBQQ__QuoteLine__c',
                RecordTypeId: this.recordTypeId
            };
            qliRecs.forEach(function(element){
                qlRec[element.fieldName]=element.value;
                console.log('test '+element.fieldName+'values '+element.value);
            })
            console.log(qlRec);
            this.qlList.push(qlRec);
        }
        console.log('list>'+this.qlList);
        return this.qlList;
    }

}
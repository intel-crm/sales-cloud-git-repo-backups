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
        {fname:'SBQQ__Product__c',editable:true,required:true,label:'Product/Part#'},
        {fname:'core_cpq_requested_qty__c',editable:true,required:true,label:'EAU Quantity'},
        {fname:'core_cpq_years_nbr__c',editable:true,required:true,label:'# Years'},
        {fname:'price_requested_resale_amt__c',editable:true,required:false,label:'Requested Resale'},
        {fname:'core_cpq_production_dt__c',required:true,label:'Production Start Date'},
        {fname:'core_cpq_reg_number_txt__c',editable:true,required:false,label:'PSG Reg #'}  
    ];
    @api
    validateopn(){
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
        this.template.querySelector('c-psg_quoteline-lightning-datatable').sendValidationResult(data);
    }
    @api
    opencolumnsupdaterequest(){
        this.showSpinner = true;
        this.template.querySelector('c-psg_quoteline-lightning-datatable').opencolumnsupdaterequest();
        this.showSpinner = false;
    }
    //added for DPA
    @api
    opencolumnsDPArequest(){
        this.showSpinner = true;
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
        this.temptrue = true;
    }

    addnewquoteline(event){
        const selectEvent = new CustomEvent('addnewquoteline', {detail: event.detail});
        this.dispatchEvent(selectEvent);
    }
    handleCloseUpdateRequest(event){
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
    }
    //added for DPA
    @api
    senddparequest(quoteMap,status,quoteType){
        const returnValue = this.template.querySelector('c-psg_quoteline-lightning-datatable').senddparequest(quoteMap,status,quoteType);
    }
    //added for ALN
    @api
    sendalnrequest(quoteMap,status,quoteType){
        const returnValue = this.template.querySelector('c-psg_quoteline-lightning-datatable').sendalnrequest(quoteMap,status,quoteType);
    }
    
    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    deleteRow(event) {
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
        if(this.isEdit){
            for(var i=0;i<this.qlEditList.length;i++){
                var inputCls='.'+this.qlEditList[i].Name;
                var qliRecs=this.template.querySelectorAll(inputCls);
                var qlRec={
                    sobjectType: 'SBQQ__QuoteLine__c',
                    Id:this.qlEditList[i].Id,
                    SBQQ__Quote__c:this.qlEditList[i].SBQQ__Quote__c
                };
                qliRecs.forEach(function(element){
                    qlRec[element.fieldName]=element.value;
                })
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
            })
            this.qlList.push(qlRec);
        }
        return this.qlList;
    }

}
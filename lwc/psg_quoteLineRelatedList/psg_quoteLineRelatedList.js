import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { loadStyle } from 'lightning/platformResourceLoader';
import myStaticStyles from '@salesforce/resourceUrl/psg_customQuoteLineCss';
import { fireEvent } from 'c/pubsub';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';

export default class psg_quoteLineRelatedList extends NavigationMixin(LightningElement) {
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT }) objectInfo;
    @wire(CurrentPageReference) pageRef;

    @api recordId;
    @track qlEditList=[];
    @track isEdit=false;
    @track distyPercent;
    @track brokenCost;
    @track showSpinner=false;
    @track showData=false;
    @track allSelected=false;
    @track costTypeSwitch=true;
    @track costType1=true;
    @track costType2=false;

    @track qlColumns=[
        {fname:'PSG_Product_Nm__c',required:true,label:'Product/Part#'},
        {fname:'PSG_Product_Family_Txt__c',required:false,label:'Product Family'},
        {fname:'PSG_Quote_Line_Type_txt__c',required:false,label:'Line Type'},
        {fname:'PSG_Suggested_Resale_Amt__c',required:true,label:'Suggested Resale'},
        {fname:'PSG_Distributor_Margin_Pct__c',required:true,label:'Distributor Margin %'},
        {fname:'PSG_BrokenCost_Amt__c',required:false,label:'Broken Cost'},
        {fname:'PSG_Requested_Qty_qty__c',required:false,label:'Requested Quantity'},
        {fname:'PSG_Requested_Resale_Amt__c',required:false,label:'Requested Resale'},
        {fname:'SBQQ__ListPrice__c',required:true,label:'List Unit Price'},
        {fname:'PSG_Std_Fwd_Cost_Amt__c',required:false,label:'Std/Fwd Cost'},
        {fname:'PSG_Production_Dt__c',required:true,label:'Production Start Date'},
        {fname:'PSG_Pricing_Start_Date_dt__c',required:false,label:'Pricing Start Date'},
        {fname:'PSG_Pricing_End_Date_Dt__c',required:false,label:'Pricing End Date'},
        {fname:'PSG_Reg_Number_txt__c',required:false,label:'PSG Reg #'},
    ];


    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'PSG Quote Line - Create');
    } 

    connectedCallback(){
        //loadStyle(this, myStaticStyles + '.css')
        this.getQLData(this.recordId);
    }

    

    enableEdit(){
        this.isEdit=true;
    }

    cancelEdit(){
        this.isEdit=false;
    }

    setInputType(event){
        let type=event.target.value;
        if(type=='DistyMargin'){
            this.costTypeSwitch=true;
            this.costType1=true;
            this.costType2=false;
        }
        else if(type=='BrokenCost'){
            this.costTypeSwitch=false;
            this.costType1=false;
            this.costType2=true;
        }
    }

    handleAllSelected(event) {
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                fireEvent(this.pageRef, "selectAllSwitch", event.target.checked);
            }
        }
    }

    handleChildSelect(event) {
        var rowId=event.detail.dataId;
        this.allSelected=this.getAllRows();
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked=this.allSelected;
            }
        }
    }

    getAllRows(){
        var allSelectedFlag = true;
        this.template.querySelectorAll("c-psg_quote-line-related-list-child").forEach(element => {
            allSelectedFlag = allSelectedFlag && element.handleSelectedRows().isSelected;
        });
        return allSelectedFlag;
    }

    handleChildDelete(){
        this.getQLData(this.recordId);
    }

    handleChange(event){
        if(event.target.name=='DistyMargin'){
            this.distyPercent=event.detail.value;
        }
        else if(event.target.name=='BrokenCost'){
            this.brokenCost=event.detail.value;
        }
    }

    massUpdateRecord(){ 
        let selectedRecords = [];
        this.template.querySelectorAll("c-psg_quote-line-related-list-child").forEach(element => {
            let rowDetails=element.handleSelectedRows();
            if(rowDetails.isSelected){
                selectedRecords.push({
                    Id:rowDetails.qlId,
                });
            }
        });

        if(selectedRecords.length<1){
            this.showToast('No rows selected','Please select atleast one row to update.','error');
        }
        else{
            if((this.costTypeSwitch==true && (this.distyPercent==null || this.distyPercent==undefined)) ||
            this.costTypeSwitch==false && (this.brokenCost==null || this.brokenCost==undefined)) {
                this.showToast('No value entered','Please enter a value to apply','error');
            }
            else{
                if(this.costTypeSwitch){
                    fireEvent(this.pageRef, "massUpdateDMSwitch", this.distyPercent);
                }
                else{
                    fireEvent(this.pageRef, "massUpdateBCSwitch", this.brokenCost);
                }
            }
        }
    }  

    saveRows(){
        var qlRecList=[];
        this.template.querySelectorAll("c-psg_quote-line-related-list-child")
        .forEach(element => {
            var rec=element.handleQLSubmit();
            qlRecList.push(rec);
        });
        this.apexUpdateCall(qlRecList);
    }

    showToast(msgTitle,msg,type){
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }

    navigateToNewQL() {
        const defaultValues = encodeDefaultFieldValues({
            SBQQ__Quote__c : this.recordId,
            PSG_Disti_Pct__c : 10
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                defaultFieldValues: defaultValues,
                recordTypeId: this.recordTypeId,
                navigationLocation: 'RELATED_LIST'
            }
        });
    }

}
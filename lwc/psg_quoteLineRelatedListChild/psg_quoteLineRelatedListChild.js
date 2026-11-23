import { LightningElement,track,wire,api } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import fetchContractedPrice from '@salesforce/apex/PSG_QuoteRequestController.fetchContractedPrice';

export default class Psg_quoteLineRelatedListChild extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api item;
    @api isSelected;
    @api isEdit;
    @track showRows=false;
    @track rowSelected=false;
    @track showLoadingSpinner = true;
    @track qlColumns=[
        {fname:'PSG_Product_Nm__c',required:true,label:'Product/Part#'},
        {fname:'PSG_Product_Family_Txt__c',required:false,label:'Product Family'},
        {fname:'PSG_Contracted_Price__c',required:false,label:'Contracted Price'},
        {fname:'SBQQ__ListPrice__c',required:true,label:'List Unit Price'},
        {fname:'PSG_Quote_Line_Type_txt__c',required:false,label:'Line Type'},
        {fname:'PSG_Suggested_Resale_Amt__c',required:true,label:'Suggested Resale'},
        {fname:'PSG_Distributor_Margin_Pct__c',required:true,label:'Distributor Margin %'},
        {fname:'PSG_BrokenCost_Amt__c',required:false,label:'Broken Cost'},
        {fname:'PSG_Requested_Qty_qty__c',required:false,label:'Requested Quantity'},
        {fname:'PSG_Requested_Resale_Amt__c',required:false,label:'Requested Resale'},        
        {fname:'PSG_Std_Fwd_Cost_Amt__c',required:false,label:'Std/Fwd Cost'},
        {fname:'PSG_Production_Dt__c',required:true,label:'Production Start Date'},
        {fname:'PSG_Pricing_Start_Date_dt__c',required:false,label:'Pricing Start Date'},
        {fname:'PSG_Pricing_End_Date_Dt__c',required:false,label:'Pricing End Date'},
        {fname:'PSG_Reg_Number_txt__c',required:false,label:'PSG Reg #'},
        {fname:'PSG_Account_nm__c',required:false,label:'Account'},
    ];

    
    connectedCallback(){
        console.log('connectedCallback inside');
        if(this.item!=undefined && this.item!=null){
            this.showRows=true;
            for(var i=0;i<this.qlColumns.length;i++){
                this.qlColumns[i].value= this.item[this.qlColumns[i].fname];
            }
        }
        registerListener('selectAllSwitch', this.handleSelectAllChange, this);
        registerListener('massUpdateDMSwitch', this.handleMassDMUpdate, this);
        registerListener('massUpdateBCSwitch', this.handleMassBCUpdate, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleMassDMUpdate(distyPercent){
        if(this.rowSelected){
            var dMarginIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Distributor_Margin_Pct__c");
            var bCostIndex = this.qlColumns.findIndex(col => col.fname == "PSG_BrokenCost_Amt__c");
            var resaleIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Suggested_Resale_Amt__c");
            
            var suggestedResale=this.qlColumns[resaleIndex].value;
            var brokenCost= suggestedResale - (suggestedResale * (distyPercent/100));
            this.qlColumns[dMarginIndex].value=distyPercent;
            this.qlColumns[bCostIndex].value=brokenCost.toFixed(2);
        }
    }

    handleMassBCUpdate(brokenCost){
        if(this.rowSelected){
            var dMarginIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Distributor_Margin_Pct__c");
            var bCostIndex = this.qlColumns.findIndex(col => col.fname == "PSG_BrokenCost_Amt__c");
            var resaleIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Suggested_Resale_Amt__c");

            var suggestedResale=this.qlColumns[resaleIndex].value;
            this.qlColumns[bCostIndex].value=brokenCost;
            var distyMargin= ((suggestedResale - brokenCost)/suggestedResale)*100;
            this.qlColumns[dMarginIndex].value=distyMargin.toFixed(2);
        }
    }

    handleSelectAllChange(allSelected){
        allSelected;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = allSelected;
                this.rowSelected=allSelected;
            }
        }
    }
    
    handleRecordFormDataLoad(event){
        this.showLoadingSpinner = false;
    }
    handleSelectChange(event){
        this.rowSelected=event.target.checked;
        const customEvt= new CustomEvent('childselection', {
            detail:{isSelected:event.target.checked,dataId:event.target.dataId}
        });
        this.dispatchEvent(customEvt);
    }

    
    // //method to get contactracted price
    // @track contracedPriceReceived;
    // getContractedPrice(id){
    //     fetchContractedPrice({contractedPriceId:id}).then(result=>{
    //        console.log('Data received '+result);
    //        this.contracedPriceReceived = result;
    //     })
    //     .catch(error=>{
    //         console.log('no records found'+error);
    //     })
    // }

    handleChange(event){
        var fname=event.target.fieldName;
        var index=this.qlColumns.findIndex(col => col.fname == fname);
        this.qlColumns[index].value=event.target.value;

        var dMarginIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Distributor_Margin_Pct__c");
        var bCostIndex = this.qlColumns.findIndex(col => col.fname == "PSG_BrokenCost_Amt__c");
        var resaleIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Suggested_Resale_Amt__c");
        var contractedPriceIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Contracted_Price__c");
        console.log('contractedPriceIndex >> +'+contractedPriceIndex);
        var listPriceIndex = this.qlColumns.findIndex(col => col.fname == "SBQQ__ListPrice__c");
        if(fname=='PSG_Suggested_Resale_Amt__c' || fname=='PSG_Distributor_Margin_Pct__c' ){
             //Broken cost = Suggested resale - (Suggested resale * (distributor margin %/100))
            var suggestedResale=this.qlColumns[resaleIndex].value;
            var distyMargin=this.qlColumns[dMarginIndex].value;
            var brokenCost= suggestedResale - (suggestedResale * (distyMargin/100));
            this.qlColumns[bCostIndex].value=brokenCost.toFixed(2);
        }
        else if(fname=='PSG_BrokenCost_Amt__c'){
            // Distributor margin =(Suggested resale - broken cost)/suggested resale
            var suggestedResale=this.qlColumns[resaleIndex].value;
            var brokenCost=this.qlColumns[bCostIndex].value;
            var distyMargin= ((suggestedResale - brokenCost)/suggestedResale)*100;
            this.qlColumns[dMarginIndex].value=distyMargin.toFixed(2);
        }else if(fname=='PSG_Contracted_Price__c'){
            console.log('Your are inside PSG_Contracted_Price__c condition');
            var contractedPriceId = this.qlColumns[contractedPriceIndex].value;
            //call the method from here
            fetchContractedPrice({contractedPriceId:contractedPriceId}).then(result=>{
                console.log('Data received '+result);
                var contractedPrice = result;
                console.log('Contracted Price :'+contractedPrice);
                this.qlColumns[listPriceIndex].value = contractedPrice;
                console.log('>>'+contractedPrice+ ' '+ contractedPriceId );

             })
             .catch(error=>{
                 console.log('no records found'+error);
             })
           

        }
    }

    deleteRow(event) {
        this.showLoadingSpinner = true;
        console.log('delete id>',event.target.accessKey);
        deleteRecord(event.target.accessKey)
        .then(() => {
            this.showLoadingSpinner = false;
            this.showToast('Success','Quote Line was deleted','success');
            const customEvt= new CustomEvent('childdeletion', {
                detail:{recId:event.target.accessKey}
            });
            this.dispatchEvent(customEvt);
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            this.showToast('Error deleting record',error.body.message,'error');
        });
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

    @api handleQLSubmit() {
        var inputCls='.'+this.item.Name;
        var qliRecs=this.template.querySelectorAll(inputCls);
        var qlRec={
            sobjectType: 'SBQQ__QuoteLine__c',
            Id:this.item.Id,
            SBQQ__Quote__c:this.item.SBQQ__Quote__c
        };
        qliRecs.forEach(function(element){
            qlRec[element.fieldName]=element.value;
        })
        return qlRec;
    }

    @api handleSelectedRows(){
        return {isSelected:this.rowSelected,qlId:this.item.Id};
    }

    viewRecord(event) {
        // Navigate to Quote Line record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "SBQQ__QuoteLine__c",
                "actionName": "view"
            },
        });
    }
}
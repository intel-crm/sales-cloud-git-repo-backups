import { LightningElement, api, track,wire } from 'lwc';
import getRebateClaimLineItems from '@salesforce/apex/PCC_RebateClaimApproveController.getRebateClaimLineItems'; // Replace with your actual Apex method
import updateClaimLineItemsDataList from '@salesforce/apex/PCC_RebateClaimApproveController.updateClaimLineItemsDataList';
import get6QPSData from '@salesforce/apex/PCC_RebateClaimApproveController.get6QPSData';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import RejectionCode_FIELD from '@salesforce/schema/PCC_Rebate_Claim_Line_Item__c.PCC_Rejection_Code__c';
import Rebate_Claim_LineItem_OBJECT from '@salesforce/schema/PCC_Rebate_Claim_Line_Item__c';
import PCC_ApproveReject_MaxReach from '@salesforce/label/c.PCC_ApproveReject_MaxReach';
import PCC_ApproveReject_RejComment from '@salesforce/label/c.PCC_ApproveReject_RejComment';
import PCC_ApproveReject_RejCode from '@salesforce/label/c.PCC_ApproveReject_RejCode';
import PCC_ApproveReject_SubQty from '@salesforce/label/c.PCC_ApproveReject_SubQty';
import PCC_ApproveReject_SchQty from '@salesforce/label/c.PCC_ApproveReject_SchQty';

const RecordsPerPage = 100;

export default class core_PCC_RebateClaim_ApproveReject extends LightningElement {
    @api recordId;
    @track lineItems = [];
    @track error;
    @track isModalOpen = true;
    disableSaveBtn = false;
    @api hasData;
    @track disableRejFields = false;
    @track disableAppFields = false;
    @track picklistOptions= [];
    errorList = [];
    @track isLoading = true;
    @track errormsg = '';
    errorMessageToDisplay='';
    rebateClaimLIrecordTypeId;
    selectedItems = 0;
    //PAGINATION
    @track totalRecordCount;
    @track pageNumber;
    totalPageCount;
    startRecord;
    endRecord;
    end = false;
    records = [];
    //@track oppId ;
    //productIds = new Set(); ;
    @track AllApprovechecking = false;
    @track AllRejectchecking = false;
    allAppCheckedInPageNo = [];
    allRejCheckedInPageNo = [];
    delayTimeout;
    quotLineId =[];
    //prodIdQtyMap = new Map();
    rebateAppQtyQutlineNo = new Map();
    rebateRejQtyQutlineNo = new Map();
    @track value;
    @track sumationOfrebateQty;
    @track resultofget6QPSSchQty = '';
    @track resultofget6QPSSubQty = '';
    @track approvedDdata = false;
    //@track errorMsgWrpsubQty = '';
    //@track errorMsgWrpallqty = '';


    @wire(getObjectInfo, { objectApiName: Rebate_Claim_LineItem_OBJECT })
    rebateClaimLineItemInfo({ error, data }) {
        if (data) {
            this.rebateClaimLIrecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.rebateClaimLIrecordTypeId = undefined;
        }
    }

    @wire(getPicklistValues,{ recordTypeId: '$rebateClaimLIrecordTypeId', fieldApiName: RejectionCode_FIELD})
    picklistResults({ error, data }) {
        if (data) {
            this.picklistOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.picklistOptions = undefined;
        }
    }

    connectedCallback() {
        this.fetchLineItems();
    }

    get disableButton() { 
        return !(this.selectedItems>0 && this.selectedItems<=100 && !(this.disableSaveBtn));
    }

    selectedItemsCountToast(){
        if(this.selectedItems === 100){
            const evnt = new ShowToastEvent({
                    title : PCC_ApproveReject_MaxReach,
                    variant : 'Warning',
                    mode : 'dismissable'
            });
            this.dispatchEvent(evnt);
        }
        else if(this.selectedItems > 100){
            const evnt = new ShowToastEvent({
                    title : PCC_ApproveReject_MaxReach,
                    variant : 'Error',
                    mode : 'dismissable'
            });
            this.dispatchEvent(evnt);
        }
    }

    fetchLineItems() {
        getRebateClaimLineItems({ rebateClaimId: this.recordId })
            .then(result => {
                if (result && result.length > 0) {
                    this.totalRecordCount = result.length;
                    this.pageNumber = 1;
                    this.totalPageCount = Math.ceil(this.totalRecordCount / RecordsPerPage);
                    console.log('AA Items fetched successfully', result);
                    this.records = result.map((item, index) => ({
                        ...item,
                        serialNumber: index + 1,
                        approve: false,
                        reject: false,
                        oppURL: '/lightning/r/' + item.PCC_Opportunity__c + '/view',
                        prodURL:'/lightning/r/' + item.PCC_Product__c + '/view',
                        qliURL: '/lightning/r/' + item.PCC_Quote_Line_Number__c + '/view',
                        rejectionCode: '',
                        rejectionComment: '',
                        disableFields: true
                    }));
                    this.error = undefined;
                    console.log('AA 95 this.records',this.totalPageCount, this.records);
                   
                    this.preparePaginationList();
                }/*
                else if(result && result.errorMsg !== '' && result.hasAccess === false) {
                    this.hasData = false;
                    this.errormsg = result.errorMsg ;
                    this.isLoading = false;
                    clearTimeout(this.delayTimeout);
                    this.delayTimeout = setTimeout(() => {
                        this.closeModal();
                    }, 5000);
                }
                else if(result && result.errorMsg !== '' && result.hasAccess === true){
                    this.hasData = false;
                    this.errormsg = result.errorMsg ;
                    this.isLoading = false;
                    clearTimeout(this.delayTimeout);
                    this.delayTimeout = setTimeout(() => {
                        this.closeModal();
                    }, 5000);
                }*/

            })
            .catch(error => {
                console.log('AA Error', error);
                this.error = error;
                this.records = undefined;
                this.isLoading = false;
            });
    }

    handleAllApproveChange(event) {
        this.template.querySelector('[data-id="allApprove"]').blur();
        let blankRow = this.lineItems;
        let fullBlankRow = this.records;
        const recEventName = ((this.pageNumber-1)*100);
        this.AllApprovechecking =  (event.target.checked === true)? true :false;
        if(event.target.checked === true) {
            this.allAppCheckedInPageNo.push(this.pageNumber);
        }
        else if(event.target.checked === false && this.allAppCheckedInPageNo.includes(this.pageNumber)){            
            const index = this.allAppCheckedInPageNo.indexOf(this.pageNumber);
            this.allAppCheckedInPageNo.splice(index, 1);
        }
        for(let i = 0; i < blankRow.length; i++) {
            blankRow[i].approve = event.target.checked;
            fullBlankRow[recEventName+i].approve = event.target.checked;
            blankRow[i].disableFields = true;
            this.selectedItems = (event.target.checked === true)? this.selectedItems+1 :this.selectedItems-1;
            if(blankRow[i].reject === true){
                blankRow[i].reject = false;
                fullBlankRow[recEventName+i].reject = false;
            }
            if(blankRow[i].rejectionCode !== ''){
                blankRow[i].rejectionCode = '';
                fullBlankRow[recEventName+i].rejectionCode = '';
            }
            if(blankRow[i].rejectionComment!== ''){
                blankRow[i].rejectionComment = '';
                fullBlankRow[recEventName+i].rejectionComment = '';
            }
        }
        this.lineItems = blankRow;
        this.records = fullBlankRow;
        if(this.selectedItems>=100){
            this.selectedItemsCountToast();
        }
    }

    handleAllRejectChange(event) {
        this.template.querySelector('[data-id="allReject"]').blur();
        let blankRow = this.lineItems;
        let fullBlankRow = this.records;
        const recEventName = ((this.pageNumber-1)*100);
        this.AllRejectchecking = (event.target.checked === true)? true :false;
        if(event.target.checked === true) {
            this.allRejCheckedInPageNo.push(this.pageNumber);
        }
        else if(event.target.checked === false && this.allRejCheckedInPageNo.includes(this.pageNumber)){            
            const index = this.allRejCheckedInPageNo.indexOf(this.pageNumber);
            this.allRejCheckedInPageNo.splice(index, 1);
        }
        for(let i = 0; i < blankRow.length; i++) {
            blankRow[i].reject = event.target.checked;
            fullBlankRow[recEventName+i].reject = event.target.checked;
            blankRow[i].disableFields = (event.target.checked === true) ? false : true;
            this.selectedItems = (event.target.checked === true)? this.selectedItems+1 :this.selectedItems-1;
            if(blankRow[i].approve === true){
                blankRow[i].approve = false;
                fullBlankRow[recEventName+i].approve = false;
            }
        }
        this.lineItems = blankRow;
        this.records = fullBlankRow;
        if(this.selectedItems>=100){
            this.selectedItemsCountToast();
        }
    }

    handleSingleApproveChange(event) {
        this.template.querySelector('[data-id="approve"]').blur();
        const eventName = event.target.name;
        const recEventName = ((this.pageNumber-1)*100)+eventName;
        let blankRow = this.lineItems;
        let fullBlankRow = this.records;
        this.selectedItems = (event.target.checked === true) ? this.selectedItems+1 : this.selectedItems-1;
        if(this.selectedItems>=100){
            this.selectedItemsCountToast();
        }
        blankRow[eventName].approve = event.target.checked;
        blankRow[eventName].disableFields = true;
        fullBlankRow[recEventName].approve = event.target.checked;
        if(blankRow[eventName].rejectionCode !== ''){
            blankRow[eventName].rejectionCode = '';
            fullBlankRow[recEventName].rejectionCode = '';
        }
        if(blankRow[eventName].rejectionComment !== ''){
            blankRow[eventName].rejectionComment = '';
            fullBlankRow[recEventName].rejectionComment = '';
        }
        this.lineItems = blankRow;
        this.records = fullBlankRow;
    }

    handleSingleRejectChange(event) {
        this.template.querySelector('[data-id="reject"]').blur();
        const eventName = event.target.name;
        const recEventName = ((this.pageNumber-1)*100)+eventName;
        let blankRow = this.lineItems;
        let fullBlankRow = this.records;
        this.selectedItems = (event.target.checked === true) ? this.selectedItems+1 : this.selectedItems-1;
        if(this.selectedItems>=100){
            this.selectedItemsCountToast();
        }
        blankRow[eventName].reject = event.target.checked;
        blankRow[eventName].disableFields = (event.target.checked === true) ? false : true;
        fullBlankRow[recEventName].reject = event.target.checked;
        this.lineItems = blankRow;
        this.records  = fullBlankRow;
    }

    handleRejCodeChange(event) {
        const eventName = event.target.name
        let blankRow = this.lineItems;
        blankRow[eventName].rejectionCode = event.detail.value;
        this.lineItems = blankRow;
    }

    handleRejCommChange(event) {
        const eventName = event.target.name
        let blankRow = this.lineItems;
        blankRow[eventName].rejectionComment = event.target.value;
        this.lineItems = blankRow;
    }

    closeModal() {
        //this.dispatchEvent(new CloseActionScreenEvent());
        const closeModalEvent = new CustomEvent("modalclose");
        this.dispatchEvent(closeModalEvent);
    }

    async handleSave(event) {
        let blankRow = this.records;
        let rebateClaimLineItemsDataList = [];
        //let rebateClaimLineItemsIdList = [];
        let submittedRCLI = 0;
        let emptyRCode = [];
        let emptyRComment = [];
        this.errorList = [];
        this.disableSaveBtn = true;
        this.isLoading = true;
        this.rebateAppQtyQutlineNo.clear();
        this.rebateRejQtyQutlineNo.clear();
        for(let i = 0; i < blankRow.length; i++){
            if(blankRow[i].approve === true || blankRow[i].reject === true) {
                let rcData = new Object();
                
                
                if(blankRow[i].approve === true){
                    this.approvedDdata = true;
                    rcData.PCC_Status__c=                 'Approved';
                    rcData.PCC_Approved_Rebate_Amount__c=  blankRow[i].PCC_Claimed_Rebate_Amount__c;
                    rcData.PCC_Rejection_Code__c=          blankRow[i].rejectionCode;
                    rcData.PCC_Rejection_Comments__c=      blankRow[i].rejectionComment;

                    if(this.rebateAppQtyQutlineNo.has(blankRow[i].PCC_Quote_Line_Number__c)){
                        this.sumationOfrebateQty=0;
                            this.sumationOfrebateQty=blankRow[i].PCC_Quantity__c + this.rebateAppQtyQutlineNo.get(blankRow[i].PCC_Quote_Line_Number__c);
                            this.rebateAppQtyQutlineNo.set(blankRow[i].PCC_Quote_Line_Number__c,this.sumationOfrebateQty);
                        }
                    else{
                            this.rebateAppQtyQutlineNo.set(blankRow[i].PCC_Quote_Line_Number__c, blankRow[i].PCC_Quantity__c);
                        }  
                    console.log('rebateAppQtyQutlineNo Data',this.rebateAppQtyQutlineNo);
                    
                } 
                else if(blankRow[i].reject === true){

                    if(this.rebateRejQtyQutlineNo.has(blankRow[i].PCC_Quote_Line_Number__c)){
                        this.sumationOfrebateQty=0;
                            this.sumationOfrebateQty=blankRow[i].PCC_Quantity__c + this.rebateRejQtyQutlineNo.get(blankRow[i].PCC_Quote_Line_Number__c);
                            this.rebateRejQtyQutlineNo.set(blankRow[i].PCC_Quote_Line_Number__c,this.sumationOfrebateQty);
                        }
                    else{
                            this.rebateRejQtyQutlineNo.set(blankRow[i].PCC_Quote_Line_Number__c, blankRow[i].PCC_Quantity__c);
                        }  
                    console.log('rebateRejQtyQutlineNo Data',this.rebateRejQtyQutlineNo);
                    
                    if(blankRow[i].rejectionCode === ''){
                        emptyRCode.push(blankRow[i].serialNumber);
                    }
                    if(blankRow[i].rejectionComment === ''){
                        emptyRComment.push(blankRow[i].serialNumber);
                    }
                    else if(blankRow[i].rejectionCode !== '' && blankRow[i].rejectionComment !== '') {
                        rcData.PCC_Status__c=              'Rejected';
                        rcData.PCC_Rejection_Code__c=      blankRow[i].rejectionCode;
                        rcData.PCC_Rejection_Comments__c=  blankRow[i].rejectionComment;
                    }
                }

                rcData.Id=                                 blankRow[i].Id;
                rcData.PCC_Invoice_Date__c = blankRow[i].PCC_Invoice_Date__c;;
                rcData.PCC_Quantity__c = blankRow[i].PCC_Quantity__c;
                rcData.PCC_Quote_Line_Number__c = blankRow[i].PCC_Quote_Line_Number__c;
                rebateClaimLineItemsDataList.push(rcData);
                //rebateClaimLineItemsIdList.push(rcData.Id);
            }
            else{
                submittedRCLI++ ;
            }   
        }
        console.log('rebateAppQtyQutlineNo Data',this.rebateAppQtyQutlineNo);
        console.log('rebateRejQtyQutlineNo Data',this.rebateRejQtyQutlineNo);
        if(this.approvedDdata==true){
            await this.get6QPSData();
            console.log('New class work');
        }
        console.log('New class not work');


        if(this.resultofget6QPSSchQty != ''){
            let error = PCC_ApproveReject_SchQty+' '+ this.resultofget6QPSSchQty;
            this.errorList.push(error);
        } 
        if(this.resultofget6QPSSubQty != ''){
            let error = PCC_ApproveReject_SubQty+' '+ this.resultofget6QPSSubQty;
            this.errorList.push(error);
        }
        if(emptyRCode.length > 0) {
            let error = PCC_ApproveReject_RejCode+' '+ emptyRCode;
            this.errorList.push(error);
        }
        if(emptyRComment.length > 0) {
            let error = PCC_ApproveReject_RejComment+' '+ emptyRComment;
            this.errorList.push(error);
        }
        if(this.errorList.length>0) {
            this.template.querySelector('c-custom-toast').showToast("sticky");
            this.disableSaveBtn = false;
            this.isLoading = false;
        }

        console.log('AA errorList', this.errorList);
        console.log('AA rebateClaimLineItemsDataList',submittedRCLI, rebateClaimLineItemsDataList);
        if(rebateClaimLineItemsDataList.length > 0 && emptyRCode.length == 0 && emptyRComment.length ==0 && (this.resultofget6QPSSchQty=='' && this.resultofget6QPSSubQty=='')) {
            updateClaimLineItemsDataList({rcliDataString: JSON.stringify(rebateClaimLineItemsDataList) , rebateClaimId: this.recordId, submittedRCLI: submittedRCLI})
            .then(result => {
                if(result == true ){
                    this.isLoading = false;
                    this.closeModal();
                    const evnt = new ShowToastEvent({
                        message: 'Claim Line Item updated successfully!!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evnt);
                    
                    window.clearTimeout(this.delayTimeout);
                    this.delayTimeout = setTimeout(() => {
                        window.location.reload();
                    }, 500);          
                }
            })
           .catch(error => {
                this.errorMessageToDisplay = '';
                this.disableSaveBtn = false;
                if(error.body){
                    console.log('error.body',error);
                    if (Array.isArray(error.body)) {
                        this.errorMessageToDisplay += error.body.map(e => e.message).join(', ');
                    }
                    else if(typeof error.body === 'object'){
                        let fieldErrors = error.body.fieldErrors;
                        let pageErrors = error.body.pageErrors;
                        let duplicateResults = error.body.duplicateResults;
                        let exceptionError = error.body.message;
    
                        if(exceptionError && typeof exceptionError === 'string') {
                            this.errorMessageToDisplay += exceptionError;
                        }
                        if(fieldErrors){
                            for(var fieldName in fieldErrors){
                            let errorList = fieldErrors[fieldName];
                            for(var i=0; i < errorList.length; i++){
                                this.errorMessageToDisplay +=  errorList[i].message + ' ';
                            }
                            }
                        }
                        if(pageErrors && pageErrors.length > 0){
                            for(let i=0; i < pageErrors.length; i++){
                            this.errorMessageToDisplay +=  pageErrors[i].message;
                            }
                        }
                        if(duplicateResults && duplicateResults.length > 0){
                            this.errorMessageToDisplay += 'duplicate result error';
                        }
                    }  
                }
                console.error('AA err  ', this.errorMessageToDisplay);
                this.isLoading = false;
                const evnt = new ShowToastEvent({
                    title : 'Unexpected Error!',
                    message : this.errorMessageToDisplay,
                    variant : 'Error',
                    mode : 'sticky'
                });
                this.dispatchEvent(evnt);
            });
        }
    
    }

    handleClick(event) {  
        this.isLoading = true;
        let label = event.target.label;
        if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } 
    }

    handleNext() {
        this.pageNumber += 1;
        this.AllApprovechecking = (this.allAppCheckedInPageNo.includes(this.pageNumber)) ? true : false;
        this.AllRejectchecking = (this.allRejCheckedInPageNo.includes(this.pageNumber)) ? true : false;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNumber -= 1;
        this.AllApprovechecking = (this.allAppCheckedInPageNo.includes(this.pageNumber)) ? true : false;
        this.AllRejectchecking =  (this.allRejCheckedInPageNo.includes(this.pageNumber)) ? true : false;
        this.preparePaginationList();
    }

    preparePaginationList() {
        let begin = (this.pageNumber - 1) * parseInt(RecordsPerPage);
        let end = parseInt(begin) + parseInt(RecordsPerPage);
        this.lineItems = this.records.slice(begin, end);
        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecordCount ? this.totalRecordCount : end;
        this.end = end > this.totalRecordCount ? true : false;
        console.log('AA this.lineItems',this.lineItems);
        console.log('AA begin end ',begin,end,this.startRecord,this.endRecord,this.end);
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
            this.isLoading = false;
        }, 500);
    }

    disableEnableActions() {
        let buttons = this.template.querySelectorAll('[data-id="pgnBtn"]');
        console.log('AA buttons', buttons);
        buttons.forEach(bun => {
            if (bun.label === "Previous") {
                bun.disabled = this.pageNumber === 1 ? true : false;
            }else if (bun.label === "Next") {
                bun.disabled = this.pageNumber === this.totalPageCount ? true : false;
            } 
        });
    }

    async get6QPSData(){
        //this.resultofget6QPSData ='';
        //const str =JSON.stringify(this.rebateAppQtyQutlineNo);
        const appobj = [...this.rebateAppQtyQutlineNo].reduce((arr, [key, value]) => {
            arr[key] = value;
           return arr;
         }, {});

        const rebateAppqtyQLI = JSON.stringify(appobj);

         const rejobj = [...this.rebateRejQtyQutlineNo].reduce((arr, [key, value]) => {
            arr[key] = value;
           return arr;
         }, {});

        const rebaterejqtyQLI = JSON.stringify(rejobj);

        console.log('New Data'+rebateAppqtyQLI);

        const result = JSON.parse(JSON.stringify(await  get6QPSData({rebateAppQtyQutlineNostr:rebateAppqtyQLI,rebateRejQtyQutlineNostr:rebaterejqtyQLI})));

        //this.errorMsgWrpallqty = result.errorMsgWrpallqty;
        //this.errorMsgWrpsubQty = result.errorMsgWrpsubQty;
        //console.log(this.errorMsgWrpallqty,this.errorMsgWrpsubQty);
        this.resultofget6QPSSchQty =  result.errorMsgWrpallqty ;
        this.resultofget6QPSSubQty =  result.errorMsgWrpsubQty ;
        console.log('result',result);
        //console.log('returned value',this.resultofget6QPSData);
    }

}
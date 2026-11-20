import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import {loadStyle} from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import checkCaseSubCatEDQRules from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.checkCaseSubCatEDQRules'; // krishna
import addEnvironmentVariables from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.addEnvironmentVariables';
import getEnvironmentVariables_CaseCat from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.getEnvironmentVariables_CaseCat'; // krishna
import Core_IPS_Lightning_Base_URL from '@salesforce/label/c.Core_IPS_Lightning_Base_URL';
export default class Core_IPS_CaseSubCatAddEnvDetails_Lex extends NavigationMixin(LightningElement){
    columns = [
        { label: 'Question No', fieldName: 'Name' },
        { label: 'Question', fieldName: 'Core_IPS_Question', type: 'text' },
        { label: 'Required', fieldName: 'required', type: 'boolean',editable:true },
        { label: 'Agent Only', fieldName: 'agentOnly', type: 'boolean',editable:true },
        { label: 'Parent Question', fieldName: 'ParentQuestion', type: 'text' },
    ];
    
    tableData; 
    wiredRec=[];
    showData;
    spinner=false;
     updatedTabledata=[];   
    fldsItemValues =[];
    searchFldsItemValues=[];
    selectedEdqs=[];
    @track type = 'All data';
    @track isloading = true;
    rowLimit =10;
    rowOffSet=0;
    recordId;
    temprecid;
    cnt=0;
    alledqs;
    switchView;
    searchResult;
    isAccess = true;
    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1 && this.recordId != this.temprecid){
            window.location.reload();
        }
    }

    getrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }
    }


    connectedCallback(){
        this.recordId = this.getrecordId();
        this.cnt = 1;
        this.temprecid = this.recordId;
        this.checkConditions();
        this.RefreshValues();
     loadStyle(this, Core_IPS_Upload_Attachment_LEX)
            .then(result => {});
    
    }

    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 500));
        this.getEdqRecords('Load Data');
        this.getEdqRecords('All Data');
    }


    checkConditions(){
        this.showmsg = true;
        console.log('Record-Id',this.recordId);
        checkCaseSubCatEDQRules({recordId: this.recordId}).then(result=>{
            if(result=='Success'){
                   this.showData = true;
            }
            else if(result=='InsufficientAccess'){
                this.showData = false;
                this.isAccess = false;
            }
            else{
                this.showData = false;
                this.isAccess = true;
                this.Message = result;
                console.log(this.Message);
            }
        })

    }
    getEdqRecords(msg){
        let type = msg;
        //console.log('Type-',type);
        //console.log('Rec-id',this.recordId);
        return getEnvironmentVariables_CaseCat({recordId: this.recordId, limitSize : this.rowLimit,
        offset : this.rowOffSet,
        fetchType : type}).then(result=>{
            this.switchView = true;
            //console.log('Offset',this.rowOffSet);
            //console.log('Result from method=',result);
                
                if(type=='Load Data'){
                    //console.log('92');
                    
                   
                this.updatedTabledata = [...this.updatedTabledata,...result];
                   
                }
                if(type=='All Data'){
                    this.alledqs = result;
                }
                
            
        })
    }
    handleLoadMore(event){
        const currentRecord = this.updatedTabledata;
        //console.log('data-loading');
        const { target } = event;
        target.isLoading = true;
        if(this.rowOffSet <= 200){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            //console.log('inside-if-rowoffset',this.rowOffSet);
            this.getEdqRecords('Load Data')
                .then(()=> {
                    target.isLoading = false;
                });
        }
        else{
            this.isloading = false;
            target.isLoading = false;
        }
    }
    
    
    saveHandleAction(event) {
        this.fldsItemValues = event.detail.draftValues;
        //console.log('DraftValues-original'+JSON.stringify(this.fldsItemValues));
        let tempList = Object.assign([], this.updatedTabledata);
        for(let i=0;i<this.updatedTabledata.length;i++){
            for(let j=0;j<this.fldsItemValues.length;j++){
                if(this.fldsItemValues[j].Id==this.updatedTabledata[i].Id){
                    let rec = Object.assign({}, tempList[i]);
                    if(this.fldsItemValues[j].agentOnly==true && this.fldsItemValues[j].required==true ){
                        rec.agentOnly=true;
                        rec.required=true;
                    }
                    else if(this.fldsItemValues[j].agentOnly==true){
                        rec.agentOnly=true;
                    }
                    else if(this.fldsItemValues[j].required==true){
                        rec.required=true;
                    }
                    if(this.fldsItemValues[j].agentOnly==false && this.fldsItemValues[j].required==false ){
                        rec.agentOnly=false;
                        rec.required=false;
                    }
                    else if(this.fldsItemValues[j].agentOnly==false){
                        rec.agentOnly=false;
                    }
                    else if(this.fldsItemValues[j].required==false){
                        rec.required=false;
                    }
                    tempList[i]=rec;
                    
                }
            }
            this.updatedTabledata=tempList;
        }
       // console.log('Afterupdate',this.updatedTabledata);
              // console.log('Updated Data-93',this.updatedTabledata);
       
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully!!',
                variant: 'success'
            })
        );
        this.fldsItemValues = [];
        
         refreshApex(this.updatedTabledata);
    }
    saveHandleActionSearchResult(event) {
        this.searchFldsItemValues = event.detail.draftValues;
        //console.log('DraftValues'+JSON.stringify(this.searchFldsItemValues));
        //console.log('Serachresult'+JSON.stringify(this.searchResult));
        let tempList = Object.assign([], this.searchResult);
        for(let i=0;i<this.searchResult.length;i++){
            for(let j=0;j<this.searchFldsItemValues.length;j++){
                if(this.searchFldsItemValues[j].Id==this.searchResult[i].Id){
                    let rec = Object.assign({}, tempList[i]);
                    if(this.searchFldsItemValues[j].agentOnly==true && this.searchFldsItemValues[j].required==true ){
                        rec.agentOnly=true;
                        rec.required=true;
                    }
                    else if(this.searchFldsItemValues[j].agentOnly==true){
                        rec.agentOnly=true;
                    }
                    else if(this.searchFldsItemValues[j].required==true){
                        rec.required=true;
                    }
                    if(this.searchFldsItemValues[j].agentOnly==false && this.searchFldsItemValues[j].required==false ){
                        rec.agentOnly=false;
                        rec.required=false;
                    }
                    else if(this.searchFldsItemValues[j].agentOnly==false){
                        rec.agentOnly=false;
                    }
                    else if(this.searchFldsItemValues[j].required==false){
                        rec.required=false;
                    }
                    tempList[i]=rec;
                    
                }
            }
            this.searchResult=tempList;
        }
        //console.log('Afterupdate Search table data',this.searchResult);
        //console.log('Updated Data-93',this.searchResult);
       
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully!!',
                variant: 'success'
            })
        );
        this.searchFldsItemValues = [];
        
         refreshApex(this.searchResult);
    }
    addEdqs(){
        //selectedEdqs
        this.spinner=true;
        if(this.selectedEdqs.length>0){
            addEnvironmentVariables({SpenvDetails: this.selectedEdqs, sprecId:null, caseCatRecId:this.recordId}).then(result=>{
                if(result=='true'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records inserted Successfully!!',
                            variant: 'success'
                        }));
                        this.spinner=false;
                        // location.reload();
                        /*this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: 'Core_IPS_Product_Issue_Category__c', // objectApiName is optional
                                actionName: 'view'
                            }
                        });*/
                        window.location.href = Core_IPS_Lightning_Base_URL+'/lightning/r/Core_IPS_Product_Issue_Category__c/'+this.recordId+'/view';     
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'Error'
                        }));
                        this.spinner=false;
                        console.log('Error in Insertion=',result); 
                }
                
            })
    
        }
        else{
            alert('No rows are selected. Please select atleast one row');
            this.spinner = false;
        }
        
    }
    handleRowActions(event){
        let rec = event.detail.selectedRows;
        
        //console.log('Record',rec);
       
        this.selectedEdqs = rec;
        //console.log('Selcted edqs',this.selectedEdqs);
        
    }
    templist=[];
    edqsearchbox(event) {
        try{
            let tempattach = [];
            this.searchText = event.target.value;
            //console.log('All edqs'+JSON.stringify(this.alledqs));
            //console.log('search-text',this.searchText);
            if(this.searchText) {
                this.alledqs.forEach(attach =>{
                    if(attach.Core_IPS_Question != undefined && attach.Core_IPS_Question.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Name != undefined && attach.Name.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    
                });
               // console.log('tempvar',tempattach);
                this.searchResult = tempattach;
               // console.log('searchresult='+JSON.stringify(this.searchResult));
                this.switchView =false;
            } else {
                this.switchView = true;
            }
        }catch(error){
            console.log('error in search handler '+error.message());
        }    
    }
    goTOCaseCatRecordPage(){
        // View a custom object record.
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Product_Issue_Category__c', // objectApiName is optional
                actionName: 'view'
            }
        });*/
        window.location.href = Core_IPS_Lightning_Base_URL+'/lightning/r/Core_IPS_Product_Issue_Category__c/'+this.recordId+'/view';    
    }
    
}
import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import {loadStyle} from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkCaseSubCatRules from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.checkCaseSubCatRules'; // krishna
import addSubCategories from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.addSubCategories';
import getSubCategories from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.getSubCategories'; // krishna
import Core_IPS_Lightning_Base_URL from '@salesforce/label/c.Core_IPS_Lightning_Base_URL';

export default class Core_IPS_AddCaseSubCat_Lex extends NavigationMixin(LightningElement) {
    columns = [
        {label: 'Sub Category', fieldName: 'Name'},
        {label: 'Status', fieldName:'Core_Status__c'}
    ];
    
    allsubcat=[];
    showData;
    spinner=false;
    updatedTabledata=[];
    selectedSubCat=[];
    @track type = 'All Data';
    @track isloading = true;
    rowLimit =10;
    rowOffSet=0;
    cnt=0;
    recordId;
    temprecid;
    switchview;
    searchResult=[];
    
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
        this.getSubCatRecords('Load Data');
        this.getSubCatRecords('All Data');
    }



    checkConditions(){
        this.showmsg = true;
        console.log('Record-Id',this.recordId);
        checkCaseSubCatRules({recordId: this.recordId}).then(result=>{
            if(result=='Success'){
                   this.showData = true;
            }
            else{
                this.showData = false;
                this.Message = result;
                console.log(this.Message);
            }
        })

    }
    getSubCatRecords(msg){
        let type = msg;
        console.log('Inside method');
        return getSubCategories({recordID: this.recordId, limitsize : this.rowLimit,
            offset : this.rowOffSet,
            fetchType : type}).then(result=>{
                this.switchview = true;
                //console.log('Offset',this.rowOffSet);
                //console.log('Result from method=',result);
                    
                    if(type=='Load Data'){
                        //console.log('92');
                        
                       
                    this.updatedTabledata = [...this.updatedTabledata,...result];
                     console.log('Data',this.updatedTabledata);  
                    }
                    if(type=='All Data'){
                        this.allsubcat = result;
                    }
                    
                
            }).catch(error=>{
                console.log('Error in data',error);
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
            this.getSubCatRecords('Load Data')
                .then(()=> {
                    target.isLoading = false;
                });
        }
        else{
            this.isloading = false;
            target.isLoading = false;
        }
    }
    handleRowActions(event){
        let rec = event.detail.selectedRows;
        
        //console.log('Record',rec);
       
        this.selectedSubCat = rec;
        console.log('Selcted subcat',this.selectedSubCat);
        
    }
    addSubCatRecords(){
        this.spinner=true;
        if(this.selectedSubCat.length>0){
            addSubCategories({recordId: this.recordId, subcatList: this.selectedSubCat}).then(result=>{
                if(result=='true'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records inserted Successfully!!',
                            variant: 'success'
                        }));
                        this.spinner=false;
                        location.reload();
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'Error'
                        }));
                        this.spinner=false;
                        console.log('Error',result);
                }
                
            })
    
        }
        else{
            alert('No rows are selected. Please select atleast one row');
            this.spinner = false;
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
    subcatsearchbox(event) {
        try{
            let tempattach = [];
            this.searchText = event.target.value;
            //console.log('All edqs'+JSON.stringify(this.alledqs));
            //console.log('search-text',this.searchText);
            if(this.searchText) {
                this.allsubcat.forEach(attach =>{
                    if(attach.Name != undefined && attach.Name.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Core_Type__c != undefined && attach.Core_Type__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    
                });
               // console.log('tempvar',tempattach);
                this.searchResult = tempattach;
               // console.log('searchresult='+JSON.stringify(this.searchResult));
                this.switchview =false;
            } else {
                this.switchview = true;
            }
        }catch(error){
            console.log('error in search handler '+error.message());
        }    
    }

}
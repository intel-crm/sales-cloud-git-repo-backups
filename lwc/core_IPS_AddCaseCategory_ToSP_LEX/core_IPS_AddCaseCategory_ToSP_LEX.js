import { LightningElement,track,api,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import {loadStyle} from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkSPCaseCatRules from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.checkSPCaseCatRules'; // krishna
import addCategories from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.addCategories';
import getCategories from '@salesforce/apex/Core_IPS_addEDQToProduct_LEX.getCategories'; // krishna
import Core_IPS_Lightning_Base_URL from '@salesforce/label/c.Core_IPS_Lightning_Base_URL';


export default class Core_IPS_AddCaseCategory_ToSP_LEX extends NavigationMixin(LightningElement) {
    columns = [
        {label: 'Case Category', fieldName: 'Name'},
        {label: 'Status', fieldName:'Core_Status__c'}
    ];
    
    allcat=[];
    showData;
    spinner=false;
    updatedTabledata=[];
    selectedCat=[];
    @track type = 'All Data';
    @track isloading = true;
    recordId;
    temprecid;
    cnt=0;
    rowLimit =10;
    rowOffSet=0;
    switchview;
    searchResult=[];
    disableAddCaseButton = false;
    
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
        this.getCatRecords('Load Data');
        this.getCatRecords('All Data');
    }



    checkConditions(){
        this.showmsg = true;
        console.log('Record-Id',this.recordId);
        checkSPCaseCatRules({recordId: this.recordId}).then(result=>{
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
    getCatRecords(msg){
        let type = msg;
        console.log('Inside method');
        return getCategories({recordId: this.recordId, limitsize : this.rowLimit,
            offset : this.rowOffSet,
            fetchtype : type}).then(result=>{
                this.switchview = true;
                //console.log('Offset',this.rowOffSet);
                //console.log('Result from method=',result);
                    
                    if(type=='Load Data'){
                        //console.log('92');
                        
                       
                    this.updatedTabledata = [...this.updatedTabledata,...result];
                     console.log('Data',this.updatedTabledata);  
                    }
                    if(type=='All Data'){
                        this.allcat = result;
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
            this.getCatRecords('Load Data')
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
        this.disableAddCaseButton = false;
        let rec = event.detail.selectedRows;
        
        //console.log('Record',rec);
       
        this.selectedCat = rec;
        console.log('Selcted subcat',this.selectedCat);
        
    }
    addCatRecords(){
        this.disableAddCaseButton = true;
        this.addCatRecords = true;
        if(this.selectedCat.length>0){
            addCategories({recordId: this.recordId, catList: this.selectedCat}).then(result=>{
                this.spinner = false;
                if(result=='true'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records inserted Successfully!!',
                            variant: 'success'
                        }));
                        // this.spinner=false;
                        location.reload();
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'Error'
                        }));
                        // this.spinner=false;
                        console.log('Error',result);
                }
                
            })
    
        }
        else{
            alert('No rows are selected. Please select atleast one row');
            this.spinner = false;
        }
    }
    goTOSPRecordPage(){
        // View a custom object record.
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Supported_Product__c', // objectApiName is optional
                actionName: 'view'
            }
        });*/
        window.location.href = Core_IPS_Lightning_Base_URL+'/lightning/r/Core_IPS_Supported_Product__c/'+this.recordId+'/view';    
    }
    catsearchbox(event) {
        try{
            let tempattach = [];
            this.searchText = event.target.value;
            //console.log('All edqs'+JSON.stringify(this.alledqs));
            //console.log('search-text',this.searchText);
            if(this.searchText) {
                this.allcat.forEach(attach =>{
                    if(attach.Name != undefined && attach.Name.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
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
import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import {loadStyle} from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSpportedProductList from '@salesforce/apex/Core_IPS_Copy_CategoriesEDQ_LEX.getSpportedProductList';
import copyCaseCatSubCatEDQ from '@salesforce/apex/Core_IPS_Copy_CategoriesEDQ_LEX.copyCaseCatSubCatEDQ';
import checkUserPermission from '@salesforce/apex/Core_IPS_Copy_CategoriesEDQ_LEX.checkUserPermission';
import Core_IPS_Lightning_Base_URL from '@salesforce/label/c.Core_IPS_Lightning_Base_URL';
export default class Core_IPS_Copy_Categories_EDQ_Lex extends NavigationMixin(LightningElement) {
    
    
    
    splist=[];
    allsplist =[];
    switchView;
    rowLimit = 10;
    rowOffSet =0;
    recordId;
    spsearchchlist=[];
    sprecord;
    temprecid;
    cnt=0; 
    spinner;
    showmsg;
    message;
    disabledCopyCat = false;
    columns=[
        {label:'Supported Product Name', fieldName:'Core_Supported_Product_Name__c',type:'text'},
        {label:'Supported Product ID', fieldName:'Name',type:'text'},
        {label:'Access Flag', fieldName:'Core_Flag_Status__c',type:'text'}
    ];
    
    
    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1 && this.recordId != this.temprecid){
            window.location.reload();
        }
        this.switchView = false;
        this.getSPRecList('Load Data');
        this.getSPRecList('All Data');
    }

    getrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }
        
    }

    connectedCallback(){
        this.recordId = this.getrecordId();
        loadStyle(this, Core_IPS_Upload_Attachment_LEX)
            .then(result => {});
        this.cnt = 1;
        this.temprecid = this.recordId;
        //this.RefreshValues();
        this.checkPermissions();
        
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 500));
        this.getSPRecList('Load Data');
        this.getSPRecList('All Data');
    }


    checkPermissions(){
        checkUserPermission({recordId: this.recordId}).then(result=>{
            if(result=='true'){
                this.showmsg = false;
            }
            else{
                this.showmsg = true;
                this.message = result;
            }
        }).catch(Error=>{
            console.log('Error in checking user record permissions',Error);
        })
    }

    getSPRecList(msg){
        let type = msg;
        return getSpportedProductList({recordId: this.recordId, limitsize: this.rowLimit, offset: this.rowOffSet, fetchtype: type}).then(result=>{
            this.switchView = true;
            if(msg=='Load Data'){
                this.splist = [...this.splist,...result];
            }
            else if(msg=='All Data'){
                this.allsplist = result;
            }
        }).catch(error=>{
            console.log('Error in data',error);
        })
    }
    handleLoadMore(event){
        const currentRecord = this.splist;
        //console.log('data-loading');
        const { target } = event;
        target.isLoading = true;
        if(this.rowOffSet <= 200){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            //console.log('inside-if-rowoffset',this.rowOffSet);
            this.getSPRecList('Load Data')
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
        var selectedRows=event.detail.selectedRows;
        this.sprecord = selectedRows[0].Id;
        console.log('Selected Rows',selectedRows);
        this.disabledCopyCat = false;
    }
    spsearchbox(event) {
        try{
            let tempattach = [];
            this.searchText = event.target.value;
            
            if(this.searchText) {
                this.allsplist.forEach(attach =>{
                    if(attach.Name != undefined && attach.Name.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Core_Supported_Product_Name__c != undefined && attach.Core_Supported_Product_Name__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    
                });
               // console.log('tempvar',tempattach);
                this.spsearchchlist = tempattach;
               // console.log('searchresult='+JSON.stringify(this.searchResult));
                this.switchView =false;
            } else {
                this.switchView = true;
            }
        }catch(error){
            console.log('error in search handler '+error.message());
        }    
    }
    navigateToRecordPage(){
        this.goTOSPRecordPage(this.recordId);
    }
    goTOSPRecordPage(recId){
        // View a custom object record.
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recId,
        //         objectApiName: 'Core_IPS_Supported_Product__c', // objectApiName is optional
        //         actionName: 'view'
        //     }
        // });
        window.location.href = Core_IPS_Lightning_Base_URL+'/lightning/r/Core_IPS_Supported_Product__c/'+this.recordId+'/view';
    }
    copyCatEDQ(){
    this.disabledCopyCat = true;
       if(this.sprecord != null){
        let res = confirm('The copy action will first delete all existing Category & EDQ assignments if they exist - please confirm.');
        if(res==true){
             this.spinner = true;
             console.log('Inside if action ok');
             console.log('Selcted SP Rec ID',this.sprecord);
             
                 copyCaseCatSubCatEDQ({selsprecID: this.sprecord,cursprecId: this.recordId}).then(result=>{
                     if(result=='true'){
                        this.spinner = true;
                         this.dispatchEvent(
                             new ShowToastEvent({
                                 title: 'Success',
                                 message: 'Copy Categories, EDQ Successfull!!',
                                 variant: 'success'
                             }));
                             //this.spinner=false;
                             this.goTOSPRecordPage(this.sprecord);
                     }
                     else{
                         this.dispatchEvent(
                             new ShowToastEvent({
                                 title: 'Error',
                                 message: result,
                                 variant: 'Error'
                             }));
                     }
                 });
        }
        else{
         this.goTOSPRecordPage(this.recordId);       
        }
    } 
    else{
        alert('No row selected, Please select a row');
    }   
  }
}
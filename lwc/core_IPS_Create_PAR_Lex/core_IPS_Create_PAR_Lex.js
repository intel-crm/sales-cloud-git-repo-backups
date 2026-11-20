import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
import {loadStyle} from "lightning/platformResourceLoader";
import getAccount from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.getAccount';
import getProducts from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.getProducts';
import pushProducts from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.pushProducts';
import getSupportedProducts from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.getSupportedProducts';
import checkAccounts from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.checkAccounts';
import getLineItemsmethod from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.getLineItemsmethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Core_IPS_PAR_NON_NDA_Error_Msg from '@salesforce/label/c.Core_IPS_PAR_NON_NDA_Error_Msg';
import Core_IPS_Insufficient_Privileges_PAR from '@salesforce/label/c.Core_IPS_Insufficient_Privileges_PAR';
import Core_IPS_Non_IPS_Active_PAR from '@salesforce/label/c.Core_IPS_Non_IPS_Active_PAR';
import {refreshApex} from '@salesforce/apex';


export default class Core_IPS_Create_PAR_Lex extends NavigationMixin(LightningElement) {
    
    
    
    cnt=0;
    srchText;
    temprecid;
    ifData=true;
    spinner;
    recordId;
    selectedRecords=[];
    refreshData=[];
    lastSavedData=[];
    isEnabled=true;
    sections = ['A', 'B'];
    sections1 = ['C','D'];
    members=['heelo','hi,howru'];
    accountsData=[];
    lastSavedData=[];
    draftValues=[];
    slicedSpList=[];
    fldsItemValues=[];
    firstScreen = true;
    secondScreen = false;
    accName;
    getData;
    NoData;
    commentChngVal = '';
    productIdsList = [];
    existingProductIds = [];
    productsToAdd = [];
    @track productIds=[];
    @track errorSupportedProductsData = [];
    rowLimit = 15;
    rowOffSet = 0;
    filteredProductsToAdd = [];
    spinnerOnSubmit = false;
    tempProdList = [];
    label = {
        Core_IPS_PAR_NON_NDA_Error_Msg,
        Core_IPS_Insufficient_Privileges_PAR,
        Core_IPS_Non_IPS_Active_PAR,
    }

    supportedListOptions=[
        {label:'Supported Product Name', fieldName:'name',type:'text'},
        {label:'Support Org Name', fieldName:'Support Org Name',type:'text'},
        {label:'Product Focus Area', fieldName:'ProdArea',type:'text'},
        {label:'Approval Type', fieldName:'Approval Type',type:'text'},
    ];
    // chetan - modified eitable : false to make the fields readonly 
    columns=[{label: 'Supported Product Name', fieldName: 'name',type: "text"},
        {label: 'Code Name', fieldName: 'CodeName',type: "text"},
        {label: 'Product Name EPM ID', fieldName: 'EPMID',type: "text"},
        { label: 'Product Focus Area', fieldName: 'ProdArea',type: "picklistEditTemplate",editable:false, typeAttributes:{
            options: {fieldName:'ProdOptions'},
            value :{fieldName:'ProdArea'},
            context:{fieldName:'Id'},
            placeholder :'Select Product Focus Area',
            
        }}
    ];
    

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        this.srchText = '';
        this.commentChngVal = '';
        
        if(this.cnt==1 && this.recordId != this.temprecid){
            window.location.reload();
        }
        this.fetchAccounts();
    
    if(this.recordId == this.temprecid){
        this.slicedSpList = [];
        this.firstScreen = true;
        this.secondScreen = false;
        this.getData = false;
    }   
    }
    rowActionLineitems(event){
        
        let rec = event.detail.selectedRows;
        this.productIds=rec.map(value=> {
             return value?.SupProduct?.Id;
            });
        }
    
    getrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }
        
    }

    userPresent = true;
    isNDAPresent = true;
    isActive = false;
    showData = false;

    connectedCallback(){
        this.recordId = this.getrecordId();
        //this.fetchAccounts();
        loadStyle(this, Core_IPS_Upload_Attachment_LEX)
            .then(result => {});
        this.cnt = 1;
        this.temprecid = this.recordId;
        this.supportedProductRecords();
        
    }
        @wire (getAccount,{accId: '$recordId'})
            getData(result){
                this.refreshData = result;
                if(result !=null){
                    this.accName = result.data;
                }
            }
            
    fetchAccounts(){
        checkAccounts({accId: this.recordId})
        .then(result => {
            if(result.accountRecord.Core_CNDA_Number__c == undefined) {
                this.isNDAPresent = false;
                
            } else {
                this.isNDAPresent = true;
            }
            
            if(result.accountRecord.Core_IPS_Active__c == false){
                this.isActive = true;
            } else {
                this.isActive = false;
            }
            this.userPresent = result.userPresent;
            this.showData = true;
        })
        .catch(error => {
            console.log('error occured in checkAccounts',error);
        })
        
    }    
    
    handleKeyChange(event){
        this.srchText = event.target.value;
        if(this.srchText.length>0){
            this.isEnabled=false;
        }
        else{
            this.isEnabled=true;
        }
        
    }
    handleAccountSearchOnClick(event){
        this.spinner =true;
        this.rowOffSet = 0;
        getSupportedProducts({searchText: this.srchText ,limitSize:this.rowLimit,offset:this.rowOffSet}).then(result=>{
            if(result!=null){
                this.slicedSpList=[];
                
                if(result.length>0){
                    this.getData=true;
                    this.NoData = false;
                }
                else{
                    this.getData = false;
                    this.NoData=true;
                }
                result.forEach(element => {
                    let options=[];
                        for(let i=0;i<element.prodOrgs.length;i++){
                            let obj1 ={
                                'label': element.prodOrgs[i].value,
                                'value': element.prodOrgs[i].value,
                                'Id': element.prod.Id
                            };
                            options.push(obj1);
                        }
                        
                        let obj={
                            'name': element.prod.Name,
                            'prod': element.prod,
                            'ProductEPMId': element.ProductEPMId,
                            'SupProduct':element.SupProduct,
                            'enabledForSubscriptions': element.enabledForSubscriptions,
                            'selectedProductOrganization':element.selectedProductOrganization,
                            'productOrgoneSize': element.productOrgoneSize,
                            'prodOrgs':element.prodOrgs,
                            'relatedSupProduct':element.relatedSupProduct,
                            'supportTierList':element.supportTierList,
                            'CodeName': element.prod.Core_Code_Name__c,
                            'EPMID': element.prod.Core_Product_Name_EPM_ID__c,
                            'ProdArea': element.prodOrgs[0].value,
                            'ProdOptions' : options,
                            'Support Org Name': element.SupProduct.Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,
                            'Approval Type': element.SupProduct.Core_Flag_Status__c,
                            'Id' : element.prod.Id
                        };
                        this.slicedSpList = [...this.slicedSpList,obj];
                        
                });
                this.lastSavedData = this.slicedSpList;
                this.spinner = false;
            }
        })
        .catch(error=>{
            this.spinner = false;
            this.NoData = true;
            this.getData = false;
        })
    
    }
    sendDataToParent(event){
        this.accountsData = event.detail.data;
    }
    
    navigateToRecordPage(){
        // View a custom object record.
        if (this.commentChngVal == '' ||(this.commentChngVal!=undefined && this.commentChngVal.trim() =='')  || this.commentChngVal == null || this.commentChngVal == undefined) {
             console.log('error');
             const evt = new ShowToastEvent({
                title: "ERROR",
                message: 'Please enter the submitter comments',
                variant: 'error',
             });
             this.dispatchEvent(evt);
        return;
       }
       

       for(let product of this.productsToAdd) {
        if(!this.productsToRemove.includes(product.Id)) {
            this.filteredProductsToAdd.push(product);
        }
       }
       
       if(this.filteredProductsToAdd.length == 0){
        const evt1 = new ShowToastEvent({
            title: "ERROR!!!",
            message: 'Please select atleast one product',
            variant: 'error',
         });
         this.dispatchEvent(evt1);
         return;
     }
     this.spinnerOnSubmit = true;
        pushProducts({productsToAdd: this.filteredProductsToAdd, accountId: this.recordId, submitterCommentsText : this.commentChngVal})
        .then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully',
                    variant: 'success'
                 })
           )
            this.spinnerOnSubmit = false;
              this[NavigationMixin.Navigate]({
                  type: 'standard__recordPage',
                  attributes: {
                      recordId: this.recordId,
                      objectApiName: 'Account', // objectApiName is optional
                      actionName: 'view'
                  }
              });
              
              this.filteredProductsToAdd = [];
              this.productsToRemove = [];
              this.productsToAdd = [];
        })
        .catch(error=>{
            this.spinnerOnSubmit = false;
        })
        
      
    }
    async gotoSecondScreen(){
        for(let i=0; i<this.selectedRecords.length; i++){
                this.productIdsList.push(this.selectedRecords[i].Id);
                for(let j=0; j<this.draftValues.length;j++){
                     if(this.selectedRecords[i]["Id"] == this.draftValues[j].Id){
                         for(let k=0; k<this.selectedRecords[i]["prodOrgs"].length; k++){
                            if(this.selectedRecords[i]["prodOrgs"][k]["value"] == this.draftValues[j]["value"]){
                                this.selectedRecords[i]["selectedProductOrganization"] = this.selectedRecords[i]["prodOrgs"][k]["label"];
                            }
                        }
                    }
                }
            }

        await getLineItemsmethod({productList: JSON.stringify(this.selectedRecords)}).then(result=>{
            let res = JSON.parse(JSON.stringify(result));
            for(let obj of res){
                for(let selobj of this.selectedRecords){
                    if(selobj["prod"]["Id"] == obj["prod"]["Id"]){
                        selobj["SupProduct"] = obj["SupProduct"];
                        selobj["prodOrgName"] = obj["prodOrgName"];
                        selobj["prodOrgId"] = obj["prodOrgId"];
                        selobj["prodOrgDescription"] = obj["prodOrgDescription"];
                        selobj["prodEPMId"] = obj["prodEPMId"];
                        selobj["FlagStatus"] = obj["FlagStatus"];
                        selobj["UniqueOrgEPMId"] = obj["UniqueOrgEPMId"];
                    }
                }
            }

        })
        .catch(error=>{
            console.log('error',error);
        })  
      await getProducts({accountId: this.recordId, productIds: JSON.stringify(this.productIdsList)}).then(result=>{
            for(let j = 0; j< result.length; j++) {
                //this.existingProductIds.push(result[j].Product2Id);
                this.existingProductIds.push(result[j].Core_Supported_Product__c);
            }
            for(let k = 0; k < this.selectedRecords.length; k++) {
                if(this.existingProductIds.includes(this.selectedRecords[k]["SupProduct"]["Id"])) {
                    this.selectedRecords[k].disabled = true;
                    this.selectedRecords[k].check = false;
                    this.selectedRecords[k].color = "background-color: rgb(243, 213, 78)";
                }
                else {
                    this.selectedRecords[k].disabled = false;
                    this.selectedRecords[k].check = true;
                    this.selectedRecords[k].color = "";
                    this.productsToAdd.push(this.selectedRecords[k]); 
                }
                refreshApex(this.productsToAdd);
            }
        })
        .catch(error=>{
            console.log('error',error);
        })
        this.firstScreen = false;
        this.secondScreen = true;
    }
    
    subCommentsOnchng(event){
        this.commentChngVal = event.detail.value;
    }
    gotoFirstScreen(){
        this.firstScreen = true;
        this.secondScreen = false;
        this.selectedRecords = [];
        this.productsToAdd = [];
        this.draftValues = [];
        this.slicedSpList = this.tempProdList;
    }
    handleEvent(event){
        let prodArea = event.detail.row;
        let prodAreaID = event.detail;
        let rec = event.detail.selectedRows;
    }
    
    cancelHandleAction(event){
        this.handleAccountSearchOnClick(event);
    }
    updateDatatable(){
        for(let i=0;i<this.lastSavedData.length;i++){
            this.slicedSpList = [...this.slicedSpList,this.lastSavedData[i]];
        }
        refreshApex(this.slicedSpList);
        this.spinner=false;
    }
    saveHandleAction(event) {
    }
    handleRowAction(event){
        let rec = event.detail.selectedRows;
        if(event.detail.selectedRows.length>0){
            this.ifData = false;
            this.selectedRecords = rec;
        }
        else{
            this.ifData = true;
            
            
        }
    }
    
    picklistChanged(event){
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, value: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.slicedSpList));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.slicedSpList = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

lineItemProds;
productsToRemove = [];
    onchangeLineItems(event) {
        let flag = event.target.checked;
        if(!flag && !this.productsToRemove.includes(event.target.value)) {
            this.productsToRemove.push(event.target.value);
        }
        if(flag && this.productsToRemove.includes(event.target.value)) {
            let index = this.productsToRemove.indexOf(event.target.value)
            this.productsToRemove.splice(index, 1);
        }
        
    }

    cancelbutton() {
        this.commentChngVal = '';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    supportedProductRecords(){
        return getSupportedProducts({searchText: this.srchText, limitSize: this.rowLimit , offset : this.rowOffSet })
          .then(result =>{
             result.forEach(element => {
                    let options=[];
                        for(let i=0;i<element.prodOrgs.length;i++){
                            let obj1 ={
                                'label': element.prodOrgs[i].value,
                                'value': element.prodOrgs[i].value,
                                'Id': element.prod.Id
                            };
                            options.push(obj1);
                        }
                        
                        let obj={
                            'name': element.prod.Name,
                            'prod': element.prod,
                            'ProductEPMId': element.ProductEPMId,
                            'SupProduct':element.SupProduct,
                            'enabledForSubscriptions': element.enabledForSubscriptions,
                            'selectedProductOrganization':element.selectedProductOrganization,
                            'productOrgoneSize': element.productOrgoneSize,
                            'prodOrgs':element.prodOrgs,
                            'relatedSupProduct':element.relatedSupProduct,
                            'supportTierList':element.supportTierList,
                            'CodeName': element.prod.Core_Code_Name__c,
                            'EPMID': element.prod.Core_Product_Name_EPM_ID__c,
                            'ProdArea': element.prodOrgs[0].value,
                            'ProdOptions' : options,
                            'Support Org Name': element.SupProduct.Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,
                            'Approval Type': element.SupProduct.Core_Flag_Status__c,
                            'Id' : element.prod.Id
                        };
                        this.slicedSpList = [...this.slicedSpList,obj];
                        this.tempProdList = this.slicedSpList;
                        
                });
                                     
          })
          .catch(error=>{
                  this.errorSupportedProductsData = error;
          });
      }
      

    loadMoreData(event) {
        const currentRecord = this.slicedSpList;
        this.spinner = true;
        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.supportedProductRecords()
        .then(()=> {
            this.spinner = false;
        }); 
    }

}
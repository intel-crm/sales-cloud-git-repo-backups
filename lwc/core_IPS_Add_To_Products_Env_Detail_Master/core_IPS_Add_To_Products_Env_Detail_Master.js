import { LightningElement,track,wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import addToProducts from '@salesforce/apex/Core_IPS_AddProductsEnvDetailMaster_LEX.addToProducts';
import getSupportedProducts from '@salesforce/apex/Core_IPS_AddProductsEnvDetailMaster_LEX.getSupportedProducts';
import checkBusinessRules from '@salesforce/apex/Core_IPS_AddProductsEnvDetailMaster_LEX.checkBusinessRules';


export default class Core_IPS_Add_To_Products_Env_Detail_Master extends NavigationMixin(LightningElement) {

    columns = [
        { label: 'Supported Product Name', fieldName: 'Name' },
        { label: 'Required', fieldName: 'required',  type: 'boolean', editable:true },
        { label: 'Agent Only', fieldName: 'agentOnly', type: 'boolean', editable:true },
    ];

    @track supportedProductsData = [];
    @track errorSupportedProductsData = [];
    @track selectedSupportedProductRecord = [];
    @track tempList = [];
    @track fldsItemValues = [];
    @track showData;
    @track Core_Supported_Product;
    @track lightningSpinner = false;
    rowLimit = 5;
    rowOffSet = 0;
    @track currentPageReference;
    MainURL;
    url;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    
    get recordId(){
        return this.currentPageReference?.state?.c__recordId;
    }
    
    connectedCallback(){
        console.log('--- connectedCallback recordId---', this.recordId);

        this.MainURL = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Environment_Variables__c',
                actionName: 'view'
            }
        };
        this[ NavigationMixin.GenerateUrl ]( this.MainURL )
            .then( url => this.url = url );


        this.validateBusinessRules();
        this.supportedProductRecords();
    }
    
    validateBusinessRules(){
        this.showmsg = true;
        console.log('---recordId checkBusinessRules---', this.recordId);
        checkBusinessRules({recordId: this.recordId})
         .then(result=>{
            if(result =='Success'){
                   this.showData = true;
            }
            else{
                this.showData = false;
                this.Message = result;
                console.log('---showData Message---', this.Message);
            }
        })

    }

    supportedProductRecords(){
      console.log('---recordId---', this.recordId);
      return getSupportedProducts({recordId : this.recordId, limitSize: this.rowLimit , offset : this.rowOffSet })
        .then(result =>{
            console.log('Method Result----' +JSON.stringify(result));
           
                this.supportedProductsData = [...this.supportedProductsData, ...result];
                //this.supportedProductsData = result;
                console.log('---supportedProductsData Result----' +JSON.stringify(this.supportedProductsData)); 
                  
        })
        .catch(error=>{
                this.errorSupportedProductsData = error;
                console.log('----errorSupportedProductsData---'+error);
        });
    }
    
    loadMoreData(event) {
        const currentRecord = this.supportedProductsData;
        console.log('----load more data---');
        const { target } = event;
        target.isLoading = true;

        // if(this.rowOffSet <= 200){ 
           this.rowOffSet = this.rowOffSet + this.rowLimit;
           this.supportedProductRecords()
            .then(()=> {
                target.isLoading = false;
            });  
        //}     
    }

    handleSave(event){
        this.fldsItemValues = event.detail.draftValues;
        console.log('---fldsItemValues---',this.fldsItemValues);
        let tempList = Object.assign([], this.supportedProductsData);
        for(let i=0;i<this.supportedProductsData.length;i++){
            for(let j=0;j<this.fldsItemValues.length;j++){
                if(this.fldsItemValues[j].Id==this.supportedProductsData[i].Id){
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
            this.supportedProductsData=tempList;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully!!',
                variant: 'success'
            })
        );
        this.fldsItemValues = [];
        
         refreshApex(this.supportedProductsData);
    }

    handleRowSelection(event){
        let supportedProductRecord = event.detail.selectedRows;  
        console.log('---supportedProductRecord---', supportedProductRecord);   
        this.selectedSupportedProductRecord = supportedProductRecord;
        console.log('selectedSupportedProductRecord',JSON.stringify(this.selectedSupportedProductRecord));
        
    }

    addToProduct(){
        console.log('--Inside addToProduct method--');
        console.log('---recordId---', this.recordId);
        this.lightningSpinner = true;
        if(this.selectedSupportedProductRecord.length>0){
            addToProducts({supportedProductDetails: this.selectedSupportedProductRecord, recordId: this.recordId})
             .then(result=>{
                console.log('--result addToProduct method--', result);
                if(result==true){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records inserted Successfully',
                            variant: 'success'
                        }));
                }
                this.lightningSpinner=false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Core_IPS_Environment_Variables__c',
                        actionName: 'view'
                    }
                });
                //location.reload();
            })    
            .catch(error =>{
                console.log('---error---' +JSON.stringify(error));
                this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error!',
                           message: 'something went wrong', 
                                    // error.body.output.fieldErrors.Core_IPS_Public_Product__c[1].message,
                           variant: 'error'
                        })
                )
            })
        }
        else{
            alert('No products are selected. Please select atleast one product');
            this.lightningSpinner = false;
        }   
    }

    exitAction(){
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Environment_Variables__c',
                actionName: 'view'
            }
        }); */

         window.open( this.url , '_self');
    }     

 
}
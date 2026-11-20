import { LightningElement,wire,track,api } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import checklistForApproval from '@salesforce/apex/Core_OppApprovalCtrl.checklistForApproval';
import submitApproval from '@salesforce/apex/Core_OppApprovalCtrl.submitApproval';
import updateSalesPriceData from '@salesforce/apex/Core_OppApprovalCtrl.updateSalesPriceData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import customCSS from '@salesforce/resourceUrl/toastCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

const dataTableColumns = [
    { label: 'Product Name', fieldName: 'productNames',initialWidth: 400,sortable: "true" },
    { label: 'Quote#', fieldName: 'quoteNumbers' ,initialWidth: 90},
    { label: 'Quote Line#', fieldName: 'quoteLineNumbers' ,initialWidth: 125,sortable: "true" },
    { label: 'Sales price', fieldName: 'salesPrices' ,initialWidth: 110 },
    { label: 'Approved ECAP Price', fieldName: 'approvedECAPPrices' ,initialWidth: 180 }
    
];

export default class Core_OppApprovalLWC extends NavigationMixin(LightningElement) {

    @track dataList =[];
    @track activeTab = '';
    @track selectedData =[];
    @track listOfErrors ={};
    @track isSalesPriceUpdated = true ;
    @track isDataImproper = true ;
    @track dataTableColumns = dataTableColumns ;
    @track rowOffset = 0;
    @track updateStatus;
    errorMessageToDisplay = '';
   // @track draftValues = [];
    @track loaded = false;
    @track msg;
    //@track hardStopList = new Array(3);
    @track hardStopList = [];
    //@track softStopList = new Array(3);
    @track softStopList = [];
    @track submitDisabled=true;
    @track comments;
    @api recordId;
    @api auraInvoke = false;
    @track showErrorButton; 
    @track showWarningButton;
    @track warningSize;
    @track errorSize;
    @track totalSoftStop;
    @track totalHardStop;
    @track showCheckList;
    @track showErrors;
    @track showWarnings;
    @track showEPACData = false;
    @track warningButtonDisabled;
    @track errorButtonDisabled;
    @track showHideTab = true;
    @track toastTitle;
    @track toastMessage;
    @track toastVariant;
    @track auraInvoke = false;
   
    
    get setDatatableHeight(){
    if(this.dataList.length == 0){
        return  'height:4rem;';
    }else if(this.dataList.length >= 10){
        return 'height:25rem;';
    }
    }

     get bDisableBackBtn(){
       console.log('inside disable back'+this.activeTab+'-'+this.showErrors );
        if((this.activeTab == 1) || (this.activeTab == 2 && this.showErrors != true )
            || (this.activeTab == 3 &&  this.showWarnings != true && this.showErrors != true)
         ){
            return true;
        }else if ((this.activeTab == 2 && this.showErrors == true )|| 
        (this.activeTab == 3 && (this.showErrors == true  || this.showWarnings== true) )){
            return false;
        }
       // return Number(this.activeTab) == 1 ? true : false;
       
    }
     get bDisableNextBtn(){
       console.log('inside disable Next'+this.activeTab+'-'+this.showWarnings+'-'+this.showEPACData );
        if((this.activeTab == 3) || (this.activeTab == 2 && this.showEPACData != true ) ||
        (this.activeTab == 1 && this.showWarnings != true && this.showEPACData != true) ){
            return true;
        }else {
            return false;
        }
        //return Number(this.activeTab) == 3 ? true : false;
    }
    
    handleActive(event) {
     this.activeTab = event.target.value;
      console.log('inside handleactive '+this.activeTab+'-'+this.showErrors+'-'+this.showEPACData );
     if((this.activeTab == 3 && this.showErrors != true ) || 
     ( this.activeTab == 2 && this.showEPACData != true && this.showErrors != true ) ){
          this.submitDisabled = false;
      }else{
          this.submitDisabled = true;
      }
    }
    
    goBack(){
        let activeTabValue = Number(this.activeTab) - 1;
        this.activeTab = activeTabValue.toString();
      }
    goNext(){
      let activeTabValue = Number(this.activeTab) + 1;
      this.activeTab = activeTabValue.toString();
      
    }

    closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
    }
    /*handleWarningDisplay(){
        this.showWarnings = true;
        this.showErrors = false;
    }
    handleErrorDisplay(){
        this.showWarnings = false;
        this.showErrors = true;
    }*/
    commentChange(event) {
        this.comments = event.detail.value;
    }

    @api
    get isCalledFromAura() {
        if(this.recordId==null)
        {   
            return false;
            
        }
        else return true;
    }
    
   @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        
        if (currentPageReference && this.recordId==null) {
            this.recordId = currentPageReference.state.recordId;
        }   
    }
    
    connectedCallback() {
        this.loaded = true;

         loadStyle(this, customCSS).then(() => {
            //console.log('css loaded successfully');
        }).catch(error => {
           // console.log('error to load css');
        });

        console.log('RecordId=='+this.recordId);
        //Added parameter for method - TWC3123-3676- To track Apporval action
        checklistForApproval({ oppId: this.recordId, comments: this.comments})
        .then(result =>{
            //this.msg= result;
            this.loaded = false;
            this.hardStopList = result.hardStopList;
            //this.hardStopList[1] = result.hardStopList[1];
            //this.hardStopList[2] = result.hardStopList[2];
            this.softStopList = result.softStopList;
            //this.softStopList[1] = result.softStopList[1];
            //this.softStopList[2] = result.softStopList[2];
            this.totalSoftStop = result.totalSoftStop;
            this.totalHardStop = result.totalHardStop;
            this.warningSize = "Warnings";
            this.errorSize = "Errors";
            console.log(result.softStopList);
            /*if(this.hardStopList.length !== result.hardStopList.length || this.softStopList.length !== result.softStopList.length ){
                this.showCheckList = true;
            }*/
            /*if ((this.hardStopList !== undefined && this.hardStopList.length > 0) || (this.softStopList !== undefined && this.softStopList.length > 0) ) {
                //this.showError = true;
                
            }*/
            if(this.hardStopList == undefined || this.hardStopList.length == 0){ //if no errors?
                this.submitDisabled = false;
                this.showWarnings = true;
                
                this.errorButtonDisabled = true;
                this.showErrorButton = false;
            }
            else if(!(this.hardStopList == undefined || this.hardStopList.length == 0)){ //if errors?
                this.showErrors = true;
                this.showErrorButton = true;
                this.showWarnings = true;
                this.errorSize = "Errors-["+this.hardStopList.length+"]";
            }
            if(this.softStopList !== undefined && this.softStopList.length > 0){ //if warning?
                this.showWarnings = true;
                this.warningSize = "Warnings-["+this.softStopList.length+"]";
                this.showWarningButton = true;
            }
            if(this.softStopList == undefined || this.softStopList.length == 0){ //if no warning?
                this.warningButtonDisabled = true;
                this.showWarningButton = false;
                this.showWarnings = false;
            }
            if((this.softStopList == undefined || this.softStopList.length == 0) && (this.hardStopList == undefined || this.hardStopList.length == 0)){ //if no error/warning?
                this.showWarnings = false;
                this.showErrors = false;
                this.showHideTab = false;

            }
            
            /*if(this.hardStopList == undefined || this.hardStopList.length == 0){
                
               this.msg = "No major issues.";
            }*/
            
            this.dataList = result.quoteLineData ;
           
            if(this.dataList != undefined && this.dataList.length >0){
                this.showEPACData = true;
                this.showHideTab = true;
            }
        
            
        })
        .catch(error =>{
            
            this.loaded = false;
            this.errorMsg = error;
            this.toastTitle = "Failure";
            //alert(JSON.stringify(error.body));
            //alert(JSON.stringify(error.body.pageErrors));
            this.toastMessage = JSON.stringify(error.body.message);
            this.toastVariant = "error";
            
            this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
        });
    }


    handleSubmitClick(event){
       this.loaded = true;
       
       if( this.showEPACData == true){
        this.dataValidation();
       }

       if(this.isDataImproper && this.showEPACData == true ){
       this.updateData();
       }
    
     if(this.isSalesPriceUpdated && this.isDataImproper){
        
      //  console.log('inside submit');
      submitApproval({ oppId: this.recordId, comments: this.comments})
        .then(result =>{
            
            eval("$A.get('e.force:refreshView').fire();");
            this.dispatchEvent(new CloseActionScreenEvent());
            if(this.auraInvoke){
                const toastEvent = new ShowToastEvent({
                    title: `Opportunity submitted successfully for Approval !!`,
                    message: '',
                    variant: 'success',
                    duration : 8000,
                });
                this.dispatchEvent(toastEvent);
                this.dispatchEvent(new CustomEvent('closequickmodal'));
            }
            this.loaded = false;
            
        })
        .catch(error =>{
            
            this.loaded = false;
            this.errorMsg = error;
            this.toastTitle = "Failure";
            this.toastMessage = JSON.stringify(error.body.message);
            this.toastVariant = "error";
            
            this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
        });
      }
       
       
    }

   getSelectedRowData(event){
        var selectedRows = event.detail.selectedRows;
        console.log('selectedRows'+selectedRows);
        this.selectedData = selectedRows;
        this.dataValidation();
   } 

    dataValidation(){
        console.log('inside data validation');
        this.errorMessageToDisplay = '';
        this.isDataImproper = true;
        let listofErrors = new Set();
        for (let i = 0; i < this.selectedData.length-1; i++) {
             for (let j = i + 1; j <this.selectedData.length; j++) {
            if(this.selectedData[i].Id === this.selectedData[j].Id)     {
                 
                  listofErrors.add(this.selectedData[j].productNames);
            }
             break;
            }
           
        }
        listofErrors.forEach((value) =>{
          this.errorMessageToDisplay +=  value+' \n';   
        });
      
    //console.log('errorMessageToDisplay-'+this.errorMessageToDisplay);

       if(this.errorMessageToDisplay != '' ){

        this.isDataImproper = false;
        this.loaded = false;

        this.dispatchEvent(
            
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You cannot select/update more than one Quote Line for a Product, Please review the selection on following products'+' \n' + this.errorMessageToDisplay,
                    variant: 'error',
                    mode : 'sticky'
                    
                })
            );
       }

    }

    updateData(){
    if(this.selectedData.length > 0  ){               
        console.log('inside updatedta');
        
       /* var draftValues = this.template.querySelector('lightning-datatable').draftValues;
       
        for (let j = 0; j < this.selectedData.length; j++){
           for (let i = 0; i < draftValues.length; i++){
           
               if(draftValues[i].Id === this.selectedData[j].Id){
                   this.selectedData[j].approvedECAPPrices = draftValues[i].approvedECAPPrices;
               }
           }

          
       }*/

        updateSalesPriceData({ data: JSON.parse(JSON.stringify(this.selectedData))})
        .then(response => { 
           
            this.updateStatus = response;
            if(this.updateStatus.includes('Success')){
                console.log('Inside success'+response);
            
            const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity Sales Price updated successfully',
                    variant: 'success',
                    duration : 8000,
            
                });
                this.dispatchEvent(toastEvent);
                 this.isSalesPriceUpdated = true;
              
            }else{
            this.loaded = false;
            this.isSalesPriceUpdated = false;
            this.errorMsg = response;
            this.toastTitle = "Failure";
            this.toastMessage = response;
            this.toastVariant = "error";
            
            
            this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);
            }
        })
        .catch(error => {
           // console.log('Inside failure'+error);
            this.loaded = false;
            this.isSalesPriceUpdated = false;
            this.errorMsg = error;
            this.toastTitle = "Failure";
            this.toastMessage = JSON.stringify(error.body.message);
            this.toastVariant = "error";
            
            this.showToast(this.toastTitle, this.toastMessage, this.toastVariant);

        });
        
        this.selectedData = [];
        
    }
    }
    
    navigateToCheckListVF() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
                attributes: {
                    url: '/apex/Core_OppApproveChecklist?id=' + this.recordId
                }
            
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
             duration:' 5000',
        });
        this.dispatchEvent(event);
    }

     renderedCallback(){
        let firstIcon  = this.template.querySelector(`[data-id='error']`);
        const firstStyleCss = document.createElement('style');
        firstStyleCss.innerText = ` .tabsetCss #${firstIcon} .slds-icon-utility-error svg {
                                fill:red !important;
                                }
                            `;
        if (this.template.querySelector('lightning-tabset') != null) {
            this.template.querySelector('lightning-tabset').appendChild(firstStyleCss);
        }


        let secondIcon  = this.template.querySelector(`[data-id='warning']`);
        const secondStyleCss = document.createElement('style');
        secondStyleCss.innerText = ` .tabsetCss #${secondIcon} .slds-icon-utility-warning svg {
                                fill:orange !important;
                                }
                            `;
        if (this.template.querySelector('lightning-tabset') != null) {
            this.template.querySelector('lightning-tabset').appendChild(secondStyleCss);
        }
    }

}
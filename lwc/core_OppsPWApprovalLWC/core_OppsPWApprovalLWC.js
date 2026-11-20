import { LightningElement,wire,track,api } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import checklistForApproval from '@salesforce/apex/Core_OppsPWApprovalCtrl.checklistForApproval';
import submitApproval from '@salesforce/apex/Core_OppsPWApprovalCtrl.submitApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class core_OppsPWApprovalLWC extends NavigationMixin(LightningElement) {
    
    @track loaded = false;
    @track msg;
    //@track hardStopList = new Array(3);
    @track hardStopList = [];
    //@track softStopList = new Array(3);
    @track softStopList = [];
    @track submitDisabled=true;
    @track comments;
    @api recordId;
    @track showErrorButton;
    @track showWarningButton;
    @track warningSize;
    @track errorSize;
    @track totalSoftStop;
    @track totalHardStop;
    @track showCheckList;
    @track showErrors;
    @track showWarnings;
    @track warningButtonDisabled;
    @track errorButtonDisabled;
    @track showHideTab = true;
    @track toastTitle;
    @track toastMessage;
    @track toastVariant;
    @track isPWApproval = false; // Added for TWC3123-3676- To track Apporval action
    
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

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback() {
        this.loaded = true;
        
        checklistForApproval({ oppId: this.recordId, comments: this.comments, isPWApproval:true})
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
        submitApproval({ oppId: this.recordId, comments: this.comments})
        .then(result =>{
            this.loaded = false;
            eval("$A.get('e.force:refreshView').fire();");
					/*	setTimeout(function() {
                location.reload();
              }, 1000);*/
            this.dispatchEvent(new CloseActionScreenEvent());
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